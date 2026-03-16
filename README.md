# 🚲 Cyclistic Case Study  
### Google Data Analytics Certificate — Behavioral Analysis of Casual vs. Annual Members

---

## 📌 Overview
Cyclistic is a bike-share program in Chicago with 5,824 bicycles and 692 docking stations, operating since 2016. Customers who purchase single-ride or full-day passes are classified as casual riders, while those with annual memberships are Cyclistic members.

Annual members represent the majority of recurring demand, while casual riders account for a significant portion of leisure usage. This case study analyzes historical trip data from 2024–2025 to uncover behavioral differences, explore motivations to convert casual riders to members, and guide marketing strategies.

The analysis follows the six-step data analytics process: Ask → Prepare → Process → Analyze → Share → Act.

---

## 🎯 Business Task (Ask Phase)
The project aims to answer the following:

1. How do annual members and casual riders differ in trip frequency, duration, and usage patterns?  
2. Which factors could motivate casual riders to purchase annual memberships?
3. How can Cyclistic leverage marketing and promotions to increase member conversion?

These questions inform marketing strategies designed to convert casual riders into annual members.

---

## 📥 Data Collection and Preparation (Prepare Phase)
**Data Sources:**  
- Divvy/Cyclistic bike trip system (Jan 2024 – Dec 2025)
- CSV format, one row per trip
- All data anonymized (no PII)

**Key Fields:**  
- ride_id – unique trip identifier
- start_time / end_time – timestamps for ride start and end
- rideable_type – type of vehicle (Classic Bike, Electric Bike, Electric Scooter)
- start_station_name / start_station_id, end_station_name / end_station_id – station information
- start_lat, start_lng, end_lat, end_lng – geographic coordinates
- member_casual – rider classification (Member or Casual)

**Initial Data Assessment:**
- **Missing values:** some rides missing station names/IDs (2–2.3M) or end coordinates (12,767 rides); documented for potential spatial filtering.
- **Duplicate records:** 211 duplicate ride_ids detected.
- **Column variability:** raw column names and labels noted (e.g., member vs casual, classic_bike vs electric_bike vs scooter_bike).

**Data Quality (ROCCC):**
- Reliable, Objective, Complete, Consistent, Current

This phase establishes a full understanding of the raw dataset, ensuring all subsequent transformations are reproducible and based on a reliable starting point. 
All data is **anonymized** and stored in `/data`.

---

## 🧹 Data Transformation (Process Phase)
Performed with **R (tidyverse)**:

1. **Duplicate Removal:** removed 211 duplicate ride_ids.  
2. **Column Standardization and Recoding:**
   member_casual → user_type (Member / Casual)
   rideable_type → vehicle_type (Classic Bike / Electric Bike / Electric Scooter)
4. **Ride Duration Calculation & Filtering:**
   ride_length_min = ended_at - started_at
   Negative, zero, <1 min, or >24h durations removed (292,069 rides excluded). 
6. **Temporal Feature Engineering:** Added ride_date, day_of_week, month, hour, part_of_day, is_weekend.
7. **Geographic Filtering & Feature Engineering:**
   Trips outside Chicago bounding box removed (333 rides)
   Rounded coordinates to ~100 m (lat_round, lng_round) for spatial analysis.
9. **Final Dataset Consolidation:** 11,120,949 rides × 22 variables, ready for descriptive and spatial analysis. 

All scripts are in `/scripts`.

---

## 📊 Data Analysis (Analyze Phase)
Analysis focused on seven dimensions:

### 1️⃣ User Distribution
- Members: 7,125,281 rides (64.1%)
- Casuals: 3,995,668 rides (35.9%)
- **Insight:** Members form the core recurring demand; casual riders are significant for leisure usage.
- **Business Implication:** Targeted conversion strategies could increase recurring revenue.

### 2️⃣ Weekly Usage Patterns
Casuals: peak weekends (Saturday 20.6%, Sunday 16.9%)
Members: consistent weekdays (>1M rides/day)
**Insight:** Casual riders mostly leisure-oriented; members follow commuting patterns.
**Implication:** Weekend promotions for casual riders; highlight membership benefits for frequent usage.

### 3️⃣ Hourly Usage Patterns
Members peak at 8 AM (morning) & 5 PM (evening)
Casuals peak in late afternoon and weekends
**Implication:** Conversion campaigns could emphasize weekday commuting benefits for casual riders.

### 4️⃣ Ride Duration
Members: 75.5% of rides 0–15 min
Casuals: 59.4% 0–15 min; 5.3% >60 min
**Insight:** Casuals take longer, especially weekends → leisure use
**Implication:** Memberships could be marketed for recreational trips.

### 5️⃣ Monthly Trends
Seasonal pattern: peak in summer, low in winter
Casuals: stronger seasonality, up to 15.79% rides in August
Members: more consistent across year
**Implication:** Focus campaigns during spring/summer for casual rider conversion.

### 6️⃣ Geographic Patterns
Casual ride hotspots near tourist attractions and lakefronts
Members distributed across city → commuting and regular use
**Implication:** Promote membership at leisure/tourist hotspots.

### 7️⃣ Vehicle Type Usage
Electric bikes most used, followed by classic bikes, then e-scooter
Casuals take longer trips across all vehicle types
**Implication:** Conversion focus should remain on behavior patterns rather than bike type.

Visualizations are in `/visuals`.

---

## 📨 Share Phase
- Interactive dashboard developed in Tableau Desktop
- Highlights differences in:
   Hourly and daily patterns
   Ride duration
   Monthly and seasonal trends
   Geographic distribution & tourist areas
- Dashboard preview included below:

![Dashboard Preview](../visuals/figure-11-final-dashboard.png) 

Dashboard files are located in `/dashboard`.

---

## 🚀 Act Phase — Recommendations

### Top Three Strategic Recommendations:
1. **Promote Membership for Frequent Riders**  
   - Highlight long-term value and cost benefits.

2. **Target Marketing in Tourist & Recreational Areas**  
   - Promotional signage and partnerships near hotspots.

3. **Encourage Weekday Usage via Commuting Campaigns**  
   - Emphasize convenience and time savings compared to other transport.

---

## 📂 Repository Structure

cyclistic-case-study/

├── `data/` # Raw and cleaned datasets (Jan 2024 – Dec 2025)

├── `scripts/` # Data cleaning and analysis scripts (.R)

├── `visuals/` Charts and images used in the report/dashboard

├── `dashboard/` # Tableau dashboard files (.twb / .twbx)

├── `final-report/` # Final report (PDF/DOCX)

├── `README.md` # Project documentation (this file)

---

## 📜 Conclusion
- Clear behavioral differences observed between casual riders and members
- Casuals: leisure-oriented, weekends, tourist areas
- Members: consistent usage, commuting patterns, shorter trips
- Recommendations provide actionable strategies for increasing member conversion and enhancing service engagement.

---

## 📄 Data License
- Source: Divvy Bike Share System (Lyft Bikes and Scooters, LLC)
- Publicly available: https://www.divvybikes.com/system-data
- Educational and analytical use only.

---

## 👨‍💻 Author
Julio Rodrigues - Data Analyst  
[LinkedIn](https://www.linkedin.com/in/julio-cesar-rodrigues/) | Portfolio | [GitHub](https://github.com/juliorodrigues97)

