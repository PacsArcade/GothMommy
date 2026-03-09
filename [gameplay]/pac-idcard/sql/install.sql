-- pac-idcard SQL install
-- Run this ONCE before starting the resource.
-- Safe to re-run (IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS `pac_idcard` (
    `charid` varchar(50) NOT NULL,
    `data`   longtext,
    PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pac_idcard_history` (
    `charid`       int(11)      NOT NULL,
    `prev_license` varchar(64)  NOT NULL DEFAULT '',
    `deleted_at`   datetime     NOT NULL,
    PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pac_idcard_forgery_log` (
    `id`          int(11)      NOT NULL AUTO_INCREMENT,
    `real_charid` int(11)      NOT NULL,
    `card_charid` varchar(50)  NOT NULL,
    `checked_by`  int(11)      NOT NULL,
    `checked_at`  datetime     NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
