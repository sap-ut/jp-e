-- ==========================================================
-- SP-7 GLASS ERP - COMPLETE DATABASE
-- Author: SP-7 Technologies
-- File: SP7_ERP_Complete.sql
-- Description: Complete ERP System for Glass Industry
-- ==========================================================

DROP DATABASE IF EXISTS sp7_erp;
CREATE DATABASE sp7_erp;
USE sp7_erp;

-- ==========================================================
-- 1. MASTER TABLES
-- ==========================================================

-- 1.1 UOM Master
CREATE TABLE tbl_uom_master (
    uom_id INT PRIMARY KEY AUTO_INCREMENT,
    uom_code VARCHAR(10) UNIQUE,
    uom_name VARCHAR(50),
    is_active TINYINT DEFAULT 1
);

INSERT INTO tbl_uom_master (uom_code, uom_name) VALUES
('SQFT', 'Sq. Feet'),
('SQMT', 'Sq. Meter'),
('NOS', 'Numbers'),
('RFT', 'Running Feet');

-- 1.2 Glass Type Master
CREATE TABLE tbl_glass_type_master (
    glass_type_id INT PRIMARY KEY AUTO_INCREMENT,
    glass_code VARCHAR(20) UNIQUE,
    glass_name VARCHAR(100),
    description TEXT,
    is_active TINYINT DEFAULT 1
);

INSERT INTO tbl_glass_type_master (glass_code, glass_name) VALUES
('CLR', 'Clear Glass'),
('TNT', 'Tinted Glass'),
('RF', 'Reflective Glass'),
('FRST', 'Frosted Glass'),
('LAMI', 'Laminated Glass'),
('DGU', 'Double Glazing Unit'),
('TEMP', 'Tempered Glass'),
('BENT', 'Bent Glass'),
('PRINT', 'Printed Glass'),
('ACD', 'Acid Etched Glass');

-- 1.3 Payment Terms Master
CREATE TABLE tbl_payment_terms (
    term_id INT PRIMARY KEY AUTO_INCREMENT,
    term_name VARCHAR(100),
    days INT,
    is_active TINYINT DEFAULT 1
);

INSERT INTO tbl_payment_terms (term_name, days) VALUES
('Immediate', 0),
('7 Days', 7),
('15 Days', 15),
('30 Days', 30),
('45 Days', 45),
('60 Days', 60),
('Advance Full', 0),
('50% Advance', 0),
('COD', 0);

-- 1.4 Customer Master (Bill To + Ship To)
CREATE TABLE tbl_customer_master (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(50) UNIQUE,
    customer_name VARCHAR(200),
    customer_type TINYINT COMMENT '1=Dealer, 2=Retail, 3=Distributor, 4=Export',
    
    -- Bill To Address
    bill_address VARCHAR(255),
    bill_address2 VARCHAR(255),
    bill_city VARCHAR(100),
    bill_state VARCHAR(100),
    bill_pincode VARCHAR(10),
    bill_gst VARCHAR(20),
    bill_pan VARCHAR(20),
    bill_phone VARCHAR(20),
    bill_email VARCHAR(100),
    bill_contact_person VARCHAR(100),
    
    -- Default Ship To
    ship_address VARCHAR(255),
    ship_address2 VARCHAR(255),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_pincode VARCHAR(10),
    ship_contact_person VARCHAR(100),
    ship_phone VARCHAR(20),
    ship_email VARCHAR(100),
    
    is_multi_ship TINYINT DEFAULT 0,
    credit_limit BIGINT DEFAULT 0,
    credit_days INT DEFAULT 30,
    payment_term_id INT,
    salesperson_id INT DEFAULT 1,
    is_active TINYINT DEFAULT 1,
    created_at INT,
    updated_at INT,
    FOREIGN KEY (payment_term_id) REFERENCES tbl_payment_terms(term_id)
);

-- 1.5 Multiple Ship To Addresses
CREATE TABLE tbl_customer_ship_addresses (
    ship_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    ship_code VARCHAR(50),
    ship_name VARCHAR(200),
    attention VARCHAR(100),
    address VARCHAR(255),
    address2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    is_default TINYINT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at INT,
    FOREIGN KEY (customer_id) REFERENCES tbl_customer_master(customer_id)
);

-- 1.6 Item Master
CREATE TABLE tbl_item_master (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_code VARCHAR(50) UNIQUE,
    item_name VARCHAR(200),
    item_category VARCHAR(50),
    glass_type_id INT,
    thickness INT COMMENT 'MM mein',
    min_thickness INT,
    max_thickness INT,
    hsn_code VARCHAR(20),
    uom_id INT DEFAULT 1,
    is_active TINYINT DEFAULT 1,
    created_at INT,
    FOREIGN KEY (glass_type_id) REFERENCES tbl_glass_type_master(glass_type_id),
    FOREIGN KEY (uom_id) REFERENCES tbl_uom_master(uom_id)
);

INSERT INTO tbl_item_master (item_code, item_name, glass_type_id, thickness, hsn_code, uom_id) VALUES
('CLR-04', 'Clear Glass 4mm', 1, 4, '700510', 1),
('CLR-05', 'Clear Glass 5mm', 1, 5, '700510', 1),
('CLR-06', 'Clear Glass 6mm', 1, 6, '700510', 1),
('CLR-08', 'Clear Glass 8mm', 1, 8, '700510', 1),
('CLR-10', 'Clear Glass 10mm', 1, 10, '700510', 1),
('CLR-12', 'Clear Glass 12mm', 1, 12, '700510', 1),
('TNT-05', 'Tinted Glass 5mm', 2, 5, '700521', 1),
('TNT-06', 'Tinted Glass 6mm', 2, 6, '700521', 1),
('RF-06', 'Reflective Glass 6mm', 3, 6, '700529', 1),
('LAMI-08', 'Laminated Glass 8mm', 5, 8, '700729', 1);

-- 1.7 Fast Process Master (Fabrication)
CREATE TABLE tbl_fast_process_master (
    process_id INT PRIMARY KEY AUTO_INCREMENT,
    process_code VARCHAR(20) UNIQUE,
    process_name VARCHAR(100),
    process_category VARCHAR(50) COMMENT 'HOLE, CUTOUT, SHAPE, EDGE',
    uom_id INT DEFAULT 3 COMMENT '3=Nos',
    is_active TINYINT DEFAULT 1,
    sort_order INT,
    created_at INT
);

INSERT INTO tbl_fast_process_master (process_code, process_name, process_category, uom_id, sort_order) VALUES
('H', 'Holes', 'HOLE', 3, 1),
('C', 'Cutout', 'CUTOUT', 3, 2),
('SP', 'Shape Cut', 'SHAPE', 3, 3),
('BH', 'Big Hole', 'HOLE', 3, 4),
('CSK', 'Counter Sunk Holes', 'HOLE', 3, 5),
('L-SP', 'L Shape', 'SHAPE', 3, 6),
('BX-CUT', 'Box Cut', 'CUTOUT', 3, 7),
('C-CUT', 'Counter Cut', 'CUTOUT', 3, 8),
('WC', 'Wheel Cut', 'CUTOUT', 3, 9),
('EP', 'Edge Polish', 'EDGE', 4, 10);

-- 1.8 Fast Process Rates (Thickness Wise)
CREATE TABLE tbl_fast_process_rates (
    rate_id INT PRIMARY KEY AUTO_INCREMENT,
    process_id INT NOT NULL,
    thickness INT COMMENT 'MM',
    rate_per_nos BIGINT COMMENT 'Paise mein',
    rate_per_running_ft BIGINT,
    min_rate BIGINT COMMENT 'Minimum charges',
    min_diameter INT,
    max_diameter INT,
    is_active TINYINT DEFAULT 1,
    effective_from INT,
    effective_to INT,
    created_at INT,
    FOREIGN KEY (process_id) REFERENCES tbl_fast_process_master(process_id)
);

INSERT INTO tbl_fast_process_rates (process_id, thickness, rate_per_nos, min_rate, min_diameter, max_diameter) VALUES
-- Holes (H)
(1, 4, 30, 3000, 5, 50),
(1, 5, 30, 3000, 5, 50),
(1, 6, 30, 3000, 5, 50),
(1, 8, 30, 3000, 5, 50),
(1, 10, 30, 3000, 5, 50),
(1, 12, 30, 3000, 5, 50),
-- Cutout (C)
(2, 4, 100, 5000, 20, 200),
(2, 5, 100, 5000, 20, 200),
(2, 6, 100, 5000, 20, 200),
-- Shape Cut (SP)
(3, 6, 300, 10000, 50, 500),
-- Big Hole (BH)
(4, 8, 250, 10000, 51, 200),
-- Box Cut (BX-CUT)
(7, 15, 350, 15000, 50, 300);

-- 1.9 Additional Charges Master (40+ Charges)
CREATE TABLE tbl_charges_master (
    charge_id INT PRIMARY KEY AUTO_INCREMENT,
    charge_code VARCHAR(30) UNIQUE,
    charge_name VARCHAR(200),
    charge_category VARCHAR(50),
    calc_type TINYINT COMMENT '1=Fixed, 2=%, 3=Per SqFt, 4=Per Piece, 5=Per Kg, 6=Per RFT',
    calc_value BIGINT COMMENT 'Paise ya percentage',
    gst_applicable TINYINT DEFAULT 1,
    gst_rate INT DEFAULT 18,
    hsn_code VARCHAR(20),
    is_mandatory TINYINT DEFAULT 0,
    is_editable TINYINT DEFAULT 1,
    is_active TINYINT DEFAULT 1,
    display_order INT,
    created_at INT
);

INSERT INTO tbl_charges_master (charge_code, charge_name, charge_category, calc_type, calc_value, gst_rate, display_order) VALUES
-- Freight & Transport
('FRGHT', 'Freight Charges', 'FREIGHT', 3, 5000, 5, 1),
('FRGHT2', 'Freight 2', 'FREIGHT', 3, 4500, 5, 2),
('TRNSIT', 'Transit Handling Charges', 'FREIGHT', 2, 200, 18, 3),
('INSUR', 'Insurance Charges', 'INSURANCE', 2, 100, 18, 4),
('INSHR', 'Insurance & Handling Chrg', 'INSURANCE', 2, 150, 18, 5),
('SELFPK', 'Self Pick', 'FREIGHT', 1, 0, 0, 6),
('TOPAY', 'To Pay', 'FREIGHT', 1, 0, 0, 7),

-- Packing
('PACK', 'Packing Charges', 'PACKING', 3, 7500, 5, 8),
('WRAP', 'Wrapping Charges', 'PACKING', 3, 3500, 5, 9),
('JUMBO', 'Jumbo Charges', 'PACKING', 3, 10000, 5, 10),
('FOR', 'FOR', 'PACKING', 1, 0, 0, 11),
('ASACT', 'As Per Actual', 'PACKING', 1, 0, 18, 12),

-- Wastage
('WSTSP', 'Wastage Chrgs (Sentry Plus)', 'WASTAGE', 2, 500, 18, 13),
('WSTSHT', 'Wastage Chrgs (Sheets)', 'WASTAGE', 4, 25000, 18, 14),

-- Processing
('DOC', 'Documentation Charges', 'PROCESS', 1, 5000, 18, 15),
('EXTRA', 'Extra Charges', 'PROCESS', 1, 0, 18, 16),
('CHMPR', 'Champhring Charge', 'PROCESS', 6, 1500, 18, 17),
('CHEMP', 'Chemphring Charge', 'PROCESS', 6, 1500, 18, 18),
('BEVEL', 'Bevelling Charges', 'PROCESS', 3, 12000, 18, 19),
('FROST', 'Frosted Charges', 'PROCESS', 3, 8000, 18, 20),
('FROST2', 'Frost Charges', 'PROCESS', 3, 8000, 18, 21),
('SHAPE', 'Shape Charges', 'PROCESS', 1, 30000, 18, 22),
('SHAPEP', 'Shape Charges (%)', 'PROCESS', 2, 1000, 18, 23),
('LAMI', 'Lami Charges', 'PROCESS', 3, 15000, 18, 24),

-- DGU
('DGU', 'DGU Charges', 'PROCESS', 3, 25000, 18, 25),
('DGU2', 'Double Glazing Charges', 'PROCESS', 3, 25000, 18, 26),

-- Delivery
('EXPDLV', 'Exp Delv Charges', 'DELIVERY', 2, 500, 18, 27),
('EXPDLV2', 'Exp Delv Charges(%)', 'DELIVERY', 2, 800, 18, 28),
('ENRGY', 'Energy Surcharge', 'SURCHARGE', 2, 200, 18, 29),

-- Labour
('HWCHARGE', 'Hardware Charge', 'LABOUR', 1, 0, 18, 30),
('FIXLAB', 'Fixing & Labour Charge', 'LABOUR', 3, 5000, 18, 31),
('INSTALL', 'Installation Charges', 'LABOUR', 3, 7500, 18, 32),

-- Other
('ADDCHRG', 'Additional Charges', 'OTHER', 1, 0, 18, 33),
('ADDCHRG2', 'Additional ChargeS', 'OTHER', 1, 0, 18, 34),
('OTHER', 'Other Charges', 'OTHER', 1, 0, 18, 35);

-- 1.10 Salesperson Master
CREATE TABLE tbl_salesperson_master (
    salesperson_id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson_code VARCHAR(50) UNIQUE,
    salesperson_name VARCHAR(200),
    mobile VARCHAR(20),
    email VARCHAR(100),
    commission_percent INT DEFAULT 0,
    target_amount BIGINT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at INT
);

INSERT INTO tbl_salesperson_master (salesperson_code, salesperson_name, mobile, email) VALUES
('SP001', 'Rajesh Kumar', '9876543210', 'rajesh@sp7.com'),
('SP002', 'Priya Sharma', '9876543211', 'priya@sp7.com'),
('SP003', 'Amit Patel', '9876543212', 'amit@sp7.com');

-- 1.11 Bank Master
CREATE TABLE tbl_bank_master (
    bank_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(200),
    account_no VARCHAR(50),
    account_holder VARCHAR(200),
    ifsc_code VARCHAR(20),
    branch VARCHAR(100),
    is_active TINYINT DEFAULT 1
);

INSERT INTO tbl_bank_master (bank_name, account_no, account_holder, ifsc_code, branch) VALUES
('State Bank of India', '12345678901', 'SP-7 Technologies', 'SBIN0001234', 'Pune Main'),
('HDFC Bank', '12345678901234', 'SP-7 Technologies', 'HDFC0001234', 'MG Road Pune');

-- 1.12 Vehicle Master
CREATE TABLE tbl_vehicle_master (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_no VARCHAR(20) UNIQUE,
    vehicle_type VARCHAR(50),
    owner_name VARCHAR(200),
    driver_name VARCHAR(200),
    driver_phone VARCHAR(20),
    is_active TINYINT DEFAULT 1
);

-- 1.13 Size Group Master (Jumbo/Cut Size)
CREATE TABLE tbl_size_group_master (
    size_group_id INT PRIMARY KEY AUTO_INCREMENT,
    size_group_name VARCHAR(100),
    min_height INT,
    max_height INT,
    min_width INT,
    max_width INT,
    sort_order INT
);

INSERT INTO tbl_size_group_master (size_group_name, min_height, max_height, min_width, max_width, sort_order) VALUES
('Jumbo', 2000, 2500, 3000, 4000, 1),
('Semi Jumbo', 1500, 1999, 2000, 2999, 2),
('Cut Size', 500, 1499, 500, 1999, 3),
('Narrow', 100, 499, 100, 499, 4),
('Mini', 1, 99, 1, 99, 5);

-- ==========================================================
-- 2. TRANSACTION TABLES
-- ==========================================================

-- 2.1 Proforma Invoice Master
CREATE TABLE tbl_pi_master (
    pi_id INT PRIMARY KEY AUTO_INCREMENT,
    pi_number VARCHAR(50) UNIQUE NOT NULL,
    pi_date INT NOT NULL,
    customer_id INT NOT NULL,
    ship_address_id INT,
    customer_po_no VARCHAR(100),
    po_date INT,
    payment_term_id INT,
    valid_upto INT,
    delivery_terms TEXT,
    salesperson_id INT,
    remarks TEXT,
    
    -- Financial Summary
    subtotal BIGINT DEFAULT 0,
    discount_total BIGINT DEFAULT 0,
    taxable_amount BIGINT DEFAULT 0,
    cgst_total BIGINT DEFAULT 0,
    sgst_total BIGINT DEFAULT 0,
    igst_total BIGINT DEFAULT 0,
    round_off BIGINT DEFAULT 0,
    grand_total BIGINT DEFAULT 0,
    amount_in_words VARCHAR(500),
    
    -- Snapshot
    ship_to_address TEXT,
    ship_to_contact VARCHAR(100),
    ship_to_phone VARCHAR(20),
    
    -- Status
    status TINYINT DEFAULT 1 COMMENT '1=Draft, 2=Confirmed, 3=Converted to WO, 4=Cancelled',
    created_by INT,
    created_at INT,
    updated_at INT,
    
    FOREIGN KEY (customer_id) REFERENCES tbl_customer_master(customer_id),
    FOREIGN KEY (ship_address_id) REFERENCES tbl_customer_ship_addresses(ship_id),
    FOREIGN KEY (payment_term_id) REFERENCES tbl_payment_terms(term_id),
    FOREIGN KEY (salesperson_id) REFERENCES tbl_salesperson_master(salesperson_id)
);

-- 2.2 PI Details (Line Items)
CREATE TABLE tbl_pi_details (
    pi_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    pi_id INT NOT NULL,
    item_id INT,
    item_code VARCHAR(50),
    description TEXT,
    glass_type_id INT,
    thickness INT,
    
    -- Dimensions
    height_actual INT,
    width_actual INT,
    height_chargeable INT,
    width_chargeable INT,
    dimension_uom_id INT DEFAULT 1 COMMENT '1=MM, 2=Inches',
    
    quantity INT,
    unit_id INT,
    
    -- Fabrication (JSON)
    fabrication_details JSON,
    
    -- Pricing
    rate BIGINT COMMENT 'Paise',
    discount_percent INT,
    discount_amount BIGINT,
    tax_rate INT,
    tax_amount BIGINT,
    total_amount BIGINT,
    
    remarks TEXT,
    
    FOREIGN KEY (pi_id) REFERENCES tbl_pi_master(pi_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id),
    FOREIGN KEY (glass_type_id) REFERENCES tbl_glass_type_master(glass_type_id),
    FOREIGN KEY (unit_id) REFERENCES tbl_uom_master(uom_id)
);

-- 2.3 PI Terms & Conditions
CREATE TABLE tbl_pi_terms (
    term_id INT PRIMARY KEY AUTO_INCREMENT,
    pi_id INT NOT NULL,
    term_description TEXT,
    sort_order INT,
    FOREIGN KEY (pi_id) REFERENCES tbl_pi_master(pi_id) ON DELETE CASCADE
);

-- 2.4 Transaction Charges (PI/Invoice)
CREATE TABLE tbl_transaction_charges (
    trans_charge_id INT PRIMARY KEY AUTO_INCREMENT,
    trans_type TINYINT COMMENT '1=PI, 2=Invoice, 3=WO, 4=DC',
    trans_id INT NOT NULL,
    charge_id INT,
    charge_code VARCHAR(30),
    charge_name VARCHAR(200),
    calc_type TINYINT,
    calc_value BIGINT,
    base_amount BIGINT,
    charge_amount BIGINT,
    gst_rate INT,
    gst_amount BIGINT,
    total_amount BIGINT,
    is_manual TINYINT DEFAULT 0,
    remarks VARCHAR(255),
    created_at INT,
    FOREIGN KEY (charge_id) REFERENCES tbl_charges_master(charge_id)
);

-- 2.5 Work Order Master
CREATE TABLE tbl_work_order_master (
    wo_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_number VARCHAR(50) UNIQUE NOT NULL,
    pi_id INT NOT NULL,
    wo_date INT,
    customer_id INT,
    ship_address_id INT,
    delivery_date INT,
    priority TINYINT DEFAULT 2 COMMENT '1=High, 2=Normal, 3=Low',
    production_status TINYINT DEFAULT 1 COMMENT '1=Pending, 2=Cutting, 3=Processing, 4=Completed, 5=Delivered',
    billing_status TINYINT DEFAULT 0 COMMENT '0=Pending, 1=Partial, 2=Fully Billed',
    ship_to_address TEXT,
    ship_to_contact VARCHAR(100),
    ship_to_phone VARCHAR(20),
    delivery_instructions TEXT,
    remarks TEXT,
    created_by INT,
    created_at INT,
    updated_at INT,
    FOREIGN KEY (pi_id) REFERENCES tbl_pi_master(pi_id),
    FOREIGN KEY (customer_id) REFERENCES tbl_customer_master(customer_id),
    FOREIGN KEY (ship_address_id) REFERENCES tbl_customer_ship_addresses(ship_id)
);

-- 2.6 Work Order Details
CREATE TABLE tbl_work_order_details (
    wo_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_id INT NOT NULL,
    pi_detail_id INT,
    item_id INT,
    description TEXT,
    glass_type_id INT,
    thickness INT,
    height_actual INT,
    width_actual INT,
    height_chargeable INT,
    width_chargeable INT,
    dimension_uom_id INT,
    quantity INT,
    unit_id INT,
    
    -- Production Tracking
    cut_qty INT DEFAULT 0,
    processed_qty INT DEFAULT 0,
    rejected_qty INT DEFAULT 0,
    balance_qty INT DEFAULT 0,
    
    fabrication_details JSON,
    rate BIGINT,
    discount_amount BIGINT,
    tax_amount BIGINT,
    total_amount BIGINT,
    
    status TINYINT DEFAULT 1 COMMENT '1=Pending, 2=In Progress, 3=Completed, 4=Rejected',
    remarks TEXT,
    
    FOREIGN KEY (wo_id) REFERENCES tbl_work_order_master(wo_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id)
);

-- 2.7 Cutting Plan
CREATE TABLE tbl_wo_cutting_plan (
    cutting_plan_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_detail_id INT NOT NULL,
    sheet_no INT,
    jumbo_height INT,
    jumbo_width INT,
    cut_pos_x INT,
    cut_pos_y INT,
    cut_height INT,
    cut_width INT,
    quantity INT DEFAULT 1,
    cutting_status TINYINT DEFAULT 1 COMMENT '1=Pending, 2=Cut, 3=Reject',
    cut_by INT,
    cut_at INT,
    remarks TEXT,
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id) ON DELETE CASCADE
);

-- 2.8 Processing Stages
CREATE TABLE tbl_wo_processing_stages (
    processing_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_detail_id INT NOT NULL,
    stage_type TINYINT COMMENT '1=Edge Polish, 2=Hole, 3=Cutout, 4=Tempering, 5=Lami',
    stage_sequence INT,
    quantity INT,
    completed_qty INT DEFAULT 0,
    rejected_qty INT DEFAULT 0,
    start_date INT,
    end_date INT,
    operator_id INT,
    machine_id INT,
    status TINYINT DEFAULT 1 COMMENT '1=Pending, 2=Running, 3=Completed, 4=Hold',
    remarks TEXT,
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id) ON DELETE CASCADE
);

-- 2.9 Despatch / Delivery
CREATE TABLE tbl_wo_despatch (
    despatch_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_id INT NOT NULL,
    wo_detail_id INT,
    despatch_date INT,
    quantity INT,
    vehicle_id INT,
    vehicle_no VARCHAR(20),
    driver_name VARCHAR(100),
    driver_phone VARCHAR(20),
    lr_number VARCHAR(50),
    transport_name VARCHAR(100),
    delivery_status TINYINT DEFAULT 1 COMMENT '1=Dispatched, 2=Delivered, 3=Partial',
    delivered_date INT,
    remarks TEXT,
    created_at INT,
    FOREIGN KEY (wo_id) REFERENCES tbl_work_order_master(wo_id),
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id)
);

-- ==========================================================
-- 3. PRICE MASTER
-- ==========================================================

CREATE TABLE tbl_price_master_header (
    price_id INT PRIMARY KEY AUTO_INCREMENT,
    price_code VARCHAR(50) UNIQUE,
    price_name VARCHAR(200),
    effective_from INT,
    effective_to INT,
    customer_category_id INT,
    is_default TINYINT DEFAULT 0,
    status TINYINT DEFAULT 1 COMMENT '1=Draft, 2=Active, 3=Expired',
    created_by INT,
    created_at INT,
    updated_at INT
);

CREATE TABLE tbl_price_master_details (
    price_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    price_id INT NOT NULL,
    item_id INT,
    glass_type_id INT,
    thickness INT,
    min_height INT,
    max_height INT,
    min_width INT,
    max_width INT,
    size_group_id INT,
    quality_grade TINYINT DEFAULT 1,
    unit_id INT,
    rate BIGINT COMMENT 'Paise',
    min_rate BIGINT,
    cutting_charges BIGINT,
    wastage_percent INT,
    min_quantity INT,
    max_quantity INT,
    discount_percent INT,
    priority INT DEFAULT 99,
    remarks VARCHAR(255),
    is_active TINYINT DEFAULT 1,
    FOREIGN KEY (price_id) REFERENCES tbl_price_master_header(price_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id),
    FOREIGN KEY (size_group_id) REFERENCES tbl_size_group_master(size_group_id)
);

-- ==========================================================
-- 4. INDEXES FOR PERFORMANCE
-- ==========================================================

CREATE INDEX idx_pi_customer ON tbl_pi_master(customer_id);
CREATE INDEX idx_pi_date ON tbl_pi_master(pi_date);
CREATE INDEX idx_pi_status ON tbl_pi_master(status);
CREATE INDEX idx_wo_pi ON tbl_work_order_master(pi_id);
CREATE INDEX idx_wo_status ON tbl_work_order_master(production_status);
CREATE INDEX idx_wo_customer ON tbl_work_order_master(customer_id);
CREATE INDEX idx_wo_delivery ON tbl_work_order_master(delivery_date);
CREATE INDEX idx_customer_code ON tbl_customer_master(customer_code);
CREATE INDEX idx_item_code ON tbl_item_master(item_code);
CREATE INDEX idx_process_thickness ON tbl_fast_process_rates(process_id, thickness);

-- ==========================================================
-- 5. VIEWS FOR REPORTS
-- ==========================================================

-- PI Summary View
CREATE VIEW view_pi_summary AS
SELECT 
    p.pi_id,
    p.pi_number,
    p.pi_date,
    c.customer_name,
    c.bill_gst,
    s.ship_name,
    p.grand_total,
    p.status,
    CASE 
        WHEN p.status = 1 THEN 'Draft'
        WHEN p.status = 2 THEN 'Confirmed'
        WHEN p.status = 3 THEN 'Converted to WO'
        WHEN p.status = 4 THEN 'Cancelled'
    END AS status_name,
    p.created_at
FROM tbl_pi_master p
LEFT JOIN tbl_customer_master c ON p.customer_id = c.customer_id
LEFT JOIN tbl_customer_ship_addresses s ON p.ship_address_id = s.ship_id;

-- WO Production Status View
CREATE VIEW view_wo_production AS
SELECT 
    w.wo_id,
    w.wo_number,
    w.wo_date,
    w.delivery_date,
    c.customer_name,
    s.ship_name,
    w.production_status,
    CASE 
        WHEN w.production_status = 1 THEN 'Pending'
        WHEN w.production_status = 2 THEN 'Cutting'
        WHEN w.production_status = 3 THEN 'Processing'
        WHEN w.production_status = 4 THEN 'Completed'
        WHEN w.production_status = 5 THEN 'Delivered'
    END AS status_name,
    SUM(d.quantity) AS total_qty,
    SUM(d.cut_qty) AS total_cut,
    SUM(d.processed_qty) AS total_processed,
    SUM(d.rejected_qty) AS total_rejected,
    SUM(d.balance_qty) AS total_balance
FROM tbl_work_order_master w
LEFT JOIN tbl_customer_master c ON w.customer_id = c.customer_id
LEFT JOIN tbl_customer_ship_addresses s ON w.ship_address_id = s.ship_id
LEFT JOIN tbl_work_order_details d ON w.wo_id = d.wo_id
GROUP BY w.wo_id;

-- ==========================================================
-- 6. SAMPLE DATA FOR TESTING
-- ==========================================================

-- Sample Customer
INSERT INTO tbl_customer_master (
    customer_code, customer_name, customer_type,
    bill_address, bill_city, bill_state, bill_pincode, bill_gst, bill_phone,
    ship_address, ship_city, ship_state, ship_pincode, ship_contact_person, ship_phone,
    credit_limit, payment_term_id, created_at
) VALUES (
    'CUST001', 'ABC Glass Pvt Ltd', 1,
    'Plot 45, Industrial Area', 'Pune', 'Maharashtra', '411035', '27ABCDE1234F1Z5', '020-12345678',
    'Gat 789, Warehousing Zone', 'Pimpri', 'Maharashtra', '411018', 'Rajesh Kumar', '9876543210',
    5000000, 4, UNIX_TIMESTAMP()
);

-- Sample Ship To
INSERT INTO tbl_customer_ship_addresses (
    customer_id, ship_code, ship_name, address, city, state, pincode, contact_person, phone, is_default
) VALUES 
(1, 'SITE001', 'Factory Gate 1', 'Gat 789, Warehousing Zone', 'Pimpri', 'Maharashtra', '411018', 'Rajesh Kumar', '9876543210', 1),
(1, 'SITE002', 'Corporate Office', '5th Floor, ABC Building, MG Road', 'Pune', 'Maharashtra', '411001', 'Priya Sharma', '9876543211', 0),
(1, 'SITE003', 'Project Site - Rohan Elara', 'Tower A, Phase 3', 'Wakad', 'Maharashtra', '411057', 'Sanjay Patil', '9876543212', 0);

-- Sample PI
INSERT INTO tbl_pi_master (
    pi_number, pi_date, customer_id, ship_address_id, payment_term_id, salesperson_id,
    subtotal, discount_total, taxable_amount, cgst_total, sgst_total, grand_total, status, created_at
) VALUES (
    'PI/2025/00001', 20250213, 1, 1, 4, 1,
    9901200, 292300, 11620240, 891110, 891110, 11620220, 2, UNIX_TIMESTAMP()
);

-- Sample PI Details
INSERT INTO tbl_pi_details (
    pi_id, item_id, item_code, glass_type_id, thickness,
    height_actual, width_actual, height_chargeable, width_chargeable,
    quantity, unit_id, rate, discount_percent, discount_amount, tax_rate, tax_amount, total_amount
) VALUES (
    1, 3, 'CLR-08', 1, 8,
    2140, 3300, 2140, 3300,
    50, 1, 8500, 5, 21250, 18, 68850, 453900
);

-- ==========================================================
-- 7. STORED PROCEDURES
-- ==========================================================

-- Generate PI Number
DELIMITER $$
CREATE PROCEDURE sp_generate_pi_number(OUT pi_no VARCHAR(50))
BEGIN
    DECLARE year VARCHAR(4);
    DECLARE seq INT;
    
    SET year = DATE_FORMAT(NOW(), '%Y');
    
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(pi_number, '/', -1) AS UNSIGNED)), 0) + 1
    INTO seq
    FROM tbl_pi_master
    WHERE pi_number LIKE CONCAT('PI/', year, '/%');
    
    SET pi_no = CONCAT('PI/', year, '/', LPAD(seq, 5, '0'));
END$$
DELIMITER ;

-- Calculate Area in SqFt
DELIMITER $$
CREATE FUNCTION fn_calc_sqft(height_mm INT, width_mm INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (height_mm * width_mm) / 14400.0;
END$$
DELIMITER ;

-- ==========================================================
-- 8. TRIGGERS
-- ==========================================================

-- Update WO balance qty on despatch
DELIMITER $$
CREATE TRIGGER trg_update_wo_balance
AFTER INSERT ON tbl_wo_despatch
FOR EACH ROW
BEGIN
    UPDATE tbl_work_order_details 
    SET balance_qty = quantity - (
        SELECT COALESCE(SUM(quantity), 0) 
        FROM tbl_wo_despatch 
        WHERE wo_detail_id = NEW.wo_detail_id
    )
    WHERE wo_detail_id = NEW.wo_detail_id;
END$$
DELIMITER ;

-- ==========================================================
-- 9. USER MANAGEMENT (BASIC)
-- ==========================================================

CREATE TABLE tbl_users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255),
    full_name VARCHAR(200),
    email VARCHAR(100),
    mobile VARCHAR(20),
    user_role TINYINT COMMENT '1=Admin, 2=Manager, 3=Supervisor, 4=Operator, 5=Sales',
    is_active TINYINT DEFAULT 1,
    last_login INT,
    created_at INT
);

INSERT INTO tbl_users (username, password, full_name, user_role) VALUES
('admin', SHA2('admin123', 256), 'Administrator', 1),
('manager', SHA2('manager123', 256), 'Production Manager', 2),
('sales', SHA2('sales123', 256), 'Sales Manager', 5);

-- ==========================================================
-- 10. SYSTEM SETTINGS
-- ==========================================================

CREATE TABLE tbl_system_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE,
    setting_value TEXT,
    setting_group VARCHAR(50),
    description VARCHAR(255)
);

INSERT INTO tbl_system_settings (setting_key, setting_value, setting_group, description) VALUES
('company_name', 'SP-7 Glass ERP', 'GENERAL', 'Company Name'),
('company_address', 'Pune, Maharashtra', 'GENERAL', 'Company Address'),
('company_gst', '27ABCDE1234F1Z5', 'GENERAL', 'Company GST'),
('company_pan', 'ABCDE1234F', 'GENERAL', 'Company PAN'),
('cutting_gap_mm', '4', 'PRODUCTION', 'Cutting blade gap in MM'),
('edge_allowance_mm', '10', 'PRODUCTION', 'Edge allowance in MM'),
('min_cut_size_mm', '100', 'PRODUCTION', 'Minimum cut size in MM'),
('backup_path', 'C:\\SP7_ERP_Backup', 'SYSTEM', 'Database backup path'),
('invoice_prefix', 'INV', 'BILLING', 'Invoice number prefix'),
('pi_prefix', 'PI', 'BILLING', 'PI number prefix'),
('wo_prefix', 'WO', 'PRODUCTION', 'Work order prefix');

-- ==========================================================
-- FINAL: DATABASE READY
-- ==========================================================

SELECT '✅ SP-7 GLASS ERP DATABASE CREATED SUCCESSFULLY' AS STATUS;
SELECT CONCAT('📦 TABLES CREATED: ', COUNT(*)) AS INFO FROM information_schema.tables WHERE table_schema = 'sp7_erp';
