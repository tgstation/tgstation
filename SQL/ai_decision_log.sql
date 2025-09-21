-- AI Decision Telemetry schema additions for the AI-Controlled Human Crew Foundation.
-- Import alongside tgstation_schema.sql to create audit tables for administrator blackboard tooling.

CREATE TABLE IF NOT EXISTS `ai_decision_log` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `round_id` INT NOT NULL COMMENT 'game_id / round identifier',
    `profile_id` VARCHAR(64) NOT NULL COMMENT 'ai crew profile identifier',
    `job_id` VARCHAR(64) NOT NULL COMMENT 'crew job code for filtering',
    `action_category` VARCHAR(64) NOT NULL COMMENT 'taxonomy bucket used for exploration multiplier',
    `selected_action` VARCHAR(128) NOT NULL,
    `exploration_bonus` FLOAT NOT NULL,
    `rollout_count` SMALLINT UNSIGNED NOT NULL,
    `result` ENUM('success','partial','failure','aborted') NOT NULL,
    `decision_epoch_ms` BIGINT UNSIGNED NOT NULL COMMENT 'world.timeofday snapshot when decision executed',
    `notes` TEXT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_ai_decision_log_round` (`round_id`),
    KEY `idx_ai_decision_log_profile` (`profile_id`),
    KEY `idx_ai_decision_log_category` (`action_category`),
    KEY `idx_ai_decision_log_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Retention: keep raw telemetry for 24 hours. Aggregations should downsample separately.
DROP EVENT IF EXISTS `ev_purge_old_ai_decisions`;
CREATE EVENT `ev_purge_old_ai_decisions`
    ON SCHEDULE EVERY 1 HOUR
    DO
        DELETE FROM `ai_decision_log`
        WHERE `created_at` < (NOW() - INTERVAL 1 DAY);
