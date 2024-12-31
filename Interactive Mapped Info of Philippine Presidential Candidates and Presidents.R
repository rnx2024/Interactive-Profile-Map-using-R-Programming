library(leaflet)
library(htmltools)
library(dplyr)
library(stringr)

# Load the dataset with the correct file path
election_data <- read.csv("C:\\Users\\acer\\Documents\\R_Case_Studies\\elections_data_final.csv")

# Display the first few rows of the dataset
head(election_data)

# Replace NA values with "Unknown" for categorical variables
election_data[is.na(election_data)] <- "Unknown"

# Check for any remaining NA values in latitude and longitude
sum(is.na(election_data$lat))
sum(is.na(election_data$lng))

# Function to adjust lat and lng if there are duplicates with different names
adjust_lat_lng <- function(data) {
  seen_locations <- list()
  horizontal_adjustment <- TRUE
  
  for (i in 1:nrow(data)) {
    city <- data$city[i]
    lat <- data$lat[i]
    lng <- data$lng[i]
    name <- data$name[i]
    location_key <- paste(city, lat, lng, sep = "_")
    
    if (location_key %in% names(seen_locations)) {
      if (seen_locations[[location_key]] != name) {
        if (horizontal_adjustment) {
          data$lng[i] <- lng + runif(1, -0.50, 0.10)
        } else {
          data$lat[i] <- lat + runif(1, -0.10, 0.60)
        }
        horizontal_adjustment <- !horizontal_adjustment
        location_key <- paste(city, data$lat[i], data$lng[i], sep = "_")
      }
    }
    
    seen_locations[[location_key]] <- name
  }
  
  return(data)
}

# Adjust the latitude and longitude in the dataset
election_data <- adjust_lat_lng(election_data)

# Group by candidate name to ensure unique entries and handle winning status
processed_data <- election_data %>%
  group_by(name) %>%
  summarize(
    latitude = first(lat),
    longitude = first(lng),
    has_won = max(has_won),
    tooltip = first(apply(election_data[election_data$name == first(name), ], 1, function(row) {
      paste("<b>Name:</b>", row["name"], "<br>",
            "<b>Party:</b>", row["party"], "<br>",
            "<b>Birthday:</b>", row["birthday"], "<br>",
            "<b>Age on Elections:</b>", row["age_on_elections"], "<br>",
            "<b>Sex:</b>", row["sex"], "<br>",
            "<b>City:</b>", row["city"], "<br>",
            "<b>Province:</b>", row["province"], "<br>",
            "<b>Region:</b>", row["region"], "<br>",
            "<b>Island:</b>", row["island"], "<br>",
            "<b>Birth Order:</b>", row["birth_order"], "<br>",
            "<b>Number of Siblings:</b>", row["sibling_no"], "<br>",
            "<b>Alma Mater:</b>", row["alma_mater"], "<br>",
            "<b>Highest Education Attained:</b>", row["hi_educ_attain"], "<br>",
            "<b>Last College Attended:</b>", row["last_college_attended"], "<br>",
            "<b>Degree Obtained:</b>", row["degree_obtained"], "<br>",
            "<b>Last Job:</b>", row["last_job"], "<br>",
            "<b>Number of Government Positions Served:</b>", row["no_of_govt_positions_served"], "<br>",
            "<b>Served in Government:</b>", row["served_in_gov't"], "<br>",
            "<b>Years of Service:</b>", row["years_of_service"], "<br>",
            "<b>Is Married:</b>", row["is_married"])
    }))
  ) %>%
  ungroup()

# Create the interactive map
map <- leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
  setView(lng = 121.7740, lat = 12.8797, zoom = 6)

# Loop through each candidate to add standard markers with tooltips
for (i in 1:nrow(processed_data)) {
  map <- map %>%
    addMarkers(
      lng = as.numeric(processed_data$longitude[i]),
      lat = as.numeric(processed_data$latitude[i]),
      icon = icons(
        iconUrl = ifelse(processed_data$has_won[i] == 1, "http://maps.google.com/mapfiles/ms/icons/green-dot.png", "http://maps.google.com/mapfiles/ms/icons/red-dot.png"),
        iconWidth = 35, iconHeight = 35
        
