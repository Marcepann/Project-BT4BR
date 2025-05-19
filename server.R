library(shiny)
library(shinydashboard)

server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$n), col = "#007ACC", border = "white")
  })
  
  output$infoBoxObs <- renderInfoBox({
    infoBox("Cool stuff", input$n, icon = icon("list"), color = "blue")
  })
}
