-- =====================================================
-- SMARTERNAK IoT EGG QUALITY MONITORING SYSTEM
-- Database Schema for MySQL 8.0+
-- ESP32-CAM AI Scanner + ESP32 DevKit V1 Controller + HC-SR04 Counter Integration
-- =====================================================



-- Create database
CREATE DATABASE IF NOT EXISTS smarternak_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE smarternak_db;

-- =====================================================
-- USERS TABLE
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
    remember_token VARCHAR(100),
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
-- ESP32 DEVICES TABLE (IoT Devices)
-- =====================================================
CREATE TABLE esp32_devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    device_name VARCHAR(100) NOT NULL,
    device_type ENUM('esp32_cam_ai_scanner', 'esp32_devkit_controller') NOT NULL,
    mac_address VARCHAR(17) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    wifi_ssid VARCHAR(100),
    signal_strength INT, -- WiFi signal strength in dBm
    status ENUM('online', 'offline', 'maintenance', 'error') DEFAULT 'offline',
    firmware_version VARCHAR(50),
    hardware_version VARCHAR(50),
    ai_model_version VARCHAR(50), -- For ESP32-CAM AI model version
    controller_mode ENUM('automatic', 'manual', 'calibration') DEFAULT 'automatic', -- For ESP32 DevKit V1
    configuration JSON,
    last_ping TIMESTAMP NULL,
    last_heartbeat TIMESTAMP NULL,
    uptime_seconds BIGINT DEFAULT 0,
    reset_count INT DEFAULT 0,
    error_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_device_type (device_type),
    INDEX idx_status (status),
    INDEX idx_mac_address (mac_address),
    INDEX idx_last_ping (last_ping),
    INDEX idx_active (is_active),
    INDEX idx_last_heartbeat (last_heartbeat)
);

-- =====================================================
-- CONVEYOR SYSTEMS TABLE
-- =====================================================
CREATE TABLE conveyor_systems (
    conveyor_id INT AUTO_INCREMENT PRIMARY KEY,
    conveyor_name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    capacity INT NOT NULL DEFAULT 100, -- Reduced for prototype/maket scale
    
    -- Speed control for prototype conveyor
    speed_level TINYINT DEFAULT 1, -- Speed level 1-10 (1=slowest, 10=fastest)
    speed_pwm_value INT DEFAULT 100, -- PWM value 0-255 for motor control
    speed_percentage DECIMAL(5,2) DEFAULT 50.00, -- Speed as percentage 0-100%
    speed_cm_per_second DECIMAL(6,2) DEFAULT 5.00, -- Linear speed in cm/s for prototype
    
    -- Physical dimensions for prototype/maket
    belt_length_cm DECIMAL(8,2) DEFAULT 100.00, -- Belt length in centimeters (prototype scale)
    belt_width_cm DECIMAL(6,2) DEFAULT 15.00, -- Belt width in centimeters
    
    -- Sorting mechanism configuration
    sorting_mechanism ENUM('servo_motor', 'pneumatic', 'mechanical') DEFAULT 'servo_motor',
    servo_angle_good_eggs INT DEFAULT 90, -- Servo angle for good eggs path (degrees)
    servo_angle_bad_eggs INT DEFAULT 0, -- Servo angle for bad eggs path (degrees)
    
    -- Path destinations
    left_path_destination VARCHAR(100) DEFAULT 'Bad Eggs Collection',
    right_path_destination VARCHAR(100) DEFAULT 'Good Eggs Collection',
    
    -- System status and control
    status ENUM('active', 'inactive', 'maintenance', 'error', 'calibrating') DEFAULT 'inactive',
    operation_mode ENUM('automatic', 'manual') DEFAULT 'automatic',
    
    -- Connected ESP32 devices
    esp32_cam_device_id INT, -- ESP32-CAM for AI quality scanning
    esp32_controller_device_id INT, -- ESP32 DevKit V1 for controlling conveyor and sorting
    
    -- Configuration and settings
    settings JSON, -- Additional settings like scan position, timing, etc.
    calibration_data JSON, -- Calibration data for speed, positioning, etc.
    
    -- Maintenance and tracking
    installation_date DATE,
    last_maintenance DATE,
    total_runtime_hours DECIMAL(10,2) DEFAULT 0.00, -- Total operating hours
    total_eggs_processed INT DEFAULT 0, -- Total eggs processed counter
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Foreign key constraints
    FOREIGN KEY (esp32_cam_device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,
    FOREIGN KEY (esp32_controller_device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,
    
    -- Indexes for performance
    INDEX idx_status (status),
    INDEX idx_location (location),
    INDEX idx_active (is_active),
    INDEX idx_operation_mode (operation_mode),
    INDEX idx_speed_level (speed_level),
    INDEX idx_esp32_devices (esp32_cam_device_id, esp32_controller_device_id)
);

-- =====================================================
-- AI QUALITY MODELS TABLE
-- =====================================================
CREATE TABLE ai_quality_models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    model_type ENUM('tensorflow_lite', 'edge_impulse', 'custom') NOT NULL,
    accuracy_percentage DECIMAL(5,2),
    confidence_threshold DECIMAL(3,2) DEFAULT 0.80,
    model_file_path VARCHAR(500),
    model_size_kb INT,
    training_dataset_info JSON,
    performance_metrics JSON,
    is_active BOOLEAN DEFAULT TRUE,
    deployed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_model_version (model_version),
    INDEX idx_active (is_active),
    INDEX idx_model_type (model_type)
);

-- =====================================================
-- QUALITY STANDARDS TABLE
-- =====================================================
CREATE TABLE quality_standards (
    standard_id INT AUTO_INCREMENT PRIMARY KEY,
    standard_name VARCHAR(100) NOT NULL,
    min_weight DECIMAL(6,2) DEFAULT 0.00,
    max_weight DECIMAL(6,2) DEFAULT 100.00,
    min_length DECIMAL(6,2) DEFAULT 0.00,
    max_length DECIMAL(6,2) DEFAULT 10.00,
    min_width DECIMAL(6,2) DEFAULT 0.00,
    max_width DECIMAL(6,2) DEFAULT 10.00,
    min_height DECIMAL(6,2) DEFAULT 0.00,
    max_height DECIMAL(6,2) DEFAULT 10.00,
    ai_confidence_threshold DECIMAL(3,2) DEFAULT 0.75,
    criteria_description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_active (is_active),
    INDEX idx_standard_name (standard_name)
);

-- =====================================================
-- PRODUCTION BATCHES TABLE
-- =====================================================
CREATE TABLE production_batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_code VARCHAR(50) NOT NULL UNIQUE,
    production_date DATE NOT NULL,
    total_eggs_detected INT DEFAULT 0, -- Total eggs detected by HC-SR04
    total_eggs_scanned INT DEFAULT 0, -- Total eggs scanned by ESP32-CAM
    good_eggs_sorted INT DEFAULT 0, -- Good eggs sorted to right path
    bad_eggs_sorted INT DEFAULT 0, -- Bad eggs sorted to left path
    unscanned_eggs INT DEFAULT 0, -- Detected but not scanned by AI
    sorting_accuracy DECIMAL(5,2) DEFAULT 0.00, -- Sorting mechanism accuracy
    good_percentage DECIMAL(5,2) DEFAULT 0.00,
    scan_coverage_percentage DECIMAL(5,2) DEFAULT 0.00, -- scanned/detected ratio
    statistics JSON,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_batch_code (batch_code),
    INDEX idx_production_date (production_date),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- EGG DETECTION DATA TABLE (HC-SR04 Sensor Data via ESP32 DevKit V1)
-- =====================================================
CREATE TABLE egg_detection_data (
    detection_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    controller_device_id INT NOT NULL, -- ESP32 DevKit V1 that received HC-SR04 data
    conveyor_id INT NOT NULL,
    batch_id INT,
    egg_sequence_number INT NOT NULL, -- Sequential number of detected egg
    distance_cm DECIMAL(6,2), -- Distance measured by HC-SR04
    trigger_threshold_cm DECIMAL(6,2), -- Threshold that triggered detection
    detection_confidence DECIMAL(3,2) DEFAULT 1.00,
    sensor_temperature DECIMAL(5,2), -- Temperature compensation
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (controller_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id) ON DELETE SET NULL,
    
    INDEX idx_controller_conveyor (controller_device_id, conveyor_id),
    INDEX idx_detected_at (detected_at),
    INDEX idx_batch_sequence (batch_id, egg_sequence_number),
    INDEX idx_date_conveyor (DATE(detected_at), conveyor_id)
);

-- =====================================================
-- EGG AI SCANS TABLE (ESP32-CAM AI Scanner Data)
-- =====================================================
CREATE TABLE egg_ai_scans (
    scan_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    egg_code VARCHAR(50) NOT NULL UNIQUE,
    cam_device_id INT NOT NULL, -- ESP32-CAM that performed the scan
    controller_device_id INT NOT NULL, -- ESP32 DevKit V1 that received the AI result
    conveyor_id INT NOT NULL,
    batch_id INT,
    standard_id INT,
    model_id INT,
    detection_id BIGINT, -- Link to detection data if available
    quality ENUM('good', 'bad', 'uncertain') NOT NULL,
    ai_confidence DECIMAL(5,4), -- AI model confidence score (0.0000-1.0000)
    ai_prediction_time_ms INT, -- Time taken for AI prediction in milliseconds
    communication_latency_ms INT, -- Time to send result from CAM to Controller
    weight DECIMAL(6,2),
    length DECIMAL(6,2),
    width DECIMAL(6,2),
    height DECIMAL(6,2),
    quality_score DECIMAL(5,2),
    defect_types JSON, -- Array of detected defects
    bounding_box JSON, -- Egg detection bounding box coordinates
    quality_notes TEXT,
    image_url VARCHAR(500),
    image_size_kb INT,
    image_resolution VARCHAR(20), -- e.g., "640x480"
    lighting_conditions ENUM('good', 'poor', 'variable') DEFAULT 'good',
    processing_time_ms INT, -- Total processing time
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cam_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (controller_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id) ON DELETE SET NULL,
    FOREIGN KEY (standard_id) REFERENCES quality_standards(standard_id) ON DELETE SET NULL,
    FOREIGN KEY (model_id) REFERENCES ai_quality_models(model_id) ON DELETE SET NULL,
    FOREIGN KEY (detection_id) REFERENCES egg_detection_data(detection_id) ON DELETE SET NULL,
    
    INDEX idx_egg_code (egg_code),
    INDEX idx_quality (quality),
    INDEX idx_scanned_at (scanned_at),
    INDEX idx_cam_controller (cam_device_id, controller_device_id),
    INDEX idx_batch_quality (batch_id, quality),
    INDEX idx_date_quality (DATE(scanned_at), quality),
    INDEX idx_ai_confidence (ai_confidence),
    INDEX idx_detection_link (detection_id)
);

-- =====================================================
-- EGG SORTING ACTIONS TABLE (ESP32 DevKit V1 Sorting Commands)
-- =====================================================
CREATE TABLE egg_sorting_actions (
    action_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    controller_device_id INT NOT NULL, -- ESP32 DevKit V1 that executed the action
    conveyor_id INT NOT NULL,
    scan_id BIGINT, -- Link to AI scan that triggered this action
    detection_id BIGINT, -- Link to detection data
    batch_id INT,
    egg_sequence_number INT,
    sorting_decision ENUM('sort_left', 'sort_right', 'no_action') NOT NULL,
    sorting_reason ENUM('ai_bad_quality', 'ai_good_quality', 'manual_override', 'system_default') NOT NULL,
    ai_quality_result ENUM('good', 'bad', 'uncertain') NULL,
    ai_confidence DECIMAL(5,4),
    actuator_type ENUM('pneumatic', 'servo', 'mechanical') NOT NULL,
    actuator_response_time_ms INT, -- Time taken for actuator to respond
    action_success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (controller_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (scan_id) REFERENCES egg_ai_scans(scan_id) ON DELETE SET NULL,
    FOREIGN KEY (detection_id) REFERENCES egg_detection_data(detection_id) ON DELETE SET NULL,
    FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id) ON DELETE SET NULL,
    
    INDEX idx_controller_conveyor (controller_device_id, conveyor_id),
    INDEX idx_executed_at (executed_at),
    INDEX idx_sorting_decision (sorting_decision),
    INDEX idx_batch_sequence (batch_id, egg_sequence_number),
    INDEX idx_scan_link (scan_id),
    INDEX idx_detection_link (detection_id)
);

-- =====================================================
-- ESP32 COMMUNICATION LOGS TABLE (Inter-device communication)
-- =====================================================
CREATE TABLE esp32_communication_logs (
    comm_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_device_id INT NOT NULL, -- Device that sent the message
    receiver_device_id INT NOT NULL, -- Device that received the message
    message_type ENUM('ai_result', 'sensor_data', 'control_command', 'heartbeat', 'error_report') NOT NULL,
    message_content JSON NOT NULL,
    transmission_method ENUM('wifi_direct', 'mqtt', 'http_api', 'serial') NOT NULL,
    message_size_bytes INT,
    transmission_time_ms INT,
    success BOOLEAN DEFAULT TRUE,
    error_code VARCHAR(20),
    error_message TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    received_at TIMESTAMP NULL,
    acknowledged_at TIMESTAMP NULL,
    
    FOREIGN KEY (sender_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    
    INDEX idx_sender_receiver (sender_device_id, receiver_device_id),
    INDEX idx_message_type (message_type),
    INDEX idx_sent_at (sent_at),
    INDEX idx_success (success)
);

-- =====================================================
-- ESP32 SENSORS TABLE
-- =====================================================
CREATE TABLE esp32_sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT NOT NULL,
    sensor_name VARCHAR(100) NOT NULL,
    sensor_type ENUM('hc_sr04', 'camera', 'temperature', 'humidity', 'light', 'voltage', 'current', 'memory', 'actuator') NOT NULL,
    gpio_pin VARCHAR(20), -- GPIO pin number (e.g., "GPIO2,GPIO4" for HC-SR04)
    unit VARCHAR(20),
    min_value DECIMAL(10,4),
    max_value DECIMAL(10,4),
    calibration_offset DECIMAL(10,4) DEFAULT 0.0000,
    sampling_rate_hz DECIMAL(6,2) DEFAULT 1.00, -- Sampling frequency
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    
    INDEX idx_device_sensor (device_id, sensor_type),
    INDEX idx_sensor_type (sensor_type),
    INDEX idx_active (is_active),
    INDEX idx_gpio_pin (gpio_pin)
);

-- =====================================================
-- SENSOR DATA TABLE (Time-series data from ESP32)
-- =====================================================
CREATE TABLE sensor_data (
    data_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    device_id INT NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    raw_value DECIMAL(10,4), -- Raw sensor reading before calibration
    status ENUM('normal', 'warning', 'critical', 'error') DEFAULT 'normal',
    quality_flag ENUM('good', 'questionable', 'bad') DEFAULT 'good',
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sensor_id) REFERENCES esp32_sensors(sensor_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    
    INDEX idx_sensor_recorded (sensor_id, recorded_at),
    INDEX idx_device_recorded (device_id, recorded_at),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_status (status)
) PARTITION BY RANGE (UNIX_TIMESTAMP(recorded_at)) (
    PARTITION p_2024 VALUES LESS THAN (UNIX_TIMESTAMP('2025-01-01')),
    PARTITION p_2025 VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =====================================================
-- ESP32 DEVICE LOGS TABLE
-- =====================================================
CREATE TABLE esp32_device_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    device_id INT NOT NULL,
    log_level ENUM('debug', 'info', 'warning', 'error', 'critical') NOT NULL,
    log_source ENUM('system', 'wifi', 'camera', 'sensor', 'ai_model', 'actuator', 'communication', 'memory', 'storage') NOT NULL,
    message TEXT NOT NULL,
    error_code VARCHAR(20),
    metadata JSON,
    memory_usage_kb INT,
    free_heap_kb INT,
    cpu_usage_percent DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    
    INDEX idx_device_level (device_id, log_level),
    INDEX idx_created_at (created_at),
    INDEX idx_log_source (log_source),
    INDEX idx_error_code (error_code)
);

-- =====================================================
-- CONVEYOR LOGS TABLE
-- =====================================================
CREATE TABLE conveyor_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conveyor_id INT NOT NULL,
    user_id INT,
    device_id INT,
    action_type ENUM('start', 'stop', 'pause', 'resume', 'speed_change', 'maintenance', 'error', 'reset', 'calibration', 'sorting_mode_change') NOT NULL,
    message TEXT NOT NULL,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,
    
    INDEX idx_conveyor_action (conveyor_id, action_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    INDEX idx_device_id (device_id)
);

-- =====================================================
-- ALERTS TABLE
-- =====================================================
CREATE TABLE alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    conveyor_id INT,
    alert_type ENUM('device_offline', 'sensor_anomaly', 'quality_drop', 'maintenance_due', 'system_error', 'ai_model_error', 'detection_mismatch', 'sorting_failure', 'communication_error', 'wifi_weak') NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    metadata JSON,
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    status ENUM('active', 'acknowledged', 'resolved', 'dismissed') DEFAULT 'active',
    resolved_by INT,
    
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (resolved_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_status_severity (status, severity),
    INDEX idx_triggered_at (triggered_at),
    INDEX idx_alert_type (alert_type),
    INDEX idx_device_conveyor (device_id, conveyor_id)
);

-- =====================================================
-- MAINTENANCE LOGS TABLE
-- =====================================================
CREATE TABLE maintenance_logs (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    conveyor_id INT NOT NULL,
    device_id INT,
    user_id INT,
    maintenance_type ENUM('preventive', 'corrective', 'emergency', 'inspection', 'calibration', 'firmware_update', 'actuator_service') NOT NULL,
    description TEXT NOT NULL,
    actions_taken TEXT,
    cost DECIMAL(10,2),
    scheduled_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    status ENUM('scheduled', 'in_progress', 'completed', 'cancelled') DEFAULT 'scheduled',
    next_maintenance_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conveyor_id) REFERENCES conveyor_systems(conveyor_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    
    INDEX idx_conveyor_status (conveyor_id, status),
    INDEX idx_device_status (device_id, status),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_maintenance_type (maintenance_type)
);

-- =====================================================
-- USER SESSIONS TABLE
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
-- NOTIFICATIONS TABLE
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
-- REPORTS TABLE
-- =====================================================
CREATE TABLE reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_name VARCHAR(200) NOT NULL,
    report_type ENUM('egg_quality', 'conveyor_performance', 'production_statistics', 'activity_history', 'ai_performance', 'device_health', 'sorting_efficiency') NOT NULL,
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
-- SYSTEM SETTINGS TABLE
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
-- API TOKENS TABLE (for ESP32 device authentication)
-- =====================================================
CREATE TABLE api_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    user_id INT,
    token_name VARCHAR(100) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    permissions JSON,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_token_hash (token_hash),
    INDEX idx_device_active (device_id, is_active),
    INDEX idx_expires_at (expires_at)
);

-- =====================================================
-- AUDIT LOGS TABLE (for security and compliance)
-- =====================================================
CREATE TABLE audit_logs (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    device_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,
    
    INDEX idx_user_action (user_id, action),
    INDEX idx_device_action (device_id, action),
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- INSERT DEFAULT DATA
-- =====================================================

-- Default superadmin user (password: superadmin123)
INSERT INTO users (name, email, password_hash, role, is_active) VALUES 
('Super Administrator', 'superadmin@smarternak.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'superadmin', TRUE);

-- Default admin user (password: admin123)
INSERT INTO users (name, email, password_hash, role, is_active, created_by) VALUES 
('Administrator', 'admin@smarternak.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', TRUE, 1);

-- Default AI quality model
INSERT INTO ai_quality_models (model_name, model_version, model_type, accuracy_percentage, confidence_threshold, model_file_path) VALUES 
('Egg Quality Classifier v1.0', '1.0.0', 'tensorflow_lite', 92.50, 0.80, '/models/egg_quality_v1.tflite');

-- Default quality standards
INSERT INTO quality_standards (standard_name, min_weight, max_weight, min_length, max_length, min_width, max_width, min_height, max_height, ai_confidence_threshold, criteria_description) VALUES 
('Standard Grade A', 50.00, 70.00, 5.50, 6.50, 4.00, 5.00, 4.00, 5.00, 0.85, 'Premium quality eggs for retail market - High AI confidence required'),
('Standard Grade B', 45.00, 65.00, 5.00, 6.00, 3.50, 4.50, 3.50, 4.50, 0.75, 'Good quality eggs for commercial use - Medium AI confidence'),
('Standard Grade C', 40.00, 60.00, 4.50, 5.50, 3.00, 4.00, 3.00, 4.00, 0.65, 'Basic quality eggs for processing - Lower AI confidence acceptable');

-- Default system settings
INSERT INTO system_settings (setting_key, setting_value, description, data_type, is_public) VALUES 
('app_name', 'Smarternak ESP32 Dual Controller', 'Application name', 'string', TRUE),
('app_version', '1.0.0', 'Application version', 'string', TRUE),
('max_file_upload_size', '10485760', 'Maximum file upload size in bytes (10MB)', 'integer', FALSE),
('session_timeout', '3600', 'Session timeout in seconds (1 hour)', 'integer', FALSE),
('notification_email_enabled', 'true', 'Enable email notifications', 'boolean', FALSE),
('esp32_heartbeat_interval', '30', 'ESP32 heartbeat interval in seconds', 'integer', FALSE),
('hc_sr04_trigger_distance', '15', 'HC-SR04 trigger distance in cm', 'integer', FALSE),
('ai_confidence_threshold', '0.75', 'Default AI confidence threshold', 'float', FALSE),
('image_capture_quality', '85', 'JPEG image quality (1-100)', 'integer', FALSE),
('sorting_delay_ms', '500', 'Delay between AI result and sorting action in milliseconds', 'integer', FALSE),
('communication_timeout_ms', '2000', 'Communication timeout between ESP32 devices in milliseconds', 'integer', FALSE),('backup_retention_days', '30', 'Number of days to retain backups', 'integer', FALSE),('api_rate_limit_default', '1000', 'Default API rate limit per hour', 'integer', FALSE),('api_rate_limit_esp32', '5000', 'ESP32 device API rate limit per hour', 'integer', FALSE),('dashboard_cache_ttl', '300', 'Dashboard cache TTL in seconds (5 minutes)', 'integer', FALSE),('polling_interval_active', '2000', 'Frontend polling interval when conveyor active (ms)', 'integer', TRUE),('polling_interval_inactive', '10000', 'Frontend polling interval when conveyor inactive (ms)', 'integer', TRUE),('max_file_upload_size_mb', '10', 'Maximum file upload size in MB', 'integer', FALSE),('api_request_log_retention_days', '7', 'API request logs retention in days', 'integer', FALSE),('enable_api_rate_limiting', 'true', 'Enable API rate limiting', 'boolean', FALSE),('enable_request_logging', 'true', 'Enable API request logging', 'boolean', FALSE);

-- Default conveyor system
INSERT INTO conveyor_systems (conveyor_name, location, capacity, belt_length_cm, sorting_mechanism, left_path_destination, right_path_destination, status) VALUES 
('Main Conveyor Line 1', 'Production Floor A', 1500, 300.00, 'pneumatic', 'Bad Eggs Collection Bin', 'Good Eggs Collection Bin', 'inactive');

-- =====================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =====================================================

-- Daily production summary view with detection vs scanning vs sorting comparison
CREATE VIEW daily_production_summary AS
SELECT 
    DATE(edd.detected_at) as production_date,
    pb.batch_code,
    pb.total_eggs_detected,
    pb.total_eggs_scanned,
    pb.good_eggs_sorted,
    pb.bad_eggs_sorted,
    pb.unscanned_eggs,
    pb.scan_coverage_percentage,
    pb.sorting_accuracy,
    COUNT(DISTINCT edd.detection_id) as detected_eggs,
    COUNT(DISTINCT eas.scan_id) as scanned_eggs,
    COUNT(DISTINCT esa.action_id) as sorted_eggs,
    SUM(CASE WHEN eas.quality = 'good' THEN 1 ELSE 0 END) as ai_good_eggs,
    SUM(CASE WHEN eas.quality = 'bad' THEN 1 ELSE 0 END) as ai_bad_eggs,
    SUM(CASE WHEN eas.quality = 'uncertain' THEN 1 ELSE 0 END) as ai_uncertain_eggs,
    ROUND(AVG(eas.ai_confidence), 4) as avg_ai_confidence,
    ROUND((SUM(CASE WHEN eas.quality = 'good' THEN 1 ELSE 0 END) / COUNT(eas.scan_id)) * 100, 2) as ai_good_percentage
FROM egg_detection_data edd
LEFT JOIN production_batches pb ON edd.batch_id = pb.batch_id
LEFT JOIN egg_ai_scans eas ON edd.detection_id = eas.detection_id
LEFT JOIN egg_sorting_actions esa ON edd.detection_id = esa.detection_id
GROUP BY DATE(edd.detected_at), pb.batch_code
ORDER BY production_date DESC;

-- ESP32 device status overview with communication health
CREATE VIEW esp32_device_status_overview AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.status,
    d.last_ping,
    d.last_heartbeat,
    d.signal_strength,
    d.firmware_version,
    d.ai_model_version,
    d.controller_mode,
    d.uptime_seconds,
    d.error_count,
    CASE 
        WHEN d.last_heartbeat > DATE_SUB(NOW(), INTERVAL 2 MINUTE) THEN 'online'
        WHEN d.last_heartbeat > DATE_SUB(NOW(), INTERVAL 10 MINUTE) THEN 'warning'
        ELSE 'offline'
    END as connection_status,
    COUNT(DISTINCT eas.scan_id) as scans_today,
    COUNT(DISTINCT edd.detection_id) as detections_today,
    COUNT(DISTINCT esa.action_id) as sorting_actions_today,
    COUNT(DISTINCT ecl.comm_id) as communications_today
FROM esp32_devices d
LEFT JOIN egg_ai_scans eas ON d.device_id = eas.cam_device_id AND DATE(eas.scanned_at) = CURDATE()
LEFT JOIN egg_detection_data edd ON d.device_id = edd.controller_device_id AND DATE(edd.detected_at) = CURDATE()
LEFT JOIN egg_sorting_actions esa ON d.device_id = esa.controller_device_id AND DATE(esa.executed_at) = CURDATE()
LEFT JOIN esp32_communication_logs ecl ON (d.device_id = ecl.sender_device_id OR d.device_id = ecl.receiver_device_id) AND DATE(ecl.sent_at) = CURDATE()
WHERE d.is_active = TRUE
GROUP BY d.device_id;

-- Active alerts view with ESP32 dual controller specific alerts
CREATE VIEW active_alerts_summary AS
SELECT 
    alert_type,
    severity,
    COUNT(*) as alert_count,
    MIN(triggered_at) as oldest_alert,
    MAX(triggered_at) as newest_alert
FROM alerts 
WHERE status = 'active'
GROUP BY alert_type, severity
ORDER BY 
    FIELD(severity, 'critical', 'high', 'medium', 'low'),
    alert_count DESC;

-- AI Performance and Sorting Efficiency metrics view
CREATE VIEW ai_sorting_performance_metrics AS
SELECT 
    DATE(eas.scanned_at) as scan_date,
    eas.model_id,
    aqm.model_name,
    aqm.model_version,
    COUNT(DISTINCT eas.scan_id) as total_scans,
    AVG(eas.ai_confidence) as avg_ai_confidence,
    AVG(eas.ai_prediction_time_ms) as avg_prediction_time_ms,
    AVG(eas.communication_latency_ms) as avg_communication_latency_ms,
    SUM(CASE WHEN eas.quality = 'uncertain' THEN 1 ELSE 0 END) as uncertain_predictions,
    COUNT(DISTINCT esa.action_id) as total_sorting_actions,
    SUM(CASE WHEN esa.action_success = TRUE THEN 1 ELSE 0 END) as successful_sorting_actions,
    AVG(esa.actuator_response_time_ms) as avg_actuator_response_time_ms,
    ROUND((SUM(CASE WHEN eas.quality = 'uncertain' THEN 1 ELSE 0 END) / COUNT(eas.scan_id)) * 100, 2) as uncertainty_rate,
    ROUND((SUM(CASE WHEN esa.action_success = TRUE THEN 1 ELSE 0 END) / COUNT(esa.action_id)) * 100, 2) as sorting_success_rate
FROM egg_ai_scans eas
JOIN ai_quality_models aqm ON eas.model_id = aqm.model_id
LEFT JOIN egg_sorting_actions esa ON eas.scan_id = esa.scan_id
GROUP BY DATE(eas.scanned_at), eas.model_id
ORDER BY scan_date DESC;

-- Communication health between ESP32 devices
CREATE VIEW esp32_communication_health AS
SELECT 
    DATE(ecl.sent_at) as communication_date,
    sd.device_name as sender_device,
    rd.device_name as receiver_device,
    ecl.message_type,
    COUNT(*) as total_messages,
    SUM(CASE WHEN ecl.success = TRUE THEN 1 ELSE 0 END) as successful_messages,
    AVG(ecl.transmission_time_ms) as avg_transmission_time_ms,
    ROUND((SUM(CASE WHEN ecl.success = TRUE THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as success_rate
FROM esp32_communication_logs ecl
JOIN esp32_devices sd ON ecl.sender_device_id = sd.device_id
JOIN esp32_devices rd ON ecl.receiver_device_id = rd.device_id
GROUP BY DATE(ecl.sent_at), ecl.sender_device_id, ecl.receiver_device_id, ecl.message_type
ORDER BY communication_date DESC;

-- =====================================================
-- CREATE STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure to calculate daily statistics with detection, scanning, and sorting data
CREATE PROCEDURE CalculateDailyStatsWithSorting(IN target_date DATE)
BEGIN
    DECLARE total_detected INT DEFAULT 0;
    DECLARE total_scanned INT DEFAULT 0;
    DECLARE good_count INT DEFAULT 0;
    DECLARE bad_count INT DEFAULT 0;
    DECLARE uncertain_count INT DEFAULT 0;
    DECLARE good_sorted INT DEFAULT 0;
    DECLARE bad_sorted INT DEFAULT 0;
    DECLARE batch_code_val VARCHAR(50);
    
    -- Generate batch code
    SET batch_code_val = CONCAT('BATCH-', DATE_FORMAT(target_date, '%Y%m%d'));
    
    -- Get detection data (HC-SR04 via ESP32 DevKit V1)
    SELECT COUNT(*) INTO total_detected
    FROM egg_detection_data 
    WHERE DATE(detected_at) = target_date;
    
    -- Get AI scanning data (ESP32-CAM)
    SELECT 
        COUNT(*),
        SUM(CASE WHEN quality = 'good' THEN 1 ELSE 0 END),
        SUM(CASE WHEN quality = 'bad' THEN 1 ELSE 0 END),
        SUM(CASE WHEN quality = 'uncertain' THEN 1 ELSE 0 END)
    INTO total_scanned, good_count, bad_count, uncertain_count
    FROM egg_ai_scans 
    WHERE DATE(scanned_at) = target_date;
    
    -- Get sorting action data (ESP32 DevKit V1)
    SELECT 
        SUM(CASE WHEN sorting_decision = 'sort_right' AND action_success = TRUE THEN 1 ELSE 0 END),
        SUM(CASE WHEN sorting_decision = 'sort_left' AND action_success = TRUE THEN 1 ELSE 0 END)
    INTO good_sorted, bad_sorted
    FROM egg_sorting_actions 
    WHERE DATE(executed_at) = target_date;
    
    -- Insert or update batch record
    INSERT INTO production_batches (
        batch_code, production_date, total_eggs_detected, total_eggs_scanned, 
        good_eggs_sorted, bad_eggs_sorted, unscanned_eggs, good_percentage, 
        scan_coverage_percentage, sorting_accuracy
    )
    VALUES (
        batch_code_val, target_date, total_detected, total_scanned, 
        good_sorted, bad_sorted, (total_detected - total_scanned),
        CASE WHEN total_scanned > 0 THEN (good_count / total_scanned) * 100 ELSE 0 END,
        CASE WHEN total_detected > 0 THEN (total_scanned / total_detected) * 100 ELSE 0 END,
        CASE WHEN total_scanned > 0 THEN ((good_sorted + bad_sorted) / total_scanned) * 100 ELSE 0 END
    )
    ON DUPLICATE KEY UPDATE
        total_eggs_detected = total_detected,
        total_eggs_scanned = total_scanned,
        good_eggs_sorted = good_sorted,
        bad_eggs_sorted = bad_sorted,
        unscanned_eggs = (total_detected - total_scanned),
        good_percentage = CASE WHEN total_scanned > 0 THEN (good_count / total_scanned) * 100 ELSE 0 END,
        scan_coverage_percentage = CASE WHEN total_detected > 0 THEN (total_scanned / total_detected) * 100 ELSE 0 END,
        sorting_accuracy = CASE WHEN total_scanned > 0 THEN ((good_sorted + bad_sorted) / total_scanned) * 100 ELSE 0 END,
        updated_at = CURRENT_TIMESTAMP;
        
    -- Update all related tables with batch_id
    UPDATE egg_detection_data edd
    JOIN production_batches pb ON pb.batch_code = batch_code_val
    SET edd.batch_id = pb.batch_id
    WHERE DATE(edd.detected_at) = target_date AND edd.batch_id IS NULL;
    
    UPDATE egg_ai_scans eas
    JOIN production_batches pb ON pb.batch_code = batch_code_val
    SET eas.batch_id = pb.batch_id
    WHERE DATE(eas.scanned_at) = target_date AND eas.batch_id IS NULL;
    
    UPDATE egg_sorting_actions esa
    JOIN production_batches pb ON pb.batch_code = batch_code_val
    SET esa.batch_id = pb.batch_id
    WHERE DATE(esa.executed_at) = target_date AND esa.batch_id IS NULL;
    
END //

-- Procedure to clean old data
CREATE PROCEDURE CleanOldData()
BEGIN
    -- Delete old sensor data (older than 1 year)
    DELETE FROM sensor_data WHERE recorded_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    -- Delete old ESP32 device logs (older than 3 months)
    DELETE FROM esp32_device_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH);
    
    -- Delete old communication logs (older than 1 month)
    DELETE FROM esp32_communication_logs WHERE sent_at < DATE_SUB(NOW(), INTERVAL 1 MONTH);
    
    -- Delete old audit logs (older than 6 months)
    DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);
    
    -- Delete expired sessions
    DELETE FROM user_sessions WHERE expires_at < NOW();
    
    -- Delete expired reports
    DELETE FROM reports WHERE expires_at < NOW();
    
    -- Archive old notifications (older than 3 months)
    UPDATE notifications 
    SET status = 'archived' 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH) AND status != 'archived';
    
END //

-- Procedure to check ESP32 device health and communication
CREATE PROCEDURE CheckESP32SystemHealth()
BEGIN
    -- Check for offline devices
    INSERT INTO alerts (device_id, alert_type, severity, title, message, metadata)
    SELECT 
        device_id,
        'device_offline',
        'high',
        CONCAT('ESP32 Device Offline: ', device_name),
        CONCAT('Device has not sent heartbeat for more than 10 minutes'),
        JSON_OBJECT('last_heartbeat', last_heartbeat, 'device_type', device_type)
    FROM esp32_devices 
    WHERE is_active = TRUE 
    AND (last_heartbeat < DATE_SUB(NOW(), INTERVAL 10 MINUTE) OR last_heartbeat IS NULL)
    AND device_id NOT IN (
        SELECT device_id FROM alerts 
        WHERE alert_type = 'device_offline' AND status = 'active' AND device_id IS NOT NULL
    );
    
    -- Check for communication failures between ESP32-CAM and ESP32 DevKit V1
    INSERT INTO alerts (alert_type, severity, title, message, metadata)
    SELECT 
        'communication_error',
        'high',
        'ESP32 Inter-device Communication Failure',
        'High failure rate in communication between ESP32-CAM and ESP32 DevKit V1',
        JSON_OBJECT('failure_rate', failure_rate, 'total_attempts', total_attempts)
    FROM (
        SELECT 
            ROUND((SUM(CASE WHEN success = FALSE THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as failure_rate,
            COUNT(*) as total_attempts
        FROM esp32_communication_logs 
        WHERE sent_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        AND message_type = 'ai_result'
    ) comm_stats
    WHERE failure_rate > 20 AND total_attempts > 10
    AND NOT EXISTS (
        SELECT 1 FROM alerts 
        WHERE alert_type = 'communication_error' AND status = 'active'
    );
    
    -- Check for sorting mechanism failures
    INSERT INTO alerts (conveyor_id, alert_type, severity, title, message, metadata)
    SELECT 
        conveyor_id,
        'sorting_failure',
        'medium',
        'Sorting Mechanism Failure Rate High',
        CONCAT('Sorting failure rate is ', failure_rate, '% in the last hour'),
        JSON_OBJECT('failure_rate', failure_rate, 'total_actions', total_actions)
    FROM (
        SELECT 
            conveyor_id,
            ROUND((SUM(CASE WHEN action_success = FALSE THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as failure_rate,
            COUNT(*) as total_actions
        FROM egg_sorting_actions 
        WHERE executed_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        GROUP BY conveyor_id
    ) sorting_stats
    WHERE failure_rate > 15 AND total_actions > 20
    AND conveyor_id NOT IN (
        SELECT conveyor_id FROM alerts 
        WHERE alert_type = 'sorting_failure' AND status = 'active' AND conveyor_id IS NOT NULL
    );
    
END //

DELIMITER ;

-- =====================================================
-- CREATE TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger to update batch statistics when detection data is inserted
CREATE TRIGGER update_batch_stats_after_detection_insert
AFTER INSERT ON egg_detection_data
FOR EACH ROW
BEGIN
    CALL CalculateDailyStatsWithSorting(DATE(NEW.detected_at));
END //

-- Trigger to update batch statistics when AI scan is inserted
CREATE TRIGGER update_batch_stats_after_ai_scan_insert
AFTER INSERT ON egg_ai_scans
FOR EACH ROW
BEGIN
    CALL CalculateDailyStatsWithSorting(DATE(NEW.scanned_at));
END //

-- Trigger to update batch statistics when sorting action is inserted
CREATE TRIGGER update_batch_stats_after_sorting_insert
AFTER INSERT ON egg_sorting_actions
FOR EACH ROW
BEGIN
    CALL CalculateDailyStatsWithSorting(DATE(NEW.executed_at));
END //

-- Trigger to log ESP32 device status changes
CREATE TRIGGER log_esp32_status_change
AFTER UPDATE ON esp32_devices
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO esp32_device_logs (device_id, log_level, log_source, message, metadata)
        VALUES (NEW.device_id, 'info', 'system', 
               CONCAT('Device status changed from ', OLD.status, ' to ', NEW.status),
               JSON_OBJECT('old_status', OLD.status, 'new_status', NEW.status, 'timestamp', NOW()));
    END IF;
    
    IF OLD.controller_mode != NEW.controller_mode AND NEW.device_type = 'esp32_devkit_controller' THEN
        INSERT INTO esp32_device_logs (device_id, log_level, log_source, message, metadata)
        VALUES (NEW.device_id, 'info', 'system', 
               CONCAT('Controller mode changed from ', OLD.controller_mode, ' to ', NEW.controller_mode),
               JSON_OBJECT('old_mode', OLD.controller_mode, 'new_mode', NEW.controller_mode, 'timestamp', NOW()));
    END IF;
END //

-- Trigger to create alert for quality drops and sorting issues
CREATE TRIGGER check_quality_and_sorting_issues
AFTER INSERT ON egg_ai_scans
FOR EACH ROW
BEGIN
    DECLARE recent_bad_count INT DEFAULT 0;
    DECLARE recent_total_count INT DEFAULT 0;
    DECLARE bad_percentage DECIMAL(5,2) DEFAULT 0;
    DECLARE low_confidence_count INT DEFAULT 0;
    
    -- Check last 100 scans for quality drop
    SELECT 
        COUNT(*),
        SUM(CASE WHEN quality = 'bad' THEN 1 ELSE 0 END),
        SUM(CASE WHEN ai_confidence < 0.7 THEN 1 ELSE 0 END)
    INTO recent_total_count, recent_bad_count, low_confidence_count
    FROM (
        SELECT quality, ai_confidence FROM egg_ai_scans 
        WHERE conveyor_id = NEW.conveyor_id 
        ORDER BY scanned_at DESC 
        LIMIT 100
    ) recent_scans;
    
    IF recent_total_count >= 50 THEN
        SET bad_percentage = (recent_bad_count / recent_total_count) * 100;
        
        -- Alert for high bad egg percentage
        IF bad_percentage > 20 THEN
            INSERT INTO alerts (conveyor_id, device_id, alert_type, severity, title, message, metadata)
            VALUES (NEW.conveyor_id, NEW.cam_device_id, 'quality_drop', 'high', 
                   'Quality Drop Detected',
                   CONCAT('Bad egg percentage has reached ', bad_percentage, '% in recent scans'),
                   JSON_OBJECT('bad_percentage', bad_percentage, 'sample_size', recent_total_count));
        END IF;
        
        -- Alert for low AI confidence
        IF low_confidence_count > 25 THEN
            INSERT INTO alerts (conveyor_id, device_id, alert_type, severity, title, message, metadata)
            VALUES (NEW.conveyor_id, NEW.cam_device_id, 'ai_model_error', 'medium', 
                   'Low AI Confidence Detected',
                   CONCAT('AI model showing low confidence in ', low_confidence_count, ' out of ', recent_total_count, ' recent scans'),
                   JSON_OBJECT('low_confidence_count', low_confidence_count, 'sample_size', recent_total_count));
        END IF;
    END IF;
END //

-- Trigger to check detection vs scanning mismatch
CREATE TRIGGER check_detection_scanning_mismatch
AFTER INSERT ON egg_detection_data
FOR EACH ROW
BEGIN
    DECLARE detected_today INT DEFAULT 0;
    DECLARE scanned_today INT DEFAULT 0;
    DECLARE mismatch_percentage DECIMAL(5,2) DEFAULT 0;
    
    -- Get today's counts
    SELECT COUNT(*) INTO detected_today
    FROM egg_detection_data 
    WHERE DATE(detected_at) = DATE(NEW.detected_at) AND conveyor_id = NEW.conveyor_id;
    
    SELECT COUNT(*) INTO scanned_today
    FROM egg_ai_scans 
    WHERE DATE(scanned_at) = DATE(NEW.detected_at) AND conveyor_id = NEW.conveyor_id;
    
    -- Check for significant mismatch (only if we have enough data)
    IF detected_today > 50 AND scanned_today > 0 THEN
        SET mismatch_percentage = ABS(detected_today - scanned_today) / detected_today * 100;
        
        IF mismatch_percentage > 15 THEN
            INSERT INTO alerts (conveyor_id, alert_type, severity, title, message, metadata)
            VALUES (NEW.conveyor_id, 'detection_mismatch', 'medium', 
                   'Detection vs Scanning Mismatch',
                   CONCAT('Significant difference between detected (', detected_today, ') and scanned (', scanned_today, ') eggs'),
                   JSON_OBJECT('detected_today', detected_today, 'scanned_today', scanned_today, 'mismatch_percentage', mismatch_percentage));
        END IF;
    END IF;
END //

-- Trigger to log communication between ESP32 devices
CREATE TRIGGER log_esp32_communication_success
AFTER UPDATE ON esp32_communication_logs
FOR EACH ROW
BEGIN
    IF OLD.success IS NULL AND NEW.success = FALSE THEN
                INSERT INTO esp32_device_logs (device_id, log_level, log_source, message, metadata)        VALUES (NEW.sender_device_id, 'error', 'communication',                CONCAT('Communication failed to device ', NEW.receiver_device_id, ': ', NEW.error_message),               JSON_OBJECT('receiver_device_id', NEW.receiver_device_id, 'message_type', NEW.message_type, 'error_code', NEW.error_code));    END IF;END //-- Procedure to update dashboard cache untuk REST API pollingCREATE PROCEDURE UpdateDashboardCache()BEGIN    DECLARE current_hour TINYINT DEFAULT HOUR(NOW());    DECLARE current_date DATE DEFAULT CURDATE();    DECLARE detected_count INT DEFAULT 0;    DECLARE scanned_count INT DEFAULT 0;    DECLARE good_count INT DEFAULT 0;    DECLARE bad_count INT DEFAULT 0;    DECLARE uncertain_count INT DEFAULT 0;    DECLARE avg_confidence DECIMAL(5,4) DEFAULT 0.0000;    DECLARE devices_online_count INT DEFAULT 0;    DECLARE alerts_count INT DEFAULT 0;    DECLARE last_scan TIMESTAMP DEFAULT NULL;    DECLARE sorting_success DECIMAL(5,2) DEFAULT 0.00;        -- Get detection data for current date    SELECT COUNT(*) INTO detected_count    FROM egg_detection_data     WHERE DATE(detected_at) = current_date;        -- Get AI scanning data for current date    SELECT         COUNT(*),        SUM(CASE WHEN quality = 'good' THEN 1 ELSE 0 END),        SUM(CASE WHEN quality = 'bad' THEN 1 ELSE 0 END),        SUM(CASE WHEN quality = 'uncertain' THEN 1 ELSE 0 END),        AVG(ai_confidence),        MAX(scanned_at)    INTO scanned_count, good_count, bad_count, uncertain_count, avg_confidence, last_scan    FROM egg_ai_scans     WHERE DATE(scanned_at) = current_date;        -- Get devices online count    SELECT COUNT(*) INTO devices_online_count    FROM esp32_devices     WHERE status = 'online' AND is_active = TRUE;        -- Get active alerts count    SELECT COUNT(*) INTO alerts_count    FROM alerts     WHERE status = 'active';        -- Get sorting success rate    SELECT         CASE WHEN COUNT(*) > 0         THEN ROUND((SUM(CASE WHEN action_success = TRUE THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2)        ELSE 0 END    INTO sorting_success    FROM egg_sorting_actions     WHERE DATE(executed_at) = current_date;        -- Insert or update cache    INSERT INTO dashboard_cache (        cache_date, cache_hour, total_eggs_detected, total_eggs_scanned,        good_eggs, bad_eggs, uncertain_eggs,         good_percentage, scan_coverage_percentage, avg_ai_confidence,        sorting_success_rate, devices_online, active_alerts, last_scan_time    )    VALUES (        current_date, current_hour, detected_count, scanned_count,        good_count, bad_count, uncertain_count,        CASE WHEN scanned_count > 0 THEN ROUND((good_count / scanned_count) * 100, 2) ELSE 0 END,        CASE WHEN detected_count > 0 THEN ROUND((scanned_count / detected_count) * 100, 2) ELSE 0 END,        COALESCE(avg_confidence, 0),        sorting_success, devices_online_count, alerts_count, last_scan    )    ON DUPLICATE KEY UPDATE        total_eggs_detected = detected_count,        total_eggs_scanned = scanned_count,        good_eggs = good_count,        bad_eggs = bad_count,        uncertain_eggs = uncertain_count,        good_percentage = CASE WHEN scanned_count > 0 THEN ROUND((good_count / scanned_count) * 100, 2) ELSE 0 END,        scan_coverage_percentage = CASE WHEN detected_count > 0 THEN ROUND((scanned_count / detected_count) * 100, 2) ELSE 0 END,        avg_ai_confidence = COALESCE(avg_confidence, 0),        sorting_success_rate = sorting_success,        devices_online = devices_online_count,        active_alerts = alerts_count,        last_scan_time = last_scan,        updated_at = CURRENT_TIMESTAMP;        END //-- Procedure untuk API rate limiting checkCREATE PROCEDURE CheckRateLimit(    IN p_identifier VARCHAR(255),    IN p_identifier_type ENUM('ip', 'device', 'user', 'api_key'),    IN p_endpoint VARCHAR(100),    IN p_max_requests INT,    IN p_window_seconds INT,    OUT p_allowed BOOLEAN,    OUT p_remaining_requests INT,    OUT p_reset_time TIMESTAMP)BEGIN    DECLARE current_count INT DEFAULT 0;    DECLARE window_start TIMESTAMP DEFAULT NOW();    DECLARE existing_window TIMESTAMP DEFAULT NULL;        -- Check existing rate limit entry    SELECT requests_count, window_start INTO current_count, existing_window    FROM api_rate_limits     WHERE identifier = p_identifier     AND identifier_type = p_identifier_type    AND endpoint = p_endpoint    AND window_start > DATE_SUB(NOW(), INTERVAL p_window_seconds SECOND)    ORDER BY window_start DESC    LIMIT 1;        -- If no existing window or window expired, create new one    IF existing_window IS NULL OR existing_window < DATE_SUB(NOW(), INTERVAL p_window_seconds SECOND) THEN        SET current_count = 0;        SET window_start = NOW();                INSERT INTO api_rate_limits (            identifier, identifier_type, endpoint, requests_count,             window_start, window_duration_seconds, max_requests        )        VALUES (            p_identifier, p_identifier_type, p_endpoint, 1,            window_start, p_window_seconds, p_max_requests        )        ON DUPLICATE KEY UPDATE            requests_count = 1,            window_start = window_start,            updated_at = CURRENT_TIMESTAMP;                    SET current_count = 1;    ELSE        -- Update existing window        UPDATE api_rate_limits         SET requests_count = requests_count + 1,            updated_at = CURRENT_TIMESTAMP        WHERE identifier = p_identifier         AND identifier_type = p_identifier_type        AND endpoint = p_endpoint        AND window_start = existing_window;                SET current_count = current_count + 1;        SET window_start = existing_window;    END IF;        -- Check if limit exceeded    IF current_count <= p_max_requests THEN        SET p_allowed = TRUE;        SET p_remaining_requests = p_max_requests - current_count;    ELSE        SET p_allowed = FALSE;        SET p_remaining_requests = 0;                -- Update blocked_until if needed        UPDATE api_rate_limits         SET blocked_until = DATE_ADD(window_start, INTERVAL p_window_seconds SECOND)        WHERE identifier = p_identifier         AND identifier_type = p_identifier_type        AND endpoint = p_endpoint        AND window_start = window_start;    END IF;        SET p_reset_time = DATE_ADD(window_start, INTERVAL p_window_seconds SECOND);    END //DELIMITER ;

-- =====================================================
-- CREATE EVENTS FOR AUTOMATED TASKS
-- =====================================================

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Daily statistics calculation
CREATE EVENT daily_stats_calculation_dual_esp32
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 23:59:00'
DO
  CALL CalculateDailyStatsWithSorting(CURDATE());

-- ESP32 system health check every 5 minutes
CREATE EVENT esp32_system_health_check
ON SCHEDULE EVERY 5 MINUTE
STARTS NOW()
DO
  CALL CheckESP32SystemHealth();

-- Weekly data cleanupCREATE EVENT weekly_cleanup_dual_esp32ON SCHEDULE EVERY 1 WEEKSTARTS '2024-01-01 02:00:00'DO  CALL CleanOldData();-- Dashboard cache update every hourCREATE EVENT update_dashboard_cache_hourlyON SCHEDULE EVERY 1 HOURSTARTS NOW()DO  CALL UpdateDashboardCache();-- API rate limit cleanup every hourCREATE EVENT cleanup_api_rate_limitsON SCHEDULE EVERY 1 HOURSTARTS NOW()DO  DELETE FROM api_rate_limits   WHERE window_start < DATE_SUB(NOW(), INTERVAL window_duration_seconds SECOND);

-- =====================================================
-- GRANT PERMISSIONS (Example for different user roles)
-- =====================================================

-- Create application userCREATE USER IF NOT EXISTS 'smarternak_app'@'%' IDENTIFIED BY 'secure_app_password_2024!';GRANT SELECT, INSERT, UPDATE, DELETE ON smarternak_db.* TO 'smarternak_app'@'%';GRANT EXECUTE ON PROCEDURE smarternak_db.UpdateDashboardCache TO 'smarternak_app'@'%';GRANT EXECUTE ON PROCEDURE smarternak_db.CheckRateLimit TO 'smarternak_app'@'%';

-- Create read-only user for reporting
CREATE USER IF NOT EXISTS 'smarternak_readonly'@'%' IDENTIFIED BY 'readonly_password_2024!';
GRANT SELECT ON smarternak_db.* TO 'smarternak_readonly'@'%';

-- Create ESP32-CAM user (AI scanner permissions)
CREATE USER IF NOT EXISTS 'smarternak_esp32_cam'@'%' IDENTIFIED BY 'esp32_cam_password_2024!';
GRANT SELECT, INSERT ON smarternak_db.egg_ai_scans TO 'smarternak_esp32_cam'@'%';
GRANT SELECT, INSERT ON smarternak_db.sensor_data TO 'smarternak_esp32_cam'@'%';
GRANT SELECT, INSERT ON smarternak_db.esp32_device_logs TO 'smarternak_esp32_cam'@'%';GRANT SELECT, INSERT ON smarternak_db.esp32_communication_logs TO 'smarternak_esp32_cam'@'%';GRANT SELECT, INSERT ON smarternak_db.uploaded_files TO 'smarternak_esp32_cam'@'%';
GRANT SELECT ON smarternak_db.esp32_devices TO 'smarternak_esp32_cam'@'%';
GRANT SELECT ON smarternak_db.quality_standards TO 'smarternak_esp32_cam'@'%';
GRANT SELECT ON smarternak_db.ai_quality_models TO 'smarternak_esp32_cam'@'%';
GRANT UPDATE (last_ping, last_heartbeat, status, signal_strength, uptime_seconds, error_count) ON smarternak_db.esp32_devices TO 'smarternak_esp32_cam'@'%';

-- Create ESP32 DevKit V1 user (controller permissions)
CREATE USER IF NOT EXISTS 'smarternak_esp32_controller'@'%' IDENTIFIED BY 'esp32_controller_password_2024!';
GRANT SELECT, INSERT ON smarternak_db.egg_detection_data TO 'smarternak_esp32_controller'@'%';
GRANT SELECT, INSERT ON smarternak_db.egg_sorting_actions TO 'smarternak_esp32_controller'@'%';
GRANT SELECT, INSERT ON smarternak_db.sensor_data TO 'smarternak_esp32_controller'@'%';
GRANT SELECT, INSERT ON smarternak_db.esp32_device_logs TO 'smarternak_esp32_controller'@'%';
GRANT SELECT, INSERT, UPDATE ON smarternak_db.esp32_communication_logs TO 'smarternak_esp32_controller'@'%';
GRANT SELECT ON smarternak_db.esp32_devices TO 'smarternak_esp32_controller'@'%';
GRANT SELECT ON smarternak_db.egg_ai_scans TO 'smarternak_esp32_controller'@'%';
GRANT SELECT ON smarternak_db.conveyor_systems TO 'smarternak_esp32_controller'@'%';
GRANT UPDATE (last_ping, last_heartbeat, status, signal_strength, uptime_seconds, error_count, controller_mode) ON smarternak_db.esp32_devices TO 'smarternak_esp32_controller'@'%';

FLUSH PRIVILEGES;

-- =====================================================-- INDEXES FOR PERFORMANCE OPTIMIZATION-- =====================================================-- Additional composite indexes for common queriesCREATE INDEX idx_egg_ai_scans_date_quality_conveyor ON egg_ai_scans (DATE(scanned_at), quality, conveyor_id);CREATE INDEX idx_egg_ai_scans_ai_confidence ON egg_ai_scans (ai_confidence, quality);CREATE INDEX idx_egg_detection_date_conveyor ON egg_detection_data (DATE(detected_at), conveyor_id);CREATE INDEX idx_egg_sorting_date_decision ON egg_sorting_actions (DATE(executed_at), sorting_decision);CREATE INDEX idx_sensor_data_sensor_date ON sensor_data (sensor_id, DATE(recorded_at));CREATE INDEX idx_alerts_status_severity_date ON alerts (status, severity, triggered_at);CREATE INDEX idx_esp32_logs_device_level_date ON esp32_device_logs (device_id, log_level, DATE(created_at));CREATE INDEX idx_communication_logs_devices_date ON esp32_communication_logs (sender_device_id, receiver_device_id, DATE(sent_at));-- =====================================================-- REST API OPTIMIZATION ADDITIONS-- =====================================================-- Dashboard Cache Table untuk Polling PerformanceCREATE TABLE dashboard_cache (    cache_id INT AUTO_INCREMENT PRIMARY KEY,    cache_date DATE NOT NULL,    cache_hour TINYINT NOT NULL DEFAULT 0, -- 0-23 untuk hourly cache    total_eggs_detected INT DEFAULT 0,    total_eggs_scanned INT DEFAULT 0,    good_eggs INT DEFAULT 0,    bad_eggs INT DEFAULT 0,    uncertain_eggs INT DEFAULT 0,    good_percentage DECIMAL(5,2) DEFAULT 0.00,    scan_coverage_percentage DECIMAL(5,2) DEFAULT 0.00,    avg_ai_confidence DECIMAL(5,4) DEFAULT 0.0000,    sorting_success_rate DECIMAL(5,2) DEFAULT 0.00,    devices_online INT DEFAULT 0,    active_alerts INT DEFAULT 0,    last_scan_time TIMESTAMP NULL,    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,        UNIQUE KEY unique_cache_entry (cache_date, cache_hour),    INDEX idx_cache_date_hour (cache_date, cache_hour),    INDEX idx_updated_at (updated_at));-- API Rate Limiting TableCREATE TABLE api_rate_limits (    limit_id INT AUTO_INCREMENT PRIMARY KEY,    identifier VARCHAR(255) NOT NULL, -- IP address, device_id, atau user_id    identifier_type ENUM('ip', 'device', 'user', 'api_key') NOT NULL,    endpoint VARCHAR(100) NOT NULL,    requests_count INT DEFAULT 0,    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    window_duration_seconds INT DEFAULT 3600, -- 1 hour default    max_requests INT DEFAULT 1000, -- Default limit    blocked_until TIMESTAMP NULL,    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,        UNIQUE KEY unique_rate_limit (identifier, endpoint, window_start),    INDEX idx_identifier_endpoint (identifier, endpoint),    INDEX idx_window_start (window_start),    INDEX idx_blocked_until (blocked_until));-- File Upload Tracking TableCREATE TABLE uploaded_files (    file_id INT AUTO_INCREMENT PRIMARY KEY,    user_id INT,    device_id INT,    original_filename VARCHAR(255) NOT NULL,    stored_filename VARCHAR(255) NOT NULL,    file_path VARCHAR(500) NOT NULL,    file_size INT NOT NULL,    mime_type VARCHAR(100) NOT NULL,    file_category ENUM('egg_image', 'report', 'firmware', 'model', 'log', 'other') DEFAULT 'other',    upload_source ENUM('web_ui', 'esp32_cam', 'esp32_controller', 'api') DEFAULT 'web_ui',    checksum VARCHAR(64), -- SHA-256 checksum    is_processed BOOLEAN DEFAULT FALSE,    processing_status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',    processing_result JSON,    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    processed_at TIMESTAMP NULL,    expires_at TIMESTAMP NULL,        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,        INDEX idx_user_category (user_id, file_category),    INDEX idx_device_source (device_id, upload_source),    INDEX idx_uploaded_at (uploaded_at),    INDEX idx_processing_status (processing_status),    INDEX idx_expires_at (expires_at),    INDEX idx_checksum (checksum));-- API Request Logs untuk Monitoring dan DebuggingCREATE TABLE api_request_logs (    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,    request_id VARCHAR(36) NOT NULL, -- UUID untuk tracking    user_id INT,    device_id INT,    api_key_id INT,    method ENUM('GET', 'POST', 'PUT', 'DELETE', 'PATCH') NOT NULL,    endpoint VARCHAR(255) NOT NULL,    request_ip VARCHAR(45) NOT NULL,    user_agent TEXT,    request_headers JSON,    request_body JSON,    response_status INT NOT NULL,    response_time_ms INT NOT NULL,    response_size_bytes INT,    error_message TEXT,    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,    FOREIGN KEY (device_id) REFERENCES esp32_devices(device_id) ON DELETE SET NULL,    FOREIGN KEY (api_key_id) REFERENCES api_tokens(token_id) ON DELETE SET NULL,        INDEX idx_request_id (request_id),    INDEX idx_endpoint_status (endpoint, response_status),    INDEX idx_created_at (created_at),    INDEX idx_user_endpoint (user_id, endpoint),    INDEX idx_device_endpoint (device_id, endpoint),    INDEX idx_response_time (response_time_ms)) PARTITION BY RANGE (UNIX_TIMESTAMP(created_at)) (    PARTITION p_2024 VALUES LESS THAN (UNIX_TIMESTAMP('2025-01-01')),    PARTITION p_2025 VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01')),    PARTITION p_future VALUES LESS THAN MAXVALUE);-- Additional Indexes untuk REST API PerformanceCREATE INDEX idx_egg_scans_today ON egg_ai_scans (DATE(scanned_at), quality);CREATE INDEX idx_devices_status_heartbeat ON esp32_devices (status, last_heartbeat);CREATE INDEX idx_alerts_active_severity ON alerts (status, severity) WHERE status = 'active';CREATE INDEX idx_conveyor_status_updated ON conveyor_systems (status, updated_at);CREATE INDEX idx_production_batches_date ON production_batches (production_date DESC);CREATE INDEX idx_sensor_data_recent ON sensor_data (device_id, recorded_at DESC);CREATE INDEX idx_user_sessions_active ON user_sessions (user_id, is_active, expires_at);-- =====================================================-- OPTIMIZED VIEWS FOR REST API POLLING-- =====================================================-- Quick Dashboard Summary ViewCREATE VIEW dashboard_quick_summary ASSELECT     CURDATE() as summary_date,    COALESCE(dc.total_eggs_detected, 0) as total_eggs_detected,    COALESCE(dc.total_eggs_scanned, 0) as total_eggs_scanned,    COALESCE(dc.good_eggs, 0) as good_eggs,    COALESCE(dc.bad_eggs, 0) as bad_eggs,    COALESCE(dc.good_percentage, 0) as good_percentage,    COALESCE(dc.scan_coverage_percentage, 0) as scan_coverage_percentage,    COALESCE(dc.avg_ai_confidence, 0) as avg_ai_confidence,    COALESCE(dc.devices_online, 0) as devices_online,    COALESCE(dc.active_alerts, 0) as active_alerts,    dc.last_scan_time,    dc.updated_at as cache_updated_atFROM dashboard_cache dc WHERE dc.cache_date = CURDATE() AND dc.cache_hour = HOUR(NOW())LIMIT 1;-- System Status Quick ViewCREATE VIEW system_status_quick ASSELECT     (SELECT COUNT(*) FROM esp32_devices WHERE status = 'online' AND is_active = TRUE) as devices_online,    (SELECT COUNT(*) FROM esp32_devices WHERE is_active = TRUE) as total_devices,    (SELECT COUNT(*) FROM alerts WHERE status = 'active') as active_alerts,    (SELECT COUNT(*) FROM alerts WHERE status = 'active' AND severity = 'critical') as critical_alerts,    (SELECT status FROM conveyor_systems WHERE conveyor_id = 1) as main_conveyor_status,    (SELECT MAX(scanned_at) FROM egg_ai_scans WHERE DATE(scanned_at) = CURDATE()) as last_scan_time,    (SELECT MAX(detected_at) FROM egg_detection_data WHERE DATE(detected_at) = CURDATE()) as last_detection_time,    NOW() as status_timestamp;-- Recent Eggs Summary ViewCREATE VIEW recent_eggs_summary ASSELECT     eas.scan_id,    eas.egg_code,    eas.quality,    eas.ai_confidence,    eas.scanned_at,    cs.conveyor_name,    eas.quality_scoreFROM egg_ai_scans easJOIN conveyor_systems cs ON eas.conveyor_id = cs.conveyor_idWHERE DATE(eas.scanned_at) = CURDATE()ORDER BY eas.scanned_at DESCLIMIT 50;-- Device Health Summary ViewCREATE VIEW device_health_summary ASSELECT     d.device_id,    d.device_name,    d.device_type,    d.status,    d.last_heartbeat,    d.signal_strength,    d.uptime_seconds,    d.error_count,    CASE         WHEN d.last_heartbeat > DATE_SUB(NOW(), INTERVAL 2 MINUTE) THEN 'healthy'        WHEN d.last_heartbeat > DATE_SUB(NOW(), INTERVAL 10 MINUTE) THEN 'warning'        ELSE 'critical'    END as health_status,    TIMESTAMPDIFF(SECOND, d.last_heartbeat, NOW()) as seconds_since_heartbeatFROM esp32_devices dWHERE d.is_active = TRUEORDER BY d.device_type, d.device_name;

-- =====================================================
-- SAMPLE DATA FOR TESTING (Optional)
-- =====================================================

-- Sample ESP32 devices
INSERT INTO esp32_devices (device_name, device_type, mac_address, ip_address, wifi_ssid, status, firmware_version, ai_model_version, controller_mode) VALUES 
('ESP32-CAM-AI-Scanner-001', 'esp32_cam_ai_scanner', '24:6F:28:AB:CD:01', '192.168.1.100', 'Smarternak_WiFi', 'online', '1.0.0', '1.0.0', NULL),
('ESP32-DevKit-Controller-001', 'esp32_devkit_controller', '24:6F:28:AB:CD:02', '192.168.1.101', 'Smarternak_WiFi', 'online', '1.0.0', NULL, 'automatic');

-- Update conveyor system with ESP32 devices
UPDATE conveyor_systems SET 
    esp32_cam_device_id = 1, 
    esp32_controller_device_id = 2 
WHERE conveyor_id = 1;

-- Sample sensors for ESP32 devices
INSERT INTO esp32_sensors (device_id, sensor_name, sensor_type, gpio_pin, unit, min_value, max_value) VALUES 
(1, 'Camera Module', 'camera', 'GPIO4', 'pixels', 0, 2073600), -- 1920x1080 pixels
(1, 'Internal Temperature', 'temperature', 'INTERNAL', 'celsius', -10, 85),
(1, 'Light Sensor', 'light', 'GPIO33', 'lux', 0, 1000),
(2, 'HC-SR04 Distance Sensor', 'hc_sr04', 'GPIO2,GPIO4', 'cm', 2, 400),
(2, 'Internal Temperature', 'temperature', 'INTERNAL', 'celsius', -10, 85),
(2, 'Pneumatic Actuator', 'actuator', 'GPIO5', 'boolean', 0, 1),
(2, 'System Voltage', 'voltage', 'ADC1', 'volts', 0, 5);

-- =====================================================
-- ESP32 DUAL CONTROLLER SYSTEM CONFIGURATION NOTES
-- =====================================================

/*
ESP32-CAM AI SCANNER CONFIGURATION:
1. AI Model: TensorFlow Lite model for egg quality classification
2. Image Resolution: 640x480 for balance between quality and processing speed
3. JPEG Quality: 85% for good balance between quality and size
4. WiFi: 2.4GHz network with strong signal strength
5. Communication: Send AI results to ESP32 DevKit V1 via WiFi/MQTT
6. Memory Management: Implement garbage collection for image processing

ESP32 DEVKIT V1 CONTROLLER CONFIGURATION:
1. HC-SR04 Sensor: Trigger=GPIO2, Echo=GPIO4, 15cm detection threshold
2. Pneumatic Actuator: GPIO5 for sorting mechanism control
3. Communication: Receive AI results from ESP32-CAM, send sensor data
4. Control Logic: Sort left (bad eggs) or right (good eggs) based on AI results
5. Timing: Coordinate detection, AI scanning, and sorting actions

SYSTEM WORKFLOW:
1. HC-SR04 detects egg passing → ESP32 DevKit V1 logs detection
2. ESP32-CAM captures image → AI processes → sends result to DevKit V1
3. ESP32 DevKit V1 receives AI result → triggers sorting mechanism
4. Sorting action executed → log success/failure
5. All data synchronized to database

COMMUNICATION PROTOCOL:
1. Message Format: JSON with egg_id, quality, confidence, timestamp
2. Timeout: 2 seconds for AI result communication
3. Retry Logic: 3 attempts with exponential backoff
4. Fallback: Default sorting action if communication fails

PERFORMANCE CONSIDERATIONS:
1. Optimize AI inference time on ESP32-CAM (target <500ms)
2. Minimize communication latency between devices
3. Implement efficient sorting mechanism timing
4. Monitor system throughput and bottlenecks
5. Regular calibration of HC-SR04 sensor and actuators
*/