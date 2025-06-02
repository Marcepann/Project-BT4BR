library(shiny)
library(plotly)
library(dplyr)
library(readr)
library(tidyr)

# Load data from a CSV file
df <- read_csv("Bratwurst_with_sauerkraut.csv")

# ---- UI ----
ui <- fluidPage(
  titlePanel("Top 15 Countries by Trade Imbalance"),
  sidebarLayout(
    sidebarPanel(
      # Let the user pick which ingredient to look at
      selectInput("ingredient", "Select Ingredient:", choices = unique(df$Item)),
      
      # This will be the year slider, created dynamically based on ingredient
      uiOutput("year_ui")
    ),
    mainPanel(
      # Where the bar chart will show up
      plotlyOutput("balancePlot")
    )
  )
)

# ---- SERVER ----
server <- function(input, output, session) {
  
  # Create a year slider that only shows years with data for the selected ingredient
  output$year_ui <- renderUI({
    req(input$ingredient)
    years_available <- df %>%
      filter(Item == input$ingredient) %>%
      distinct(Year) %>%
      arrange(Year) %>%
      pull(Year)
    
    sliderInput("year", "Select Year:",
                min = min(years_available),
                max = max(years_available),
                value = max(years_available),
                step = 1,
                sep = "",
                ticks = FALSE)
  })
  
  # Prepare the data for the plot: filter by ingredient and year, calculate trade balance, and pick top 15 countries
  trade_balance <- reactive({
    req(input$ingredient, input$year)
    df %>%
      filter(Item == input$ingredient, Year == input$year) %>%
      select(Area, Element, Value) %>%
      pivot_wider(names_from = Element, values_from = Value, values_fill = 0) %>%
      mutate(Balance = `Export quantity` - `Import quantity`) %>%
      group_by(Area) %>%
      summarize(Balance = sum(Balance), .groups = "drop") %>%
      mutate(abs_balance = abs(Balance)) %>%
      arrange(desc(abs_balance)) %>%
      slice_head(n = 15)
  })
  
  # Draw the bar chart showing trade balance, color coded by surplus ++ (green) or deficit -- (red)
  output$balancePlot <- renderPlotly({
    d <- trade_balance()
    
    # nothing to plot if data is empty~
    if (nrow(d) == 0) return(NULL)
    
    plot_ly(d,
            x = ~Balance,
            y = ~reorder(Area, Balance),
            type = "bar",
            orientation = "h",
            marker = list(color = ~ifelse(Balance > 0, "green", "red")),
            hovertemplate = paste('Balance: %{x:,} tons<extra></extra>')
    ) %>%
      layout(
        title = paste("Top 15 Trade Balance Differences for", input$ingredient, "in", input$year),
        xaxis = list(title = "Trade Balance (Export - Import)"),
        yaxis = list(title = "")
      )
  })
}

# Start the app :)
shinyApp(ui, server)
