# install.packages(c("shiny", "plotly", "readr", "dplyr", "RColorBrewer"))
library(shiny)
library(plotly)
library(readr)
library(dplyr)
library(RColorBrewer)

# Load data from a CSV file
df <- read_csv("C:/Users/wikto/Downloads/spaghetti_swiat.csv")

# ---- UI ----
ui <- fluidPage(
  titlePanel("Percentage of ingredients in a given dish"),
  
  
  sidebarLayout(
    sidebarPanel(
      # Let the user choose whether to view import or export data
      selectInput("element", "Type of data:", choices = c("Import quantity", "Export quantity")),
      selectInput("country", "Choose country:", choices = NULL),
      sliderInput("year", "Years range:", min=1960, max=2023, value=c(1960,2023))
      
    ),
    
    mainPanel(
      plotlyOutput("piePlot")
    )
  )
)


# ---- SERVER ----
server <- function(input, output, session) {
  observe({
    updateSelectInput(session, "country", choices = unique(df$Area))
  })
  output$piePlot <- renderPlotly({
    
    req(input$country, input$element, input$year)
    
    # Filtrowanie danych
    pie_data <- df %>%
      filter(
        Area == input$country,
        Element == input$element,
        !is.na(Value), !is.na(Item),
        Year >= input$year[1], Year <= input$year[2]
      ) %>%
      group_by(Item) %>%
      summarise(total = sum(Value, na.rm = TRUE)) %>%
      arrange(desc(total))
    
    
    plot_ly(
      pie_data,
      labels = ~Item,
      values = ~total,
      type = "pie",
      textinfo = "label+percent",
      insidetextorientation = "radial"
    ) %>%
      layout(title = paste("Share of", input$element, "in", input$country, "from", input$year[1], "to", input$year[2]),
      margin=list(l=350)
  )
  })
}
  
# RUN
shinyApp(ui, server)
