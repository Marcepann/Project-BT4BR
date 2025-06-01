library(shiny)
library(plotly)
library(readr)
library(dplyr)
library(countrycode)


df <- read_csv("spaghetti_swiat.csv")
df$iso3 <- countrycode(df$Area, origin = "country.name", destination = "iso3c")


ui <- fillPage(
  titlePanel("Global Import/Export of Products"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("ingredient", "Choose Product:", choices = NULL),
      selectInput("element", "Import or Export:", choices = c("Import quantity", "Export quantity")),
      selectInput("year", "Choose Year:", choices = NULL)
    ),
    
    mainPanel(
      plotlyOutput("worldMap", height = "100%")
    )
  )
)


server <- function(input, output, session) {
  observe({
    updateSelectInput(session, "ingredient", choices = unique(df$Item))
  })
  
  observeEvent(c(input$ingredient, input$element), {
    req(input$ingredient, input$element)
    
    available_years <- df %>%
      filter(Item == input$ingredient,
             Element == input$element,
             !is.na(Value)) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    updateSelectInput(session, "year", choices = available_years)
  })
  
  output$worldMap <- renderPlotly({
    req(input$ingredient, input$year, input$element)
    
    filtered <- df %>%
      filter(Item == input$ingredient,
             Year == input$year,
             Element == input$element,
             !is.na(Value),
             !is.na(iso3))
    
    plot_geo(filtered) %>%
      add_trace(
        z = ~Value,
        color = ~Value,
        colors = "Blues",
        text = ~paste(Area, "<br>", Value, "t"),
        locations = ~iso3,
        marker = list(line = list(color = "gray", width = 0.5))
      ) %>%
      colorbar(title = "Quantity (t)") %>%
      layout(
        title = paste(input$element, "of", input$ingredient, "in", input$year),
        geo = list(
          showframe = FALSE,
          showcoastlines = FALSE,
          showcountries = TRUE,  # fixing non-visible countries
          countrycolor = "gray",  # colour of non-visible countries outline
          projection = list(type = 'equirectangular')
        ),
        margin = list(t = 80, b = 0, l = 0, r = 0)
      )
  })
}


shinyApp(ui, server)
