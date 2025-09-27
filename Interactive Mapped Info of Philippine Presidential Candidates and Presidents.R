library(leaflet)
library(htmltools)
library(dplyr)
library(stringr)

election_data <- read.csv("elections_data_final.csv")

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

# image URLs keyed with full names
image_url_map <- c(
  "Benigno Simeon Cojuangco Aquino III"        = "https://upload.wikimedia.org/wikipedia/commons/1/1d/Benigno_%22Noynoy%22_S._Aquino_III_%28cropped%29.jpg",
  "Carlos Polistico Garcia"                    = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Carlos_P._Garcia_Official_Malaca%C3%B1an_Portrait.jpg/250px-Carlos_P._Garcia_Official_Malaca%C3%B1an_Portrait.jpg",
  "Diosdado Pangan Macapagal Sr."              = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Diosdado_Macapagal_Official_Malaca%C3%B1an_Portrait.jpg/250px-Diosdado_Macapagal_Official_Malaca%C3%B1an_Portrait.jpg",
  "Elpidio Rivera Quirino"                     = "https://i0.wp.com/www.nndb.com/people/145/000098848/elpidio-quirino-1.jpg",
  "Emilio Aguinaldo y Famy"                    = "https://static.wikia.nocookie.net/philippines/images/8/8d/Emilio_Aguinaldo2.webp/revision/latest?cb=20240331102225",
  "Ferdinand \"Bongbong\" Romualdez Marcos Jr."= "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Portrait_of_President_Ferdinand_R._Marcos%2C_Jr_%28cropped%29.jpg/250px-Portrait_of_President_Ferdinand_R._Marcos%2C_Jr_%28cropped%29.jpg",
  "Ferdinand Emmanuel Edralin Marcos Sr."      = "https://philippineculturaleducation.com.ph/wp-content/uploads/2017/10/sk-marcos-ferdinand.jpg",
  "Fidel Valdez Ramos"                         = "https://peace.gov.ph/wp-content/uploads/2025/05/FVR-400x400.png",
  "Jose Marcelo Ejercito Sr."                  = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Joseph_Estrada_Official_Malaca%C3%B1an_Portrait.jpg/250px-Joseph_Estrada_Official_Malaca%C3%B1an_Portrait.jpg",
  "José Paciano Laurel y García"               = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/President_Jose_P._Laurel.jpg/250px-President_Jose_P._Laurel.jpg",
  "Manuel Acuña Roxas"                         = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Roxas-w960.jpg/250px-Roxas-w960.jpg",
  "Maria Corazon \"Cory\" Sumulong Cojuangco Aquino" = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Corazon_Aquino_Official_Malaca%C3%B1an_Portrait.jpg/250px-Corazon_Aquino_Official_Malaca%C3%B1an_Portrait.jpg",
  "Maria Gloria Macaraeg Macapagal Arroyo"     = "https://upload.wikimedia.org/wikipedia/commons/3/33/President_Arroyo_%2806-14-2006%29.jpg",
  "Ramon del Fierro Magsaysay Sr."             = "https://i0.wp.com/www.nndb.com/people/143/000098846/ramon-magsaysay-1.jpg",
  "Rodrigo Roa Duterte"                        = "https://upload.wikimedia.org/wikipedia/commons/5/5e/President_Rodrigo_Duterte_portrait_%28cropped%29.jpg",
  "Sergio Osmeña Sr."                          = "https://philippinespres.weebly.com/uploads/6/3/8/1/6381749/5536795.jpg"
)

# Loop through each candidate to add location markers with tooltips
for (i in 1:nrow(processed_data)) {
  nm <- processed_data$name[i]
  img_url <- if (nm %in% names(image_url_map)) image_url_map[nm] else NA_character_
  
  # prepend image to existing tooltip HTML
  img_tag <- if (!is.na(img_url)) sprintf(
    "<img src='%s' style='width:140px;height:auto;border-radius:6px;margin-bottom:6px;'>",
    img_url
  ) else ""
  popup_html <- paste0(img_tag, processed_data$tooltip[i])
  
  map <- map %>%
    addMarkers(
      lng = as.numeric(processed_data$longitude[i]),
      lat = as.numeric(processed_data$latitude[i]),
      icon = icons(
        iconUrl = ifelse(processed_data$has_won[i] == 1,
                         "http://maps.google.com/mapfiles/ms/icons/green-dot.png",
                         "http://maps.google.com/mapfiles/ms/icons/red-dot.png"),
        iconWidth = 35,
        iconHeight = 35
      ),
      popup = popup_html
    )
}

map
