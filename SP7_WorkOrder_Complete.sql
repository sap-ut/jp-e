-- ==========================================================
-- SP-7 GLASS ERP - WORK ORDER MODULE (COMPLETE)
-- Author: SP-7 Technologies
-- File: SP7_WorkOrder_Complete.sql
-- Description: Complete Work Order with Production Tracking
-- ==========================================================

USE sp7_erp;

-- ==========================================================
-- 1. WORK ORDER MASTER (Enhanced)
-- ==========================================================

ALTER TABLE tbl_work_order_master 
ADD COLUMN wo_type TINYINT DEFAULT 1 COMMENT '1=Regular, 2=Urgent, 3=Sample, 4=Rework',
ADD COLUMN supervisor_id INT,
ADD COLUMN machine_id INT,
ADD COLUMN estimated_hours INT,
ADD COLUMN actual_hours INT,
ADD COLUMN quality_check TINYINT DEFAULT 0 COMMENT '0=Pending, 1=Passed, 2=Failed',
ADD COLUMN qc_by INT,
ADD COLUMN qc_date INT,
ADD COLUMN completed_date INT,
ADD COLUMN hold_reason TEXT,
ADD COLUMN cancel_reason TEXT;

-- ==========================================================
-- 2. WORK ORDER DETAILS (Enhanced)
-- ==========================================================

ALTER TABLE tbl_work_order_details
ADD COLUMN cutting_priority TINYINT DEFAULT 2 COMMENT '1=High, 2=Normal, 3=Low',
ADD COLUMN edge_polish TINYINT DEFAULT 0 COMMENT '0=No, 1=Yes',
ADD COLUMN edge_polish_type VARCHAR(50) COMMENT 'Flat, Pencil, Bevel',
ADD COLUMN tempering TINYINT DEFAULT 0,
ADD COLUMN tempering_temp INT,
ADD COLUMN lamination TINYINT DEFAULT 0,
ADD COLUMN lami_thickness INT,
ADD COLUMN printing TINYINT DEFAULT 0,
ADD COLUMN print_color VARCHAR(50),
ADD COLUMN batch_no VARCHAR(50),
ADD COLUMN serial_no_start INT,
ADD COLUMN serial_no_end INT,
ADD COLUMN qc_status TINYINT DEFAULT 0 COMMENT '0=Pending, 1=Pass, 2=Fail, 3=Rework',
ADD COLUMN qc_remarks TEXT,
ADD COLUMN rework_count INT DEFAULT 0,
ADD COLUMN start_time INT,
ADD COLUMN end_time INT;

-- ==========================================================
-- 3. PRODUCTION STAGES MASTER
-- ==========================================================

CREATE TABLE tbl_production_stages_master (
    stage_id INT PRIMARY KEY AUTO_INCREMENT,
    stage_code VARCHAR(20) UNIQUE,
    stage_name VARCHAR(100),
    stage_sequence INT,
    is_mandatory TINYINT DEFAULT 0,
    estimated_time_minutes INT,
    machine_type VARCHAR(50),
    skill_level TINYINT COMMENT '1=Basic, 2=Intermediate, 3=Expert',
    is_active TINYINT DEFAULT 1,
    created_at INT
);

INSERT INTO tbl_production_stages_master 
(stage_code, stage_name, stage_sequence, is_mandatory, estimated_time_minutes) VALUES
('CUT', 'Cutting', 1, 1, 30),
('EP', 'Edge Polishing', 2, 0, 45),
('DRILL', 'Drilling/Holes', 3, 0, 20),
('CUTOUT', 'Cutout', 4, 0, 25),
('TEMP', 'Tempering', 5, 0, 120),
('LAMI', 'Lamination', 6, 0, 90),
('PRINT', 'Printing', 7, 0, 60),
('QC', 'Quality Check', 8, 1, 15),
('PACK', 'Packing', 9, 1, 30);

-- ==========================================================
-- 4. ENHANCED CUTTING PLAN
-- ==========================================================

ALTER TABLE tbl_wo_cutting_plan
ADD COLUMN jumbo_id INT,
ADD COLUMN jumbo_code VARCHAR(50),
ADD COLUMN cut_sequence INT,
ADD COLUMN blade_thickness INT DEFAULT 4,
ADD COLUMN edge_allowance_top INT DEFAULT 10,
ADD COLUMN edge_allowance_bottom INT DEFAULT 10,
ADD COLUMN edge_allowance_left INT DEFAULT 10,
ADD COLUMN edge_allowance_right INT DEFAULT 10,
ADD COLUMN wastage_sqmm BIGINT,
ADD COLUMN wastage_percent DECIMAL(5,2),
ADD COLUMN machine_id INT,
ADD COLUMN operator_id INT,
ADD COLUMN cutting_time INT,
ADD COLUMN rework_reason TEXT,
ADD COLUMN parent_cut_id INT,
ADD COLUMN is_remnant TINYINT DEFAULT 0 COMMENT '0=New Sheet, 1=Remnant Piece',
ADD COLUMN remnant_id INT,
ADD COLUMN barcode VARCHAR(100),
ADD COLUMN qr_code TEXT;

-- ==========================================================
-- 5. MACHINE MASTER
-- ==========================================================

CREATE TABLE tbl_machine_master (
    machine_id INT PRIMARY KEY AUTO_INCREMENT,
    machine_code VARCHAR(50) UNIQUE,
    machine_name VARCHAR(100),
    machine_type VARCHAR(50) COMMENT 'Cutting, Polishing, Tempering, Lami',
    model_no VARCHAR(50),
    manufacturer VARCHAR(100),
    installation_date INT,
    max_sheet_height INT,
    max_sheet_width INT,
    max_thickness INT,
    min_thickness INT,
    cutting_speed INT,
    power_rating INT,
    is_active TINYINT DEFAULT 1,
    last_maintenance INT,
    next_maintenance INT,
    operator_id INT,
    status TINYINT DEFAULT 1 COMMENT '1=Idle, 2=Running, 3=Maintenance, 4=Breakdown',
    created_at INT
);

INSERT INTO tbl_machine_master 
(machine_code, machine_name, machine_type, max_sheet_height, max_sheet_width, max_thickness) VALUES
('CUT-01', 'Automatic Glass Cutter 1', 'Cutting', 3300, 6000, 19),
('CUT-02', 'Automatic Glass Cutter 2', 'Cutting', 3300, 6000, 19),
('EP-01', 'Edge Polisher 1', 'Polishing', 3300, 6000, 25),
('EP-02', 'Edge Polisher 2', 'Polishing', 3300, 6000, 25),
('TEMP-01', 'Tempering Furnace 1', 'Tempering', 2400, 3600, 12),
('DRILL-01', 'CNC Drilling Machine', 'Drilling', 2000, 3000, 19);

-- ==========================================================
-- 6. OPERATOR MASTER
-- ==========================================================

CREATE TABLE tbl_operator_master (
    operator_id INT PRIMARY KEY AUTO_INCREMENT,
    operator_code VARCHAR(50) UNIQUE,
    operator_name VARCHAR(100),
    mobile VARCHAR(20),
    email VARCHAR(100),
    designation VARCHAR(50),
    skill_level TINYINT COMMENT '1=Trainee, 2=Junior, 3=Senior, 4=Expert',
    machine_id INT,
    shift TINYINT COMMENT '1=Day, 2=Night, 3=General',
    hourly_rate BIGINT,
    is_active TINYINT DEFAULT 1,
    joining_date INT,
    created_at INT
);

INSERT INTO tbl_operator_master 
(operator_code, operator_name, mobile, designation, skill_level, shift) VALUES
('OP-001', 'Ramesh Shinde', '9876512340', 'Senior Cutter', 4, 1),
('OP-002', 'Suresh Patil', '9876512341', 'Cutter', 3, 1),
('OP-003', 'Mahesh Joshi', '9876512342', 'Polishing Expert', 4, 2),
('OP-004', 'Dinesh Kulkarni', '9876512343', 'CNC Operator', 3, 2),
('OP-005', 'Ganesh Pawar', '9876512344', 'Tempering Operator', 3, 1);

-- ==========================================================
-- 7. JUMBO GLASS INVENTORY
-- ==========================================================

CREATE TABLE tbl_jumbo_inventory (
    jumbo_id INT PRIMARY KEY AUTO_INCREMENT,
    jumbo_code VARCHAR(50) UNIQUE,
    item_id INT,
    glass_type_id INT,
    thickness INT,
    height INT,
    width INT,
    actual_area_sqmm BIGINT,
    available_area_sqmm BIGINT,
    sheet_no VARCHAR(50),
    batch_no VARCHAR(50),
    supplier VARCHAR(200),
    received_date INT,
    expiry_date INT,
    quality_grade TINYINT COMMENT '1=A Grade, 2=B Grade, 3=Commercial',
    is_cut TINYINT DEFAULT 0,
    parent_jumbo_id INT,
    location_rack VARCHAR(50),
    location_row VARCHAR(50),
    location_bin VARCHAR(50),
    status TINYINT DEFAULT 1 COMMENT '1=Available, 2=Partial, 3=Used, 4=Damaged, 5=Quarantine',
    created_by INT,
    created_at INT,
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id),
    FOREIGN KEY (glass_type_id) REFERENCES tbl_glass_type_master(glass_type_id)
);

-- ==========================================================
-- 8. PRODUCTION TRACKING - DAILY ENTRY
-- ==========================================================

CREATE TABLE tbl_production_daily_entry (
    entry_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_detail_id INT NOT NULL,
    operator_id INT,
    machine_id INT,
    entry_date INT,
    shift TINYINT,
    quantity_produced INT,
    quantity_rejected INT,
    rejected_reason TEXT,
    start_time INT,
    end_time INT,
    hours_spent DECIMAL(5,2),
    remarks TEXT,
    created_at INT,
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id),
    FOREIGN KEY (operator_id) REFERENCES tbl_operator_master(operator_id),
    FOREIGN KEY (machine_id) REFERENCES tbl_machine_master(machine_id)
);

-- ==========================================================
-- 9. REJECTION / BREAKAGE REGISTER
-- ==========================================================

CREATE TABLE tbl_rejection_register (
    rejection_id INT PRIMARY KEY AUTO_INCREMENT,
    wo_id INT,
    wo_detail_id INT,
    stage_id INT,
    rejection_date INT,
    rejection_type TINYINT COMMENT '1=Breakage, 2=Scratch, 3=Crack, 4=Size Mismatch, 5=Quality, 6=Other',
    quantity INT,
    size_height INT,
    size_width INT,
    area_sqft DECIMAL(10,2),
    rejection_reason TEXT,
    responsible_operator INT,
    is_rework TINYINT DEFAULT 0,
    rework_wo_id INT,
    remarks TEXT,
    created_by INT,
    created_at INT,
    FOREIGN KEY (wo_id) REFERENCES tbl_work_order_master(wo_id),
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id),
    FOREIGN KEY (stage_id) REFERENCES tbl_production_stages_master(stage_id)
);

-- ==========================================================
-- 10. WORK ORDER - PI CONVERSION PROCEDURE
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_convert_pi_to_wo(IN p_pi_id INT)
BEGIN
    DECLARE v_wo_id INT;
    DECLARE v_wo_number VARCHAR(50);
    DECLARE v_year VARCHAR(4);
    DECLARE v_seq INT;
    DECLARE v_customer_id INT;
    DECLARE v_ship_address_id INT;
    DECLARE v_done INT DEFAULT FALSE;
    
    -- Cursor for PI details
    DECLARE cur_items CURSOR FOR 
        SELECT 
            pi_detail_id, item_id, glass_type_id, thickness,
            height_actual, width_actual, height_chargeable, width_chargeable,
            dimension_uom_id, quantity, unit_id, rate,
            discount_amount, tax_amount, total_amount,
            fabrication_details
        FROM tbl_pi_details 
        WHERE pi_id = p_pi_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- Check if already converted
    IF EXISTS (SELECT 1 FROM tbl_work_order_master WHERE pi_id = p_pi_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PI already converted to Work Order';
    END IF;
    
    -- Generate WO Number
    SET v_year = DATE_FORMAT(NOW(), '%Y');
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(wo_number, '/', -1) AS UNSIGNED)), 0) + 1
    INTO v_seq
    FROM tbl_work_order_master
    WHERE wo_number LIKE CONCAT('WO/', v_year, '/%');
    
    SET v_wo_number = CONCAT('WO/', v_year, '/', LPAD(v_seq, 5, '0'));
    
    -- Get customer info from PI
    SELECT customer_id, ship_address_id 
    INTO v_customer_id, v_ship_address_id
    FROM tbl_pi_master 
    WHERE pi_id = p_pi_id;
    
    -- Create WO Master
    INSERT INTO tbl_work_order_master (
        wo_number, pi_id, wo_date, customer_id, ship_address_id,
        delivery_date, priority, production_status, created_at
    ) VALUES (
        v_wo_number, p_pi_id, UNIX_TIMESTAMP(), v_customer_id, v_ship_address_id,
        DATE_ADD(CURDATE(), INTERVAL 7 DAY), 2, 1, UNIX_TIMESTAMP()
    );
    
    SET v_wo_id = LAST_INSERT_ID();
    
    -- Copy PI items to WO details
    OPEN cur_items;
    read_loop: LOOP
        FETCH cur_items INTO 
            v_pi_detail_id, v_item_id, v_glass_type_id, v_thickness,
            v_h_act, v_w_act, v_h_chg, v_w_chg,
            v_dim_uom, v_qty, v_unit, v_rate,
            v_disc_amt, v_tax_amt, v_total, v_fab;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO tbl_work_order_details (
            wo_id, pi_detail_id, item_id, glass_type_id, thickness,
            height_actual, width_actual, height_chargeable, width_chargeable,
            dimension_uom_id, quantity, unit_id, rate,
            discount_amount, tax_amount, total_amount,
            fabrication_details, cut_qty, processed_qty, balance_qty, status
        ) VALUES (
            v_wo_id, v_pi_detail_id, v_item_id, v_glass_type_id, v_thickness,
            v_h_act, v_w_act, v_h_chg, v_w_chg,
            v_dim_uom, v_qty, v_unit, v_rate,
            v_disc_amt, v_tax_amt, v_total,
            v_fab, 0, 0, v_qty, 1
        );
        
    END LOOP;
    CLOSE cur_items;
    
    -- Update PI status
    UPDATE tbl_pi_master SET status = 3 WHERE pi_id = p_pi_id;
    
    -- Return WO ID and Number
    SELECT v_wo_id AS wo_id, v_wo_number AS wo_number;
    
END$$
DELIMITER ;

-- ==========================================================
-- 11. PRODUCTION STATUS UPDATE PROCEDURE
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_update_production_status(IN p_wo_detail_id INT)
BEGIN
    DECLARE v_total_qty INT;
    DECLARE v_cut_qty INT;
    DECLARE v_processed_qty INT;
    DECLARE v_wo_id INT;
    DECLARE v_all_completed BOOLEAN DEFAULT TRUE;
    
    -- Get current quantities
    SELECT 
        quantity, cut_qty, processed_qty, wo_id
    INTO 
        v_total_qty, v_cut_qty, v_processed_qty, v_wo_id
    FROM tbl_work_order_details 
    WHERE wo_detail_id = p_wo_detail_id;
    
    -- Update balance
    UPDATE tbl_work_order_details 
    SET balance_qty = v_total_qty - v_cut_qty
    WHERE wo_detail_id = p_wo_detail_id;
    
    -- Update WO detail status
    IF v_cut_qty >= v_total_qty THEN
        IF v_processed_qty >= v_total_qty THEN
            UPDATE tbl_work_order_details 
            SET status = 3 -- Completed
            WHERE wo_detail_id = p_wo_detail_id;
        ELSE
            UPDATE tbl_work_order_details 
            SET status = 2 -- In Progress
            WHERE wo_detail_id = p_wo_detail_id;
        END IF;
    END IF;
    
    -- Check if all items in WO are completed
    SELECT IF(SUM(CASE WHEN status != 3 THEN 1 ELSE 0 END) = 0, TRUE, FALSE)
    INTO v_all_completed
    FROM tbl_work_order_details
    WHERE wo_id = v_wo_id;
    
    -- Update WO master status
    IF v_all_completed THEN
        UPDATE tbl_work_order_master 
        SET production_status = 4, -- Completed
            completed_date = UNIX_TIMESTAMP()
        WHERE wo_id = v_wo_id;
    END IF;
    
END$$
DELIMITER ;

-- ==========================================================
-- 12. CUTTING PLAN GENERATION PROCEDURE
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_generate_cutting_plan(
    IN p_wo_detail_id INT,
    IN p_jumbo_height INT,
    IN p_jumbo_width INT,
    IN p_cutting_gap INT
)
BEGIN
    DECLARE v_piece_height INT;
    DECLARE v_piece_width INT;
    DECLARE v_quantity INT;
    DECLARE v_pieces_per_row INT;
    DECLARE v_rows_per_sheet INT;
    DECLARE v_pieces_per_sheet INT;
    DECLARE v_sheets_needed INT;
    DECLARE v_remaining_qty INT;
    DECLARE v_sheet_no INT DEFAULT 1;
    DECLARE v_current_x INT DEFAULT 0;
    DECLARE v_current_y INT DEFAULT 0;
    DECLARE v_wo_id INT;
    DECLARE v_jumbo_id INT;
    
    -- Get WO details
    SELECT 
        wo_id, height_chargeable, width_chargeable, quantity
    INTO 
        v_wo_id, v_piece_height, v_piece_width, v_quantity
    FROM tbl_work_order_details 
    WHERE wo_detail_id = p_wo_detail_id;
    
    -- Add cutting gap
    SET v_piece_height = v_piece_height + p_cutting_gap;
    SET v_piece_width = v_piece_width + p_cutting_gap;
    
    -- Calculate pieces per sheet
    SET v_pieces_per_row = FLOOR(p_jumbo_width / v_piece_width);
    SET v_rows_per_sheet = FLOOR(p_jumbo_height / v_piece_height);
    SET v_pieces_per_sheet = v_pieces_per_row * v_rows_per_sheet;
    
    -- Calculate sheets needed
    SET v_sheets_needed = CEIL(v_quantity / v_pieces_per_sheet);
    SET v_remaining_qty = v_quantity;
    
    -- Create cutting plan
    WHILE v_sheet_no <= v_sheets_needed AND v_remaining_qty > 0 DO
        
        -- Get available jumbo sheet
        SELECT jumbo_id INTO v_jumbo_id
        FROM tbl_jumbo_inventory
        WHERE item_id = (SELECT item_id FROM tbl_work_order_details WHERE wo_detail_id = p_wo_detail_id)
            AND thickness = (SELECT thickness FROM tbl_work_order_details WHERE wo_detail_id = p_wo_detail_id)
            AND height = p_jumbo_height
            AND width = p_jumbo_width
            AND status = 1 -- Available
        LIMIT 1;
        
        SET v_current_x = 0;
        SET v_current_y = 0;
        
        -- Generate cuts for this sheet
        WHILE v_current_y + v_piece_height <= p_jumbo_height AND v_remaining_qty > 0 DO
            
            WHILE v_current_x + v_piece_width <= p_jumbo_width AND v_remaining_qty > 0 DO
                
                INSERT INTO tbl_wo_cutting_plan (
                    wo_detail_id, sheet_no, jumbo_id,
                    jumbo_height, jumbo_width,
                    cut_pos_x, cut_pos_y,
                    cut_height, cut_width,
                    quantity, cutting_status,
                    cut_sequence
                ) VALUES (
                    p_wo_detail_id, v_sheet_no, v_jumbo_id,
                    p_jumbo_height, p_jumbo_width,
                    v_current_x, v_current_y,
                    v_piece_height - p_cutting_gap, 
                    v_piece_width - p_cutting_gap,
                    1, 1, -- Pending
                    v_sheet_no * 100 + v_current_y
                );
                
                SET v_current_x = v_current_x + v_piece_width;
                SET v_remaining_qty = v_remaining_qty - 1;
                
            END WHILE;
            
            SET v_current_x = 0;
            SET v_current_y = v_current_y + v_piece_height;
            
        END WHILE;
        
        SET v_sheet_no = v_sheet_no + 1;
        
    END WHILE;
    
    -- Update WO cutting qty
    UPDATE tbl_work_order_details 
    SET cut_qty = v_quantity - v_remaining_qty
    WHERE wo_detail_id = p_wo_detail_id;
    
    -- Call status update
    CALL sp_update_production_status(p_wo_detail_id);
    
END$$
DELIMITER ;

-- ==========================================================
-- 13. PRODUCTION REPORT VIEW
-- ==========================================================

CREATE VIEW view_production_report AS
SELECT 
    w.wo_number,
    w.wo_date,
    w.delivery_date,
    c.customer_name,
    s.ship_name AS site_name,
    i.item_code,
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
    CASE 
        WHEN d.status = 1 THEN 'Pending'
        WHEN d.status = 2 THEN 'In Progress'
        WHEN d.status = 3 THEN 'Completed'
        WHEN d.status = 4 THEN 'Rejected'
    END AS status_name,
    o.operator_name,
    m.machine_name,
    cp.sheet_no,
    cp.cut_pos_x,
    cp.cut_pos_y,
    cp.cutting_status,
    r.rejection_reason,
    r.rejection_date
FROM tbl_work_order_master w
JOIN tbl_customer_master c ON w.customer_id = c.customer_id
LEFT JOIN tbl_customer_ship_addresses s ON w.ship_address_id = s.ship_id
JOIN tbl_work_order_details d ON w.wo_id = d.wo_id
JOIN tbl_item_master i ON d.item_id = i.item_id
LEFT JOIN tbl_wo_cutting_plan cp ON d.wo_detail_id = cp.wo_detail_id
LEFT JOIN tbl_production_daily_entry e ON d.wo_detail_id = e.wo_detail_id
LEFT JOIN tbl_operator_master o ON e.operator_id = o.operator_id
LEFT JOIN tbl_machine_master m ON e.machine_id = m.machine_id
LEFT JOIN tbl_rejection_register r ON d.wo_detail_id = r.wo_detail_id;

-- ==========================================================
-- 14. REJECTION ANALYSIS VIEW
-- ==========================================================

CREATE VIEW view_rejection_analysis AS
SELECT 
    DATE_FORMAT(FROM_UNIXTIME(r.rejection_date), '%Y-%m') AS month,
    r.rejection_type,
    CASE 
        WHEN r.rejection_type = 1 THEN 'Breakage'
        WHEN r.rejection_type = 2 THEN 'Scratch'
        WHEN r.rejection_type = 3 THEN 'Crack'
        WHEN r.rejection_type = 4 THEN 'Size Mismatch'
        WHEN r.rejection_type = 5 THEN 'Quality'
        ELSE 'Other'
    END AS rejection_type_name,
    i.item_name,
    d.thickness,
    SUM(r.quantity) AS total_rejected,
    SUM(r.area_sqft) AS total_area,
    COUNT(*) AS total_incidents,
    o.operator_name,
    p.stage_name
FROM tbl_rejection_register r
JOIN tbl_work_order_details d ON r.wo_detail_id = d.wo_detail_id
JOIN tbl_item_master i ON d.item_id = i.item_id
LEFT JOIN tbl_production_stages_master p ON r.stage_id = p.stage_id
LEFT JOIN tbl_operator_master o ON r.responsible_operator = o.operator_id
GROUP BY month, r.rejection_type, i.item_name, d.thickness, o.operator_name, p.stage_name;

-- ==========================================================
-- 15. OPERATOR PRODUCTIVITY VIEW
-- ==========================================================

CREATE VIEW view_operator_productivity AS
SELECT 
    o.operator_code,
    o.operator_name,
    o.designation,
    COUNT(DISTINCT e.entry_id) AS total_entries,
    SUM(e.quantity_produced) AS total_produced,
    SUM(e.quantity_rejected) AS total_rejected,
    (SUM(e.quantity_produced) - SUM(e.quantity_rejected)) AS net_production,
    SUM(e.hours_spent) AS total_hours,
    ROUND((SUM(e.quantity_produced) - SUM(e.quantity_rejected)) / SUM(e.hours_spent), 2) AS productivity_per_hour,
    ROUND((SUM(e.quantity_rejected) / SUM(e.quantity_produced)) * 100, 2) AS rejection_percentage
FROM tbl_operator_master o
LEFT JOIN tbl_production_daily_entry e ON o.operator_id = e.operator_id
WHERE e.entry_date >= UNIX_TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 30 DAY))
GROUP BY o.operator_id;

-- ==========================================================
-- 16. SAMPLE WORK ORDER DATA
-- ==========================================================

-- Create sample WO from existing PI
CALL sp_convert_pi_to_wo(1);

-- Generate cutting plan for first WO detail
SET @wo_detail_id = (SELECT wo_detail_id FROM tbl_work_order_details LIMIT 1);
CALL sp_generate_cutting_plan(@wo_detail_id, 6000, 3300, 4);

-- Add some production entries
INSERT INTO tbl_production_daily_entry 
(wo_detail_id, operator_id, machine_id, entry_date, shift, quantity_produced, hours_spent)
SELECT 
    wo_detail_id, 1, 1, UNIX_TIMESTAMP(), 1, 20, 4.5
FROM tbl_work_order_details 
WHERE wo_detail_id = @wo_detail_id;

-- Update production status
CALL sp_update_production_status(@wo_detail_id);

-- ==========================================================
-- FINAL: WORK ORDER MODULE READY
-- ==========================================================

SELECT '✅ SP-7 WORK ORDER MODULE INSTALLED SUCCESSFULLY' AS STATUS;
SELECT '📦 New Tables: Production Stages, Machine Master, Operator Master, Jumbo Inventory, Daily Entry, Rejection Register' AS INFO;
SELECT '⚙️ Stored Procedures: Convert PI to WO, Generate Cutting Plan, Update Production Status' AS INFO;
SELECT '📊 Views: Production Report, Rejection Analysis, Operator Productivity' AS INFO;