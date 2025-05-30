library(shiny)
library(shinythemes)
library(markdown)
library(plotly)
library(readr)
library(dplyr)
library(countrycode)
library(RColorBrewer)

ui <- tagList(
  themeSelector(),
  navbarPage("BT4BR project",  # title on the left side of our page
             tabPanel("Description",
                      mainPanel(
                               wellPanel(
                                 h3("What is this project about?"),
                                 p("It's a really really cool project, please grade it well :D")
                               )
                      )
             ),
             tabPanel("Graphs",
                        sidebarPanel(
                          uiOutput("infoBoxObs"),
                          sliderInput("n", "Numbers", min = 10, max = 500, value = 100)
                        ),
                        mainPanel(
                          plotOutput("hist")
                        )
             ),
             tabPanel("About us",
                      mainPanel(
                        column(4,
                               wellPanel(
                                 h4("Kaja"),
                                 div(style = "text-align: center;", 
                                     img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats")
                               )
                        ),
                        column(4,
                               wellPanel(
                                 h4("Wiktoria"),
                                 div(style = "text-align: center;", 
                                     img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats")
                               )
                        ),
                        column(4,
                               wellPanel(
                                 h4("Kasia"),
                                 div(style = "text-align: center;", 
                                     img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats")
                               )
                        )
                      )
             ),
             tabPanel("Description",
                      mainPanel(
                        includeMarkdown("include.md")
                      )
             )
  )
)
