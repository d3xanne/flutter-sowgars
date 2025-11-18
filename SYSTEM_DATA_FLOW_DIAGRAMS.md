# Hacienda Elizabeth - Data Flow Diagrams (DFD)
## Complete System Documentation from Context to Level 4

---

## 📊 **CONTEXT DIAGRAM (Level 0 DFD)**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                    HACIENDA ELIZABETH SYSTEM (0)                        │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Processes:                                                      │  │
│  │  • Manage Sugar Records                                          │  │
│  │  • Manage Inventory                                              │  │
│  │  • Manage Supplier Transactions                                  │  │
│  │  • Manage Weather Data                                           │  │
│  │  • Generate Insights & Analytics                                │  │
│  │  • Manage Alerts & Notifications                                 │  │
│  │  • Generate Reports & Export Data                                │  │
│  │  • Real-time Data Synchronization                                │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │                    │
         │                    │                    │                    │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │  User   │         │ Weather  │         │Supplier │         │Supabase │
    │(Manager)│         │   API    │         │         │         │Database │
    └────┬────┘         └────┬────┘         └────┬────┘         └────┬────┘
         │                    │                    │                    │
```

### **External Entities:**
- **E1: User (Farm Manager/Admin)** - System operator
- **E2: Weather API** - External weather service (OpenWeatherMap)
- **E3: Supplier** - External supplier entities
- **E4: Supabase Database** - Cloud database service

### **Data Flows:**

**From User (E1) to System (0):**
- User Commands (Sugar Record Management, Inventory Management, Supplier Management, Settings)
- Reports Request
- Export Request
- Insight Generation Request
- Data Cleanup Request

**From System (0) to User (E1):**
- Dashboard Display
- Sugar Records Data
- Inventory Data
- Supplier Transaction Data
- Weather Information
- Alerts & Notifications
- Reports & Analytics
- Exported Data (CSV)

**From Weather API (E2) to System (0):**
- Weather Data (Temperature, Humidity, Wind Speed, Precipitation, Conditions)

**From System (0) to Weather API (E2):**
- Weather API Request (Location: Talisay City, Negros Occidental)

**From Supplier (E3) to System (0):**
- Supplier Transaction Data (Purchase Orders, Item Details, Amounts)

**From System (0) to Supabase Database (E4):**
- Sugar Records (CREATE, UPDATE, DELETE, READ)
- Inventory Items (CREATE, UPDATE, DELETE, READ)
- Supplier Transactions (CREATE, UPDATE, DELETE, READ)
- Alerts (CREATE, UPDATE, READ)
- Weather Data (CREATE, READ)
- Realtime Events (CREATE, READ)
- Farm Settings (CREATE, UPDATE, READ)
- Farming Insights (CREATE, READ)

**From Supabase Database (E4) to System (0):**
- Sugar Records Data
- Inventory Items Data
- Supplier Transactions Data
- Alerts Data
- Weather Data
- Realtime Events
- Farm Settings
- Farming Insights
- Real-time Change Notifications

---

## 📊 **LEVEL 1 DFD**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                         HACIENDA ELIZABETH SYSTEM                        │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  1.0             │  │  2.0             │  │  3.0             │   │
│  │  Manage Sugar    │  │  Manage          │  │  Manage Supplier │   │
│  │  Records         │  │  Inventory       │  │  Transactions    │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  4.0             │  │  5.0             │  │  6.0             │   │
│  │  Manage Weather  │  │  Generate        │  │  Manage Alerts  │   │
│  │  Data            │  │  Insights        │  │  & Notifications │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  7.0             │  │  8.0             │                            │
│  │  Generate        │  │  Synchronize     │                            │
│  │  Reports &       │  │  Data (Real-time)│                           │
│  │  Export Data     │  │                  │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │                    │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │  User   │         │ Weather │         │Supplier │         │Supabase│
    │(Manager)│         │   API   │         │         │         │Database│
    └─────────┘         └─────────┘         └─────────┘         └─────────┘
```

### **Processes (Level 1):**

1. **Process 1.0: Manage Sugar Records**
   - Create, Read, Update, Delete sugar records
   - Validate sugar record data
   - Track sugarcane growth metrics

2. **Process 2.0: Manage Inventory**
   - Create, Read, Update, Delete inventory items
   - Monitor stock levels
   - Track inventory categories

3. **Process 3.0: Manage Supplier Transactions**
   - Record supplier purchases
   - Track transaction amounts
   - Manage supplier relationships

4. **Process 4.0: Manage Weather Data**
   - Fetch weather from API
   - Store weather data
   - Display weather information

5. **Process 5.0: Generate Insights**
   - Analyze farming data
   - Generate recommendations
   - Calculate predictions

6. **Process 6.0: Manage Alerts & Notifications**
   - Create alerts
   - Monitor low stock
   - Send notifications

7. **Process 7.0: Generate Reports & Export Data**
   - Generate analytics reports
   - Export to CSV
   - Create data visualizations

8. **Process 8.0: Synchronize Data (Real-time)**
   - Sync with Supabase
   - Handle local storage
   - Manage real-time subscriptions

### **Data Stores (Level 1):**

- **D1: Sugar Records** - Stores all sugarcane monitoring records
- **D2: Inventory Items** - Stores all inventory/farm supplies
- **D3: Supplier Transactions** - Stores all supplier purchase records
- **D4: Alerts** - Stores system alerts and notifications
- **D5: Weather Data** - Stores weather information
- **D6: Realtime Events** - Stores activity tracking events
- **D7: Farm Settings** - Stores application configuration
- **D8: Farming Insights** - Stores generated farming insights

### **Data Flows (Level 1):**

**From User to Processes:**
- User → 1.0: Sugar Record Input
- User → 2.0: Inventory Input
- User → 3.0: Supplier Transaction Input
- User → 4.0: Weather Refresh Request
- User → 5.0: Generate Insight Request
- User → 6.0: Alert Acknowledgment
- User → 7.0: Report Request, Export Request
- User → 8.0: Sync Request

**From Processes to User:**
- 1.0 → User: Sugar Records Display
- 2.0 → User: Inventory Display
- 3.0 → User: Supplier Transactions Display
- 4.0 → User: Weather Display
- 5.0 → User: Insights Display
- 6.0 → User: Alerts Display
- 7.0 → User: Reports Display, Exported Files
- 8.0 → User: Sync Status

**From Processes to Data Stores:**
- 1.0 → D1: Sugar Records (Create/Update/Delete)
- 2.0 → D2: Inventory Items (Create/Update/Delete)
- 3.0 → D3: Supplier Transactions (Create/Update/Delete)
- 4.0 → D5: Weather Data (Create)
- 5.0 → D8: Farming Insights (Create)
- 6.0 → D4: Alerts (Create/Update)
- 8.0 → D1, D2, D3, D4, D5, D6, D7, D8: Sync Data

**From Data Stores to Processes:**
- D1 → 1.0, 5.0, 7.0, 8.0: Sugar Records Data
- D2 → 2.0, 5.0, 6.0, 7.0, 8.0: Inventory Items Data
- D3 → 3.0, 5.0, 7.0, 8.0: Supplier Transactions Data
- D4 → 6.0, 7.0, 8.0: Alerts Data
- D5 → 4.0, 5.0, 7.0, 8.0: Weather Data
- D6 → 7.0, 8.0: Realtime Events Data
- D7 → 8.0: Farm Settings
- D8 → 5.0, 7.0: Farming Insights Data

**From Weather API to Process:**
- Weather API → 4.0: Weather Data Response

**From Process to Weather API:**
- 4.0 → Weather API: Weather Request

**From Supplier to Process:**
- Supplier → 3.0: Transaction Data

**From Supabase to Process:**
- Supabase → 8.0: Real-time Updates, Database Records

**From Process to Supabase:**
- 8.0 → Supabase: Database Operations (CRUD)

---

## 📊 **LEVEL 2 DFD - Process 1.0: Manage Sugar Records**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                    PROCESS 1.0: MANAGE SUGAR RECORDS                     │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  1.1             │  │  1.2             │  │  1.3             │   │
│  │  Create Sugar    │  │  Update Sugar    │  │  Delete Sugar    │   │
│  │  Record          │  │  Record          │  │  Record          │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  1.4             │  │  1.5             │                            │
│  │  Retrieve Sugar  │  │  Validate Sugar │                            │
│  │  Records         │  │  Record Data    │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D1      │        │ Process   │
    │         │          │  Sugar   │        │   8.0      │
    │         │          │ Records  │        │ (Sync)    │
    └─────────┘          └──────────┘        └───────────┘
```

### **Sub-processes (1.0):**

1. **1.1: Create Sugar Record**
   - Input: Date, Variety, Soil Test, Fertilizer, Height (cm), Notes
   - Validation: Date range, Variety selection, Height range
   - Output: New Sugar Record → D1

2. **1.2: Update Sugar Record**
   - Input: Record ID, Updated Fields
   - Validation: Record exists, Valid updates
   - Output: Updated Sugar Record → D1

3. **1.3: Delete Sugar Record**
   - Input: Record ID
   - Validation: Record exists
   - Output: Deletion Confirmation → D1

4. **1.4: Retrieve Sugar Records**
   - Input: Query Parameters (Date range, Variety filter)
   - Output: Sugar Records List → User

5. **1.5: Validate Sugar Record Data**
   - Input: All Sugar Record Fields
   - Validation Rules: Date format, Variety enum, Height > 0, Required fields
   - Output: Validation Result → 1.1, 1.2

### **Data Flows (1.0):**

- User → 1.1: New Sugar Record Data
- User → 1.2: Update Sugar Record Request
- User → 1.3: Delete Sugar Record Request
- User → 1.4: Retrieve Sugar Records Request
- 1.1 → 1.5: Record Data for Validation
- 1.2 → 1.5: Record Data for Validation
- 1.5 → 1.1: Validation Result
- 1.5 → 1.2: Validation Result
- 1.1 → D1: New Sugar Record
- 1.2 → D1: Updated Sugar Record
- 1.3 → D1: Delete Request
- D1 → 1.4: Sugar Records Data
- 1.4 → User: Sugar Records Display
- D1 → 8.0: Sugar Records for Sync
- 8.0 → D1: Synced Sugar Records

---

## 📊 **LEVEL 2 DFD - Process 2.0: Manage Inventory**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                    PROCESS 2.0: MANAGE INVENTORY                        │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  2.1             │  │  2.2             │  │  2.3             │   │
│  │  Create          │  │  Update          │  │  Delete          │   │
│  │  Inventory Item  │  │  Inventory Item  │  │  Inventory Item  │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  2.4             │  │  2.5             │  │  2.6             │   │
│  │  Retrieve        │  │  Check Low Stock│  │  Validate        │   │
│  │  Inventory       │  │  Levels          │  │  Inventory Data  │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D2      │        │ Process   │
    │         │          │Inventory  │        │   6.0     │
    │         │          │ Items     │        │ (Alerts)  │
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (2.0):**

1. **2.1: Create Inventory Item**
   - Input: Name, Category, Quantity, Unit, Last Updated
   - Validation: Required fields, Quantity >= 0, Valid category
   - Output: New Inventory Item → D2

2. **2.2: Update Inventory Item**
   - Input: Item ID, Updated Fields (Quantity, Category, etc.)
   - Validation: Item exists, Valid updates
   - Output: Updated Inventory Item → D2

3. **2.3: Delete Inventory Item**
   - Input: Item ID
   - Validation: Item exists
   - Output: Deletion Confirmation → D2

4. **2.4: Retrieve Inventory**
   - Input: Query Parameters (Category filter, Name search)
   - Output: Inventory Items List → User

5. **2.5: Check Low Stock Levels**
   - Input: Threshold (default: 10)
   - Process: Compare inventory quantities with threshold
   - Output: Low Stock Alert → 6.0 (Alert Management)

6. **2.6: Validate Inventory Data**
   - Input: All Inventory Fields
   - Validation Rules: Name required, Category enum, Quantity >= 0, Unit required
   - Output: Validation Result → 2.1, 2.2

### **Data Flows (2.0):**

- User → 2.1: New Inventory Item Data
- User → 2.2: Update Inventory Item Request
- User → 2.3: Delete Inventory Item Request
- User → 2.4: Retrieve Inventory Request
- 2.1 → 2.6: Item Data for Validation
- 2.2 → 2.6: Item Data for Validation
- 2.6 → 2.1: Validation Result
- 2.6 → 2.2: Validation Result
- 2.1 → D2: New Inventory Item
- 2.2 → D2: Updated Inventory Item
- 2.3 → D2: Delete Request
- D2 → 2.4: Inventory Items Data
- D2 → 2.5: Inventory Items for Low Stock Check
- 2.5 → 6.0: Low Stock Alert
- 2.4 → User: Inventory Display

---

## 📊 **LEVEL 2 DFD - Process 3.0: Manage Supplier Transactions**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│              PROCESS 3.0: MANAGE SUPPLIER TRANSACTIONS                  │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  3.1             │  │  3.2             │  │  3.3             │   │
│  │  Create          │  │  Update          │  │  Delete          │   │
│  │  Supplier        │  │  Supplier        │  │  Supplier        │   │
│  │  Transaction     │  │  Transaction     │  │  Transaction     │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  3.4             │  │  3.5             │                            │
│  │  Retrieve        │  │  Validate        │                            │
│  │  Supplier        │  │  Transaction     │                            │
│  │  Transactions    │  │  Data            │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D3      │        │ Process   │
    │Supplier │          │Supplier   │        │   2.0     │
    │         │          │Transactions│        │(Inventory)│
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (3.0):**

1. **3.1: Create Supplier Transaction**
   - Input: Supplier Name, Item Name, Quantity, Unit, Amount, Date, Notes
   - Validation: Required fields, Amount > 0, Valid date
   - Output: New Supplier Transaction → D3

2. **3.2: Update Supplier Transaction**
   - Input: Transaction ID, Updated Fields
   - Validation: Transaction exists, Valid updates
   - Output: Updated Supplier Transaction → D3

3. **3.3: Delete Supplier Transaction**
   - Input: Transaction ID
   - Validation: Transaction exists
   - Output: Deletion Confirmation → D3

4. **3.4: Retrieve Supplier Transactions**
   - Input: Query Parameters (Date range, Supplier filter)
   - Output: Supplier Transactions List → User

5. **3.5: Validate Transaction Data**
   - Input: All Transaction Fields
   - Validation Rules: Supplier name required, Amount > 0, Date format, Quantity > 0
   - Output: Validation Result → 3.1, 3.2

### **Data Flows (3.0):**

- User/Supplier → 3.1: New Transaction Data
- User → 3.2: Update Transaction Request
- User → 3.3: Delete Transaction Request
- User → 3.4: Retrieve Transactions Request
- 3.1 → 3.5: Transaction Data for Validation
- 3.2 → 3.5: Transaction Data for Validation
- 3.5 → 3.1: Validation Result
- 3.5 → 3.2: Validation Result
- 3.1 → D3: New Supplier Transaction
- 3.2 → D3: Updated Supplier Transaction
- 3.3 → D3: Delete Request
- D3 → 3.4: Supplier Transactions Data
- 3.4 → User: Supplier Transactions Display
- 3.1 → 2.0: Transaction triggers inventory update (if applicable)

---

## 📊 **LEVEL 2 DFD - Process 4.0: Manage Weather Data**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                    PROCESS 4.0: MANAGE WEATHER DATA                      │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  4.1             │  │  4.2             │  │  4.3             │   │
│  │  Fetch Weather   │  │  Store Weather   │  │  Retrieve        │   │
│  │  from API        │  │  Data           │  │  Weather Data    │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐                                                  │
│  │  4.4             │                                                  │
│  │  Format Weather  │                                                  │
│  │  Display         │                                                  │
│  └──────────────────┘                                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐         ┌─────▼─────┐        ┌─────▼─────┐
    │ Weather │         │   D5      │        │  User     │
    │   API   │         │  Weather  │        │           │
    │         │         │   Data    │        │           │
    └─────────┘         └───────────┘        └───────────┘
```

### **Sub-processes (4.0):**

1. **4.1: Fetch Weather from API**
   - Input: Location (Talisay City, Negros Occidental - Lat: 10.2439, Lon: 123.8417)
   - Process: HTTP GET request to OpenWeatherMap API
   - Output: Weather API Response

2. **4.2: Store Weather Data**
   - Input: Weather Data (Temperature, Humidity, Wind Speed, Conditions, etc.)
   - Process: Parse and store in database
   - Output: Weather Data → D5

3. **4.3: Retrieve Weather Data**
   - Input: Query (Current or Historical)
   - Output: Weather Data → 4.4

4. **4.4: Format Weather Display**
   - Input: Raw Weather Data
   - Process: Format for UI display (icons, colors, units)
   - Output: Formatted Weather → User

### **Data Flows (4.0):**

- User → 4.1: Weather Refresh Request
- 4.1 → Weather API: Weather Request (Location)
- Weather API → 4.1: Weather Data Response
- 4.1 → 4.2: Raw Weather Data
- 4.2 → D5: Stored Weather Data
- D5 → 4.3: Weather Data
- 4.3 → 4.4: Weather Data for Formatting
- 4.4 → User: Formatted Weather Display

---

## 📊 **LEVEL 2 DFD - Process 5.0: Generate Insights**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                    PROCESS 5.0: GENERATE INSIGHTS                        │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  5.1             │  │  5.2             │  │  5.3             │   │
│  │  Analyze Sugar   │  │  Analyze         │  │  Calculate       │   │
│  │  Records         │  │  Inventory Data  │  │  Recommendations │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  5.4             │  │  5.5             │  │  5.6             │   │
│  │  Analyze         │  │  Generate        │  │  Store Insights  │   │
│  │  Weather Impact  │  │  Farming         │  │                   │   │
│  │                  │  │  Insights        │  │                   │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D8      │        │   D1, D2,  │
    │         │          │Farming    │        │   D3, D5  │
    │         │          │ Insights  │        │           │
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (5.0):**

1. **5.1: Analyze Sugar Records**
   - Input: Sugar Records from D1
   - Process: Calculate averages, trends, variety performance
   - Output: Sugar Analysis Results → 5.5

2. **5.2: Analyze Inventory Data**
   - Input: Inventory Items from D2
   - Process: Calculate usage patterns, stock trends
   - Output: Inventory Analysis → 5.5

3. **5.3: Calculate Recommendations**
   - Input: Analysis results from 5.1, 5.2, 5.4
   - Process: Apply farming rules, variety selection, fertilizer recommendations
   - Output: Recommendations → 5.5

4. **5.4: Analyze Weather Impact**
   - Input: Weather Data from D5
   - Process: Correlate weather with farming outcomes
   - Output: Weather Impact Analysis → 5.5

5. **5.5: Generate Farming Insights**
   - Input: All analysis results
   - Process: Combine data into comprehensive insights (variety selection, water requirements, planting timing, harvest estimation, fertilizer recommendations, financial analysis)
   - Output: Complete Insights → 5.6

6. **5.6: Store Insights**
   - Input: Generated Insights
   - Process: Save to database
   - Output: Insights → D8

### **Data Flows (5.0):**

- User → 5.5: Generate Insight Request
- D1 → 5.1: Sugar Records Data
- D2 → 5.2: Inventory Items Data
- D3 → 5.2: Supplier Transactions Data (for cost analysis)
- D5 → 5.4: Weather Data
- 5.1 → 5.5: Sugar Analysis Results
- 5.2 → 5.5: Inventory Analysis Results
- 5.4 → 5.5: Weather Impact Analysis
- 5.5 → 5.3: Analysis Data for Recommendations
- 5.3 → 5.5: Recommendations
- 5.5 → 5.6: Complete Insights
- 5.6 → D8: Stored Insights
- D8 → User: Insights Display

---

## 📊 **LEVEL 2 DFD - Process 6.0: Manage Alerts & Notifications**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│              PROCESS 6.0: MANAGE ALERTS & NOTIFICATIONS                  │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  6.1             │  │  6.2             │  │  6.3             │   │
│  │  Create Alert    │  │  Check Alert     │  │  Update Alert    │   │
│  │                  │  │  Conditions      │  │  Status          │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  6.4             │  │  6.5             │                            │
│  │  Retrieve        │  │  Send            │                            │
│  │  Alerts          │  │  Notifications   │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D4      │        │ Process   │
    │         │          │  Alerts  │        │   2.5     │
    │         │          │           │        │(Low Stock)│
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (6.0):**

1. **6.1: Create Alert**
   - Input: Title, Message, Severity (info/warning/error/success)
   - Process: Validate and create alert record
   - Output: New Alert → D4

2. **6.2: Check Alert Conditions**
   - Input: System Events (Low stock, Weather warnings, System status)
   - Process: Monitor conditions and trigger alerts
   - Output: Alert Trigger → 6.1

3. **6.3: Update Alert Status**
   - Input: Alert ID, Status (Read/Unread)
   - Process: Update alert read status
   - Output: Updated Alert → D4

4. **6.4: Retrieve Alerts**
   - Input: Query Parameters (Severity filter, Read status)
   - Output: Alerts List → User

5. **6.5: Send Notifications**
   - Input: Alert Data
   - Process: Display notification to user
   - Output: Notification Display → User

### **Data Flows (6.0):**

- 2.5 → 6.2: Low Stock Condition
- System Events → 6.2: Other Alert Conditions
- 6.2 → 6.1: Alert Trigger
- 6.1 → D4: New Alert
- D4 → 6.4: Alerts Data
- 6.4 → User: Alerts Display
- User → 6.3: Alert Acknowledgment (Mark as Read)
- 6.3 → D4: Updated Alert Status
- D4 → 6.5: Unread Alerts
- 6.5 → User: Notification Display

---

## 📊 **LEVEL 2 DFD - Process 7.0: Generate Reports & Export Data**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│          PROCESS 7.0: GENERATE REPORTS & EXPORT DATA                     │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  7.1             │  │  7.2             │  │  7.3             │   │
│  │  Generate        │  │  Generate        │  │  Generate        │   │
│  │  Analytics       │  │  Data            │  │  Export Files    │   │
│  │  Reports         │  │  Visualizations  │  │  (CSV)           │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐                                                  │
│  │  7.4             │                                                  │
│  │  Format Report   │                                                  │
│  │  Display         │                                                  │
│  └──────────────────┘                                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D1-D8    │        │  Export   │
    │         │          │   (All)    │        │   Files   │
    │         │          │            │        │           │
    └─────────┘          └────────────┘        └───────────┘
```

### **Sub-processes (7.0):**

1. **7.1: Generate Analytics Reports**
   - Input: Data from D1, D2, D3, D4, D5, D8
   - Process: Calculate KPIs, statistics, trends
   - Output: Analytics Data → 7.4

2. **7.2: Generate Data Visualizations**
   - Input: Analytics Data
   - Process: Create charts (Pie, Bar, Line), graphs
   - Output: Visualization Data → 7.4

3. **7.3: Generate Export Files (CSV)**
   - Input: Data from D1, D2, D3
   - Process: Convert to CSV format
   - Output: CSV Files → User

4. **7.4: Format Report Display**
   - Input: Analytics and Visualization Data
   - Process: Format for UI presentation
   - Output: Formatted Reports → User

### **Data Flows (7.0):**

- User → 7.1: Report Request
- User → 7.3: Export Request
- D1 → 7.1, 7.3: Sugar Records Data
- D2 → 7.1, 7.3: Inventory Items Data
- D3 → 7.1, 7.3: Supplier Transactions Data
- D4 → 7.1: Alerts Data
- D5 → 7.1: Weather Data
- D8 → 7.1: Farming Insights Data
- 7.1 → 7.2: Analytics Data
- 7.2 → 7.4: Visualization Data
- 7.1 → 7.4: Analytics Data
- 7.4 → User: Formatted Reports Display
- 7.3 → User: CSV Export Files

---

## 📊 **LEVEL 2 DFD - Process 8.0: Synchronize Data (Real-time)**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│              PROCESS 8.0: SYNCHRONIZE DATA (REAL-TIME)                   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  8.1             │  │  8.2             │  │  8.3             │   │
│  │  Sync to         │  │  Sync from       │  │  Manage Local    │   │
│  │  Supabase        │  │  Supabase        │  │  Storage         │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  8.4             │  │  8.5             │                            │
│  │  Manage Real-time│  │  Handle Conflict │                            │
│  │  Subscriptions   │  │  Resolution      │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │Supabase │          │  Local     │        │  D1-D8     │
    │Database │          │  Storage   │        │  (All)     │
    │         │          │            │        │           │
    └─────────┘          └────────────┘        └───────────┘
```

### **Sub-processes (8.0):**

1. **8.1: Sync to Supabase**
   - Input: Data from Local Storage (D1-D8)
   - Process: Upload changes to Supabase
   - Output: Sync Status, Supabase Updates

2. **8.2: Sync from Supabase**
   - Input: Supabase Data Changes
   - Process: Download and update local storage
   - Output: Synced Data → D1-D8

3. **8.3: Manage Local Storage**
   - Input: Data Operations
   - Process: Handle SharedPreferences, local cache
   - Output: Local Storage Updates → D1-D8

4. **8.4: Manage Real-time Subscriptions**
   - Input: Supabase Realtime Channels
   - Process: Listen for database changes, handle events
   - Output: Real-time Updates → 8.2

5. **8.5: Handle Conflict Resolution**
   - Input: Conflicting Data (Local vs Supabase)
   - Process: Apply merge strategy (Last Write Wins or Timestamp-based)
   - Output: Resolved Data → D1-D8

### **Data Flows (8.0):**

- User → 8.1: Manual Sync Request
- D1-D8 → 8.1: Local Data Changes
- 8.1 → Supabase: Upload Data
- Supabase → 8.4: Real-time Change Notifications
- 8.4 → 8.2: Change Events
- 8.2 → D1-D8: Synced Data
- D1-D8 → 8.3: Local Storage Operations
- 8.3 → D1-D8: Local Storage Updates
- 8.1 ↔ 8.2: Conflict Detection → 8.5
- 8.5 → D1-D8: Resolved Data

---

## 📊 **LEVEL 3 DFD - Process 1.1: Create Sugar Record**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                  PROCESS 1.1: CREATE SUGAR RECORD                        │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  1.1.1           │  │  1.1.2           │  │  1.1.3           │   │
│  │  Receive Input   │  │  Validate Input  │  │  Generate Record │   │
│  │  Data            │  │  Data            │  │  ID              │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  1.1.4           │  │  1.1.5           │                            │
│  │  Create Record   │  │  Store Record    │                            │
│  │  Object          │  │  in Database     │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  User   │          │   D1      │        │ Process   │
    │         │          │  Sugar   │        │   8.0     │
    │         │          │ Records  │        │ (Sync)    │
    └─────────┘          └──────────┘        └───────────┘
```

### **Sub-processes (1.1):**

1. **1.1.1: Receive Input Data**
   - Input: Date, Variety, Soil Test, Fertilizer, Height (cm), Notes
   - Output: Raw Input Data → 1.1.2

2. **1.1.2: Validate Input Data**
   - Validation Rules:
     - Date: Valid date format, not future date
     - Variety: Must be from enum (SP70-1143, VMC 84-524, etc.)
     - Soil Test: Non-empty string
     - Fertilizer: Non-empty string
     - Height: Integer > 0, reasonable range (0-500 cm)
     - Notes: Optional text
   - Output: Validated Data → 1.1.3, or Error → User

3. **1.1.3: Generate Record ID**
   - Process: Generate UUID using `gen_random_uuid()::text`
   - Output: Record ID → 1.1.4

4. **1.1.4: Create Record Object**
   - Input: Validated Data + Record ID
   - Process: Create SugarRecord model object with timestamps
   - Output: SugarRecord Object → 1.1.5

5. **1.1.5: Store Record in Database**
   - Input: SugarRecord Object
   - Process: Save to D1 (Local + Supabase via 8.0)
   - Output: Stored Record → D1, Confirmation → User

### **Data Flows (1.1):**

- User → 1.1.1: Input Data
- 1.1.1 → 1.1.2: Raw Input Data
- 1.1.2 → 1.1.3: Validated Data (or Error → User)
- 1.1.3 → 1.1.4: Record ID
- 1.1.4 → 1.1.5: SugarRecord Object
- 1.1.5 → D1: Stored Record
- 1.1.5 → 8.0: Sync Request
- 1.1.5 → User: Success Confirmation

---

## 📊 **LEVEL 3 DFD - Process 5.5: Generate Farming Insights**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│              PROCESS 5.5: GENERATE FARMING INSIGHTS                       │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  5.5.1           │  │  5.5.2           │  │  5.5.3           │   │
│  │  Analyze Variety │  │  Calculate Water │  │  Determine       │   │
│  │  Performance     │  │  Requirements    │  │  Planting Timing  │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  5.5.4           │  │  5.5.5           │  │  5.5.6           │   │
│  │  Estimate        │  │  Recommend       │  │  Calculate       │   │
│  │  Harvest         │  │  Fertilizers     │  │  Financial        │   │
│  │                  │  │                  │  │  Analysis         │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐                                                  │
│  │  5.5.7           │                                                  │
│  │  Compile         │                                                  │
│  │  Complete        │                                                  │
│  │  Insights        │                                                  │
│  └──────────────────┘                                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │Process  │          │  User     │        │   D8      │
    │ 5.1-5.4 │          │           │        │  Insights │
    │         │          │           │        │           │
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (5.5):**

1. **5.5.1: Analyze Variety Performance**
   - Input: Sugar Records Analysis (from 5.1)
   - Process: Compare varieties, determine best performing variety based on yield, height, maturity
   - Output: Best Variety Recommendation → 5.5.7

2. **5.5.2: Calculate Water Requirements**
   - Input: Variety data, Climate zone, Farm size
   - Process: Calculate daily/monthly water needs based on variety characteristics and climate zone adjustments
   - Output: Water Requirements → 5.5.7

3. **5.5.3: Determine Planting Timing**
   - Input: Climate zone data, Current date
   - Process: Recommend optimal planting months based on climate zone (Tropical Wet: Mar-May, Tropical Dry: Jun-Aug, Subtropical: Sep-Nov)
   - Output: Planting Timing Recommendation → 5.5.7

4. **5.5.4: Estimate Harvest**
   - Input: Variety maturity period, Soil type efficiency, Planting date
   - Process: Calculate harvest date and expected yield
   - Output: Harvest Estimation → 5.5.7

5. **5.5.5: Recommend Fertilizers**
   - Input: Variety fertilizer requirements, Soil type efficiency
   - Process: Suggest NPK ratios and amounts per hectare
   - Output: Fertilizer Recommendations → 5.5.7

6. **5.5.6: Calculate Financial Analysis**
   - Input: Variety yield, Market price per ton, Estimated costs
   - Process: Calculate estimated income, costs, profit
   - Output: Financial Analysis → 5.5.7

7. **5.5.7: Compile Complete Insights**
   - Input: All recommendations from 5.5.1-5.5.6
   - Process: Combine into comprehensive FarmingInsight object
   - Output: Complete Insights → D8, User

### **Data Flows (5.5):**

- 5.1 → 5.5.1: Sugar Records Analysis
- 5.2, 5.4 → 5.5.2: Inventory and Weather Data
- 5.4 → 5.5.3: Climate Zone Data
- 5.1 → 5.5.4: Variety and Planting Data
- 5.1 → 5.5.5: Variety Fertilizer Requirements
- 5.1 → 5.5.6: Variety Yield and Price Data
- 5.5.1-5.5.6 → 5.5.7: All Recommendations
- 5.5.7 → D8: Complete Insights
- 5.5.7 → User: Insights Display

---

## 📊 **LEVEL 3 DFD - Process 8.1: Sync to Supabase**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                  PROCESS 8.1: SYNC TO SUPABASE                          │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  8.1.1           │  │  8.1.2           │  │  8.1.3           │   │
│  │  Identify Local  │  │  Convert Data to │  │  Send HTTP       │   │
│  │  Changes         │  │  JSON Format     │  │  Request to       │   │
│  │                  │  │                  │  │  Supabase        │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  8.1.4           │  │  8.1.5           │                            │
│  │  Handle Response │  │  Update Sync     │                            │
│  │  & Errors        │  │  Status          │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │  D1-D8 │          │  Supabase │        │  User     │
    │(Local) │          │  Database │        │           │
    │        │          │           │        │           │
    └────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (8.1):**

1. **8.1.1: Identify Local Changes**
   - Input: Data from D1-D8 (Local Storage)
   - Process: Compare local data with last sync timestamp, identify new/modified records
   - Output: Changed Records → 8.1.2

2. **8.1.2: Convert Data to JSON Format**
   - Input: Changed Records (Dart Objects)
   - Process: Serialize to JSON format matching Supabase schema
   - Output: JSON Data → 8.1.3

3. **8.1.3: Send HTTP Request to Supabase**
   - Input: JSON Data, Table Name, Operation (INSERT/UPDATE/DELETE)
   - Process: POST/PATCH/DELETE request to Supabase REST API
   - Output: HTTP Response → 8.1.4

4. **8.1.4: Handle Response & Errors**
   - Input: HTTP Response
   - Process: Check status code, handle errors (network, validation, etc.)
   - Output: Success/Error Status → 8.1.5

5. **8.1.5: Update Sync Status**
   - Input: Sync Result
   - Process: Update local sync timestamp, mark records as synced
   - Output: Sync Status → User, Updated Local Storage

### **Data Flows (8.1):**

- D1-D8 → 8.1.1: Local Data
- 8.1.1 → 8.1.2: Changed Records
- 8.1.2 → 8.1.3: JSON Data
- 8.1.3 → Supabase: HTTP Request (POST/PATCH/DELETE)
- Supabase → 8.1.4: HTTP Response
- 8.1.4 → 8.1.5: Sync Result
- 8.1.5 → User: Sync Status
- 8.1.5 → D1-D8: Updated Sync Timestamps

---

## 📊 **LEVEL 4 DFD - Process 1.1.2: Validate Input Data**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│              PROCESS 1.1.2: VALIDATE INPUT DATA                          │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  1.1.2.1         │  │  1.1.2.2         │  │  1.1.2.3         │   │
│  │  Validate Date   │  │  Validate Variety│  │  Validate Height  │   │
│  │  Format          │  │  Selection       │  │  Range            │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                            │
│  │  1.1.2.4         │  │  1.1.2.5         │                            │
│  │  Validate        │  │  Compile         │                            │
│  │  Required Fields │  │  Validation      │                            │
│  │                  │  │  Results        │                            │
│  └──────────────────┘  └──────────────────┘                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │Process  │          │  User     │        │ Process   │
    │ 1.1.1   │          │ (Errors)  │        │  1.1.3    │
    │         │          │           │        │           │
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (1.1.2):**

1. **1.1.2.1: Validate Date Format**
   - Input: Date field
   - Validation: Check if date is valid format (YYYY-MM-DD), not future date, reasonable range
   - Output: Date Validation Result → 1.1.2.5

2. **1.1.2.2: Validate Variety Selection**
   - Input: Variety field
   - Validation: Check if variety is in allowed enum (SP70-1143, VMC 84-524, Phil 2009, Phil 2012, Phil 2015, Phil 2018, Phil 2021)
   - Output: Variety Validation Result → 1.1.2.5

3. **1.1.2.3: Validate Height Range**
   - Input: Height (cm) field
   - Validation: Check if height is integer > 0, reasonable range (0-500 cm)
   - Output: Height Validation Result → 1.1.2.5

4. **1.1.2.4: Validate Required Fields**
   - Input: All input fields
   - Validation: Check if required fields (Date, Variety, Soil Test, Fertilizer, Height) are not empty
   - Output: Required Fields Validation Result → 1.1.2.5

5. **1.1.2.5: Compile Validation Results**
   - Input: All validation results from 1.1.2.1-1.1.2.4
   - Process: Combine all results, determine if all validations pass
   - Output: Overall Validation Result → 1.1.3 (if valid) or Error Messages → User (if invalid)

### **Data Flows (1.1.2):**

- 1.1.1 → 1.1.2.1: Date Input
- 1.1.1 → 1.1.2.2: Variety Input
- 1.1.1 → 1.1.2.3: Height Input
- 1.1.1 → 1.1.2.4: All Input Fields
- 1.1.2.1-1.1.2.4 → 1.1.2.5: Individual Validation Results
- 1.1.2.5 → 1.1.3: Validated Data (if all valid)
- 1.1.2.5 → User: Error Messages (if validation fails)

---

## 📊 **LEVEL 4 DFD - Process 8.1.3: Send HTTP Request to Supabase**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│          PROCESS 8.1.3: SEND HTTP REQUEST TO SUPABASE                    │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │  8.1.3.1        │  │  8.1.3.2        │  │  8.1.3.3        │   │
│  │  Build API URL  │  │  Add Headers    │  │  Send HTTP       │   │
│  │  & Endpoint     │  │  & Auth Token   │  │  Request         │   │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                         │
│  ┌──────────────────┐                                                  │
│  │  8.1.3.4         │                                                  │
│  │  Handle          │                                                  │
│  │  Network Timeout │                                                  │
│  │  & Retry Logic   │                                                  │
│  └──────────────────┘                                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
    │Process  │          │  Supabase │        │ Process   │
    │ 8.1.2   │          │  REST API │        │  8.1.4    │
    │         │          │           │        │           │
    └─────────┘          └───────────┘        └───────────┘
```

### **Sub-processes (8.1.3):**

1. **8.1.3.1: Build API URL & Endpoint**
   - Input: Table Name (sugar_records, inventory_items, etc.), Operation Type
   - Process: Construct Supabase REST API URL: `https://ekmvgwfrdrnivajlnorj.supabase.co/rest/v1/{table}`
   - Output: Complete API URL → 8.1.3.2

2. **8.1.3.2: Add Headers & Auth Token**
   - Input: API URL, JSON Data
   - Process: Add HTTP headers:
     - `apikey`: SUPABASE_ANON_KEY
     - `Authorization`: Bearer {SUPABASE_ANON_KEY}
     - `Content-Type`: application/json
     - `Prefer`: return=representation
   - Output: Request with Headers → 8.1.3.3

3. **8.1.3.3: Send HTTP Request**
   - Input: Complete HTTP Request (URL, Headers, Body)
   - Process: Execute HTTP POST/PATCH/DELETE request
   - Output: HTTP Response → 8.1.3.4

4. **8.1.3.4: Handle Network Timeout & Retry Logic**
   - Input: HTTP Response or Timeout Error
   - Process: Check for timeout, implement retry logic (max 3 retries), handle network errors
   - Output: Final Response or Error → 8.1.4

### **Data Flows (8.1.3):**

- 8.1.2 → 8.1.3.1: JSON Data, Table Name
- 8.1.3.1 → 8.1.3.2: Complete API URL
- 8.1.3.2 → 8.1.3.3: HTTP Request with Headers
- 8.1.3.3 → Supabase REST API: HTTP Request
- Supabase REST API → 8.1.3.4: HTTP Response
- 8.1.3.4 → 8.1.4: Final Response or Error

---

## 📋 **SUMMARY OF ALL ENTITIES, PROCESSES, DATA STORES, AND FLOWS**

### **External Entities:**
- **E1: User (Farm Manager/Admin)** - Primary system operator
- **E2: Weather API** - External weather service provider
- **E3: Supplier** - External supplier entities
- **E4: Supabase Database** - Cloud database service

### **Main Processes (Level 1):**
1. **1.0: Manage Sugar Records**
2. **2.0: Manage Inventory**
3. **3.0: Manage Supplier Transactions**
4. **4.0: Manage Weather Data**
5. **5.0: Generate Insights**
6. **6.0: Manage Alerts & Notifications**
7. **7.0: Generate Reports & Export Data**
8. **8.0: Synchronize Data (Real-time)**

### **Data Stores:**
- **D1: Sugar Records** - All sugarcane monitoring records
- **D2: Inventory Items** - All farm supplies and equipment
- **D3: Supplier Transactions** - All supplier purchase records
- **D4: Alerts** - System alerts and notifications
- **D5: Weather Data** - Weather information and forecasts
- **D6: Realtime Events** - Activity tracking and events
- **D7: Farm Settings** - Application configuration and settings
- **D8: Farming Insights** - Generated farming recommendations

### **Key Data Flows:**
- User interactions (CRUD operations, requests)
- Real-time data synchronization (bidirectional)
- Weather API integration (fetch and store)
- Alert generation and notification
- Report generation and data export
- Insight generation from multiple data sources

---

## 📝 **NOTES:**
- All processes support both local storage (SharedPreferences) and Supabase cloud storage
- Real-time synchronization ensures data consistency across devices
- The system implements offline-first architecture with automatic fallback
- All data flows are bidirectional where applicable
- Validation occurs at multiple levels (input, business logic, database)
- Error handling is integrated at each process level

---

**Document Created:** Comprehensive DFD documentation for Hacienda Elizabeth Agricultural Management System
**Coverage:** Context Diagram through Level 4 DFDs
**Last Updated:** Based on current system implementation

