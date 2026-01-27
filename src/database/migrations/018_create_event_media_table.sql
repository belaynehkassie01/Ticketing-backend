-- Migration: 018_create_event_media_table.sql (IMPROVED VERSION)
-- Description: Store media files for events with enhanced tracking
-- Dependencies: Requires events and users tables

-- ============================================
-- TABLE: event_media (IMPROVED)
-- Purpose: Store media files for events with upload tracking and soft delete
-- ============================================

CREATE TABLE IF NOT EXISTS `event_media` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  
  -- Media Information
  `media_type` ENUM('image', 'video', 'document', 'audio') DEFAULT 'image',
  `url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT UNSIGNED COMMENT 'Size in bytes',
  `width` INT UNSIGNED COMMENT 'Width in pixels (for images/videos)',
  `height` INT UNSIGNED COMMENT 'Height in pixels (for images/videos)',
  `duration` INT UNSIGNED NULL COMMENT 'Duration in seconds (for videos/audio)',
  
  -- Captions & Descriptions (Bilingual)
  `title` VARCHAR(200),
  `title_amharic` VARCHAR(200),
  `caption` VARCHAR(500),
  `caption_amharic` VARCHAR(500),
  `description` TEXT,
  `description_amharic` TEXT,
  `alt_text` VARCHAR(500) COMMENT 'Accessibility alt text',
  
  -- Organization & Display
  `sort_order` INT DEFAULT 0,
  `is_primary` BOOLEAN DEFAULT FALSE COMMENT 'Primary/featured media for event',
  `is_cover_image` BOOLEAN DEFAULT FALSE COMMENT 'If this is the event cover image',
  
  -- Status & Approval
  `is_approved` BOOLEAN DEFAULT TRUE,
  `approved_by` BIGINT UNSIGNED NULL COMMENT 'User who approved the media',
  `approved_at` DATETIME NULL,
  `rejection_reason` TEXT COMMENT 'If media was rejected',
  
  -- Upload Tracking
  `uploaded_by` BIGINT UNSIGNED NULL COMMENT 'User who uploaded the media',
  `upload_source` ENUM('organizer', 'admin', 'system', 'user') DEFAULT 'organizer',
  `original_filename` VARCHAR(255) COMMENT 'Original filename before processing',
  
  -- Metadata
  `meta_data` JSON COMMENT 'Additional metadata: {"camera": "iPhone 12", "format": "JPEG", "compression": "high"}',
  `tags` JSON COMMENT 'Tags for media organization',
  
  -- Soft Delete & Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  `archived_at` DATETIME NULL COMMENT 'For long-term archiving',
  
  -- Foreign Keys
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_event` (`event_id`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_primary` (`is_primary`),
  INDEX `idx_is_approved` (`is_approved`),
  INDEX `idx_is_cover_image` (`is_cover_image`),
  INDEX `idx_uploaded_by` (`uploaded_by`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  
  -- Composite Indexes
  INDEX `idx_event_primary` (`event_id`, `is_primary`),
  INDEX `idx_event_approved` (`event_id`, `is_approved`),
  INDEX `idx_event_type` (`event_id`, `media_type`),
  INDEX `idx_event_order` (`event_id`, `sort_order`),
  
  -- Application-enforced constraints
  CONSTRAINT `chk_file_size` CHECK (`file_size` >= 0),
  CONSTRAINT `chk_dimensions` CHECK (`width` >= 0 AND `height` >= 0),
  CONSTRAINT `chk_duration` CHECK (`duration` IS NULL OR `duration` > 0)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event media storage with upload tracking, approval workflow, and soft delete support.';

-- ============================================
-- VIEWS FOR MEDIA MANAGEMENT
-- ============================================

-- View for event media gallery (public)
CREATE OR REPLACE VIEW `vw_event_media_gallery` AS
SELECT 
    em.id,
    em.event_id,
    em.media_type,
    em.url,
    em.thumbnail_url,
    em.title,
    em.title_amharic,
    em.caption,
    em.caption_amharic,
    em.width,
    em.height,
    em.duration,
    em.sort_order,
    em.is_primary,
    em.is_cover_image,
    em.mime_type,
    em.file_size,
    -- Display information
    CASE 
        WHEN em.media_type = 'image' THEN 'PHOTO'
        WHEN em.media_type = 'video' THEN 'VIDEO'
        WHEN em.media_type = 'document' THEN 'DOCUMENT'
        WHEN em.media_type = 'audio' THEN 'AUDIO'
        ELSE 'MEDIA'
    END as media_type_display,
    -- File size in readable format
    CASE 
        WHEN em.file_size < 1024 THEN CONCAT(em.file_size, ' B')
        WHEN em.file_size < 1048576 THEN CONCAT(ROUND(em.file_size / 1024, 1), ' KB')
        ELSE CONCAT(ROUND(em.file_size / 1048576, 1), ' MB')
    END as file_size_display
FROM `event_media` em
WHERE em.is_approved = TRUE
  AND em.deleted_at IS NULL
  AND em.event_id IN (SELECT id FROM events WHERE status = 'published')
ORDER BY em.event_id, em.sort_order, em.created_at;

-- View for organizer media management
CREATE OR REPLACE VIEW `vw_organizer_event_media` AS
SELECT 
    em.id,
    em.event_id,
    e.title as event_title,
    e.title_amharic as event_title_amharic,
    em.media_type,
    em.url,
    em.filename,
    em.file_size,
    em.width,
    em.height,
    em.is_approved,
    em.is_primary,
    em.is_cover_image,
    em.created_at,
    em.updated_at,
    u.full_name as uploaded_by_name,
    -- Approval status
    CASE 
        WHEN em.is_approved = TRUE THEN 'APPROVED'
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NOT NULL THEN 'REJECTED'
        WHEN em.is_approved = FALSE THEN 'PENDING_APPROVAL'
        ELSE 'UNKNOWN'
    END as approval_status,
    -- Media type icon
    CASE em.media_type
        WHEN 'image' THEN '📷'
        WHEN 'video' THEN '🎬'
        WHEN 'document' THEN '📄'
        WHEN 'audio' THEN '🎵'
        ELSE '📁'
    END as media_icon
FROM `event_media` em
JOIN `events` e ON em.event_id = e.id
LEFT JOIN `users` u ON em.uploaded_by = u.id
WHERE em.deleted_at IS NULL
ORDER BY em.event_id, em.sort_order;

-- View for admin media moderation
CREATE OR REPLACE VIEW `vw_admin_media_moderation` AS
SELECT 
    em.id,
    em.event_id,
    e.title as event_title,
    o.business_name as organizer_name,
    em.media_type,
    em.url,
    em.filename,
    em.mime_type,
    em.file_size,
    em.is_approved,
    em.uploaded_by,
    u.full_name as uploaded_by_name,
    u.phone as uploaded_by_phone,
    em.created_at,
    em.approved_by,
    em.approved_at,
    em.rejection_reason,
    -- Moderation flags
    CASE 
        WHEN em.mime_type LIKE 'video/%' AND em.file_size > 104857600 THEN 'LARGE_VIDEO'
        WHEN em.media_type = 'image' AND (em.width > 5000 OR em.height > 5000) THEN 'HIGH_RES_IMAGE'
        WHEN em.media_type = 'document' AND em.file_size > 10485760 THEN 'LARGE_DOCUMENT'
        ELSE 'STANDARD'
    END as moderation_flag,
    -- Action required
    CASE 
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NULL THEN 'NEEDS_REVIEW'
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NOT NULL THEN 'REJECTED_NEEDS_FOLLOWUP'
        ELSE 'NO_ACTION'
    END as action_required
FROM `event_media` em
JOIN `events` e ON em.event_id = e.id
JOIN `organizers` o ON e.organizer_id = o.id
LEFT JOIN `users` u ON em.uploaded_by = u.id
WHERE em.deleted_at IS NULL
  AND (em.is_approved = FALSE OR em.rejection_reason IS NOT NULL)
ORDER BY em.created_at DESC;