# List of packages to install
packages <- c("shiny", "reticulate", "dplyr", "ggplot2", "httr", "jsonlite")

# Function to install the package if not already installed
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
  }
}

# Apply the function to each package in the list
for (pkg in packages) {
  install_if_missing(pkg)
}

library(shiny)
library(reticulate)
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
py_install(c("requests", "pandas", "matplotlib", "beautifulsoup4", "numpy"))

# Source the Python script
source_python("pythonscripts/pythonscript.py")

ui <- fluidPage(
  titlePanel("Country Demographics Plot"),
  sidebarLayout(
    sidebarPanel(
      textInput("countryCode", "Enter Country Code", value = "CH"),
      actionButton("plotButton", "Generate Plot")
    ),
    mainPanel(
      plotOutput("demographicsPlot")
    )
  )
)

server <- function(input, output) {
  output$demographicsPlot <- renderPlot({
    req(input$plotButton)  # Ensure plot is generated only after button click
    
    # Call Python function with user input
    isolate({
      country_code <- input$countryCode
      if (nchar(country_code) > 0) {
        plot_death_to_population_grow_ratio(country_code)
      }
    })
  })
}

shinyApp(ui = ui, server = server)
