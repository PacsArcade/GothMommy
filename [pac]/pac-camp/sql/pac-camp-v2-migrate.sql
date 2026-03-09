-- pac-camp v2 migration
-- Run ONCE on gothmommy_db after deploying the feat/pac-camp v2 branch.
-- Safe to re-run (all statements use IF NOT EXISTS / IGNORE).

-- -----------------------------------------------------------------------
-- 1. Camp membership table
--    One row per invited member per camp owner.
--    owner_identifier + owner_charid = the player who owns the camp.
--    member_identifier + member_charid = the invited player.
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pac_camp_members` (
  `id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner_identifier`    VARCHAR(255) NOT NULL,
  `owner_charid`        INT(11)      NOT NULL,
  `member_identifier`   VARCHAR(255) NOT NULL,
  `member_charid`       INT(11)      NOT NULL,
  `invited_at`          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_membership` (`owner_identifier`,`owner_charid`,`member_identifier`,`member_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------
-- 2. Bedroll respawn table
--    Stores the world position of each character's placed bedroll.
--    One row per character - INSERT ... ON DUPLICATE KEY UPDATE.
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pac_camp_respawn` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier`   VARCHAR(255) NOT NULL,
  `charid`       INT(11)      NOT NULL,
  `x`            DOUBLE       NOT NULL,
  `y`            DOUBLE       NOT NULL,
  `z`            DOUBLE       NOT NULL,
  `heading`      DOUBLE       NOT NULL DEFAULT 0.0,
  `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_char_respawn` (`identifier`, `charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------
-- 3. Bedroll item  (uses correct VORP column name `limit`)
-- -----------------------------------------------------------------------
INSERT IGNORE INTO `items`
  (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `useExpired`, `metadata`, `desc`, `weight`)
VALUES
  ('bedroll', 'Bedroll', 1, 1, 'item', 1, 0, '{}', 'A bedroll you can lay out at camp to sleep and set your respawn point.', 2);
