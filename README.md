# 🚲 Cyclistic Case Study  
### Google Data Analytics Certificate — Behavioral Analysis of Casual vs. Annual Members

---

## 📌 Overview
Cyclistic is a bike-share program in Chicago with **5,824 bicycles and 692 docking stations**, operating since 2016. Customers who purchase single-ride or full-day passes are classified as **casual riders**, while those with annual memberships are **Cyclistic members**.  

Financial analysts have found that **annual members are significantly more profitable** than casual riders. This case study analyzes historical trip data to uncover behavioral differences, explore motivations that could drive casual riders to purchase memberships, and guide digital media strategies to support this conversion.  

The analysis follows the **six-step data analytics process**: Ask → Prepare → Process → Analyze → Share → Act.

---

## 🎯 Business Task (Ask Phase)
The project aims to answer the following:

1. How do annual members and casual riders differ in trip frequency, duration, and usage patterns?  
2. What factors or motivations could prompt casual riders to purchase annual memberships?  
3. How can Cyclistic leverage digital media to influence casual riders to become members?

These questions inform marketing strategies designed to convert casual riders into annual members.

---

## 📥 Data Collection and Preparation (Prepare Phase)
**Data Sources:**  
- Divvy bike trip system (Q1 2019 and Q1 2020)  
- CSV format, one row per trip  

**Key Fields:**  
- trip_id, start_time, end_time  
- start_station_id, start_station_name, end_station_id, end_station_name  
- user_type (casual/member)  
- start_lat/lng, end_lat/lng  

**Data Cleaning:**  
- Negative or zero trip durations (8,153 records) → set to NA
- Extreme durations (<1 min or >24 hours) → excluded from analysis
- Duplicate records → none detected
- Missing values were assessed and did not impact the final analysis
- Columns not relevant to the analysis (e.g., demographic attributes) were removed

**Data Quality (ROCCC):**
- Reliable, Objective, Complete, Consistent, Current

All data is **anonymized** and stored in `/data`.

---

## 🧹 Data Transformation (Process Phase)
Performed with **R (tidyverse)**:

1. **Column Standardization:** harmonized 2019 and 2020 datasets; removed redundant columns.  
2. **Ride Duration Calculation:** standardized to `duration_mins` for all trips.  
3. **Station Coordinates Completion:** merged unique station tables to fill missing lat/lng.  
4. **HQ QR Station Treatment:** preserved in dataset, excluded from maps in Tableau.  
5. **Feature Engineering:** added `day_of_week`, `month`, `hour`, `part_of_day`.  
6. **User Type Standardization:** recoded `Subscriber/Member → Member`, `Customer/Casual → Casual`.  
7. **Dataset Consolidation:** merged 2019 and 2020 into **all_trips** → 791,956 trips, 19 variables.  

All scripts are in `/scripts`.

---

## 📊 Data Analysis (Analyze Phase)
Analysis focused on six dimensions:

### 1️⃣ Overall User Distribution
- **Annual members:** 90.05% of rides  
- **Casual riders:** 9.05%  
- Insight: opportunity to convert casual riders into members.

### 2️⃣ Weekly Usage Patterns
- Casuals peak on **weekends** (Saturdays 19%, Sundays 26%)  
- Members stable **weekdays**, peak Tue–Thu (17–18%)

### 3️⃣ Daily Usage Trends
- Members: commute peaks (7–9 AM, 4–6 PM)  
- Casuals: moderate, evenly distributed throughout the day  
- Heatmaps confirm weekday vs. weekend behavior

### 4️⃣ Ride Duration
- Casuals: 36–41 mins average  
- Members: 11–13 mins average  
- Distribution: 72% of casual trips >15 mins, 78% of member trips <15 mins

### 5️⃣ Temporal Evolution
- Seasonal growth: casual rides increased 3x from Jan → Mar  
- Members stable, higher overall volume

### 6️⃣ Geographic Patterns
- Members: widespread, residential/business areas  
- Casuals: concentrated near tourist attractions  
- Insight: location-based marketing opportunities

Visualizations are in `/visuals`.

---

## 📨 Share Phase
Insights were shared via an **interactive Tableau dashboard**, summarizing user distribution, temporal patterns, ride duration, and spatial behavior.  
Decision-makers can explore actionable opportunities for marketing strategies targeting casual riders.

Dashboard files are located in /dashboard.

---

## 🚀 Act Phase — Recommendations
**Foundational Requirement:** implement basic first-party data collection (e.g., app login, email opt-in, QR/SMS ride confirmation) to track returning riders and campaign performance.

### Top Three Strategic Recommendations:
1. **Membership Strategy Optimization**  
   - Seasonal 6-month summer membership  
   - Weekend-only membership  
   - Recreation bundle (e.g., 5 rides/month)  
   - Use decoy pricing to highlight annual membership value  

2. **Events and On-Ground Engagement**  
   - Recreational group rides  
   - Fitness-oriented events  
   - Location-based pop-ups at high-traffic points  

3. **Strategic Partnerships**  
   - Hotels & tourism operators  
   - Local mobility & wellness partners  
   - Business & employer engagement  

Goal: nudge casual riders toward membership through targeted experiences and offers.

---

## 📂 Repository Structure

cyclistic-case-study/

├── data/ # Linked datasets

├── scripts/ # Data cleaning and analysis scripts (.R)

├── visuals/ # Charts, images used in report or dashboard

├── dashboard/ # Tableau dashboard files (.twb / .twbx)

├── final-report/ # Final report (DOCX or PDF)

├── README.md # Project documentation 

---

## 📜 Conclusion
Cyclistic now has a **clear understanding of behavioral differences** between annual members and casual riders.  
Insights support **data-driven marketing strategies**, optimized membership plans, and partnerships that can increase casual-to-member conversions.  
This capstone demonstrates how **analytics informs product strategy, marketing execution, and rider loyalty**.

---

## 📄 Data License
The data used in this analysis comes from the Divvy Bike Share System,
operated by Lyft Bikes and Scooters, LLC, and made publicly available
by the City of Chicago.

The dataset is subject to the Divvy Data License Agreement and is used
solely for non-commercial, educational, and analytical purposes.

Source and license:
https://www.divvybikes.com/system-data

---

## 👨‍💻 Author
Julio Rodrigues  
Data Analyst  
LinkedIn | Portfolio | GitHub

