-- ==========================================================
-- SP-7 GLASS ERP - CUTTING OPTIMIZER MODULE (COMPLETE)
-- Author: SP-7 Technologies
-- File: SP7_CuttingOptimizer_Complete.sql
-- Description: Advanced Nesting Algorithm for Glass Cutting
-- ==========================================================

USE sp7_erp;

-- ==========================================================
-- 1. CUTTING OPTIMIZER SESSIONS
-- ==========================================================

CREATE TABLE tbl_cutting_optimizer_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    session_code VARCHAR(50) UNIQUE,
    wo_detail_id INT,
    wo_id INT,
    jumbo_height INT NOT NULL,
    jumbo_width INT NOT NULL,
    jumbo_thickness INT,
    piece_height INT NOT NULL,
    piece_width INT NOT NULL,
    piece_thickness INT,
    quantity_required INT NOT NULL,
    cutting_gap INT DEFAULT 4,
    edge_allowance INT DEFAULT 10,
    min_piece_size INT DEFAULT 100,
    rotation_allowed TINYINT DEFAULT 1,
    priority TINYINT DEFAULT 2 COMMENT '1=Minimize Sheets, 2=Minimize Wastage',
    created_by INT,
    created_at INT,
    status TINYINT DEFAULT 1 COMMENT '1=Pending, 2=Optimized, 3=Approved, 4=Rejected',
    FOREIGN KEY (wo_detail_id) REFERENCES tbl_work_order_details(wo_detail_id),
    FOREIGN KEY (wo_id) REFERENCES tbl_work_order_master(wo_id)
);

-- ==========================================================
-- 2. CUTTING OPTIMIZER RESULTS
-- ==========================================================

CREATE TABLE tbl_cutting_optimizer_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    sheet_no INT NOT NULL,
    jumbo_id INT,
    cut_pos_x INT NOT NULL,
    cut_pos_y INT NOT NULL,
    cut_height INT NOT NULL,
    cut_width INT NOT NULL,
    cut_sequence INT,
    quantity INT DEFAULT 1,
    is_rotated TINYINT DEFAULT 0,
    blade_path TEXT,
    wastage_sqmm BIGINT,
    wastage_percent DECIMAL(5,2),
    cut_time_estimate INT,
    is_selected TINYINT DEFAULT 0,
    approved_by INT,
    approved_at INT,
    FOREIGN KEY (session_id) REFERENCES tbl_cutting_optimizer_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (jumbo_id) REFERENCES tbl_jumbo_inventory(jumbo_id)
);

-- ==========================================================
-- 3. NESTING ALGORITHM - GUILLOTINE CUT
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_optimize_guillotine_cut(
    IN p_wo_detail_id INT,
    IN p_jumbo_height INT,
    IN p_jumbo_width INT,
    IN p_cutting_gap INT,
    IN p_rotation_allowed BOOLEAN
)
BEGIN
    DECLARE v_session_id INT;
    DECLARE v_piece_height INT;
    DECLARE v_piece_width INT;
    DECLARE v_quantity INT;
    DECLARE v_piece_height_rot INT;
    DECLARE v_piece_width_rot INT;
    DECLARE v_remaining_qty INT;
    DECLARE v_sheet_no INT DEFAULT 1;
    DECLARE v_current_x INT;
    DECLARE v_current_y INT;
    DECLARE v_row_height INT;
    DECLARE v_pieces_in_row INT;
    DECLARE v_best_pieces_per_sheet INT DEFAULT 0;
    DECLARE v_best_orientation VARCHAR(10);
    DECLARE v_session_code VARCHAR(50);
    
    -- Generate session code
    SET v_session_code = CONCAT('OPT-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 1000), 3, '0'));
    
    -- Get WO details
    SELECT 
        height_chargeable, width_chargeable, quantity
    INTO 
        v_piece_height, v_piece_width, v_quantity
    FROM tbl_work_order_details 
    WHERE wo_detail_id = p_wo_detail_id;
    
    -- Add cutting gap
    SET v_piece_height = v_piece_height + p_cutting_gap;
    SET v_piece_width = v_piece_width + p_cutting_gap;
    
    -- Rotated dimensions
    SET v_piece_height_rot = v_piece_width;
    SET v_piece_width_rot = v_piece_height;
    
    -- Create session
    INSERT INTO tbl_cutting_optimizer_sessions (
        session_code, wo_detail_id, jumbo_height, jumbo_width,
        piece_height, piece_width, quantity_required,
        cutting_gap, rotation_allowed, created_at
    ) VALUES (
        v_session_code, p_wo_detail_id, p_jumbo_height, p_jumbo_width,
        v_piece_height - p_cutting_gap, v_piece_width - p_cutting_gap,
        v_quantity, p_cutting_gap, p_rotation_allowed, UNIX_TIMESTAMP()
    );
    
    SET v_session_id = LAST_INSERT_ID();
    SET v_remaining_qty = v_quantity;
    
    -- Main optimization loop
    WHILE v_remaining_qty > 0 DO
        
        SET v_current_x = 0;
        SET v_current_y = 0;
        SET v_row_height = 0;
        
        -- Try both orientations if allowed
        IF p_rotation_allowed THEN
            
            -- Calculate pieces per sheet in normal orientation
            SET v_pieces_in_row = FLOOR(p_jumbo_width / v_piece_width);
            SET @rows = FLOOR(p_jumbo_height / v_piece_height);
            SET @normal_total = v_pieces_in_row * @rows;
            
            -- Calculate pieces per sheet in rotated orientation
            SET v_pieces_in_row_rot = FLOOR(p_jumbo_width / v_piece_width_rot);
            SET @rows_rot = FLOOR(p_jumbo_height / v_piece_height_rot);
            SET @rotated_total = v_pieces_in_row_rot * @rows_rot;
            
            -- Choose better orientation
            IF @normal_total >= @rotated_total THEN
                SET v_best_pieces_per_sheet = @normal_total;
                SET v_best_orientation = 'NORMAL';
            ELSE
                SET v_best_pieces_per_sheet = @rotated_total;
                SET v_best_orientation = 'ROTATED';
                -- Swap dimensions for rotated
                SET @temp = v_piece_height;
                SET v_piece_height = v_piece_width;
                SET v_piece_width = @temp;
            END IF;
        ELSE
            SET v_best_pieces_per_sheet = FLOOR(p_jumbo_width / v_piece_width) * FLOOR(p_jumbo_height / v_piece_height);
            SET v_best_orientation = 'NORMAL';
        END IF;
        
        -- Generate cuts for current sheet
        WHILE v_current_y + v_piece_height <= p_jumbo_height AND v_remaining_qty > 0 DO
            
            SET v_pieces_in_row = FLOOR((p_jumbo_width - v_current_x) / v_piece_width);
            SET v_pieces_in_row = LEAST(v_pieces_in_row, v_remaining_qty);
            
            SET v_current_x = 0;
            
            WHILE v_current_x + v_piece_width <= p_jumbo_width AND v_remaining_qty > 0 DO
                
                INSERT INTO tbl_cutting_optimizer_results (
                    session_id, sheet_no,
                    cut_pos_x, cut_pos_y,
                    cut_height, cut_width,
                    cut_sequence, quantity,
                    is_rotated,
                    wastage_sqmm, wastage_percent
                ) VALUES (
                    v_session_id, v_sheet_no,
                    v_current_x, v_current_y,
                    v_piece_height - p_cutting_gap,
                    v_piece_width - p_cutting_gap,
                    (v_sheet_no * 1000) + v_current_y,
                    1,
                    CASE WHEN v_best_orientation = 'ROTATED' THEN 1 ELSE 0 END,
                    0, 0.00
                );
                
                SET v_current_x = v_current_x + v_piece_width;
                SET v_remaining_qty = v_remaining_qty - 1;
                
                IF v_remaining_qty = 0 THEN
                    LEAVE;
                END IF;
                
            END WHILE;
            
            SET v_current_y = v_current_y + v_piece_height;
            
        END WHILE;
        
        SET v_sheet_no = v_sheet_no + 1;
        
        -- Reset orientation if it was rotated for next sheet
        IF p_rotation_allowed AND v_best_orientation = 'ROTATED' THEN
            SET v_piece_height = v_piece_width_rot;
            SET v_piece_width = v_piece_height_rot;
        END IF;
        
    END WHILE;
    
    -- Update session with total sheets
    UPDATE tbl_cutting_optimizer_sessions 
    SET status = 2 -- Optimized
    WHERE session_id = v_session_id;
    
    -- Calculate wastage for each sheet
    UPDATE tbl_cutting_optimizer_results r
    JOIN tbl_cutting_optimizer_sessions s ON r.session_id = s.session_id
    SET 
        r.wastage_sqmm = (s.jumbo_height * s.jumbo_width) - 
            (SELECT SUM(cut_height * cut_width * quantity) 
             FROM tbl_cutting_optimizer_results r2 
             WHERE r2.session_id = r.session_id AND r2.sheet_no = r.sheet_no),
        r.wastage_percent = ROUND(((s.jumbo_height * s.jumbo_width) - 
            (SELECT SUM(cut_height * cut_width * quantity) 
             FROM tbl_cutting_optimizer_results r2 
             WHERE r2.session_id = r.session_id AND r2.sheet_no = r.sheet_no)) * 100.0 / 
            (s.jumbo_height * s.jumbo_width), 2);
    
    -- Return session ID
    SELECT v_session_id AS session_id, v_session_code AS session_code;
    
END$$
DELIMITER ;

-- ==========================================================
-- 4. ADVANCED NESTING - BIN PACKING (Multiple Sizes)
-- ==========================================================

CREATE TABLE tbl_nesting_bin_packing (
    bin_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT,
    bin_no INT,
    bin_height INT,
    bin_width INT,
    used_height INT,
    used_width INT,
    remaining_height INT,
    remaining_width INT,
    waste_area BIGINT,
    FOREIGN KEY (session_id) REFERENCES tbl_cutting_optimizer_sessions(session_id)
);

DELIMITER $$
CREATE PROCEDURE sp_bin_packing_optimize(
    IN p_wo_id INT,
    IN p_jumbo_height INT,
    IN p_jumbo_width INT
)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_item_id INT;
    DECLARE v_piece_height INT;
    DECLARE v_piece_width INT;
    DECLARE v_quantity INT;
    DECLARE v_session_id INT;
    DECLARE v_bin_no INT DEFAULT 1;
    DECLARE v_current_x INT;
    DECLARE v_current_y INT;
    
    -- Cursor for all items in WO
    DECLARE cur_items CURSOR FOR 
        SELECT 
            d.wo_detail_id,
            d.item_id,
            d.height_chargeable + 4 AS piece_height,
            d.width_chargeable + 4 AS piece_width,
            d.balance_qty
        FROM tbl_work_order_details d
        WHERE d.wo_id = p_wo_id AND d.balance_qty > 0
        ORDER BY (d.height_chargeable * d.width_chargeable) DESC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- Create session
    INSERT INTO tbl_cutting_optimizer_sessions (
        session_code, wo_id, jumbo_height, jumbo_width,
        quantity_required, created_at
    ) VALUES (
        CONCAT('BIN-', DATE_FORMAT(NOW(), '%Y%m%d-%H%i%s')),
        p_wo_id, p_jumbo_height, p_jumbo_width,
        (SELECT SUM(balance_qty) FROM tbl_work_order_details WHERE wo_id = p_wo_id),
        UNIX_TIMESTAMP()
    );
    
    SET v_session_id = LAST_INSERT_ID();
    
    OPEN cur_items;
    
    read_loop: LOOP
        FETCH cur_items INTO v_wo_detail_id, v_item_id, v_piece_height, v_piece_width, v_quantity;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Try to place pieces
        WHILE v_quantity > 0 DO
            
            -- Check if we can place in current bin
            IF NOT EXISTS (SELECT 1 FROM tbl_nesting_bin_packing WHERE bin_no = v_bin_no) THEN
                -- Create new bin
                INSERT INTO tbl_nesting_bin_packing 
                (session_id, bin_no, bin_height, bin_width, used_height, used_width, remaining_height, remaining_width)
                VALUES (v_session_id, v_bin_no, p_jumbo_height, p_jumbo_width, 0, 0, p_jumbo_height, p_jumbo_width);
            END IF;
            
            -- Get current bin status
            SELECT remaining_height, remaining_width, used_height, used_width
            INTO @rem_h, @rem_w, @used_h, @used_w
            FROM tbl_nesting_bin_packing
            WHERE bin_no = v_bin_no;
            
            -- Try to place
            IF v_piece_height <= @rem_h AND v_piece_width <= @rem_w THEN
                
                -- Place piece
                INSERT INTO tbl_cutting_optimizer_results (
                    session_id, sheet_no, cut_pos_x, cut_pos_y,
                    cut_height, cut_width, quantity, cut_sequence
                ) VALUES (
                    v_session_id, v_bin_no, @used_w, @used_h,
                    v_piece_height - 4, v_piece_width - 4, 1,
                    v_bin_no * 1000 + @used_h
                );
                
                -- Update bin
                UPDATE tbl_nesting_bin_packing
                SET 
                    used_height = @used_h + v_piece_height,
                    used_width = GREATEST(used_width, @used_w + v_piece_width),
                    remaining_height = bin_height - (@used_h + v_piece_height),
                    remaining_width = bin_width - used_width
                WHERE bin_no = v_bin_no;
                
                SET v_quantity = v_quantity - 1;
                
            ELSE
                -- Move to next bin
                SET v_bin_no = v_bin_no + 1;
            END IF;
            
        END WHILE;
        
    END LOOP;
    
    CLOSE cur_items;
    
    -- Update wastage calculation
    UPDATE tbl_nesting_bin_packing
    SET waste_area = (bin_height * bin_width) - 
        (SELECT SUM(cut_height * cut_width * quantity) 
         FROM tbl_cutting_optimizer_results 
         WHERE session_id = v_session_id AND sheet_no = bin_no);
    
END$$
DELIMITER ;

-- ==========================================================
-- 5. WASTAGE ANALYSIS
-- ==========================================================

CREATE VIEW view_cutting_wastage_analysis AS
SELECT 
    s.session_code,
    w.wo_number,
    s.jumbo_height,
    s.jumbo_width,
    s.piece_height,
    s.piece_width,
    s.quantity_required,
    COUNT(DISTINCT r.sheet_no) AS sheets_used,
    SUM(r.cut_height * r.cut_width * r.quantity) AS total_used_area,
    s.jumbo_height * s.jumbo_width * COUNT(DISTINCT r.sheet_no) AS total_jumbo_area,
    (s.jumbo_height * s.jumbo_width * COUNT(DISTINCT r.sheet_no)) - 
        SUM(r.cut_height * r.cut_width * r.quantity) AS total_wastage,
    ROUND(((s.jumbo_height * s.jumbo_width * COUNT(DISTINCT r.sheet_no)) - 
        SUM(r.cut_height * r.cut_width * r.quantity)) * 100.0 / 
        (s.jumbo_height * s.jumbo_width * COUNT(DISTINCT r.sheet_no)), 2) AS wastage_percent,
    AVG(r.wastage_percent) AS avg_sheet_wastage,
    s.rotation_allowed,
    s.priority,
    s.created_at
FROM tbl_cutting_optimizer_sessions s
LEFT JOIN tbl_work_order_master w ON s.wo_id = w.wo_id
LEFT JOIN tbl_cutting_optimizer_results r ON s.session_id = r.session_id
GROUP BY s.session_id;

-- ==========================================================
-- 6. REMNANT MANAGEMENT (Bacha hua pieces)
-- ==========================================================

CREATE TABLE tbl_remnant_inventory (
    remnant_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT,
    sheet_no INT,
    parent_jumbo_id INT,
    remnant_code VARCHAR(50) UNIQUE,
    remnant_height INT,
    remnant_width INT,
    thickness INT,
    item_id INT,
    glass_type_id INT,
    area_sqmm BIGINT,
    location_rack VARCHAR(50),
    location_row VARCHAR(50),
    is_available TINYINT DEFAULT 1,
    created_at INT,
    used_in_wo_id INT,
    used_date INT,
    FOREIGN KEY (session_id) REFERENCES tbl_cutting_optimizer_sessions(session_id),
    FOREIGN KEY (item_id) REFERENCES tbl_item_master(item_id)
);

DELIMITER $$
CREATE PROCEDURE sp_capture_remnants(IN p_session_id INT)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_sheet_no INT;
    DECLARE v_jumbo_height INT;
    DECLARE v_jumbo_width INT;
    DECLARE v_last_x INT;
    DECLARE v_last_y INT;
    DECLARE v_max_x INT;
    DECLARE v_max_y INT;
    DECLARE v_remnant_code VARCHAR(50);
    
    -- Cursor for sheets
    DECLARE cur_sheets CURSOR FOR 
        SELECT DISTINCT sheet_no
        FROM tbl_cutting_optimizer_results
        WHERE session_id = p_session_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- Get session details
    SELECT jumbo_height, jumbo_width
    INTO v_jumbo_height, v_jumbo_width
    FROM tbl_cutting_optimizer_sessions
    WHERE session_id = p_session_id;
    
    OPEN cur_sheets;
    
    sheet_loop: LOOP
        FETCH cur_sheets INTO v_sheet_no;
        
        IF v_done THEN
            LEAVE sheet_loop;
        END IF;
        
        -- Find max X and Y used
        SELECT MAX(cut_pos_x + cut_width), MAX(cut_pos_y + cut_height)
        INTO v_max_x, v_max_y
        FROM tbl_cutting_optimizer_results
        WHERE session_id = p_session_id AND sheet_no = v_sheet_no;
        
        -- Check right side remnant
        IF v_max_x < v_jumbo_width THEN
            SET v_remnant_code = CONCAT('REM-', DATE_FORMAT(NOW(), '%y%m%d'), '-', v_sheet_no, '-R');
            
            INSERT INTO tbl_remnant_inventory (
                session_id, sheet_no, remnant_code,
                remnant_height, remnant_width,
                area_sqmm, is_available, created_at
            ) VALUES (
                p_session_id, v_sheet_no, v_remnant_code,
                v_jumbo_height, v_jumbo_width - v_max_x,
                v_jumbo_height * (v_jumbo_width - v_max_x), 1, UNIX_TIMESTAMP()
            );
        END IF;
        
        -- Check top remnant
        IF v_max_y < v_jumbo_height THEN
            SET v_remnant_code = CONCAT('REM-', DATE_FORMAT(NOW(), '%y%m%d'), '-', v_sheet_no, '-T');
            
            INSERT INTO tbl_remnant_inventory (
                session_id, sheet_no, remnant_code,
                remnant_height, remnant_width,
                area_sqmm, is_available, created_at
            ) VALUES (
                p_session_id, v_sheet_no, v_remnant_code,
                v_jumbo_height - v_max_y, v_jumbo_width,
                (v_jumbo_height - v_max_y) * v_jumbo_width, 1, UNIX_TIMESTAMP()
            );
        END IF;
        
    END LOOP;
    
    CLOSE cur_sheets;
    
END$$
DELIMITER ;

-- ==========================================================
-- 7. CUTTING COST ESTIMATOR
-- ==========================================================

CREATE TABLE tbl_cutting_cost_estimates (
    estimate_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT,
    total_sheets INT,
    total_cuts INT,
    cutting_time_minutes INT,
    labor_cost BIGINT,
    machine_cost BIGINT,
    material_cost BIGINT,
    total_cost BIGINT,
    cost_per_sqft DECIMAL(10,2),
    estimated_at INT,
    FOREIGN KEY (session_id) REFERENCES tbl_cutting_optimizer_sessions(session_id)
);

DELIMITER $$
CREATE PROCEDURE sp_estimate_cutting_cost(IN p_session_id INT)
BEGIN
    DECLARE v_total_sheets INT;
    DECLARE v_total_cuts INT;
    DECLARE v_cutting_time INT;
    DECLARE v_labor_rate BIGINT DEFAULT 50000; -- ₹500 per hour in paise
    DECLARE v_machine_rate BIGINT DEFAULT 100000; -- ₹1000 per hour in paise
    DECLARE v_glass_rate BIGINT DEFAULT 8500; -- ₹85 per sqft in paise
    DECLARE v_total_area_sqft DECIMAL(10,2);
    DECLARE v_labor_cost BIGINT;
    DECLARE v_machine_cost BIGINT;
    DECLARE v_material_cost BIGINT;
    
    -- Calculate sheets and cuts
    SELECT 
        COUNT(DISTINCT sheet_no),
        COUNT(*),
        SUM(cut_height * cut_width * quantity) / 14400.0 -- Convert to sqft
    INTO 
        v_total_sheets, v_total_cuts, v_total_area_sqft
    FROM tbl_cutting_optimizer_results
    WHERE session_id = p_session_id;
    
    -- Estimate cutting time (2 minutes per cut approx)
    SET v_cutting_time = v_total_cuts * 2;
    
    -- Calculate costs
    SET v_labor_cost = (v_cutting_time / 60.0) * v_labor_rate;
    SET v_machine_cost = (v_cutting_time / 60.0) * v_machine_rate;
    SET v_material_cost = v_total_area_sqft * v_glass_rate;
    
    -- Insert estimate
    INSERT INTO tbl_cutting_cost_estimates (
        session_id, total_sheets, total_cuts, cutting_time_minutes,
        labor_cost, machine_cost, material_cost, total_cost,
        cost_per_sqft, estimated_at
    ) VALUES (
        p_session_id, v_total_sheets, v_total_cuts, v_cutting_time,
        v_labor_cost, v_machine_cost, v_material_cost,
        v_labor_cost + v_machine_cost + v_material_cost,
        (v_labor_cost + v_machine_cost + v_material_cost) / v_total_area_sqft,
        UNIX_TIMESTAMP()
    );
    
END$$
DELIMITER ;

-- ==========================================================
-- 8. CUTTING PLAN APPROVAL AND EXPORT
-- ==========================================================

DELIMITER $$
CREATE PROCEDURE sp_approve_cutting_plan(IN p_session_id INT, IN p_approved_by INT)
BEGIN
    DECLARE v_wo_detail_id INT;
    
    -- Get WO detail ID
    SELECT wo_detail_id INTO v_wo_detail_id
    FROM tbl_cutting_optimizer_sessions
    WHERE session_id = p_session_id;
    
    -- Mark selected results
    UPDATE tbl_cutting_optimizer_results
    SET is_selected = 1
    WHERE session_id = p_session_id;
    
    -- Update session
    UPDATE tbl_cutting_optimizer_sessions
    SET status = 3, -- Approved
        approved_by = p_approved_by,
        approved_at = UNIX_TIMESTAMP()
    WHERE session_id = p_session_id;
    
    -- Copy to actual cutting plan
    INSERT INTO tbl_wo_cutting_plan (
        wo_detail_id, sheet_no, jumbo_id,
        cut_pos_x, cut_pos_y, cut_height, cut_width,
        quantity, cut_sequence, is_remnant
    )
    SELECT 
        v_wo_detail_id, sheet_no, jumbo_id,
        cut_pos_x, cut_pos_y, cut_height, cut_width,
        quantity, cut_sequence, 0
    FROM tbl_cutting_optimizer_results
    WHERE session_id = p_session_id AND is_selected = 1;
    
    -- Update WO detail cutting qty
    UPDATE tbl_work_order_details d
    SET cut_qty = (
        SELECT SUM(quantity)
        FROM tbl_wo_cutting_plan
        WHERE wo_detail_id = d.wo_detail_id
    )
    WHERE wo_detail_id = v_wo_detail_id;
    
    -- Capture remnants
    CALL sp_capture_remnants(p_session_id);
    
    -- Estimate cost
    CALL sp_estimate_cutting_cost(p_session_id);
    
END$$
DELIMITER ;

-- ==========================================================
-- 9. CUTTING OPTIMIZER UI VIEW
-- ==========================================================

CREATE VIEW view_cutting_optimizer_ui AS
SELECT 
    s.session_id,
    s.session_code,
    w.wo_number,
    i.item_name,
    d.thickness,
    d.height_chargeable AS piece_h,
    d.width_chargeable AS piece_w,
    d.quantity,
    s.jumbo_height,
    s.jumbo_width,
    COUNT(DISTINCT r.sheet_no) AS sheets_required,
    SUM(r.quantity) AS total_pieces_placed,
    ROUND(s.jumbo_height * s.jumbo_width * COUNT(DISTINCT r.sheet_no) / 14400.0, 2) AS total_jumbo_sqft,
    ROUND(SUM(r.cut_height * r.cut_width * r.quantity) / 14400.0, 2) AS used_sqft,
    ROUND(SUM(r.wastage_sqmm) / 1e6, 2) AS total_wastage_sqm,
    ROUND(AVG(r.wastage_percent), 2) AS avg_wastage_pct,
    s.status,
    s.created_at,
    s.approved_at
FROM tbl_cutting_optimizer_sessions s
JOIN tbl_work_order_master w ON s.wo_id = w.wo_id
JOIN tbl_work_order_details d ON s.wo_detail_id = d.wo_detail_id
JOIN tbl_item_master i ON d.item_id = i.item_id
LEFT JOIN tbl_cutting_optimizer_results r ON s.session_id = r.session_id
GROUP BY s.session_id
ORDER BY s.created_at DESC;

-- ==========================================================
-- 10. SAMPLE CUTTING OPTIMIZATION
-- ==========================================================

-- Run optimization for first WO detail
SET @wo_detail_id = (SELECT wo_detail_id FROM tbl_work_order_details LIMIT 1);
SET @jumbo_h = 6000;
SET @jumbo_w = 3300;
SET @gap = 4;

CALL sp_optimize_guillotine_cut(@wo_detail_id, @jumbo_h, @jumbo_w, @gap, 1);

-- Approve the plan
SET @session_id = (SELECT session_id FROM tbl_cutting_optimizer_sessions ORDER BY session_id DESC LIMIT 1);
CALL sp_approve_cutting_plan(@session_id, 1);

-- ==========================================================
-- FINAL: CUTTING OPTIMIZER MODULE READY
-- ==========================================================

SELECT '✅ SP-7 CUTTING OPTIMIZER MODULE INSTALLED SUCCESSFULLY' AS STATUS;
SELECT '📦 New Tables: Optimizer Sessions, Results, Remnant Inventory, Cost Estimates' AS INFO;
SELECT '⚙️ Algorithms: Guillotine Cut, Bin Packing, Remnant Management, Cost Estimation' AS INFO;
SELECT '📊 Views: Wastage Analysis, Optimizer UI' AS INFO;