-- =====================================================
-- HACIENDA ELIZABETH - COMPLETE DATABASE SCHEMA
-- =====================================================
-- Run this SQL in your Supabase SQL Editor
-- Project: https://ekmvgwfrdrnivajlnorj.supabase.co

-- =====================================================
-- 1. ENABLE EXTENSIONSrr
-- =====================================================
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 2. CREATE CORE TABLES
-- =====================================================

-- Sugar Records Table
CREATE TABLE IF NOT EXISTS sugar_records (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  date DATE NOT NULL,
  variety TEXT NOT NULL,
  soil_test TEXT NOT NULL,
  fertilizer TEXT NOT NULL,
  height_cm INTEGER NOT NULL DEFAULT 0,
  notes TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory Items Table
CREATE TABLE IF NOT EXISTS inventory_items (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  unit TEXT NOT NULL DEFAULT 'pieces',
  last_updated DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Supplier Transactions Table
CREATE TABLE IF NOT EXISTS supplier_transactions (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  supplier_name TEXT NOT NULL,
  item_name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  unit TEXT NOT NULL DEFAULT 'pieces',
  amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  notes TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error', 'success')),
  read BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Realtime Events Table
CREATE TABLE IF NOT EXISTS realtime_events (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  entity TEXT NOT NULL,
  action TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weather Data Table (for future weather integration)
CREATE TABLE IF NOT EXISTS weather_data (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  city TEXT NOT NULL,
  date DATE NOT NULL,
  temperature DECIMAL(5,2),
  humidity INTEGER,
  precipitation DECIMAL(5,2),
  wind_speed DECIMAL(5,2),
  conditions TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Farm Settings Table
CREATE TABLE IF NOT EXISTS farm_settings (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  setting_key TEXT UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Sugar Records Indexes
CREATE INDEX IF NOT EXISTS idx_sugar_records_date ON sugar_records(date);
CREATE INDEX IF NOT EXISTS idx_sugar_records_variety ON sugar_records(variety);
CREATE INDEX IF NOT EXISTS idx_sugar_records_created_at ON sugar_records(created_at);

-- Inventory Items Indexes
CREATE INDEX IF NOT EXISTS idx_inventory_items_category ON inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_inventory_items_name ON inventory_items(name);
CREATE INDEX IF NOT EXISTS idx_inventory_items_last_updated ON inventory_items(last_updated);

-- Supplier Transactions Indexes
CREATE INDEX IF NOT EXISTS idx_supplier_transactions_date ON supplier_transactions(date);
CREATE INDEX IF NOT EXISTS idx_supplier_transactions_supplier ON supplier_transactions(supplier_name);
CREATE INDEX IF NOT EXISTS idx_supplier_transactions_amount ON supplier_transactions(amount);

-- Alerts Indexes
CREATE INDEX IF NOT EXISTS idx_alerts_timestamp ON alerts(timestamp);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_read ON alerts(read);

-- Realtime Events Indexes
CREATE INDEX IF NOT EXISTS idx_realtime_events_timestamp ON realtime_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_realtime_events_entity ON realtime_events(entity);

-- Weather Data Indexes
CREATE INDEX IF NOT EXISTS idx_weather_data_city_date ON weather_data(city, date);
CREATE INDEX IF NOT EXISTS idx_weather_data_date ON weather_data(date);

-- Farm Settings Indexes
CREATE INDEX IF NOT EXISTS idx_farm_settings_key ON farm_settings(setting_key);

-- =====================================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE sugar_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE realtime_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. CREATE RLS POLICIES
-- =====================================================

-- Allow all operations for now (you can restrict later for multi-user scenarios)
CREATE POLICY "Allow all operations on sugar_records" ON sugar_records
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on inventory_items" ON inventory_items
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on supplier_transactions" ON supplier_transactions
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on alerts" ON alerts
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on realtime_events" ON realtime_events
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on weather_data" ON weather_data
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on farm_settings" ON farm_settings
  FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 6. CREATE TRIGGERS FOR UPDATED_AT
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_sugar_records_updated_at 
  BEFORE UPDATE ON sugar_records 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_items_updated_at 
  BEFORE UPDATE ON inventory_items 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_supplier_transactions_updated_at 
  BEFORE UPDATE ON supplier_transactions 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_farm_settings_updated_at 
  BEFORE UPDATE ON farm_settings 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. INSERT DEFAULT DATA
-- =====================================================

-- Insert default farm settings
INSERT INTO farm_settings (setting_key, setting_value, description) VALUES
('farm_name', 'Hacienda Elizabeth', 'Name of the farm'),
('farm_location', 'Philippines', 'Location of the farm'),
('currency', 'PHP', 'Default currency'),
('language', 'en', 'Default language'),
('low_stock_threshold', '10', 'Low stock alert threshold'),
('auto_sync_enabled', 'true', 'Enable automatic data sync'),
('notifications_enabled', 'true', 'Enable push notifications'),
('dark_mode_enabled', 'false', 'Enable dark mode'),
('export_format', 'csv', 'Default export format'),
('backup_frequency', 'daily', 'How often to backup data')
ON CONFLICT (setting_key) DO NOTHING;

-- Insert sample sugar varieties
INSERT INTO sugar_records (id, date, variety, soil_test, fertilizer, height_cm, notes) VALUES
('sample-1', CURRENT_DATE - INTERVAL '30 days', 'SP70-1143', 'pH 6.5, Good', 'NPK 14-14-14', 45, 'First planting batch'),
('sample-2', CURRENT_DATE - INTERVAL '15 days', 'VMC 84-524', 'pH 6.2, Fair', 'NPK 16-20-0', 38, 'Second planting batch'),
('sample-3', CURRENT_DATE - INTERVAL '7 days', 'SP70-1143', 'pH 6.8, Excellent', 'NPK 14-14-14', 52, 'Third planting batch')
ON CONFLICT (id) DO NOTHING;

-- Insert sample inventory items
INSERT INTO inventory_items (id, name, category, quantity, unit, last_updated) VALUES
('inv-1', 'NPK 14-14-14 Fertilizer', 'Fertilizer', 25, 'bags', CURRENT_DATE),
('inv-2', 'Seeds SP70-1143', 'Seeds', 150, 'kg', CURRENT_DATE - INTERVAL '5 days'),
('inv-3', 'Pesticide Roundup', 'Pesticide', 8, 'liters', CURRENT_DATE - INTERVAL '10 days'),
('inv-4', 'Irrigation Pipes', 'Equipment', 12, 'pieces', CURRENT_DATE - INTERVAL '15 days')
ON CONFLICT (id) DO NOTHING;

-- Insert sample supplier transactions
INSERT INTO supplier_transactions (id, supplier_name, item_name, quantity, unit, amount, date, notes) VALUES
('sup-1', 'AgriSupply Co.', 'NPK 14-14-14', 50, 'bags', 2500.00, CURRENT_DATE - INTERVAL '20 days', 'Bulk order discount'),
('sup-2', 'SeedMaster Inc.', 'SP70-1143 Seeds', 100, 'kg', 1500.00, CURRENT_DATE - INTERVAL '15 days', 'Premium quality seeds'),
('sup-3', 'FarmChem Ltd.', 'Roundup Pesticide', 20, 'liters', 800.00, CURRENT_DATE - INTERVAL '10 days', 'Organic certified'),
('sup-4', 'Equipment Pro', 'Irrigation Pipes', 20, 'pieces', 1200.00, CURRENT_DATE - INTERVAL '5 days', 'Durable PVC pipes')
ON CONFLICT (id) DO NOTHING;

-- Insert sample alerts
INSERT INTO alerts (id, title, message, severity, read, timestamp) VALUES
('alert-1', 'Low Stock Alert', 'NPK 14-14-14 fertilizer is running low (5 bags remaining)', 'warning', false, NOW() - INTERVAL '2 hours'),
('alert-2', 'Weather Update', 'Heavy rain expected tomorrow. Consider covering seedlings.', 'info', false, NOW() - INTERVAL '1 hour'),
('alert-3', 'Harvest Ready', 'Batch 1 sugarcane is ready for harvest', 'success', false, NOW() - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;

-- Insert sample realtime events
INSERT INTO realtime_events (id, entity, action, message, timestamp) VALUES
('event-1', 'sugar', 'create', 'New sugar record added: SP70-1143 variety', NOW() - INTERVAL '1 hour'),
('event-2', 'inventory', 'update', 'Inventory updated: NPK fertilizer stock reduced', NOW() - INTERVAL '45 minutes'),
('event-3', 'supplier', 'create', 'New supplier transaction: AgriSupply Co. order', NOW() - INTERVAL '30 minutes'),
('event-4', 'weather', 'update', 'Weather data updated for Manila', NOW() - INTERVAL '15 minutes')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 8. CREATE VIEWS FOR REPORTING
-- =====================================================

-- View for sugar growth summary
CREATE OR REPLACE VIEW sugar_growth_summary AS
SELECT 
  variety,
  COUNT(*) as total_records,
  AVG(height_cm) as avg_height,
  MIN(height_cm) as min_height,
  MAX(height_cm) as max_height,
  MIN(date) as first_planting,
  MAX(date) as last_planting
FROM sugar_records
GROUP BY variety
ORDER BY avg_height DESC;

-- View for inventory summary
CREATE OR REPLACE VIEW inventory_summary AS
SELECT 
  category,
  COUNT(*) as total_items,
  SUM(quantity) as total_quantity,
  AVG(quantity) as avg_quantity
FROM inventory_items
GROUP BY category
ORDER BY total_quantity DESC;

-- View for supplier spending summary
CREATE OR REPLACE VIEW supplier_spending_summary AS
SELECT 
  supplier_name,
  COUNT(*) as total_transactions,
  SUM(amount) as total_spent,
  AVG(amount) as avg_transaction_amount,
  MIN(date) as first_transaction,
  MAX(date) as last_transaction
FROM supplier_transactions
GROUP BY supplier_name
ORDER BY total_spent DESC;

-- View for recent activity
CREATE OR REPLACE VIEW recent_activity AS
SELECT 
  'sugar' as entity_type,
  'Sugar Record' as description,
  created_at as activity_time
FROM sugar_records
UNION ALL
SELECT 
  'inventory' as entity_type,
  'Inventory Item' as description,
  created_at as activity_time
FROM inventory_items
UNION ALL
SELECT 
  'supplier' as entity_type,
  'Supplier Transaction' as description,
  created_at as activity_time
FROM supplier_transactions
ORDER BY activity_time DESC
LIMIT 50;

-- =====================================================
-- 9. CREATE FUNCTIONS FOR COMMON OPERATIONS
-- =====================================================

-- Function to get low stock items
CREATE OR REPLACE FUNCTION get_low_stock_items(threshold INTEGER DEFAULT 10)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  category TEXT,
  quantity INTEGER,
  unit TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    inv.id,
    inv.name,
    inv.category,
    inv.quantity,
    inv.unit
  FROM inventory_items inv
  WHERE inv.quantity <= threshold
  ORDER BY inv.quantity ASC;
END;
$$ LANGUAGE plpgsql;

-- Function to get monthly spending
CREATE OR REPLACE FUNCTION get_monthly_spending(year_param INTEGER, month_param INTEGER)
RETURNS TABLE (
  total_amount DECIMAL(12,2),
  transaction_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    SUM(st.amount) as total_amount,
    COUNT(*) as transaction_count
  FROM supplier_transactions st
  WHERE EXTRACT(YEAR FROM st.date) = year_param
    AND EXTRACT(MONTH FROM st.date) = month_param;
END;
$$ LANGUAGE plpgsql;

-- Function to clean old events (for maintenance)
CREATE OR REPLACE FUNCTION clean_old_events(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM realtime_events 
  WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. GRANT PERMISSIONS
-- =====================================================

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
-- Schema setup complete! Your database is ready for the Hacienda Elizabeth app.
-- 
-- Tables created:
-- ✅ sugar_records - Sugarcane monitoring data
-- ✅ inventory_items - Farm inventory management
-- ✅ supplier_transactions - Supplier purchase records
-- ✅ alerts - System notifications
-- ✅ realtime_events - Activity tracking
-- ✅ weather_data - Weather information
-- ✅ farm_settings - App configuration
--
-- Features enabled:
-- ✅ Row Level Security (RLS)
-- ✅ Automatic timestamps
-- ✅ Performance indexes
-- ✅ Sample data
-- ✅ Reporting views
-- ✅ Utility functions
--
-- Your app is now ready to connect to Supabase!
