-- Run once against gothmommy_db
-- Registers vampire items in vorp_inventory

INSERT IGNORE INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`)
VALUES ('ricx_vampire_transform_drink', 'Vampire Drink', 50, 1, 'item_standard', 1);

INSERT IGNORE INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`)
VALUES ('ricx_human_blood', 'Human Blood', 50, 1, 'item_standard', 1);

INSERT IGNORE INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`)
VALUES ('ricx_empty_jar', 'Empty Jar', 50, 1, 'item_standard', 1);
