-- =====================================================
-- SMARTERNAK IoT EGG QUALITY MONITORING SYSTEM
-- Database Schema for MySQL 8.0+ (FIXED VERSION)
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
        FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id) ON DELETE SET NULL,        INDEX idx_controller_conveyor (controller_device_id, conveyor_id),    INDEX idx_detected_at (detected_at),    INDEX idx_batch_sequence (batch_id, egg_sequence_number),    INDEX idx_detected_at_conveyor (detected_at, conveyor_id)
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
    INDEX idx_scanned_at_quality (scanned_at, quality),
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
('communication_timeout_ms', '2000', 'Communication timeout between ESP32 devices in milliseconds', 'integer', FALSE),
('backup_retention_days', '30', 'Number of days to retain backups', 'integer', FALSE),
('api_rate_limit_default', '1000', 'Default API rate limit per hour', 'integer', FALSE),
('api_rate_limit_esp32', '5000', 'ESP32 device API rate limit per hour', 'integer', FALSE),
('dashboard_cache_ttl', '300', 'Dashboard cache TTL in seconds (5 minutes)', 'integer', FALSE),
('polling_interval_active', '2000', 'Frontend polling interval when conveyor active (ms)', 'integer', TRUE),
('polling_interval_inactive', '10000', 'Frontend polling interval when conveyor inactive (ms)', 'integer', TRUE),
('max_file_upload_size_mb', '10', 'Maximum file upload size in MB', 'integer', FALSE),
('api_request_log_retention_days', '7', 'API request logs retention in days', 'integer', FALSE),
('enable_api_rate_limiting', 'true', 'Enable API rate limiting', 'boolean', FALSE),
('enable_request_logging', 'true', 'Enable API request logging', 'boolean', FALSE);

-- Default conveyor system
INSERT INTO conveyor_systems (conveyor_name, location, capacity, belt_length_cm, sorting_mechanism, left_path_destination, right_path_destination, status) VALUES 
('Main Conveyor Line 1', 'Production Floor A', 1500, 300.00, 'pneumatic', 'Bad Eggs Collection Bin', 'Good Eggs Collection Bin', 'inactive');

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