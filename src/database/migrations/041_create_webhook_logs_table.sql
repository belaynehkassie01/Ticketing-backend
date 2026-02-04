-- Migration: 041_create_webhook_logs_table.sql
-- Purpose: Store webhook logs

CREATE TABLE IF NOT EXISTS `webhook_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `webhook_type` ENUM('telebirr_payment', 'sms_delivery', 'email_delivery', 'third_party', 'custom') NOT NULL,
  `endpoint_url` VARCHAR(500) NOT NULL,
  `request_headers` JSON COMMENT 'HTTP headers sent',
  `request_body` TEXT,
  `request_method` VARCHAR(10) DEFAULT 'POST',
  `response_status` INT,
  `response_headers` JSON COMMENT 'HTTP headers received',
  `response_body` TEXT,
  `response_time_ms` INT,
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'retrying') DEFAULT 'pending',
  `retry_count` INT DEFAULT 0,
  `error_message` TEXT,
  `next_retry_at` DATETIME NULL,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  
  INDEX `idx_webhook_type` (`webhook_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_next_retry_at` (`next_retry_at`),
  INDEX `idx_endpoint_url` (`endpoint_url`(100)),
  INDEX `idx_response_status` (`response_status`),
  INDEX `idx_sent_at` (`sent_at`),
  
  CONSTRAINT `chk_response_time` CHECK (`response_time_ms` IS NULL OR `response_time_ms` >= 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0),
  CONSTRAINT `chk_response_status` CHECK (`response_status` IS NULL OR `response_status` BETWEEN 100 AND 599)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;