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
                      fluidPage(  
                        titlePanel("Global Import / Export of Products"),
                          tabsetPanel(
                            # ===========================================================================
                            # KASIA'S PART
                            tabPanel("Map",
                                     sidebarLayout(
                                       sidebarPanel(
                                         selectInput("map_ingredient", "Choose a Product:", choices = NULL),
                                         selectInput("map_element", "Import or Export:", choices = c("Import quantity", "Export quantity")),
                                         uiOutput("map_year_ui")
                                       ),
                                       mainPanel(
                                         plotlyOutput("worldMap", height = "600px")
                                       )
                                     )
                            ),
                            # ===========================================================================
                            # WIKTORIA'S PART
                            tabPanel("Plot",
                                     sidebarLayout(
                                       sidebarPanel(
                                         selectInput("plot_ingredient", "Choose ingredient:", choices = NULL),
                                         selectInput("country", "Choose country:", choices = NULL),
                                         selectInput("plot_element", "Type of data:", choices = c("Import quantity", "Export quantity")),
                                         uiOutput("plot_year_ui")
                                       ),
                                       
                                       mainPanel(
                                         plotlyOutput("linePlot", height = "600px", width = "900px")
                                       )
                                     )
                            )
                            # ===========================================================================
                          )
                      )
             ),
             tabPanel("About us",
                      mainPanel(
                        column(4,
                               wellPanel(
                                 h4("Kaja"),
                                 div(style = "text-align: center;", 
                                 img(src = "kociakslodziak.jpeg", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("They were in charge of putting everything together and making this beautiful website - so they did everything except the graphs (but they debugged them and tinkered with them a little.)")
                               )
                        ),
                        column(4,
                               wellPanel(
                                 h4("Wiktoria"),
                                 div(style = "text-align: center;", 
                                 img(src = "wikikot.jpg", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("She was in charge of generating the", tags$b("plots"), "in RShiny and collecting the input CSV files."),
                                 downloadButton("downloadWikiApp", "Download her code", 
                                                style = "white-space: normal; width: 100%; font-size: 14px")
                               )
                        ),
                        column(4,
                               wellPanel(
                                 h4("Kasia"),
                                 div(style = "text-align: center;", 
                                 img(src = "pysiozbysio.jpg", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                                 br(),
                                 p("She was in charge of generating the", tags$b("maps"), "in RShiny and collecting the input CSV files."),
                                 downloadButton("downloadKasiaApp", "Download her code", 
                                                style = "white-space: normal; width: 100%; font-size: 14px")
                               )
                        )
                      )
             ),
             tabPanel("Resources",
                      wellPanel(
                        includeMarkdown("sources.md")
                      )
             )
  )
)
