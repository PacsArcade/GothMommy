-- Goth Mommy RP - pac-companions
-- Run this against gothmommy_db before starting the resource

CREATE TABLE IF NOT EXISTS `companions` (
  `identifier`     varchar(40)  NOT NULL,
  `charidentifier` int          NOT NULL DEFAULT '0',
  `dog`            varchar(255) NOT NULL,
  `skin`           int          NOT NULL DEFAULT '0',
  `xp`             int                   DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
