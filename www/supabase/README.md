# 🚀 Cloud House POS — Supabase Backend Setup Guide

This guide walks you through connecting your Cloud House POS app to Supabase in under 3 minutes for production-grade authentication and realtime multi-device sync.

---

### Step 1: Create a Free Supabase Project
1. Go to [https://supabase.com](https://supabase.com) and log in.
2. Click **New Project** and name it `cloud-house-pos`.
3. Choose a strong database password and select your closest region (e.g., Mumbai, Singapore).

---

### Step 2: Run the SQL Schema & Seed
1. In your Supabase Dashboard, go to **SQL Editor** (icon on left sidebar).
2. Click **New Query**.
3. Open `schema.sql` from this folder, copy all contents, and click **Run**.
4. *(Optional for demo data)*: Open `seed.sql`, copy all contents, and click **Run**.

---

### Step 3: Get Your API Keys
1. In your Supabase Dashboard, go to **Project Settings** (gear icon) ➔ **API**.
2. Copy:
   - **Project URL** (e.g. `https://xyzabcdef.supabase.co`)
   - **Project API Anon Key** (`anon` `public` key starting with `eyJ...`)

---

### Step 4: Connect the App
You can connect in either of two ways:
1. **Directly in the App**:
   - In Cloud House POS, go to **Analytics** ➔ Tap your **Profile Avatar** (top-right) ➔ Tap **Cloud Backend Settings**.
   - Paste your **Supabase URL** and **Anon Key**, then tap **Test & Save**.
2. **Or via `www/supabase-config.js`**:
   - Paste your URL and Anon Key into `DEFAULT_SUPABASE_CONFIG` in `www/supabase-config.js`.

---

### Features Enabled by Supabase:
- 🔐 **Real Staff & Owner Email Auth**: Secure password hashing, JWT tokens, automatic token refresh.
- ⚡ **Realtime Multi-Device Sync**: When waiter takes an order on Table 5 from Phone A, it appears instantly on the cashier tablet and all other staff devices!
- 🗄️ **Persistent Cloud Database**: All orders, receipts, customers, credit ledger, and menus stay safe in PostgreSQL.
- 📶 **Offline-First Resilience**: If internet connection drops inside the cafe, the POS continues taking orders locally and syncs automatically when reconnected!
