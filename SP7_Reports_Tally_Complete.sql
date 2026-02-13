-- ==========================================================
-- SP-7 GLASS ERP - REPORTS & TALLY MODULE
-- Author: SP-7 Technologies
-- File: 05_SP7_Reports_Tally_Complete.sql
-- ==========================================================

USE sp7_erp;

-- ==========================================================
-- 1. PI REPORT VIEW
-- ==========================================================

CREATE VIEW view_pi_report AS
SELECT 
    p.pi_number,
    FROM_UNIXTIME(p.pi_date) AS pi_date,
    c.customer_name,
    c.bill_gst,
    s.ship_name,
    p.customer_po_no,
    p.subtotal,
    p.discount_total,
    p.taxable_amount,
    p.cgst_total,
    p.sgst_total,
    p.grand_total,
    CASE 
        WHEN p.status = 1 THEN 'Draft'
        WHEN p.status = 2 THEN 'Confirmed'
        WHEN p.status = 3 THEN 'Converted'
        WHEN p.status = 4 THEN 'Cancelled'
    END AS status_name
FROM tbl_pi_master p
JOIN tbl_customer_master c ON p.customer_id = c.customer_id
LEFT JOIN tbl_customer_ship_addresses s ON p.ship_address_id = s.ship_id;

-- ==========================================================
-- 2. WORK ORDER REPORT
-- ==========================================================

CREATE VIEW view_wo_report AS
SELECT 
    w.wo_number,
    FROM_UNIXTIME(w.wo_date) AS wo_date,
    FROM_UNIXTIME(w.delivery_date) AS delivery_date,
    c.customer_name,
    s.ship_name,
    COUNT(d.wo_detail_id) AS total_items,
    SUM(d.quantity) AS total_qty,
    SUM(d.cut_qty) AS cut_qty,
    SUM(d.processed_qty) AS processed_qty,
    SUM(d.rejected_qty) AS rejected_qty,
    SUM(d.balance_qty) AS balance_qty,
    CASE 
        WHEN w.production_status = 1 THEN 'Pending'
        WHEN w.production_status = 2 THEN 'Cutting'
        WHEN w.production_status = 3 THEN 'Processing'
        WHEN w.production_status = 4 THEN 'Completed'
        WHEN w.production_status = 5 THEN 'Delivered'
    END AS status_name
FROM tbl_work_order_master w
JOIN tbl_customer_master c ON w.customer_id = c.customer_id
LEFT JOIN tbl_customer_ship_addresses s ON w.ship_address_id = s.ship_id
LEFT JOIN tbl_work_order_details d ON w.wo_id = d.wo_id
GROUP BY w.wo_id;

-- ==========================================================
-- 3. PRODUCTION REPORT
-- ==========================================================

CREATE VIEW view_production_report AS
SELECT 
    w.wo_number,
    i.item_name,
    d.thickness,
    d.height_chargeable AS height,
    d.width_chargeable AS width,
    d.quantity,
    d.cut_qty,
    d.processed_qty,
    d.rejected_qty,
    d.balance_qty,
    d.status,
    cp.sheet_no,
    cp.cut_pos_x,
    cp.cut_pos_y,
    cp.cutting_status
FROM tbl_work_order_details d
JOIN tbl_work_order_master w ON d.wo_id = w.wo_id
JOIN tbl_item_master i ON d.item_id = i.item_id
LEFT JOIN tbl_wo_cutting_plan cp ON d.wo_detail_id = cp.wo_detail_id;

-- ==========================================================
-- 4. REJECTION REPORT
-- ==========================================================

CREATE TABLE tbl_rejection_master (
    rejection_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_id INT,
    wo_detail_id INT,
    rejection_date INT,
    rejection_type VARCHAR(50),
    quantity INT,
    reason TEXT,
    remarks TEXT,
    created_at INT
);

CREATE VIEW view_rejection_report AS
SELECT 
    FROM_UNIXTIME(r.rejection_date) AS date,
    w.wo_number,
    i.item_name,
    d.thickness,
    d.height_chargeable AS height,
    d.width_chargeable AS width,
    r.rejection_type,
    r.quantity,
    r.reason,
    o.operator_name
FROM tbl_rejection_master r
JOIN tbl_work_order_details d ON r.wo_detail_id = d.wo_detail_id
JOIN tbl_work_order_master w ON d.wo_id = w.wo_id
JOIN tbl_item_master i ON d.item_id = i.item_id
LEFT JOIN tbl_operator_master o ON d.operator_id = o.operator_id;

-- ==========================================================
-- 5. SALESPERSON PERFORMANCE
-- ==========================================================

CREATE VIEW view_salesperson_performance AS
SELECT 
    sp.salesperson_name,
    COUNT(DISTINCT p.pi_id) AS total_pis,
    SUM(p.grand_total) AS total_sales,
    AVG(p.grand_total) AS avg_pi_value,
    COUNT(DISTINCT p.customer_id) AS total_customers,
    SUM(p.grand_total) * sp.commission_percent / 100 AS total_commission
FROM tbl_salesperson_master sp
LEFT JOIN tbl_pi_master p ON sp.salesperson_id = p.salesperson_id
WHERE p.pi_date >= UNIX_TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 30 DAY))
GROUP BY sp.salesperson_id;

-- ==========================================================
-- 6. PENDING BILLING REPORT
-- ==========================================================

CREATE VIEW view_pending_billing AS
SELECT 
    w.wo_number,
    c.customer_name,
    FROM_UNIXTIME(w.delivery_date) AS delivery_date,
    COUNT(d.wo_detail_id) AS total_items,
    SUM(d.quantity) AS total_qty,
    SUM(d.processed_qty) AS processed_qty,
    SUM(d.balance_qty) AS pending_qty,
    DATEDIFF(CURDATE(), FROM_UNIXTIME(w.delivery_date)) AS days_pending
FROM tbl_work_order_master w
JOIN tbl_customer_master c ON w.customer_id = c.customer_id
JOIN tbl_work_order_details d ON w.wo_id = d.wo_id
WHERE w.production_status != 5 AND w.billing_status != 2
GROUP BY w.wo_id
HAVING pending_qty > 0;

-- ==========================================================
-- 7. TALLY EXPORT - LEDGER XML
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_tally_export_ledger(IN p_from_date INT, IN p_to_date INT)
BEGIN
    SELECT 
        CONCAT('
        <ENVELOPE>
            <HEADER>
                <TALLYREQUEST>Export Data</TALLYREQUEST>
            </HEADER>
            <BODY>
                <EXPORTDATA>
                    <REQUESTDESC>
                        <REPORTNAME>Ledger</REPORTNAME>
                        <STATICVARIABLES>
                            <SVFROMDATE>', FROM_UNIXTIME(p_from_date, '%Y%m%d'), '</SVFROMDATE>
                            <SVTODATE>', FROM_UNIXTIME(p_to_date, '%Y%m%d'), '</SVTODATE>
                        </STATICVARIABLES>
                    </REQUESTDESC>
                </EXPORTDATA>
            </BODY>
        </ENVELOPE>
        ') AS tally_xml;
END$$
DELIMITER ;

-- ==========================================================
-- 8. TALLY EXPORT - SALES INVOICE
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_tally_export_sales(IN p_pi_id INT)
BEGIN
    SELECT 
        p.pi_number AS voucher_no,
        FROM_UNIXTIME(p.pi_date) AS date,
        c.customer_name AS party_name,
        c.bill_gst AS gstin,
        p.grand_total AS amount,
        CONCAT('
        <VOUCHER>
            <VOUCHERTYPENAME>Sales</VOUCHERTYPENAME>
            <VOUCHERNUMBER>', p.pi_number, '</VOUCHERNUMBER>
            <DATE>', FROM_UNIXTIME(p.pi_date, '%Y%m%d'), '</DATE>
            <PARTYLEDGERNAME>', c.customer_name, '</PARTYLEDGERNAME>
            <PARTYGSTIN>', c.bill_gst, '</PARTYGSTIN>
            <AMOUNT>', p.grand_total, '</AMOUNT>
        </VOUCHER>
        ') AS tally_xml
    FROM tbl_pi_master p
    JOIN tbl_customer_master c ON p.customer_id = c.customer_id
    WHERE p.pi_id = p_pi_id;
END$$
DELIMITER ;

-- ==========================================================
-- 9. MONTHLY SALES REPORT
-- ==========================================================

CREATE VIEW view_monthly_sales AS
SELECT 
    DATE_FORMAT(FROM_UNIXTIME(p.pi_date), '%Y-%m') AS month,
    COUNT(*) AS total_invoices,
    SUM(p.grand_total) AS total_sales,
    AVG(p.grand_total) AS avg_invoice_value,
    COUNT(DISTINCT p.customer_id) AS unique_customers,
    SUM(p.cgst_total + p.sgst_total + p.igst_total) AS total_tax
FROM tbl_pi_master p
WHERE p.status IN (2, 3)
GROUP BY DATE_FORMAT(FROM_UNIXTIME(p.pi_date), '%Y-%m')
ORDER BY month DESC;

-- ==========================================================
-- 10. DASHBOARD SUMMARY
-- ==========================================================

CREATE VIEW view_dashboard_summary AS
SELECT 
    (SELECT COUNT(*) FROM tbl_pi_master WHERE pi_date >= UNIX_TIMESTAMP(CURDATE())) AS today_pi,
    (SELECT COUNT(*) FROM tbl_pi_master WHERE pi_date >= UNIX_TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 7 DAY))) AS week_pi,
    (SELECT COUNT(*) FROM tbl_work_order_master WHERE production_status = 1) AS pending_wo,
    (SELECT COUNT(*) FROM tbl_work_order_master WHERE production_status = 2) AS cutting_wo,
    (SELECT COUNT(*) FROM tbl_work_order_master WHERE production_status = 3) AS processing_wo,
    (SELECT COUNT(*) FROM tbl_work_order_master WHERE production_status = 4) AS completed_wo,
    (SELECT SUM(quantity) FROM tbl_work_order_details WHERE balance_qty > 0) AS pending_qty,
    (SELECT SUM(grand_total) FROM tbl_pi_master WHERE pi_date >= UNIX_TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 30 DAY))) AS monthly_sales,
    (SELECT SUM(grand_total) FROM tbl_pi_master) AS total_sales;

-- ==========================================================
-- FINAL
-- ==========================================================

SELECT '✅ SP-7 REPORTS & TALLY MODULE READY' AS STATUS;
SELECT '📊 10+ REPORTS CREATED' AS INFO;