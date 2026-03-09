-- pac-camp SQL injection for Goth Mommy RP
-- Run once on gothmommy_db
-- Uses VORP item schema: limit_count (not limit), desc (not metadata)

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

-- Items use VORP schema: limit_count, can_remove, type, usable, desc
INSERT IGNORE INTO `items` (`item`, `label`, `limit_count`, `can_remove`, `type`, `usable`, `desc`) VALUES
('tent_trader',              'Trader Tent',         1, 1, 'item_standard', 1, 'A traders tent for camping.'),
('tent_bounty07',            'Bounty Tent 1',       1, 1, 'item_standard', 1, 'A bounty hunter tent.'),
('tent_bounty02',            'Bounty Tent 2',       1, 1, 'item_standard', 1, 'A bounty hunter tent.'),
('tent_bounty06',            'Bounty Tent 3',       1, 1, 'item_standard', 1, 'A bounty hunter tent.'),
('tent_collector04',         'Collector Tent',      1, 1, 'item_standard', 1, 'A collector tent for camping.'),
('hitchingpost_wood',        'Hitch Post (Wood)',   1, 1, 'item_standard', 1, 'A wooden hitching post for your horse.'),
('hitchingpost_iron',        'Hitch Post (Iron)',   1, 1, 'item_standard', 1, 'An iron hitching post for your horse.'),
('hitchingpost_wood_double', 'Hitch Post (Double)', 1, 1, 'item_standard', 1, 'A double wooden hitching post.'),
('chair_wood',               'Wooden Chair',        1, 1, 'item_standard', 1, 'A simple wooden chair.'),
('table_wood01',             'Wooden Table',        1, 1, 'item_standard', 1, 'A sturdy wooden table.'),
('campfire_01',              'Campfire',            1, 1, 'item_standard', 1, 'A campfire for warmth and cooking.'),
('campfire_02',              'Campfire (Small)',    1, 1, 'item_standard', 1, 'A smaller campfire.'),
('chest_little',             'Small Chest',         1, 1, 'item_standard', 1, 'A small chest for storage.'),
('chest_medium',             'Medium Chest',        1, 1, 'item_standard', 1, 'A medium chest for storage.'),
('chest_big',                'Large Chest',         1, 1, 'item_standard', 1, 'A large chest for storage.'),
('door_01',                  'Door (Wood)',         1, 1, 'item_standard', 1, 'A lockable wooden door.'),
('door_02',                  'Door (Saloon)',       1, 1, 'item_standard', 1, 'A saloon-style door.'),
('door_03',                  'Door (Strawberry)',   1, 1, 'item_standard', 1, 'A Strawberry-style door.'),
('door_04',                  'Door (River)',        1, 1, 'item_standard', 1, 'A riverboat door.');
