create extension if not exists "uuid-ossp";

-- 1. Cafe Tables (22 Tables & Zones from video)
create table if not exists public.cafe_tables (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  theme text not null default 'theme-mint',
  sort_order int not null default 0
);

-- 2. Restaurant Menu Items (10 Categories, 60+ Items from video)
create table if not exists public.menu_items (
  id uuid primary key default uuid_generate_v4(),
  category text not null,
  name text not null,
  price numeric(10,2) not null,
  is_available boolean default true,
  created_at timestamptz default now()
);

-- 3. Customers & Credit Ledger
create table if not exists public.customers (
  id uuid primary key default uuid_generate_v4(),
  initials text not null,
  name text not null,
  phone text,
  email text,
  address text,
  credit_limit numeric(10,2) default 0,
  total_due numeric(10,2) default 0,
  color text default '#1BA63F',
  created_at timestamptz default now()
);

-- 4. Orders (Pending / Completed / Cancelled)
create table if not exists public.orders (
  id text primary key,
  table_name text not null,
  status text not null default 'Pending',
  order_time text not null,
  taken_by text default 'Dipak',
  payment_method text default 'Cash',
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz default now()
);

-- Enable Realtime Sync
alter publication supabase_realtime add table public.orders;
alter publication supabase_realtime add table public.menu_items;
alter publication supabase_realtime add table public.customers;

-- Seed Tables
insert into public.cafe_tables (name, theme, sort_order) values
  ('T1','theme-mint',1), ('T2','theme-peach',2), ('T3','theme-blue',3), ('T4','theme-pink',4),
  ('T5','theme-mint',5), ('T6','theme-peach',6), ('T7','theme-blue',7), ('T8','theme-pink',8),
  ('T9','theme-mint',9), ('T10','theme-pink',10), ('Masu wala','theme-yellow',11),
  ('Parlor wala','theme-blue',12), ('Fancy wala','theme-yellow',13), ('Pack','theme-peach',14),
  ('T11','theme-lavender',15), ('Sumit Tmg','theme-blue',16), ('Bharat Oli','theme-peach',17),
  ('Ridam','theme-blue',18), ('Dipesh Vai','theme-pink',19), ('Navin Vaii','theme-mint',20),
  ('Raj Group','theme-blue',21), ('Bijay','theme-lavender',22)
on conflict (name) do nothing;

-- Seed Menu Items
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
  ('Laphing', 'Mixed Laphing Dry', 80), ('Laphing', 'Mixed Laphing Jhol', 90);