-- ==============================================================================
-- CLOUD HOUSE POS — SUPABASE COMPLETE PRODUCTION DATABASE SCHEMA
-- Compatible with PostgreSQL 14+ / Supabase
-- Includes Profiles, Cafe Tables, Menu Items, Customers, Orders, RLS & Realtime
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. USER PROFILES (Linked with Supabase Auth users)
-- ------------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null default 'Staff Member',
  role text not null default 'waiter' check (role in ('owner', 'manager', 'cashier', 'waiter')),
  created_at timestamptz default timezone('utc'::text, now()) not null,
  updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- Trigger to auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'role', 'owner')
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = coalesce(excluded.full_name, profiles.full_name);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------------------------
-- 2. CAFE TABLES & ZONES
-- ------------------------------------------------------------------------------
create table if not exists public.cafe_tables (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  theme text not null default 'theme-mint',
  sort_order int not null default 0,
  created_at timestamptz default timezone('utc'::text, now()) not null
);

-- ------------------------------------------------------------------------------
-- 3. RESTAURANT MENU ITEMS (Categories: Coffee, Cold Beverages, Hookah, etc.)
-- ------------------------------------------------------------------------------
create table if not exists public.menu_items (
  id uuid primary key default uuid_generate_v4(),
  category text not null,
  name text not null,
  price numeric(10,2) not null check (price >= 0),
  is_available boolean default true not null,
  created_at timestamptz default timezone('utc'::text, now()) not null,
  unique (category, name)
);

-- ------------------------------------------------------------------------------
-- 4. CUSTOMERS & CREDIT LEDGER
-- ------------------------------------------------------------------------------
create table if not exists public.customers (
  id uuid primary key default uuid_generate_v4(),
  initials text not null,
  name text not null,
  phone text,
  email text,
  address text,
  credit_limit numeric(10,2) default 0,
  total_due numeric(10,2) default 0 check (total_due >= 0),
  color text default '#1BA63F',
  created_at timestamptz default timezone('utc'::text, now()) not null
);

-- ------------------------------------------------------------------------------
-- 5. ORDERS (Realtime Orders with items in JSONB)
-- ------------------------------------------------------------------------------
create table if not exists public.orders (
  id text primary key, -- e.g. 'ORD-13211'
  table_name text not null,
  status text not null default 'Pending' check (status in ('Pending', 'Completed', 'Cancelled')),
  order_time text not null,
  taken_by text not null default 'Staff',
  payment_method text not null default 'Cash' check (payment_method in ('Cash', 'Card', 'Fonepay', 'Credit', 'Past Dues', 'Digital Wallet')),
  discount numeric(10,2) not null default 0 check (discount >= 0),
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz default timezone('utc'::text, now()) not null,
  updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- ------------------------------------------------------------------------------
-- 6. PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------
create index if not exists idx_orders_status on public.orders (status);
create index if not exists idx_orders_table_name on public.orders (table_name);
create index if not exists idx_orders_created_at on public.orders (created_at desc);
create index if not exists idx_menu_items_category on public.menu_items (category);
create index if not exists idx_customers_phone on public.customers (phone);

-- ------------------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.cafe_tables enable row level security;
alter table public.menu_items enable row level security;
alter table public.customers enable row level security;
alter table public.orders enable row level security;

-- Profiles: Authenticated users can view profiles and update their own
drop policy if exists "Profiles are viewable by authenticated users" on public.profiles;
create policy "Profiles are viewable by authenticated users"
  on public.profiles for select
  to authenticated
  using (true);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- Cafe Tables: Full CRUD for authenticated & anon clients
drop policy if exists "Tables are accessible by authenticated & anon" on public.cafe_tables;
create policy "Tables are accessible by authenticated & anon"
  on public.cafe_tables for all
  using (true) with check (true);

-- Menu Items: Full CRUD for authenticated & anon clients
drop policy if exists "Menu items are accessible by authenticated & anon" on public.menu_items;
create policy "Menu items are accessible by authenticated & anon"
  on public.menu_items for all
  using (true) with check (true);

-- Customers: Full CRUD for authenticated & anon clients
drop policy if exists "Customers are accessible by authenticated & anon" on public.customers;
create policy "Customers are accessible by authenticated & anon"
  on public.customers for all
  using (true) with check (true);

-- Orders: Full CRUD for authenticated & anon clients
drop policy if exists "Orders are accessible by authenticated & anon" on public.orders;
create policy "Orders are accessible by authenticated & anon"
  on public.orders for all
  using (true) with check (true);

-- ------------------------------------------------------------------------------
-- 8. REALTIME REPLICATION (Instant multi-device live sync)
-- ------------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'orders') then
    alter publication supabase_realtime add table public.orders;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'menu_items') then
    alter publication supabase_realtime add table public.menu_items;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'customers') then
    alter publication supabase_realtime add table public.customers;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'cafe_tables') then
    alter publication supabase_realtime add table public.cafe_tables;
  end if;
end;
$$;
