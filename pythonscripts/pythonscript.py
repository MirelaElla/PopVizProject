# Importing required libraries for web search
import requests
from bs4 import BeautifulSoup
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Function to scrape data from the web
def scrape_worldbank_data(country, ind, start_year, end_year ):
    # Base URL for World Bank data on deaths
    base_url = "http://api.worldbank.org/v2/country/"
    # Constructing the full URL for the API request
    full_url = f"{base_url}{country}/indicator/{ind}?date={start_year}:{end_year}&format=json"

    # Sending request to the URL
    response = requests.get(full_url)
    # Check if the response is successful
    if response.status_code == 200:
        # Parsing the JSON response
        data = response.json()
        # Extracting the relevant data if available
        if len(data) > 1:
            return [(int(item["date"]), item["value"] , item["country"]["value"] ) for item in data[1] if item["value"] is not None]
        else:
            return "No data available"
    else:
        return "Failed to retrieve data"

def plot_death_to_population_grow_ratio(country) :
# List of countries to plot
#country = "CH" #, "FR", "DE", "IT"  # Switzerland, France, Germany, Italy
  mortality = "SP.DYN.CDRT.IN"
  newborns = "SP.DYN.CBRT.IN"
  totpop = "SP.POP.TOTL"
  start_year = "1950"
  end_year = "2024"

  mortality_data = scrape_worldbank_data(country, mortality, start_year , end_year)
  totpop_data = scrape_worldbank_data(country, totpop, start_year, end_year )
  newborn_data = scrape_worldbank_data(country, newborns, start_year, end_year )
  # Convert to DataFrame
  mortality_df = pd.DataFrame(mortality_data, columns=['Year', 'Mortality', "Country"])
  newborn_df = pd.DataFrame(newborn_data, columns=['Year', 'Newborns', "Country"])
  totpop_df = pd.DataFrame(totpop_data, columns=['Year', 'TotalPopulation', "Country"])

  # Merging the dataframes
  combined_df = mortality_df.merge(newborn_df, on='Year').merge(totpop_df, on='Year')

  # absolute mubers in newborns and mortality
  combined_df.Mortality = (combined_df.Mortality / 1000) * combined_df.TotalPopulation
  combined_df.Newborns = (combined_df.Newborns / 1000) * combined_df.TotalPopulation

  df = combined_df
  df['MortalityLog'] = np.log1p(df['Mortality'])
  df['NewbornsLog'] = np.log1p(df['Newborns'])
  df['TotalPopLog'] = np.log1p(df['TotalPopulation'])
  df['death_to_pop_ratio'] = df['TotalPopLog'] - df['MortalityLog']
  df['deaths_prop'] = np.log(df['TotalPopulation']) / df['Mortality'] * 100
  # Min-Max Normalization
  df['Mortality_Norm'] = (df['Mortality'] - df['Mortality'].min()) / (df['Mortality'].max() - df['Mortality'].min())
  df['TotalPopulation_Norm'] = (df['TotalPopulation'] - df['TotalPopulation'].min()) / (df['TotalPopulation'].max() - df['TotalPopulation'].min())
  df['Newborns_Norm'] = (df['Newborns'] - df['Newborns'].min()) / (df['Newborns'].max() - df['Newborns'].min())

  #print(df)

  # Plotting
  plt.figure(figsize=(10, 6))
  plt.plot(df['Year'], df['Mortality_Norm'], marker='o', label='Mortality Normalized')
  plt.plot(df['Year'], df['TotalPopulation_Norm'], marker='o', label='Total Population Normalized')
  plt.plot(df['Year'], df['Newborns_Norm'], marker='o', label='Total Newborns Normalized')
  m = min(df['Year'])
  y = max(df['Year'])
  country = df['Country' ][0]
  #plt.plot(df["NewbornsLog"])
  #plt.plot(df["TotalPopLog"])
  plt.title(f'Demographics in {country} ({m}-{y})')
  plt.xlabel("Year")
  plt.ylabel("Number of people, basically.. ")
  plt.grid(True)
  plt.legend()
  plt.tight_layout()
  plt.show()
