-- pac-hooker: player status table
-- Run once against gothmommy_db
-- Tracks bath timestamps and well-rested buff per character

CREATE TABLE IF NOT EXISTS `pac_player_status` (
  `id`                int(11)      NOT NULL AUTO_INCREMENT,
  `identifier`        varchar(60)  NOT NULL,
  `charid`            int(11)      NOT NULL,
  `last_bath`         int(11)      DEFAULT NULL COMMENT 'Unix timestamp of last bath',
  `well_rested_until` int(11)      DEFAULT NULL COMMENT 'Unix timestamp when well-rested buff expires',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_char` (`identifier`, `charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
