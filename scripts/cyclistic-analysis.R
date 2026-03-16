# ---------------------------
# 1. Load necessary packages
# ---------------------------
install.packages("tidyverse")
library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)  # para wday(), month(), hour()


# -----------------------------------
# 2. Import all datasets (2023–2025)
# -----------------------------------

main_folder <- "C:/Users/jujuf/Documents/google-certificate/capstone/version-2/datasets"

folders <- list.dirs(main_folder, recursive = FALSE)
all_data_list <- list()

for(folder in folders){
  files <- list.files(folder, pattern = "*.csv", full.names = TRUE)
  for(file in files){
    df <- read_csv(file, show_col_types = FALSE)
    all_data_list[[basename(file)]] <- df
  }
}

# Merge all datasets into one dataframe
cyclistic_raw <- bind_rows(all_data_list)

cat("Raw dataset dimensions: ", dim(cyclistic_raw), "\n\n")


# ----------------------
# 3. Initial inspection
# ----------------------

glimpse(cyclistic_raw)
summary(cyclistic_raw)

missing_counts <- sapply(cyclistic_raw, function(x) sum(is.na(x)))
cat("Missing values per column:\n")
print(missing_counts)

distinct_counts <- sapply(cyclistic_raw, n_distinct)
cat("\nDistinct values per column:\n")
print(distinct_counts)

cat("\nDuplicate ride IDs: ", sum(duplicated(cyclistic_raw$ride_id)), "\n\n")


# -----------------------------
# 4. Remove duplicate ride IDs
# -----------------------------

cyclistic_no_dupes <- cyclistic_raw %>%
  distinct(ride_id, .keep_all = TRUE)

cat("Removed duplicates. New dimensions: ", dim(cyclistic_no_dupes), "\n\n")


# ---------------------------------------
# 5. Standardize column types and values
# ---------------------------------------

cyclistic_standard <- cyclistic_no_dupes %>%
  rename(
    user_type = member_casual,
    vehicle_type = rideable_type
  ) %>%
  mutate(
    user_type = recode(user_type,
                       "member" = "Member",
                       "casual" = "Casual"),
    user_type = factor(user_type, levels = c("Member", "Casual")),
    
    vehicle_type = recode(vehicle_type,
                          "classic_bike" = "Classic Bike",
                          "electric_bike" = "Electric Bike",
                          "electric_scooter" = "Electric Scooter"),
    vehicle_type = factor(vehicle_type)
  )

cat("After standardization, columns:\n")
glimpse(cyclistic_standard)


# ---------------------------------------
# 6. Feature engineering (time features)
# ---------------------------------------

cyclistic_time <- cyclistic_standard %>%
  mutate(
    # Ride duration in minutes
    ride_length_min = as.numeric(difftime(ended_at, started_at, units = "mins")),
    # Date features
    ride_date = as.Date(started_at),
    day_of_week = wday(started_at, label = TRUE, week_start = 1, locale = "en_US"),
    month = month(started_at, label = TRUE, locale = "en_US"),
    hour = hour(started_at),
    # Weekend flag
    is_weekend = if_else(day_of_week %in% c("Sat", "Sun"), "Weekend", "Weekday"),
    # Part of day
    part_of_day = case_when(
      hour >= 5  & hour < 12 ~ "Morning",
      hour >= 12 & hour < 17 ~ "Afternoon",
      hour >= 17 & hour < 21 ~ "Evening",
      TRUE ~ "Night"
    )
  ) %>%
  mutate(
    is_weekend = factor(is_weekend),
    part_of_day = factor(part_of_day)
  )

cat("After time feature engineering, columns:\n")
glimpse(cyclistic_time)


# -------------------------------------------------------------------------------
# 7. Identify and remove invalid ride durations
#    - Remove unrealistic ride durations
#    - Trips shorter than 1 minute may represent unlocking or system errors
#    - Trips longer than 24 hours are considered outliers for typical bike usage
# -------------------------------------------------------------------------------

invalid_durations <- cyclistic_time %>%
  summarise(
    negatives = sum(ride_length_min < 0, na.rm = TRUE),
    zeros = sum(ride_length_min == 0, na.rm = TRUE),
    too_short = sum(ride_length_min > 0 & ride_length_min < 1, na.rm = TRUE),
    too_long = sum(ride_length_min > 1440, na.rm = TRUE)
  )

cat("Invalid ride durations before filtering:\n")
print(invalid_durations)

cyclistic_duration <- cyclistic_time %>%
  filter(between(ride_length_min, 1, 1440))

cat("Rows removed:", nrow(cyclistic_time) - nrow(cyclistic_duration), "\n")

cat("After removing invalid durations, dimensions: ", dim(cyclistic_duration), "\n\n")


# ---------------------------------------------------------------------------------------------
# 8. Geographic validation (Bounding Box)
#    - Filter trips within the Chicago geographic bounding box
#    - Coordinates were defined based on the approximate service area of the Divvy bike system
# ---------------------------------------------------------------------------------------------

cyclistic_geo <- cyclistic_duration %>%
  filter(
    start_lat  >= 41.6 & start_lat  <= 42.1,
    end_lat    >= 41.6 & end_lat    <= 42.1,
    start_lng  >= -87.9 & start_lng <= -87.5,
    end_lng    >= -87.9 & end_lng   <= -87.5
  )

cat("Rows removed:", nrow(cyclistic_duration) - nrow(cyclistic_geo), "\n")

cat("After geographic filtering, dataset dimensions: ", dim(cyclistic_geo), "\n")


# -------------------------------------------------------------------------------------
# 9. Geographic Feature Engineering
#    - Round coordinates to 3 decimals (~100m grid)
#    - This reduces location noise and helps group nearby trips for spatial clustering
# -------------------------------------------------------------------------------------

cyclistic_features <- cyclistic_geo %>%
  filter(!is.na(start_lat), !is.na(start_lng)) %>%
  mutate(
    lat_round = round(start_lat, 3),
    lng_round = round(start_lng, 3)
  )

summary(cyclistic_features %>% select(lat_round, lng_round))

cat("After geographic feature engineering, columns:\n")
glimpse(cyclistic_features)


# ---------------------------------------------------------------------------------------------
# 10. Exploratory Data Analysis (EDA)
# Business questions: How do annual members and casual riders use Cyclistic bikes differently?
# ---------------------------------------------------------------------------------------------

# Rename the final dataset to a more intuitive name
cyclistic_cleaned <- cyclistic_features

# I) Total rides per user type  *************************************************************
rides_summary <- cyclistic_cleaned %>%
  group_by(user_type) %>%
  summarise(total_rides = n()) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

rides_summary

# Plot graph
ggplot(rides_summary, aes(x = user_type, y = total_rides, fill = user_type)) +
  geom_col() +
  geom_text(aes(label = paste0(round(percentage,1), "%")),
            vjust = -0.5) +
  labs(
    title = "Total Rides by User Type",
    x = "User Type",
    y = "Total Rides"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# II) Ride length per user type (average + distribution)  *************************************************
ride_length_stats <- cyclistic_cleaned %>%
  group_by(user_type) %>%
  summarise(
    avg_ride_length = mean(ride_length_min, na.rm = TRUE),
    median_ride_length = median(ride_length_min, na.rm = TRUE),
    sd_ride_length = sd(ride_length_min, na.rm = TRUE)
  )

ride_length_stats

# Plot graph
ggplot(cyclistic_cleaned %>% filter(!is.na(ride_length_min)),
       aes(x = user_type, y = ride_length_min, fill = user_type)) +
  geom_boxplot() +
  coord_cartesian(ylim = c(0, 60)) +
  labs(
    title = "Ride Length Distribution by User Type",
    x = "User Type",
    y = "Ride Length (Minutes)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# III) Rides per days of week  *************************************************************
weekly_distribution <- cyclistic_cleaned %>%
  group_by(user_type, day_of_week) %>%
  summarise(total_rides = n(), .groups = "drop") %>%
  group_by(user_type) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

print(weekly_distribution, n = 14)

# Plot graph
ggplot(weekly_distribution,
       aes(x = day_of_week,
           y = percentage,
           color = user_type,
           group = user_type)) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  labs(
    title = "Ride Distribution by Day of Week (Percentage)",
    x = "Day of Week",
    y = "Percentage of Weekly Rides"
  ) +
  theme_minimal()

# IV) Rides per hour of day *************************************************************
hourly_distribution <- cyclistic_cleaned %>%
  group_by(user_type, hour) %>%
  summarise(total_rides = n(), .groups = "drop") %>%
  group_by(user_type) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

print(hourly_distribution, n = 48)

# Plot graph
ggplot(hourly_distribution,
       aes(x = hour,
           y = percentage,
           color = user_type,
           group = user_type)) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  labs(
    title = "Ride Distribution by Hour (Percentage)",
    x = "Hour of Day",
    y = "Percentage of Daily Rides"
  ) +
  theme_minimal()

# V) Seasonality (months)  *************************************************************
monthly_distribution <- cyclistic_cleaned %>%
  group_by(user_type, month) %>%
  summarise(total_rides = n(), .groups = "drop") %>%
  group_by(user_type) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

print(monthly_distribution, n = 24)

# Plot graph 
ggplot(monthly_distribution,
       aes(x = month,
           y = percentage,
           color = user_type,
           group = user_type)) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  labs(
    title = "Ride Distribution by Month (Percentage)",
    x = "Month",
    y = "Percentage of Annual Rides"
  ) +
  theme_minimal()

# VI) Total rides per vehicle type  *************************************************************
vehicle_distribution <- cyclistic_cleaned %>%
  group_by(user_type, vehicle_type) %>%
  summarise(total_rides = n(), .groups = "drop") %>%
  group_by(user_type) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100)

vehicle_distribution

# Plot graph
ggplot(vehicle_distribution,
       aes(x = vehicle_type,
           y = percentage,
           fill = user_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Vehicle Type Usage by User Type (Percentage)",
    x = "Vehicle Type",
    y = "Percentage of Total Rides"
  ) +
  theme_minimal()

# Média de duração por tipo de bike e usuário
avg_duration_rides <- cyclistic_cleaned %>%
  group_by(user_type, vehicle_type) %>%
  summarise(avg_ride_length = mean(ride_length_min, na.rm = TRUE),
            median_ride_length = median(ride_length_min, na.rm = TRUE),
            n = n()) %>%
  ungroup()

# Ver tabela
avg_duration_rides

# Gráfico de barras
ggplot(avg_duration_rides, aes(x = vehicle_type, y = avg_ride_length, fill = user_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Duração Média de Viagens por Tipo de Bike e Usuário",
       x = "Tipo de Bike", y = "Duração Média (minutos)", fill = "Tipo de Usuário") +
  theme_minimal()

install.packages('geosphere', repos='https://rspatial.r-universe.dev')
library(geosphere)

all_trips_cleaned <- cyclistic_cleaned %>%
  mutate(distance_m = distHaversine(
    cbind(start_lng, start_lat),
    cbind(end_lng, end_lat)
  ),
  distance_km = distance_m / 1000)  # converter para km

# Média de distância por tipo de bike e usuário
avg_distance <- all_trips_cleaned %>%
  group_by(user_type, vehicle_type) %>%
  summarise(avg_distance_km = mean(distance_km, na.rm = TRUE)) %>%
  ungroup()

# Gráfico
ggplot(avg_distance, aes(x = vehicle_type, y = avg_distance_km, fill = user_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Distância Média por Tipo de Bike e Usuário",
       x = "Tipo de Bike", y = "Distância Média (km)", fill = "Tipo de Usuário") +
  theme_minimal()

# Top stations  *************************************************************
top_stations <- cyclistic_cleaned %>%
  filter(!is.na(start_station_name)) %>%
  group_by(user_type, start_station_name) %>%
  summarise(total_rides = n(), .groups = "drop") %>%
  arrange(user_type, desc(total_rides)) %>%
  group_by(user_type) %>%
  slice_head(n = 10)

top_stations

# Plot graph 
top_stations %>%
  group_by(user_type) %>%
  mutate(percentage = total_rides / sum(total_rides) * 100) %>%
  ggplot(aes(x = reorder(start_station_name, percentage),
             y = percentage,
             fill = user_type)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Top 10 Start Stations by User Type (Percentage)",
    x = "Station",
    y = "Percentage of Rides"
  ) +
  theme_minimal()


# ---------------------------
# 14. Export cleaned dataset
# ---------------------------

write_csv(cyclistic_cleaned, "C:/Users/jujuf/Documents/Google Data Analytics Certificate/capstone/version.2/cyclistic_processed.csv")






