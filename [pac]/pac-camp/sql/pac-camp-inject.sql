-- pac-camp SQL injection for Goth Mommy RP
-- Run ONCE on gothmommy_db
--
-- STATUS: pac_camp table and all 19 items already exist in DB as of 2026-03-09.
-- This file is kept for documentation and fresh-install reference.
--
-- Correct VORP items schema:
--   item, label, limit, can_remove, type, usable, metadata, desc, weight
--   NOTE: column is 'limit' (NOT 'limit_count')

CREATE TABLE IF NOT EXISTS `pac_camp` (
  `id`               int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_identifier` varchar(255)      DEFAULT NULL,
  `owner_charid`     int(11)           DEFAULT NULL,
  `x`                double            DEFAULT NULL,
  `y`                double            DEFAULT NULL,
  `z`                double            DEFAULT NULL,
  `rot_x`            double            DEFAULT NULL,
  `rot_y`            double            DEFAULT NULL,
  `rot_z`            double            DEFAULT NULL,
  `item_name`        varchar(50)       DEFAULT NULL,
  `item_model`       varchar(100)      DEFAULT NULL,
  `shared_with`      text              DEFAULT '[]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `metadata`, `desc`, `weight`) VALUES
('tent_trader',              'Trader Tent',         1, 1, 'item_standard', 1, '{}', 'A traders tent for camping.',           0.25),
('tent_bounty07',            'Bounty Tent 1',       1, 1, 'item_standard', 1, '{}', 'A bounty hunter tent.',                 0.25),
('tent_bounty02',            'Bounty Tent 2',       1, 1, 'item_standard', 1, '{}', 'A bounty hunter tent.',                 0.25),
('tent_bounty06',            'Bounty Tent 3',       1, 1, 'item_standard', 1, '{}', 'A bounty hunter tent.',                 0.25),
('tent_collector04',         'Collector Tent',      1, 1, 'item_standard', 1, '{}', 'A collector tent for camping.',          0.25),
('hitchingpost_wood',        'Hitch Post (Wood)',   1, 1, 'item_standard', 1, '{}', 'A wooden hitching post for your horse.', 0.25),
('hitchingpost_iron',        'Hitch Post (Iron)',   1, 1, 'item_standard', 1, '{}', 'An iron hitching post for your horse.',  0.25),
('hitchingpost_wood_double', 'Hitch Post (Double)', 1, 1, 'item_standard', 1, '{}', 'A double wooden hitching post.',         0.25),
('chair_wood',               'Wooden Chair',        1, 1, 'item_standard', 1, '{}', 'A simple wooden chair.',                0.25),
('table_wood01',             'Wooden Table',        1, 1, 'item_standard', 1, '{}', 'A sturdy wooden table.',                0.25),
('campfire_01',              'Campfire',            1, 1, 'item_standard', 1, '{}', 'A campfire for warmth and cooking.',     0.25),
('campfire_02',              'Campfire (Small)',    1, 1, 'item_standard', 1, '{}', 'A smaller campfire.',                   0.25),
('chest_little',             'Small Chest',         1, 1, 'item_standard', 1, '{}', 'A small chest for storage.',            0.25),
('chest_medium',             'Medium Chest',        1, 1, 'item_standard', 1, '{}', 'A medium chest for storage.',           0.25),
('chest_big',                'Large Chest',         1, 1, 'item_standard', 1, '{}', 'A large chest for storage.',            0.25),
('door_01',                  'Door (Wood)',         1, 1, 'item_standard', 1, '{}', 'A lockable wooden door.',               0.25),
('door_02',                  'Door (Saloon)',       1, 1, 'item_standard', 1, '{}', 'A saloon-style door.',                  0.25),
('door_03',                  'Door (Strawberry)',   1, 1, 'item_standard', 1, '{}', 'A Strawberry-style door.',              0.25),
('door_04',                  'Door (River)',        1, 1, 'item_standard', 1, '{}', 'A riverboat door.',                     0.25);
