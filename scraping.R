library(httr)
library(jsonlite)
library(ggplot2)
library(dplyr)

# Function to scrape data from the World Bank
scrape_worldbank_data <- function(country, ind, start_year, end_year) {
  base_url <- "http://api.worldbank.org/v2/country/"
  full_url <- sprintf("%s%s/indicator/%s?date=%s:%s&format=json", 
                      base_url, country, ind, start_year, end_year)
  
  response <- GET(full_url)
  if (status_code(response) == 200) {
    data <- content(response, "text")
    data <- fromJSON(data)
    if (length(data) > 1) {
      return(data[[2]][!sapply(data[[2]]$value, is.null),])
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
}

# Function to plot death to population growth ratio
plot_death_to_population_grow_ratio <- function(country) {
  mortality <- "SP.DYN.CDRT.IN"
  newborns <- "SP.DYN.CBRT.IN"
  totpop <- "SP.POP.TOTL"
  start_year <- "1950"
  end_year <- "2024"
  
  # Fetch data
  mortality_data <- scrape_worldbank_data(country, mortality, start_year, end_year)
  newborn_data <- scrape_worldbank_data(country, newborns, start_year, end_year)
  totpop_data <- scrape_worldbank_data(country, totpop, start_year, end_year)
  
  # Data Transformation
  mortality_df <- mortality_data %>% 
    rename(Year = date, Mortality = value, Country = country.value)
  newborn_df <- newborn_data %>% 
    rename(Year = date, Newborns = value, Country = country.value)
  totpop_df <- totpop_data %>% 
    rename(Year = date, TotalPopulation = value, Country = country.value)
  
  # Merging Dataframes
  combined_df <- merge(mortality_df, newborn_df, by = c("Year", "Country"))
  combined_df <- merge(combined_df, totpop_df, by = c("Year", "Country"))
  
  # Calculations
  combined_df$Mortality <- (combined_df$Mortality / 1000) * combined_df$TotalPopulation
  combined_df$Newborns <- (combined_df$Newborns / 1000) * combined_df$TotalPopulation
  
  # Normalization
  combined_df$Mortality_Norm <- (combined_df$Mortality - min(combined_df$Mortality)) / 
    (max(combined_df$Mortality) - min(combined_df$Mortality))
  combined_df$TotalPopulation_Norm <- (combined_df$TotalPopulation - min(combined_df$TotalPopulation)) / 
    (max(combined_df$TotalPopulation) - min(combined_df$TotalPopulation))
  combined_df$Newborns_Norm <- (combined_df$Newborns - min(combined_df$Newborns)) / 
    (max(combined_df$Newborns) - min(combined_df$Newborns))
  
  # Plotting
  ggplot(combined_df, aes(x = Year)) +
    geom_line(aes(y = Mortality_Norm, color = "Mortality")) +
    geom_line(aes(y = TotalPopulation_Norm, color = "Total Population")) +
    geom_line(aes(y = Newborns_Norm, color = "Newborns")) +
    labs(title = paste("Demographics in", combined_df$Country[1], "(", min(combined_df$Year), "-", max(combined_df$Year), ")"),
         x = "Year",
         y = "Normalized Values") +
    theme_minimal() +
    scale_color_manual("", 
                       breaks = c("Mortality", "Total Population", "Newborns"),
                       values = c("red", "blue", "green"))
}

