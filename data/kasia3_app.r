library(shiny)
library(dplyr)
library(tidyr)
library(readr)
library(plotly)

# Load CSV file with trade data
data <- read_csv("Bratwurst_with_sauerkraut.csv")


# UI
# ================================
ui <- fluidPage(
  titlePanel("Global Spread Of Documented Ingredient Trade Before the Modernization Wave"),  # App title
  
  sidebarLayout(
    sidebarPanel(
      # Slider to choose the time range (start and end year)
      sliderInput("yearRange", "Select time range:",
                  min = min(data$Year), max = 2013,
                  value = c(min(data$Year), max(data$Year)),
                  sep = ""),
      
      # Radio buttons to choose trade type (import, export or both)
      radioButtons("tradeType", "Select trade type:",
                   choices = c("Import", "Export", "Trade (Import + Export)"),
                   selected = "Trade (Import + Export)")
    ),
    
    mainPanel(
      # Output plot (dumbbell chart)
      plotlyOutput("dumbbellPlot")
    )
  )
)

# Server
# ================================
server <- function(input, output) {
  
  output$dumbbellPlot <- renderPlotly({
    # Make sure year range is selected before plotting
    req(input$yearRange)  
    
    # Filter data based on selected years and trade type
    trade_filtered <- data %>%
      filter(Year %in% c(input$yearRange[1], input$yearRange[2])) %>%
      filter(
        case_when(
          input$tradeType == "Import" ~ Element == "Import quantity",
          input$tradeType == "Export" ~ Element == "Export quantity",
          input$tradeType == "Trade (Import + Export)" ~ Element %in% c("Import quantity", "Export quantity")
        )
      )
    
    # Count how many distinct countries are involved in trade for each item and year
    summary <- trade_filtered %>%
      group_by(Item, Year) %>%
      summarise(n_countries = n_distinct(Area), .groups = "drop") %>%
      pivot_wider(names_from = Year, values_from = n_countries,
                  names_prefix = "Year_") %>% 
      # Drop rows where data is missing for either selected year
      drop_na() 
    
    # Identify the two year columns programmatically
    year_cols <- grep("^Year_", names(summary), value = TRUE)
    
    # Reorder items by number of countries in the 2nd selected year (for visual clarity)
    summary <- summary %>%
      arrange(.data[[year_cols[2]]]) %>%
      mutate(Item = factor(Item, levels = Item))
    
    # Create the dumbbell plot using plotly
    plot_ly() %>%
      # Add gray lines connecting the two years for each item
      add_segments(data = summary,
                   x = ~.data[[year_cols[1]]],
                   xend = ~.data[[year_cols[2]]],
                   y = ~Item,
                   yend = ~Item,
                   line = list(color = 'gray'),
                   showlegend = FALSE) %>%
      
      # Left dots (start year), legend hidden
      add_markers(data = summary,
                  x = ~.data[[year_cols[1]]],
                  y = ~Item,
                  name = NULL,
                  marker = list(color = "#0e668b"),  
                  hoverinfo = "text",
                  text = ~paste(input$yearRange[1], ":", .data[[year_cols[1]]]),
                  showlegend = FALSE) %>%
      
      # Right dots (end year), legend hidden
      add_markers(data = summary,
                  x = ~.data[[year_cols[2]]],
                  y = ~Item,
                  name = NULL,
                  marker = list(color = "#c43c3f"),  
                  hoverinfo = "text",
                  text = ~paste(input$yearRange[2], ":", .data[[year_cols[2]]]),
                  showlegend = FALSE) %>%
      
      # Layout options (title, axes)
      layout(title = paste0("Change in Number of Trading Countries (", 
                            input$yearRange[1], " → ", input$yearRange[2], ") — ", input$tradeType),
             xaxis = list(title = "Number of countries"),
             yaxis = list(title = ""),
             hovermode = "closest")
  })
}

# Launch the app :)
shinyApp(ui = ui, server = server)
