# Hacienda Elizabeth - Supabase CORS Configuration Guide

## Quick Fix for XMLHttpRequest Errors

The "XMLHttpRequest error" you're seeing is due to CORS (Cross-Origin Resource Sharing) restrictions. Here's how to fix it:

### 1. Supabase Dashboard Configuration

1. **Go to your Supabase Dashboard**: https://supabase.com/dashboard
2. **Select your project**: ekmvgwfrdrnivajlnorj
3. **Navigate to Settings → API**

### 2. CORS Configuration

In the **CORS** section, add these origins:

```
http://localhost:3000
http://localhost:8080
http://localhost:9090
http://127.0.0.1:3000
http://127.0.0.1:8080
http://127.0.0.1:9090
https://your-domain.com
```

### 3. Authentication Configuration

1. **Go to Authentication → URL Configuration**
2. **Set Site URL**: `http://localhost:3000` (or your main domain)
3. **Add Redirect URLs**:
   ```
   http://localhost:3000/**
   http://127.0.0.1:3000/**
   https://your-domain.com/**
   ```

### 4. Row Level Security (RLS) Policies

Ensure your tables have proper RLS policies:

#### For `sugar_records` table:
```sql
-- Allow anonymous users to read/write (for development)
CREATE POLICY "Allow anonymous access" ON sugar_records
FOR ALL USING (true);
```

#### For `inventory_items` table:
```sql
CREATE POLICY "Allow anonymous access" ON inventory_items
FOR ALL USING (true);
```

#### For `supplier_transactions` table:
```sql
CREATE POLICY "Allow anonymous access" ON supplier_transactions
FOR ALL USING (true);
```

#### For `alerts` table:
```sql
CREATE POLICY "Allow anonymous access" ON alerts
FOR ALL USING (true);
```

### 5. Test Connection

After making these changes:

1. **Restart your Flutter app**
2. **Check the console** - you should see:
   ```
   ✅ Supabase initialized successfully
   ✅ Real-time subscriptions initialized
   ```

### 6. Production Considerations

For production deployment:

1. **Replace localhost URLs** with your actual domain
2. **Implement proper RLS policies** based on user authentication
3. **Use environment variables** for sensitive configuration
4. **Enable SSL/TLS** for secure connections

### 7. Troubleshooting

If you still see errors:

1. **Check browser console** for specific CORS error messages
2. **Verify Supabase project URL** matches your configuration
3. **Ensure API keys** are correct
4. **Test with a simple query** to verify connectivity

### 8. Database Schema Verification

Make sure your database has these tables with correct structure:

- `sugar_records` (id, date, variety, soil_test, fertilizer, height_cm, notes, created_at)
- `inventory_items` (id, name, category, quantity, unit, last_updated, created_at)
- `supplier_transactions` (id, supplier_name, item_name, quantity, unit, amount, date, notes, created_at)
- `alerts` (id, title, message, severity, timestamp, read, created_at)
- `realtime_events` (id, entity, action, message, timestamp, created_at)

## Your Current Configuration

- **Project URL**: https://ekmvgwfrdrnivajlnorj.supabase.co
- **API Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbXZnd2ZyZHJuaXZhamxub3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMjEwMjcsImV4cCI6MjA3Njc5NzAyN30.oOiYmA5w-xTWlyoDyZum2OomDBrTvncTiHGvXh9PiK8

Follow these steps and your Hacienda Elizabeth system will be fully functional with real-time database synchronization!
