-- pac-grave-robbery items
-- Run once against gothmommy_db
-- Copy item PNGs to [vorp]/vorp_inventory/html/img/

INSERT IGNORE INTO items (item, label, limit_count, can_remove, type, usable, desc)
VALUES
  ('shovel',        'Shovel',          1,  1, 'item_standard', 0, 'A sturdy digging shovel.'),
  ('grave_trinket', 'Old Trinket',      5,  1, 'item_standard', 0, 'Something dug from a grave.'),
  ('old_coin',      'Old Coin',        10,  1, 'item_standard', 0, 'A worn coin of uncertain origin.'),
  ('grave_ring',    'Tarnished Ring',   5,  1, 'item_standard', 0, 'A ring taken from the earth.');
