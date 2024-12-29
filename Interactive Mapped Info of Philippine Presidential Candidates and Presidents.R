library(leaflet)
library(htmltools)

# Load the dataset with the correct file path
election_data <- read.csv("C:\\Users\\acer\\Documents\\R_Case_Studies\\elections_data_final.csv")

# Display the first few rows of the dataset
head(election_data)

# Replace NA values with "Unknown" for categorical variables
election_data[is.na(election_data)] <- "Unknown"

# Check for any remaining NA values in latitude and longitude
sum(is.na(election_data$lat))
sum(is.na(election_data$lng))


# Create a vector of unique colors for each candidate
candidate_colors <- colorFactor(palette = rainbow(120), domain = election_data$name)

# Assign colors based on winning status
#election_data$marker_color <- ifelse(election_data$has_won == 1, "gold", candidate_colors(election_data$name))

# Create a tooltip text for each candidate
election_data$tooltip <- apply(election_data, 1, function(row) {
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
})
# Create the interactive map
map <- leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
  setView(lng = 121.7740, lat = 12.8797, zoom = 6)

# Loop through each candidate to add standard markers with tooltips
for (i in 1:nrow(election_data)) {
  map <- map %>%
    addMarkers(
      lng = as.numeric(election_data$lng[i]),
      lat = as.numeric(election_data$lat[i]),
      icon = icons(
        iconUrl = ifelse(election_data$has_won[i] == 1, "http://maps.google.com/mapfiles/ms/icons/blue-dot.png", "http://maps.google.com/mapfiles/ms/icons/red-dot.png"),
        iconWidth = 25, iconHeight = 41
      ),
      popup = HTML(election_data$tooltip[i]),
      label = HTML(election_data$tooltip[i]),
      labelOptions = labelOptions(noHide = FALSE, direction = "auto", style = list("font-size" = "12px"))
    )
}

# Display the map
map



