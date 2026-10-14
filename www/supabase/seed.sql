-- ==============================================================================
-- CLOUD HOUSE POS — SUPABASE SEED DATA
-- Run after schema.sql to populate initial cafe tables, menu items, and customers
-- ==============================================================================

-- 1. Seed Cafe Tables (22 Tables & Zones)
insert into public.cafe_tables (name, theme, sort_order) values
  ('T1','theme-mint',1), ('T2','theme-peach',2), ('T3','theme-blue',3), ('T4','theme-pink',4),
  ('T5','theme-mint',5), ('T6','theme-peach',6), ('T7','theme-blue',7), ('T8','theme-pink',8),
  ('T9','theme-mint',9), ('T10','theme-pink',10), ('Masu wala','theme-yellow',11),
  ('Parlor wala','theme-blue',12), ('Fancy wala','theme-yellow',13), ('Pack','theme-peach',14),
  ('T11','theme-lavender',15), ('Sumit Tmg','theme-blue',16), ('Bharat Oli','theme-peach',17),
  ('Ridam','theme-blue',18), ('Dipesh Vai','theme-pink',19), ('Navin Vaii','theme-mint',20),
  ('Raj Group','theme-blue',21), ('Bijay','theme-lavender',22)
on conflict (name) do nothing;

-- 2. Seed Restaurant Menu Items (60+ Items across 10 Categories)
insert into public.menu_items (category, name, price) values
  ('Coffee', 'Black Coffee', 50), ('Coffee', 'Milk', 70), ('Coffee', 'Blackcoffe double', 80),
  ('Coffee', 'Cold coffee', 85), ('Coffee', 'Iced americano', 75), ('Coffee', 'Milk coffee', 55), ('Coffee', 'Water', 20),
  ('Cold Beverages', 'Coke / Fanta / Sprite', 70), ('Cold Beverages', '6 Masala Coke / Fanta / Sprite', 100),
  ('Cold Beverages', '7 Virgin Mojito', 140), ('Cold Beverages', '8 Cold Coffee', 100),
  ('Cold Beverages', 'Cold Lemon', 50), ('Cold Beverages', 'Small Normal Lassie', 60),
  ('Hookah', '1 Normal Hookah', 230), ('Hookah', '2 Normal cloud Hookah', 300),
  ('Hookah', '3 normal extra flavour', 130), ('Hookah', '4 Cloud Hookah', 350),
  ('Hookah', '5 cloud coil', 50), ('Hookah', '6 cloud extra flavour', 240), ('Hookah', 'Blue Berry Cloud', 350),
  ('Premium Hookah', 'JIBIAR Cloud', 500), ('Premium Hookah', 'JIBIAR Normal', 350),
  ('Premium Hookah', 'Lady Killer Cloud', 450), ('Premium Hookah', 'Lady Killer Normal', 300),
  ('Premium Hookah', 'Love 66 Cloud', 450), ('Premium Hookah', 'Love 66 Normal', 300), ('Premium Hookah', 'Love 77 Cloud', 450),
  ('Smoke', 'Shikhar ice', 20), ('Smoke', 'Surya Fusion', 25), ('Smoke', 'Surya Lite', 25), ('Smoke', 'Surya Rad', 25),
  ('Snacks & Bites', 'French Fries', 120), ('Snacks & Bites', 'Sausage', 60), ('Snacks & Bites', 'Aloo Chop', 40),
  ('Snacks & Bites', 'Pakoda', 80), ('Snacks & Bites', 'Wai Wai Sadeko', 70), ('Snacks & Bites', 'Peanut Sadeko', 100),
  ('Tea', 'Hot Lemon', 45), ('Tea', 'Hot Lemon Ginger', 110), ('Tea', 'Hot Lemon Honey', 100),
  ('Tea', 'Masala Milk Tea', 40), ('Tea', 'Regular tea', 30), ('Tea', 'Apple tea', 40), ('Tea', 'Black tea', 20),
  ('Chips', '8 chips', 60), ('Chips', 'Kurkure', 40), ('Chips', 'Lays', 50), ('Chips', 'Cookies', 10),
  ('Momo & Noodles', 'C. Chicken Momo - Jhol', 140), ('Momo & Noodles', 'Chiken Momo - Stem', 120),
  ('Momo & Noodles', 'Chiken Fry Momo', 150), ('Momo & Noodles', 'C. Chowmein', 150),
  ('Momo & Noodles', 'Veg. Chowmein', 100), ('Momo & Noodles', 'Chiken Keema Noodles', 165),
  ('Momo & Noodles', 'Current With Eggs', 120), ('Momo & Noodles', '1/2 Current', 50),
  ('Momo & Noodles', 'C.Chowmin 1/3', 80), ('Momo & Noodles', 'C Chawimun Half', 80),
  ('Momo & Noodles', 'V Chawimun Half', 65), ('Momo & Noodles', 'Egg Chawimun', 135),
  ('Momo & Noodles', 'Eg Chawimun Half', 90), ('Momo & Noodles', 'Half Keema Noodles', 100),
  ('Laphing', 'Chau Chau Laphing Dry', 65), ('Laphing', 'Cho Cho Laphing Jhol', 75),
  ('Laphing', 'Mixed Laphing Dry', 80), ('Laphing', 'Mixed Laphing Jhol', 90)
on conflict (category, name) do nothing;

-- 3. Seed Customers & Credit Ledger
insert into public.customers (initials, name, phone, address, total_due, color) values
  ('A', 'Ajaya', '9812345678', 'Lalitpur', 0, '#F59E0B'),
  ('BB', 'Bharat Bhanja', '9866234475', '', 0, '#6366F1'),
  ('B', 'Bijay', '9845896631', 'Kathmandu', 2790.00, '#22C55E'),
  ('GS', 'Gyalzan S', '9865741236', '', 0, '#8B5CF6'),
  ('H', 'Himal', '9846849186', 'Pokhara', 4890.00, '#A855F7'),
  ('JW', 'Jar Wala', '9866556525', '', 0, '#F97316');

-- 4. Seed Initial Orders
insert into public.orders (id, table_name, status, order_time, taken_by, payment_method, discount, items) values
  ('ORD-13211', 'T5', 'Pending', '17:37', 'Dipak', 'Cash', 0, '[{"name": "Regular tea", "qty": 3, "price": 90.00}]'::jsonb),
  ('ORD-13210', 'T4', 'Pending', '17:19', 'Dipak', 'Cash', 0, '[{"name": "Shikhar ice", "qty": 2, "price": 40.00}, {"name": "Regular tea", "qty": 1, "price": 30.00}]'::jsonb),
  ('ORD-13209', 'T1', 'Pending', '17:15', 'Dipak', 'Cash', 0, '[{"name": "1 Normal Hookah", "qty": 1, "price": 230.00}]'::jsonb),
  ('ORD-13208', 'T2', 'Pending', '17:14', 'Dipak', 'Cash', 0, '[{"name": "Regular tea", "qty": 1, "price": 30.00}]'::jsonb),
  ('ORD-13207', 'T6', 'Pending', '17:09', 'Dipak', 'Cash', 0, '[{"name": "Black Coffee", "qty": 1, "price": 50.00}]'::jsonb),
  ('ORD-13201', 'T1', 'Completed', '10:28', 'Dipak', 'Cash', 0, '[{"name": "Regular tea", "qty": 2, "price": 60.00}, {"name": "Milk", "qty": 1, "price": 70.00}]'::jsonb),
  ('ORD-13202', 'T10', 'Completed', '10:28', 'Dipak', 'Cash', 0, '[{"name": "Regular tea", "qty": 1, "price": 30.00}, {"name": "Cookies", "qty": 1, "price": 10.00}]'::jsonb),
  ('ORD-13203', 'T3', 'Completed', '10:28', 'Dipak', 'Cash', 0, '[{"name": "Regular tea", "qty": 1, "price": 30.00}]'::jsonb),
  ('ORD-13204', 'T7', 'Completed', '10:28', 'Dipak', 'Cash', 0, '[{"name": "Surya Rad", "qty": 2, "price": 50.00}, {"name": "Regular tea", "qty": 1, "price": 30.00}]'::jsonb)
on conflict (id) do nothing;