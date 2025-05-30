server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$n), main = "Histogram", col = "#1E90FF", border = "white")
  })
  
  output$infoBoxObs <- renderUI({
    div(
      class = "well",
      h4("Info box"),
      p(paste("Number of observations:", input$n))
    )
  })
}