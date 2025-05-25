-- =====================================================
-- SMARTERNAK WEB APPLICATION DATABASE SCHEMA
-- Simplified version focused on web features only
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS db_smarternak
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE db_smarternak;

-- =====================================================
-- USERS TABLE (Core user management)
-- =====================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('superadmin', 'admin') NOT NULL DEFAULT 'admin',
    bio TEXT,
    avatar_url VARCHAR(500),
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NULL,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_active (is_active),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- =====================================================
-- USER SESSIONS TABLE (Authentication)
-- =====================================================
CREATE TABLE user_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_session_token (session_token),
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_expires_at (expires_at)
);

-- =====================================================
-- PRODUCTION BATCHES TABLE (Egg production tracking)
-- =====================================================
CREATE TABLE production_batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_code VARCHAR(50) NOT NULL UNIQUE,
    batch_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    expected_quantity INT DEFAULT 0,
    actual_quantity INT DEFAULT 0,
    status ENUM('planned', 'active', 'completed', 'cancelled') DEFAULT 'planned',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_batch_code (batch_code),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date),
    INDEX idx_created_by (created_by)
);

-- =====================================================
-- EGG SCANS TABLE (Main egg quality data - simplified)
-- =====================================================
CREATE TABLE egg_scans (
    scan_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    egg_code VARCHAR(50) NOT NULL UNIQUE,
    batch_id INT,
    quality ENUM('good', 'bad') NOT NULL,
    defect_types JSON,
    quality_notes TEXT,
    image_url VARCHAR(500),
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    scanned_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id) ON DELETE SET NULL,
    FOREIGN KEY (scanned_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_egg_code (egg_code),
    INDEX idx_batch_quality (batch_id, quality),
    INDEX idx_scanned_at (scanned_at),
    INDEX idx_quality (quality)
);

-- =====================================================
-- NOTIFICATIONS TABLE (User notifications)
-- =====================================================
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
    status ENUM('unread', 'read', 'archived') DEFAULT 'unread',
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_user_status (user_id, status),
    INDEX idx_created_at (created_at),
    INDEX idx_type (type)
);

-- =====================================================
-- REPORTS TABLE (Generated reports)
-- =====================================================
CREATE TABLE reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_name VARCHAR(200) NOT NULL,
    report_type ENUM('egg_quality', 'production_statistics', 'batch_summary', 'quality_analysis') NOT NULL,
    parameters JSON,
    file_path VARCHAR(500),
    file_format ENUM('pdf', 'excel', 'csv') NOT NULL,
    file_size INT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    download_count INT DEFAULT 0,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_user_type (user_id, report_type),
    INDEX idx_generated_at (generated_at),
    INDEX idx_expires_at (expires_at)
);

-- =====================================================
-- SYSTEM SETTINGS TABLE (Application configuration)
-- =====================================================
CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT,
    data_type ENUM('string', 'integer', 'float', 'boolean', 'json') DEFAULT 'string',
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT,
    
    FOREIGN KEY (updated_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_setting_key (setting_key),
    INDEX idx_is_public (is_public)
);

-- =====================================================
-- AUDIT LOGS TABLE (Activity tracking)
-- =====================================================
CREATE TABLE audit_logs (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_user_action (user_id, action),
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- DASHBOARD STATS TABLE (Cached statistics)
-- =====================================================
CREATE TABLE dashboard_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    stat_key VARCHAR(100) NOT NULL UNIQUE,
    stat_value JSON NOT NULL,
    description TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_stat_key (stat_key),
    INDEX idx_last_updated (last_updated)
);

-- =====================================================
-- INSERT DEFAULT DATA
-- =====================================================

-- Default superadmin user (password: superadmin123)
INSERT INTO users (name, email, password_hash, role, is_active) VALUES 
('Super Administrator', 'superadmin@smarternak.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PmvlG.', 'superadmin', TRUE);

-- Default admin user (password: admin123)
INSERT INTO users (name, email, password_hash, role, is_active, created_by) VALUES 
('Administrator', 'admin@smarternak.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PmvlG.', 'admin', TRUE, 1);

-- Default system settings
INSERT INTO system_settings (setting_key, setting_value, description, data_type, is_public) VALUES 
('app_name', 'Smarternak', 'Application name', 'string', TRUE),
('app_version', '1.0.0', 'Application version', 'string', TRUE),
('max_file_upload_size', '10485760', 'Maximum file upload size in bytes (10MB)', 'integer', FALSE),
('session_timeout', '3600', 'Session timeout in seconds (1 hour)', 'integer', FALSE),
('enable_notifications', 'true', 'Enable system notifications', 'boolean', FALSE);

-- Sample production batch
INSERT INTO production_batches (batch_code, batch_name, description, start_date, expected_quantity, status, created_by) VALUES 
('BATCH001', 'Production Batch January 2024', 'First production batch of the year', '2024-01-01', 1000, 'active', 1);

-- Initialize dashboard stats
INSERT INTO dashboard_stats (stat_key, stat_value, description) VALUES 
('total_eggs_scanned', '{"count": 0, "last_updated": null}', 'Total number of eggs scanned'),
('quality_distribution', '{"good": 0, "bad": 0}', 'Distribution of egg quality grades'),
('daily_production', '{"today": 0, "yesterday": 0, "trend": "stable"}', 'Daily production statistics'),
('active_batches', '{"count": 1, "list": []}', 'Number of active production batches');

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for egg quality summary
CREATE VIEW egg_quality_summary AS
SELECT 
    DATE(scanned_at) as scan_date,
    COUNT(*) as total_scanned,
    SUM(CASE WHEN quality = 'good' THEN 1 ELSE 0 END) as good_count,
    SUM(CASE WHEN quality = 'bad' THEN 1 ELSE 0 END) as bad_count,
    ROUND((SUM(CASE WHEN quality = 'good' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as good_percentage
FROM egg_scans 
GROUP BY DATE(scanned_at)
ORDER BY scan_date DESC;

-- View for batch statistics
CREATE VIEW batch_statistics AS
SELECT 
    b.batch_id,
    b.batch_code,
    b.batch_name,
    b.status,
    b.expected_quantity,
    COUNT(e.scan_id) as scanned_count,
    SUM(CASE WHEN e.quality = 'good' THEN 1 ELSE 0 END) as good_eggs,
    SUM(CASE WHEN e.quality = 'bad' THEN 1 ELSE 0 END) as bad_eggs,
    CASE 
        WHEN COUNT(e.scan_id) > 0 THEN ROUND((SUM(CASE WHEN e.quality = 'good' THEN 1 ELSE 0 END) / COUNT(e.scan_id)) * 100, 2)
        ELSE 0 
    END as good_percentage,
    b.start_date,
    b.end_date
FROM production_batches b
LEFT JOIN egg_scans e ON b.batch_id = e.batch_id
GROUP BY b.batch_id, b.batch_code, b.batch_name, b.status, b.expected_quantity, b.start_date, b.end_date;

-- View for user activity summary
CREATE VIEW user_activity_summary AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    u.role,
    COUNT(DISTINCT s.session_id) as total_sessions,
    MAX(s.last_activity) as last_login,
    COUNT(DISTINCT e.scan_id) as eggs_scanned,
    COUNT(DISTINCT r.report_id) as reports_generated
FROM users u
LEFT JOIN user_sessions s ON u.user_id = s.user_id
LEFT JOIN egg_scans e ON u.user_id = e.scanned_by
LEFT JOIN reports r ON u.user_id = r.user_id
WHERE u.is_active = TRUE
GROUP BY u.user_id, u.name, u.email, u.role; 