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
  navbarPage("BT4BR project", id = "main_navbar",   # title on the left side of our page
             tabPanel("Description",
                      mainPanel(
                               wellPanel(
                                 h3("What is this project about?"),
                                 p("It's a really really cool project, please grade it well :D")
                               )
                      )
             ),
             
             tabPanel("Dishes",
                      fluidPage(
                        fluidRow(
                          column(3,
                                 actionButton("Bibimbap",
                                              tagList(
                                                img(src = "Bibimbap.jpg", width = "100%"),
                                                h4("Bibimbap")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Biryani",
                                              tagList(
                                                img(src = "Biryani.jpg", width = "100%"),
                                                h4("Biryani")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Bratwurst with sauerkraut",
                                              tagList(
                                                img(src = "Bratwurst with sauerkraut.jpg", width = "100%"),
                                                h4("Bratwurst with sauerkraut", style = "white-space: normal; width: 100%")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Carbonara",
                                              tagList(
                                                img(src = "Carbonara.jpg", width = "100%"),
                                                h4("Carbonara")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Falafel",
                                              tagList(
                                                img(src = "Falafel.jpg", width = "100%"),
                                                h4("Falafel")
                                              )
                                 )
                          ),
                          column(3,
                                   actionButton("Kebab",
                                                tagList(
                                                  img(src = "Kebab.jpg", width = "100%"),
                                                  h4("Kebab")
                                                )
                                   )
                          ),
                          column(3,
                                 actionButton("Kimchi",
                                              tagList(
                                                img(src = "Kimchi.jpg", width = "100%"),
                                                h4("Kimchi")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Lecso",
                                              tagList(
                                                img(src = "Lecso.jpg", width = "100%"),
                                                h4("Lecso")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Moules-frites",
                                              tagList(
                                                img(src = "Moules-frites.jpg", width = "100%"),
                                                h4("Moules-frites")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Moussaka",
                                              tagList(
                                                img(src = "Moussaka.jpg", width = "100%"),
                                                h4("Moussaka")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Pad thai",
                                              tagList(
                                                img(src = "Pad thai.jpg", width = "100%"),
                                                h4("Pad thai")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Pierogi",
                                              tagList(
                                                img(src = "Pierogi.jpeg", width = "100%"),
                                                h4("Pierogi")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Sarma",
                                              tagList(
                                                img(src = "Sarma.jpg", width = "100%"),
                                                h4("Sarma")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Schabowy with potatoes and mizeria",
                                              tagList(
                                                img(src = "Schabowy with potatoes and mizeria.webp", width = "100%"),
                                                h4("Schabowy with potatoes and mizeria", style = "white-space: normal; width: 100%")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Spaghetti bolognese",
                                              tagList(
                                                img(src = "Spaghetti bolognese.jpg", width = "100%"),
                                                h4("Spaghetti bolognese")
                                              )
                                 )
                          ),
                          column(3,
                                 actionButton("Sushi",
                                              tagList(
                                                img(src = "Sushi.jpg", width = "100%"),
                                                h4("Sushi")
                                              )
                                 )
                          )
                        ),
                        hr(),
                        uiOutput("plot_ui")
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
                                       uiOutput("map_year_ui"),
                                       fluidRow(
                                         column(8, uiOutput("map_dish_image")),
                                         column(4, uiOutput("map_dish_flag"))
                                       )
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
                                       uiOutput("plot_year_ui"),
                                       fluidRow(
                                         column(8, uiOutput("plot_dish_image")),
                                         column(4, uiOutput("plot_dish_flag"))
                                       )
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
