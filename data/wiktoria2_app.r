# install.packages(c("shiny", "plotly", "readr", "dplyr", "RColorBrewer"))
library(shiny)
library(plotly)
library(readr)
library(dplyr)
library(RColorBrewer)

# Load data from a CSV file
df <- read_csv("Bratwurst_with_sauerkraut.csv")

# ---- UI ----
ui <- fluidPage(
  titlePanel("Top 10 countries by import/export of ingredient in years"),
  
  
  sidebarLayout(
    sidebarPanel(
      # Let the user pick which ingredient to look at
      selectInput("ingredient", "Choose ingredient:", choices = unique(df$Item)),
      # Let the user choose whether to view import or export data
      selectInput("element", "Type of data:", choices = c("Import quantity", "Export quantity")),
      # This will be the year slider, created dynamically based on ingredient and export/import
      uiOutput("year_ui")
    ),
    
    mainPanel(
      plotlyOutput("barPlot", width= "900px", height = "600px")
    )
  )
)


# ---- SERVER ----
server <- function(input, output, session) {
  
  # Create a year slider that only shows years with data for the selected ingredient and element
  output$year_ui <- renderUI({
    req(input$ingredient, input$element)
    years_available <- df %>%
      filter(Item == input$ingredient, Element==input$element) %>%
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
  
  output$barPlot <- renderPlotly({
    req(input$ingredient, input$element, input$year)
    
    # Filter data for the selected ingredient, element type (import/export),
    # and years.
    filtered <- df %>%
      filter(
        Item == input$ingredient,
        Element == input$element,
        Year == input$year,
        !is.na(Value)
      )
    
    #filter top 10 countries
    top_countries <- filtered %>%
      group_by(Area) %>%
      summarise(value = sum(Value, na.rm = TRUE)) %>%
      arrange(desc(value)) %>%
      ungroup() %>%
      head(10)
    
    if (nrow(top_countries) == 0) {
      return(plotly_empty())
    }
    
    color <- colorRampPalette(brewer.pal(8, "Set2"))(10)
    
    # Draw bar plot showing top 10 countries by import/export of the selected ingredient in the chosen year
    p <- ggplot(top_countries, aes(x = reorder(Area, value), y = value, fill = Area)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = color) +
      labs(
        title = paste(input$element, "of", input$ingredient, "in" ,input$year),
        x = "Country", y = "Average value (t)", fill = "Country"
      ) +
      theme_minimal()+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = c("x", "y"))
  })
}

# RUN
shinyApp(ui, server)
