-- Create reports table for storing report generation history
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    period VARCHAR(20) NOT NULL,
    date DATE NULL,
    format VARCHAR(10) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_size BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Indexes for better performance
    INDEX idx_user_id (user_id),
    INDEX idx_report_type (report_type),
    INDEX idx_created_at (created_at)
);

-- Create uploads/reports directory structure (this would be done manually or via application)
-- mkdir -p uploads/reports 