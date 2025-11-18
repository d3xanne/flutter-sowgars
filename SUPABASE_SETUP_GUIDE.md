# Supabase Database Setup Guide for Hacienda Elizabeth

## 🚀 Quick Setup

### Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign up/Login with your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `hacienda-elizabeth`
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to Philippines (Singapore or Tokyo)
6. Click "Create new project"
7. Wait for project to be ready (2-3 minutes)

### Step 2: Your Credentials (Already Provided)
✅ **Project URL**: `https://ekmvgwfrdrnivajlnorj.supabase.co`
✅ **Anon/Public Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbXZnd2ZyZHJuaXZhamxub3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMjEwMjcsImV4cCI6MjA3Njc5NzAyN30.oOiYmA5w-xTWlyoDyZum2OomDBrTvncTiHGvXh9PiK8`
✅ **Service Role Key**: `[Your Service Role Key - Get from Supabase Dashboard]`

### Step 3: Create Database Tables
**IMPORTANT**: Use the complete `DATABASE_SCHEMA.sql` file I created for you. It contains:
- All necessary tables with proper structure
- Performance indexes
- Row Level Security (RLS) policies
- Sample data for testing
- Utility functions and views
- Automatic timestamp triggers

Run the complete SQL in your Supabase SQL Editor:

```sql
-- Enable Row Level Security
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create Sugar Records Table
CREATE TABLE sugar_records (
  id TEXT PRIMARY KEY,
  date DATE NOT NULL,
  variety TEXT NOT NULL,
  soil_test TEXT NOT NULL,
  fertilizer TEXT NOT NULL,
  height_cm INTEGER NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Inventory Items Table
CREATE TABLE inventory_items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit TEXT NOT NULL,
  last_updated DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Supplier Transactions Table
CREATE TABLE supplier_transactions (
  id TEXT PRIMARY KEY,
  supplier_name TEXT NOT NULL,
  item_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  date DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Alerts Table
CREATE TABLE alerts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('info', 'warning', 'error')),
  read BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Realtime Events Table
CREATE TABLE realtime_events (
  id TEXT PRIMARY KEY,
  entity TEXT NOT NULL,
  action TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for all tables
ALTER TABLE sugar_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE realtime_events ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all for now - you can restrict later)
CREATE POLICY "Allow all operations on sugar_records" ON sugar_records
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on inventory_items" ON inventory_items
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on supplier_transactions" ON supplier_transactions
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on alerts" ON alerts
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on realtime_events" ON realtime_events
  FOR ALL USING (true);

-- Create indexes for better performance
CREATE INDEX idx_sugar_records_date ON sugar_records(date);
CREATE INDEX idx_inventory_items_category ON inventory_items(category);
CREATE INDEX idx_supplier_transactions_date ON supplier_transactions(date);
CREATE INDEX idx_alerts_timestamp ON alerts(timestamp);
CREATE INDEX idx_realtime_events_timestamp ON realtime_events(timestamp);
```

### Step 4: App Configuration (Already Updated)
✅ **Your credentials are already configured in the app!**

The following files have been updated with your actual Supabase credentials:
- `lib/services/supabase_service.dart` - Main database service
- `lib/main.dart` - App initialization
- `lib/services/local_repository.dart` - Hybrid storage (Supabase + local)

**No further configuration needed!** Your app is ready to connect to Supabase.

### Step 5: Test Your Setup
1. **Run the database schema**: Copy and paste the entire `DATABASE_SCHEMA.sql` content into your Supabase SQL Editor
2. **Test the app**: Your Flutter app is already configured and running
3. **Check connection**: Go to Settings → Database Status to test the connection
4. **Verify data**: Check that sample data appears in your app

## 🔧 Advanced Configuration

### Authentication (Optional)
If you want user authentication:

```sql
-- Create user profiles table
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  farm_name TEXT,
  location TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR ALL USING (auth.uid() = id);
```

### Real-time Subscriptions
Your app will automatically receive real-time updates when data changes in the database.

### Backup & Recovery
- Supabase automatically backs up your database
- You can restore from any point in time
- Export data anytime from the dashboard

## 🚨 Security Best Practices

1. **Never commit credentials to version control**
2. **Use environment variables for production**
3. **Set up proper RLS policies for multi-user scenarios**
4. **Regularly rotate your API keys**
5. **Monitor usage in the Supabase dashboard**

## 📊 Monitoring & Analytics

- **Database**: Monitor queries and performance
- **API**: Track usage and errors
- **Auth**: User management and security
- **Storage**: File uploads (if needed)

## 🆘 Troubleshooting

### Common Issues:
1. **Connection failed**: Check your URL and API key
2. **Permission denied**: Check RLS policies
3. **Table not found**: Run the SQL setup script
4. **Real-time not working**: Check if tables have RLS enabled

### Getting Help:
- Supabase Documentation: https://supabase.com/docs
- Community Discord: https://discord.supabase.com
- GitHub Issues: https://github.com/supabase/supabase

## 💰 Pricing

- **Free Tier**: 500MB database, 2GB bandwidth, 50MB file storage
- **Pro Tier**: $25/month for production use
- **Team Tier**: $599/month for teams

For a farming app, the free tier should be sufficient for testing and small-scale use.

---

**Next Steps**: After setting up Supabase, your app will have:
- ✅ Cloud database storage
- ✅ Real-time data synchronization
- ✅ Automatic backups
- ✅ Scalable infrastructure
- ✅ Professional data management

Your sugarcane farming data will be safely stored in the cloud and accessible from anywhere! 🌾☁️
