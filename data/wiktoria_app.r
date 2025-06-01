# library(shiny)
library(plotly)
library(readr)
library(dplyr)
library(countrycode)
library(RColorBrewer)
library(hrbrthemes)

table <- read_csv("spaghetti_swiat.csv")

# UI
ui <- fluidPage(
  titlePanel("Ingredients for spaghetti"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("ingredient", "Choose ingredient:", choices = NULL),
      selectInput("country", "Choose country:", choices = NULL),
      selectInput("element", "Type of data:", choices = c("Import quantity", "Export quantity")),
      sliderInput("years", "Years range:", min=1960, max=2023, value=c(1960,2023))
    ),
    
    mainPanel(
      plotlyOutput("linePlot", height = "600px", width = "900px")
    )
  )
)

# SERVER
server <- function(input, output, session) {
  
  observe({
    ingredients <- sort(unique(table$Item))
    updateSelectInput(session, "ingredient", choices = c("All ingredients", ingredients))
    updateSelectInput(session, "country", choices = unique(table$Area))
  })
  
  output$linePlot <- renderPlotly({
    
    req(input$ingredient, input$country, input$element)
    
    colors_of_ingredients <- setNames(
      colorRampPalette(brewer.pal(8, "Paired"))(length(unique(table$Item))),
      sort(unique(table$Item))
    )
    
    filtered <- table %>%
      filter(
        Area == input$country,
        Element == input$element,
        !is.na(Value), !is.na(Item),
        Year >= input$years[1], Year <= input$years[2]
      )
    
    if (input$ingredient == "All ingredients") {

      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line(size = 0.6) +
        geom_point(size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$element, "of all ingredients in", input$country),
          x = "Year", y = "Value (t)", color = "Ingredients"
        ) +
        theme_minimal()
      } 
    else {
  
      filtered <- filtered %>% 
        filter(Item == input$ingredient)
      
      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line( size = 0.6) +
        geom_point( size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$element, "of", input$ingredient, "in", input$country),
          x = "Year", y = "Value (t)", color= "Ingredient"
        ) +
        theme_minimal()
    }
    
    ggplotly(p, tooltip = c("x", "y", "color")) %>% 
      layout(hovermode = "x unified")
  })

}
shinyApp(ui, server)