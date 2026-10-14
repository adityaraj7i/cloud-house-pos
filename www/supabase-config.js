// ==============================================================================
// CLOUD HOUSE POS — SUPABASE CLIENT & CLOUD SYNC ENGINE
// Provides Production Auth, Realtime Postgres Sync, and Offline-First Resilience
// ==============================================================================

const SUPABASE_STORAGE_KEY = 'cloud_house_supabase_config_v1';

// Default Supabase Configuration (Can be customized directly from in-app Cloud Settings)
const DEFAULT_SUPABASE_CONFIG = {
  url: '',
  anonKey: ''
};

class CloudHouseBackend {
  constructor() {
    this.client = null;
    this.isConnected = false;
    this.realtimeChannel = null;
    this.initClient();
  }

  getConfig() {
    try {
      const stored = localStorage.getItem(SUPABASE_STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        if (parsed.url && parsed.anonKey) return parsed;
      }
    } catch (e) {
      console.warn('Failed to read Supabase config from storage:', e);
    }
    return DEFAULT_SUPABASE_CONFIG;
  }

  saveConfig(url, anonKey) {
    const trimmedUrl = (url || '').trim().replace(/\/+$/, '');
    const trimmedKey = (anonKey || '').trim();
    const config = { url: trimmedUrl, anonKey: trimmedKey };
    localStorage.setItem(SUPABASE_STORAGE_KEY, JSON.stringify(config));
    this.initClient();
    return this.isConfigured();
  }

  isConfigured() {
    const config = this.getConfig();
    return Boolean(config.url && config.anonKey && config.url.startsWith('https://'));
  }

  initClient() {
    const config = this.getConfig();
    if (this.isConfigured() && window.supabase && window.supabase.createClient) {
      try {
        this.client = window.supabase.createClient(config.url, config.anonKey, {
          auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: false
          }
        });
        this.isConnected = true;
      } catch (err) {
        console.error('Supabase initialization failed:', err);
        this.client = null;
        this.isConnected = false;
      }
    } else {
      this.client = null;
      this.isConnected = false;
    }
  }

  async testConnection() {
    if (!this.client) return { success: false, message: 'Supabase URL or Anon Key is missing.' };
    try {
      const { data, error } = await this.client.from('cafe_tables').select('count', { count: 'exact', head: true });
      if (error && error.code !== 'PGRST116') {
        // Even if tables don't exist yet, if auth/network succeeded, consider connected
        if (error.message.includes('relation "public.cafe_tables" does not exist')) {
          return { success: true, message: 'Connected to Supabase! (Please run schema.sql in SQL Editor).' };
        }
        return { success: false, message: error.message };
      }
      return { success: true, message: 'Successfully connected to Supabase Cloud!' };
    } catch (err) {
      return { success: false, message: err.message || 'Network error connecting to Supabase.' };
    }
  }

  // ----------------------------------------------------------------------------
  // AUTHENTICATION (Real Email Sign In / Sign Up with session management)
  // ----------------------------------------------------------------------------
  async signUp(email, password, fullName) {
    if (!this.client) {
      return { success: true, isOffline: true, user: { email, user_metadata: { full_name: fullName } } };
    }
    try {
      const { data, error } = await this.client.auth.signUp({
        email: email.trim(),
        password: password,
        options: {
          data: {
            full_name: fullName.trim()
          }
        }
      });
      if (error) throw error;
      return {
        success: true,
        user: data.user,
        session: data.session,
        needsEmailConfirm: !data.session && Boolean(data.user)
      };
    } catch (err) {
      return { success: false, error: err.message || 'Failed to sign up with Supabase' };
    }
  }

  async signIn(email, password) {
    if (!this.client) {
      return { success: true, isOffline: true, user: { email, user_metadata: { full_name: 'Staff' } } };
    }
    try {
      const { data, error } = await this.client.auth.signInWithPassword({
        email: email.trim(),
        password: password
      });
      if (error) throw error;
      return {
        success: true,
        user: data.user,
        session: data.session
      };
    } catch (err) {
      return { success: false, error: err.message || 'Invalid email or password' };
    }
  }

  async signOut() {
    if (this.client) {
      try {
        await this.client.auth.signOut();
      } catch (err) {
        console.warn('SignOut warning:', err);
      }
    }
  }

  async getCurrentSession() {
    if (!this.client) return null;
    try {
      const { data: { session } } = await this.client.auth.getSession();
      return session;
    } catch (err) {
      console.warn('Error reading session:', err);
      return null;
    }
  }

  // ----------------------------------------------------------------------------
  // DATABASE CLOUD SYNC (Orders, Customers, Menu Items, Tables)
  // ----------------------------------------------------------------------------
  async upsertOrder(order) {
    if (!this.client) return;
    try {
      await this.client.from('orders').upsert({
        id: order.id,
        table_name: order.table,
        status: order.status,
        order_time: order.time,
        taken_by: order.takenBy || 'Staff',
        payment_method: order.paymentMethod || 'Cash',
        discount: parseFloat(order.discount) || 0,
        items: order.items || [],
        updated_at: new Date().toISOString()
      });
    } catch (err) {
      console.warn(`[CloudSync] Order ${order.id} sync failed:`, err);
    }
  }

  async fetchOrders() {
    if (!this.client) return null;
    try {
      const { data, error } = await this.client
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100);
      if (error) throw error;
      return data.map(o => ({
        id: o.id,
        table: o.table_name,
        status: o.status,
        time: o.order_time,
        takenBy: o.taken_by,
        paymentMethod: o.payment_method,
        discount: parseFloat(o.discount) || 0,
        items: Array.isArray(o.items) ? o.items : []
      }));
    } catch (err) {
      console.warn('[CloudSync] Failed to fetch orders from cloud:', err);
      return null;
    }
  }

  async upsertCustomer(customer) {
    if (!this.client) return;
    try {
      await this.client.from('customers').upsert({
        name: customer.name,
        initials: customer.initials || 'C',
        phone: customer.phone || '',
        email: customer.email || '',
        address: customer.address || '',
        total_due: parseFloat(customer.due) || 0,
        color: customer.color || '#1BA63F'
      }, { onConflict: 'name' });
    } catch (err) {
      console.warn('[CloudSync] Customer sync failed:', err);
    }
  }

  async fetchCustomers() {
    if (!this.client) return null;
    try {
      const { data, error } = await this.client
        .from('customers')
        .select('*')
        .order('name', { ascending: true });
      if (error) throw error;
      return data.map(c => ({
        initials: c.initials || 'C',
        name: c.name,
        phone: c.phone || '',
        email: c.email || '',
        address: c.address || '',
        due: parseFloat(c.total_due) || 0,
        color: c.color || '#1BA63F'
      }));
    } catch (err) {
      console.warn('[CloudSync] Failed to fetch customers:', err);
      return null;
    }
  }

  // ----------------------------------------------------------------------------
  // REALTIME SUBSCRIPTION (Push updates to state across devices)
  // ----------------------------------------------------------------------------
  setupRealtimeListeners(onOrderChange) {
    if (!this.client) return;
    if (this.realtimeChannel) {
      this.client.removeChannel(this.realtimeChannel);
    }
    this.realtimeChannel = this.client
      .channel('public:orders')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'orders' }, (payload) => {
        if (typeof onOrderChange === 'function') {
          onOrderChange(payload);
        }
      })
      .subscribe((status) => {
        console.log('[Supabase Realtime] Orders subscription status:', status);
      });
  }
}

// Export singleton to window
window.cloudBackend = new CloudHouseBackend();
