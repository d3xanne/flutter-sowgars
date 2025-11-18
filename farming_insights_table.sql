-- =====================================================
-- FARMING INSIGHTS TABLE - INTEGRATED INTO HACIENDA ELIZABETH SCHEMA
-- =====================================================
-- This section adds the farming insights functionality to the existing database

-- Farming Insights Table
CREATE TABLE IF NOT EXISTS farming_insights (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    title TEXT NOT NULL,
    variety TEXT NOT NULL,
    water_requirement TEXT NOT NULL,
    best_planting_month TEXT NOT NULL,
    harvest_estimation TEXT NOT NULL,
    fertilizer_type TEXT NOT NULL,
    fertilizer_amount TEXT NOT NULL,
    estimated_income DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    net_profit DECIMAL(15,2) NOT NULL,
    soil_type TEXT NOT NULL,
    climate_zone TEXT NOT NULL,
    recommendations TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_farming_insights_variety ON farming_insights(variety);
CREATE INDEX idx_farming_insights_soil_type ON farming_insights(soil_type);
CREATE INDEX idx_farming_insights_climate_zone ON farming_insights(climate_zone);
CREATE INDEX idx_farming_insights_created_at ON farming_insights(created_at);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_farming_insights_updated_at 
    BEFORE UPDATE ON farming_insights 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO farming_insights (
    id, title, variety, water_requirement, best_planting_month, 
    harvest_estimation, fertilizer_type, fertilizer_amount, 
    estimated_income, total_cost, net_profit, soil_type, 
    climate_zone, recommendations, created_at, updated_at
) VALUES (
    'sample_1',
    'Farming Insight for Phil 2018 - 2.0 hectares',
    'Phil 2018',
    '3600 liters per day (108000 liters per month)',
    'March, April, May',
    '180.0 tons in 12 months (15/12/2024)',
    'NPK 16-16-16',
    '600 kg (12.0 bags)',
    504000.00,
    180000.00,
    324000.00,
    'Loam',
    'Tropical Wet',
    '• Plant Phil 2018 variety for optimal yield (90.0 tons/hectare)\n• Expected maturity period: 12 months\n• Sugar content: 14.0%\n• Water requirement: 3600 liters per day (108000 liters per month)\n• Install efficient irrigation system for optimal water distribution\n• Use NPK 16-16-16 fertilizer\n• Apply 600 kg (12.0 bags) for optimal growth\n• Split application: 50% at planting, 25% at 3 months, 25% at 6 months\n• Soil type: Medium water retention, Good drainage\n• Maintain pH level between 6.0-7.0\n• Regular soil testing recommended every 3 months\n• Climate zone: High (2000-4000mm) rainfall, 25-30°C temperature\n• Best planting months: March, April, May\n• Monitor weather conditions for optimal planting timing\n• Disease resistance: Very High\n• Regular field monitoring for pests and diseases\n• Implement integrated pest management (IPM) strategies\n• Plan harvest during dry season for better sugar quality\n• Ensure proper storage facilities for harvested cane\n• Coordinate with sugar mill for timely delivery',
    NOW(),
    NOW()
);

-- Create a view for easy querying of insights with formatted financial data
CREATE VIEW farming_insights_summary AS
SELECT 
    id,
    title,
    variety,
    soil_type,
    climate_zone,
    CONCAT('₱', TO_CHAR(estimated_income, 'FM999,999,999')) as formatted_income,
    CONCAT('₱', TO_CHAR(total_cost, 'FM999,999,999')) as formatted_cost,
    CONCAT('₱', TO_CHAR(net_profit, 'FM999,999,999')) as formatted_profit,
    created_at
FROM farming_insights
ORDER BY created_at DESC;

-- Create a function to generate insights (PostgreSQL version)
CREATE OR REPLACE FUNCTION GenerateFarmingInsight(
    p_soil_type VARCHAR(100),
    p_climate_zone VARCHAR(100),
    p_farm_size DECIMAL(10,2),
    p_variety VARCHAR(100)
)
RETURNS TABLE(
    id VARCHAR(255),
    title VARCHAR(500),
    variety VARCHAR(100),
    water_requirement TEXT,
    best_planting_month VARCHAR(200),
    harvest_estimation TEXT,
    fertilizer_type VARCHAR(200),
    fertilizer_amount VARCHAR(200),
    estimated_income DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    net_profit DECIMAL(15,2),
    soil_type VARCHAR(100),
    climate_zone VARCHAR(100),
    recommendations TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
DECLARE
    v_insight_id VARCHAR(255);
    v_title VARCHAR(500);
    v_water_req TEXT;
    v_planting_month VARCHAR(200);
    v_harvest_est TEXT;
    v_fertilizer_type VARCHAR(200);
    v_fertilizer_amount VARCHAR(200);
    v_estimated_income DECIMAL(15,2);
    v_total_cost DECIMAL(15,2);
    v_net_profit DECIMAL(15,2);
    v_recommendations TEXT;
BEGIN
    -- Generate unique ID
    v_insight_id := 'insight_' || EXTRACT(EPOCH FROM NOW())::TEXT || '_' || FLOOR(RANDOM() * 1000)::TEXT;
    
    -- Generate title
    v_title := 'Farming Insight for ' || p_variety || ' - ' || p_farm_size || ' hectares';
    
    -- Calculate water requirement (simplified)
    v_water_req := (p_farm_size * 1800)::TEXT || ' liters per day (' || (p_farm_size * 54000)::TEXT || ' liters per month)';
    
    -- Set planting month based on climate zone
    CASE p_climate_zone
        WHEN 'Tropical Wet' THEN v_planting_month := 'March, April, May';
        WHEN 'Tropical Dry' THEN v_planting_month := 'June, July, August';
        WHEN 'Subtropical' THEN v_planting_month := 'September, October, November';
        ELSE v_planting_month := 'March, April, May';
    END CASE;
    
    -- Calculate harvest estimation
    v_harvest_est := (p_farm_size * 85)::TEXT || ' tons in 12 months';
    
    -- Set fertilizer details
    v_fertilizer_type := 'NPK 16-16-16';
    v_fertilizer_amount := (p_farm_size * 300)::TEXT || ' kg (' || (p_farm_size * 6)::TEXT || ' bags)';
    
    -- Calculate financials (simplified)
    v_estimated_income := p_farm_size * 85 * 2700; -- 85 tons/hectare * 2700 PHP/ton
    v_total_cost := p_farm_size * 90000; -- 90,000 PHP per hectare
    v_net_profit := v_estimated_income - v_total_cost;
    
    -- Generate recommendations
    v_recommendations := '• Plant ' || p_variety || ' variety for optimal yield' || E'\n' ||
        '• Water requirement: ' || v_water_req || E'\n' ||
        '• Best planting months: ' || v_planting_month || E'\n' ||
        '• Use ' || v_fertilizer_type || ' fertilizer' || E'\n' ||
        '• Apply ' || v_fertilizer_amount || ' for optimal growth' || E'\n' ||
        '• Regular soil testing recommended every 3 months' || E'\n' ||
        '• Monitor weather conditions for optimal planting timing' || E'\n' ||
        '• Implement integrated pest management (IPM) strategies';
    
    -- Insert the insight
    INSERT INTO farming_insights (
        id, title, variety, water_requirement, best_planting_month,
        harvest_estimation, fertilizer_type, fertilizer_amount,
        estimated_income, total_cost, net_profit, soil_type,
        climate_zone, recommendations, created_at, updated_at
    ) VALUES (
        v_insight_id, v_title, p_variety, v_water_req, v_planting_month,
        v_harvest_est, v_fertilizer_type, v_fertilizer_amount,
        v_estimated_income, v_total_cost, v_net_profit, p_soil_type,
        p_climate_zone, v_recommendations, NOW(), NOW()
    );
    
    -- Return the generated insight
    RETURN QUERY
    SELECT * FROM farming_insights WHERE farming_insights.id = v_insight_id;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed for your database setup)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON farming_insights TO 'your_app_user'@'localhost';
-- GRANT EXECUTE ON PROCEDURE GenerateFarmingInsight TO 'your_app_user'@'localhost';
