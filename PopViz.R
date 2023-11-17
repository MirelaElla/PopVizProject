library(shiny)
library(ggplot2)

# Source the R script with data processing functions
source("scraping.R") # Replace with the actual name of your script

# Define UI
ui <- fluidPage(
  titlePanel("World Bank Data Visualization"),
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

# Define Server Logic
server <- function(input, output) {
  observeEvent(input$plotButton, {
    req(input$countryCode) # Ensure there is input before proceeding
    
    # Call function from the sourced script with user input
    output$demographicsPlot <- renderPlot({
      plot_death_to_population_grow_ratio(input$countryCode)
    })
  })
}

# Run the App
shinyApp(ui = ui, server = server)




