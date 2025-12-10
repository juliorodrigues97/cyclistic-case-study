#==========================================
#1.Load necessary packages
#==========================================

install.packages("tidyverse")
library(tidyverse)
library(readr)
library(dplyr)


#==========================================
#2.Load datasets
#==========================================

data_2019_q1 <- read_csv("C:/Users/jujuf/Documents/Google Data Analytics Certificate/capstone/Divvy_Trips_2019_Q1.csv")
data_2020_q1 <- read_csv("C:/Users/jujuf/Documents/Google Data Analytics Certificate/capstone/Divvy_Trips_2020_Q1.csv")


#==========================================
#3.Initial inspection of datasets
#==========================================

glimpse(data_2019_q1)
glimpse(data_2020_q1)

summary(data_2019_q1)
summary(data_2020_q1)

#Check missing values
sapply(data_2019_q1, function(x) sum(is.na(x)))
sapply(data_2020_q1, function(x) sum(is.na(x))) 

#Check distinct values
sapply(data_2019_q1, n_distinct)
sapply(data_2020_q1, n_distinct) 

#Check duplicate trip IDs
data_2019_q1[duplicated(data_2019_q1$trip_id), ]
data_2020_q1[duplicated(data_2020_q1$ride_id), ] 


#==========================================
#4.Standardize column names for consistency
#  This ensures both datasets have matching column names for merging
#==========================================

data_2019_q1 <- data_2019_q1 %>%
  rename(
    duration = tripduration,
    start_station_id = from_station_id,
    start_station_name = from_station_name,
    end_station_id = to_station_id,
    end_station_name = to_station_name,
    user_type = usertype
  ) %>%
  select(-bikeid, -gender, -birthyear)  #Remove unnecessary columns

data_2020_q1 <- data_2020_q1 %>%
  rename(
    trip_id = ride_id,
    start_time = started_at,
    end_time = ended_at,
    user_type = member_casual
  ) %>%
  select(-rideable_type)


#==========================================
#5.Standardize column types for analysis
#  Convert IDs to character and ensure consistency across datasets
#==========================================

data_2019_q1 <- data_2019_q1 %>%
  mutate(
    trip_id = as.character(trip_id),
    start_station_id = as.character(start_station_id),
    end_station_id = as.character(end_station_id)
  )

data_2020_q1 <- data_2020_q1 %>%
  mutate(
    start_station_id = as.character(start_station_id),
    end_station_id = as.character(end_station_id),
  )


#==========================================
#6.Add missing station coordinates from 2020 to 2019
#  This allows analysis of ride locations for both years
#==========================================

station_info_start <- data_2020_q1 %>%
  select(start_station_id, start_lat, start_lng) %>%
  distinct(start_station_id, .keep_all = TRUE)

data_2019_q1 <- data_2019_q1 %>%
  left_join(station_info_start, by = "start_station_id")


station_info_end <- data_2020_q1 %>%
  select(end_station_id, end_lat, end_lng) %>%
  distinct(end_station_id, .keep_all = TRUE)

data_2019_q1 <- data_2019_q1 %>%
  left_join(station_info_end, by = "end_station_id")


#==========================================
#7.Create duration in minutes for easier analysis
#==========================================

data_2019_q1 <- data_2019_q1 %>%
  mutate(duration_mins = round(duration / 60, 2)) #duration in minutes


data_2020_q1 <- data_2020_q1 %>%
  mutate(duration_mins = round(as.numeric(difftime(end_time, start_time, units = "mins")), 2))

#Remove original duration column if no longer needed
data_2019_q1 <- data_2019_q1 %>% select(-duration)


#==========================================
#8.Add year column to distinguish datasets after merging
#==========================================

data_2019_q1 <- data_2019_q1 %>% mutate(year = 2019) 

data_2020_q1 <- data_2020_q1 %>% mutate(year = 2020)


#==========================================
#9.Merge datasets into a single dataframe
#==========================================

all_trips <- bind_rows(data_2019_q1, data_2020_q1)


#==========================================
#10.Standardize user_type values
#   Ensure consistent labeling for analysis
#==========================================

all_trips <- all_trips %>% 
  mutate(user_type = recode(user_type,
                            "Subscriber" = "Member",
                            "member" = "Member",
                            "Customer" = "Casual",
                            "casual" = "Casual"))


#==========================================
#11.Identify, count and replace invalid ride durations
#   Short rides (<1 min) or extremely long (>24h) are set to NA
#==========================================

all_trips %>%
  summarise(
    negatives = sum(duration_mins < 0, na.rm = TRUE),
    zeros = sum(duration_mins == 0, na.rm = TRUE),
    too_short = sum(duration_mins > 0 & duration_mins < 1, na.rm = TRUE),
    too_long = sum(duration_mins > 1440, na.rm = TRUE)
  )

all_trips <- all_trips %>%
  mutate(duration_mins = ifelse(duration_mins < 1 | duration_mins > 1440, NA, duration_mins))


#==========================================
#12.Create temporal columns for analysis
#   day_of_week, month, hour, part_of_day
# ==========================================

all_trips <- all_trips %>%
  mutate(
    day_of_week = wday(start_time, label = TRUE, week_start = 1, locale = "en_US"),
    month = month(start_time, label = TRUE, locale = "en_US"),
    hour = hour(start_time),
    part_of_day = case_when(
      hour >= 5 & hour < 12 ~ "Morning",
      hour >= 12 & hour < 17 ~ "Afternoon",
      hour >= 17 & hour < 21 ~ "Evening",
      TRUE ~ "Night"
    )
  )


#==========================================
#13.Build station lookup table to fill missing coordinates
#==========================================

station_lookup <- all_trips %>%
  select(start_station_id, start_station_name, start_lat, start_lng) %>%
  filter(!is.na(start_lat) & !is.na(start_lng)) %>%
  distinct(start_station_id, .keep_all = TRUE) %>%
  rename(
    station_id = start_station_id,
    station_name = start_station_name,
    lat = start_lat,
    lng = start_lng
  )

all_trips <- all_trips %>%
  left_join(station_lookup, by = c("start_station_id" = "station_id")) %>%
  mutate(
    start_lat = coalesce(start_lat, lat),
    start_lng = coalesce(start_lng, lng)
  ) %>%
  select(-lat, -lng)


#==========================================
#14.Save cleaned dataset for analysis
#==========================================

write_csv(all_trips, "all_trips_cleaned.csv")

