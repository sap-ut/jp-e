-- ==========================================================
-- SP-7 GLASS ERP - GLASS INVENTORY MODULE (COMPLETE)
-- Author: SP-7 Technologies
-- File: 04_SP7_GlassInventory_Complete.sql
-- Description: Complete Glass Stock Management
-- ==========================================================

USE sp7_erp;

-- ==========================================================
-- 1. JUMBO SHEET INVENTORY
-- ==========================================================

CREATE TABLE tbl_glass_inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    sheet_code VARCHAR(50) UNIQUE NOT NULL,
    item_id INT NOT NULL,
    glass_type_id INT,
    thickness INT NOT NULL,
    height INT NOT NULL,
    width INT NOT NULL,
    area_sqft DECIMAL(10,2),
    area_sqm DECIMAL(10,2),
    
    -- Location
    godown_id INT,
    rack_no VARCHAR(20),
    row_no VARCHAR(20),
    bin_no VARCHAR(20),
    
    -- Status
    quantity INT DEFAULT 1,
    available_qty INT DEFAULT 1,
    booked_qty INT DEFAULT 0,
    damaged_qty INT DEFAULT 0,
    
    -- Tracking
    batch_no VARCHAR(50),
    supplier_id INT,
    purchase_date INT,
    purchase_rate BIGINT,
    mrp BIGINT,
    
    -- Quality
    grade TINYINT COMMENT '1=A Grade, 2=B Grade, 3=Commercial',
    is_cut TINYINT DEFAULT 0,
    parent_sheet_id INT,
    
    -- Status
    status TINYINT DEFAULT 1 COMMENT '1=Available, 2=Booked, 3=Used, 4=Damaged, 5=Quarantine',
    
    created_at INT,
    updated_at INT,
    
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id),
    FOREIGN KEY (glass_type_id) REFERENCES tbl_glass_type_master(glass_type_id)
);

-- ==========================================================
-- 2. GODOWN MASTER
-- ==========================================================

CREATE TABLE tbl_godown_master (
    godown_id INT PRIMARY KEY AUTO_INCREMENT,
    godown_code VARCHAR(50) UNIQUE,
    godown_name VARCHAR(100),
    location VARCHAR(255),
    capacity_sqft DECIMAL(10,2),
    incharge_name VARCHAR(100),
    incharge_phone VARCHAR(20),
    is_active TINYINT DEFAULT 1
);

INSERT INTO tbl_godown_master VALUES
(1, 'GDN-01', 'Main Godown - Pune', 'MIDC Bhosari', 50000, 'Ramesh Patil', '9876512345', 1),
(2, 'GDN-02', 'Factory Godown', 'Chakan', 75000, 'Suresh Shinde', '9876512346', 1);

-- ==========================================================
-- 3. STOCK TRANSACTION
-- ==========================================================

CREATE TABLE tbl_stock_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_no VARCHAR(50) UNIQUE,
    transaction_type TINYINT COMMENT '1=Purchase, 2=Issue, 3=Transfer, 4=Return, 5=Damage, 6=Adjustment',
    
    inventory_id INT,
    item_id INT,
    quantity INT,
    
    from_godown INT,
    to_godown INT,
    
    reference_type TINYINT COMMENT '1=PI, 2=WO, 3=PO, 4=GRN',
    reference_id INT,
    reference_no VARCHAR(50),
    
    rate BIGINT,
    total_value BIGINT,
    
    remarks TEXT,
    created_by INT,
    created_at INT,
    
    FOREIGN KEY (inventory_id) REFERENCES tbl_glass_inventory(inventory_id),
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id)
);

-- ==========================================================
-- 4. PURCHASE ORDER
-- ==========================================================

CREATE TABLE tbl_purchase_order_master (
    po_id INT PRIMARY KEY AUTO_INCREMENT,
    po_number VARCHAR(50) UNIQUE,
    po_date INT,
    supplier_id INT,
    expected_delivery INT,
    total_amount BIGINT,
    status TINYINT COMMENT '1=Draft, 2=Sent, 3=Confirmed, 4=Received, 5=Cancelled',
    created_by INT,
    created_at INT
);

CREATE TABLE tbl_purchase_order_details (
    po_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    po_id INT,
    item_id INT,
    thickness INT,
    height INT,
    width INT,
    quantity INT,
    rate BIGINT,
    total_amount BIGINT,
    received_qty INT DEFAULT 0,
    FOREIGN KEY (po_id) REFERENCES tbl_purchase_order_master(po_id)
);

-- ==========================================================
-- 5. GOODS RECEIPT NOTE
-- ==========================================================

CREATE TABLE tbl_grn_master (
    grn_id INT PRIMARY KEY AUTO_INCREMENT,
    grn_number VARCHAR(50) UNIQUE,
    grn_date INT,
    po_id INT,
    supplier_id INT,
    invoice_no VARCHAR(50),
    invoice_date INT,
    vehicle_no VARCHAR(20),
    received_by INT,
    status TINYINT DEFAULT 1,
    created_at INT
);

CREATE TABLE tbl_grn_details (
    grn_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    grn_id INT,
    po_detail_id INT,
    item_id INT,
    thickness INT,
    height INT,
    width INT,
    received_qty INT,
    accepted_qty INT,
    rejected_qty INT,
    reject_reason TEXT,
    FOREIGN KEY (grn_id) REFERENCES tbl_grn_master(grn_id)
);

-- ==========================================================
-- 6. STOCK VIEW
-- ==========================================================

CREATE VIEW view_stock_summary AS
SELECT 
    i.item_code,
    i.item_name,
    g.thickness,
    g.grade,
    COUNT(*) AS total_sheets,
    SUM(g.available_qty) AS available_sheets,
    SUM(g.area_sqft) AS total_area_sqft,
    SUM(g.available_qty * g.area_sqft) AS available_area_sqft,
    g.godown_id,
    g.rack_no
FROM tbl_glass_inventory g
JOIN tbl_item_master i ON g.item_id = i.item_id
WHERE g.status = 1
GROUP BY i.item_id, g.thickness, g.grade, g.godown_id;

-- ==========================================================
-- FINAL
-- ==========================================================

SELECT '✅ SP-7 GLASS INVENTORY MODULE READY' AS STATUS;