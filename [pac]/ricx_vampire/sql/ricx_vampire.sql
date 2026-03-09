-- Run once against gothmommy_db
-- Creates the vampire progression table

CREATE TABLE IF NOT EXISTS `ricx_vampire` (
  `id` int(7) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `charid` int(5) NOT NULL,
  `data` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 CHARSET=utf8mb4;
