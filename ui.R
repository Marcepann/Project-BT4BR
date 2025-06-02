library(shiny)
library(shinythemes)
library(markdown)
library(plotly)
library(readr)
library(dplyr)
library(tidyr)
library(countrycode)
library(RColorBrewer)

ui <- tagList(
  themeSelector(),
  navbarPage("BT4BR project", id = "main_navbar",   # title on the left side of our page
             tabPanel("Description",
                      tags$div(
                        style = "max-width: 800px; margin: auto; padding: 20px; font-size: 16px",
                        
                        wellPanel(
                          tags$details(
                            tags$summary(tags$b("▼ Introduction")),
                            br(),
                            p("This interactive application was created by a group of 3 bioinformatics students finishing their 3rd year of a bachelor's degree. It was developed as part of the course Basic Toolkit 4 Bioinformatics Research. The app was built using R Shiny (shinythemes) and uses packages such as markdown, plotly, readr and dplyr.")
                          )
                        ),
                        
                        wellPanel(
                          tags$details(
                            tags$summary(tags$b("▼ Goals of our project")),
                            br(),
                            p("The main goal of this project was to help us learn how to build interactive applications using real data. We chose to focus on the import and export of ingredients found in popular national dishes - such as pierogi from Poland or lecso from Hungary - and present this information in a more engaging and unconventional way.")
                          )
                        ),
                        
                        wellPanel(
                          tags$details(
                            tags$summary(tags$b("▼ What can I find here?")),
                            br(),
                            p("The application allows users select a dish and view interactive visualisations specific to that dish."),
                            br(),
                            p("It contains five main tabs:"),
                            tags$ul(
                              tags$li(tags$b("Description")),
                              p("This is the first tab that appears after launching the app. It gives an overview of the project and serves as the welcome page. It is the tab that you are currently in."),
                              tags$li(tags$b("Dishes")),
                              p("Here you will find interactive buttons with images and names of various dishes from around the world. When you click on a dish, you’ll be taken to the Graphs tab."),
                              tags$li(tags$b("Graphs")),
                              p("At first, this tab is empty. Once a dish is selected, two interactive graphs will be displayed: a choropleth map and a line chart, each in a separate subtab. You can interact with the graphs by selecting:"),
                              tags$ul(
                                tags$li("ingredient"),
                                tags$li("country"),
                                tags$li("type of data (export or import)"),
                                tags$li("year or a range of years (with a map animation showing how values change over time)")
                              ),
                              br(),
                              p("Furthermore, the selected dish image and the flag of the country of origin are displayed. On the map, the country of origin is also highlighted with a red border."),
                              tags$li(tags$b("About us")),
                              p("In this tab you can see how we divided the work within our team. There are also buttons to download the code parts used for generating the graphs."),
                              tags$li(tags$b("Resources")),
                              p("This tab lists all the websites we used when building the app.")
                            )
                          )
                        )
                      )
             ),
             
             tabPanel("Dishes",
                      fluidPage(
                        fluidRow(
                          column(3, actionButton("Bibimbap", tagList(img(src = "Bibimbap.jpg", width = "100%"), h4("Bibimbap")))),
                          column(3, actionButton("Biryani", tagList(img(src = "Biryani.jpg", width = "100%"), h4("Biryani")))),
                          column(3, actionButton("Carbonara", tagList(img(src = "Carbonara.jpg", width = "100%"), h4("Carbonara")))),
                          column(3, actionButton("Falafel", tagList(img(src = "Falafel.jpg", width = "100%"), h4("Falafel"))))
                        ),
                        br(),
                        fluidRow(
                          column(3, actionButton("Kebab", tagList(img(src = "Kebab.jpg", width = "100%"), h4("Kebab")))),
                          column(3, actionButton("Kimchi", tagList(img(src = "Kimchi.jpg", width = "100%"), h4("Kimchi")))),
                          column(3, actionButton("Lecso", tagList(img(src = "Lecso.jpg", width = "100%"), h4("Lecso")))),
                          column(3, actionButton("Moules-frites", tagList(img(src = "Moules-frites.jpg", width = "100%"), h4("Moules-frites"))))
                        ),
                        br(),
                        fluidRow(
                          column(3, actionButton("Moussaka", tagList(img(src = "Moussaka.jpg", width = "100%"), h4("Moussaka")))),
                          column(3, actionButton("Pad_thai", tagList(img(src = "Pad_thai.jpg", width = "100%"), h4("Pad thai")))),
                          column(3, actionButton("Pierogi", tagList(img(src = "Pierogi.jpeg", width = "100%"), h4("Pierogi")))),
                          column(3, actionButton("Sarma", tagList(img(src = "Sarma.jpg", width = "100%"), h4("Sarma"))))
                        ),
                        br(),
                        fluidRow(
                          column(3, actionButton("Schabowy_with_potatoes_and_mizeria", tagList(img(src = "Schabowy_with_potatoes_and_mizeria.webp", width = "100%"), h4("Schabowy with potatoes and mizeria", style = "white-space: normal; width: 100%")))),
                          column(3, actionButton("Spaghetti_bolognese", tagList(img(src = "Spaghetti_bolognese.jpg", width = "100%"), h4("Spaghetti bolognese")))),
                          column(3, actionButton("Sushi", tagList(img(src = "Sushi.jpg", width = "100%"), h4("Sushi")))),
                          column(3, actionButton("Wurst_with_sauerkraut", tagList(img(src = "Wurst_with_sauerkraut.jpg", width = "100%"), h4("Wurst with sauerkraut", style = "white-space: normal; width: 100%"))))
                        ),
                        hr(),
                        uiOutput("plot_ui")
                      )
             ),
             
             tabPanel("Graphs",
                      fluidPage(
                            tabsetPanel(
                              # ===========================================================================
                              # KASIA'S PART - 1
                              tabPanel("Import / Export Map",
                                       sidebarLayout(
                                         sidebarPanel(
                                           selectInput("kasia1_ingredient", "Choose a Product:", choices = NULL),
                                           selectInput("kasia1_element", "Import or Export:", choices = c("Import quantity", "Export quantity")),
                                           uiOutput("kasia1_year_ui"),
                                           br(),
                                           fluidRow(
                                             column(8, uiOutput("kasia1_dish_image")),
                                             column(4, uiOutput("kasia1_dish_flag"))
                                           )
                                         ),
                                         mainPanel(
                                           plotlyOutput("worldMap1", height = "600px")
                                         )
                                       )
                              ),
                              # ===========================================================================
                              # WIKTORIA'S PART - 1
                              tabPanel("Import / Export Multi-line Plot",
                                       sidebarLayout(
                                         sidebarPanel(
                                           selectInput("wiki1_ingredient", "Choose ingredient:", choices = NULL),
                                           selectInput("country", "Choose country:", choices = NULL),
                                           selectInput("wiki1_element", "Type of data:", choices = c("Import quantity", "Export quantity")),
                                           uiOutput("wiki1_year_ui"),
                                           br(),
                                           fluidRow(
                                             column(8, uiOutput("wiki1_dish_image")),
                                             column(4, uiOutput("wiki1_dish_flag"))
                                           )
                                         ),
                                         
                                         mainPanel(
                                           br(),
                                           plotlyOutput("linePlot", height = "600px", width = "900px")
                                         )
                                       )
                                ),
                                # ===========================================================================
                                # WIKTORIA'S PART - 2
                                tabPanel("Import / Export Barplot",
                                         sidebarLayout(
                                           sidebarPanel(
                                             # Let the user pick which ingredient to look at
                                             uiOutput("wiki2_ingredient_ui"),
                                             # Let the user choose whether to view import or export data
                                             selectInput("wiki2_element", "Type of data:", choices = c("Import quantity", "Export quantity")),
                                             # This will be the year slider, created dynamically based on ingredient and export/import
                                             uiOutput("wiki2_year_ui"),
                                             br(),
                                             fluidRow(
                                               column(8, uiOutput("wiki2_dish_image")),
                                               column(4, uiOutput("wiki2_dish_flag"))
                                             )
                                           ),
                                           
                                           mainPanel(
                                             br(),
                                             plotlyOutput("barPlot", width= "900px", height = "600px")
                                           )
                                         )
                                ),
                                # ===========================================================================
                                # WIKTORIA'S PART - 3
                                tabPanel("Import / Export Piechart",
                                  sidebarLayout(
                                    sidebarPanel(
                                      # Let the user choose whether to view import or export data
                                      selectInput("wiki3_element", "Type of data:", choices = c("Import quantity", "Export quantity")),
                                      selectInput("wiki3_country", "Choose country:", choices = NULL),
                                      sliderInput("wiki3_year", "Years range:", min = as.integer(1960), max = as.integer(2023), value = c(1960, 2023), step = 1, sep = ""),
                                      br(),
                                      fluidRow(
                                        column(8, uiOutput("wiki3_dish_image")),
                                        column(4, uiOutput("wiki3_dish_flag"))
                                      )
                                    ),
                                    
                                    mainPanel(
                                      br(),
                                      plotlyOutput("piePlot")
                                    )
                                  )
                                ),
                                # ===========================================================================
                                # KASIA'S PART - 2
                                tabPanel("Trade Imbalance",
                                         sidebarLayout(
                                            sidebarPanel(
                                              # Let the user pick which ingredient to look at
                                              uiOutput("kasia2_ingredient_ui"),
                                              
                                              # This will be the year slider, created dynamically based on ingredient
                                              uiOutput("kasia2_year_ui"),
                                              br(),
                                              fluidRow(
                                                column(8, uiOutput("kasia2_dish_image")),
                                                column(4, uiOutput("kasia2_dish_flag"))
                                              )
                                            ),
                                            mainPanel(
                                              br(),
                                              # Where the bar chart will show up
                                              plotlyOutput("balancePlot")
                                            )
                                          )
                                ),
                                # ===========================================================================
                                # KASIA'S PART - 3
                                tabPanel("Global Spread Of Trade",
                                         sidebarLayout(
                                           sidebarPanel(
                                             # Slider to choose the time range (start and end year)
                                             uiOutput("yearRange_ui"),
                                             
                                             # Radio buttons to choose trade type (import, export or both)
                                             radioButtons("tradeType", "Select trade type:",
                                                          choices = c("Import", "Export", "Trade (Import + Export)"),
                                                          selected = "Trade (Import + Export)"),
                                             br(),
                                             fluidRow(
                                               column(8, uiOutput("kasia3_dish_image")),
                                               column(4, uiOutput("kasia3_dish_flag"))
                                             )
                                           ),
                                           
                                           mainPanel(
                                             br(),
                                             # Output plot (dumbbell chart)
                                             plotlyOutput("dumbbellPlot")
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
                                 downloadButton("downloadWiki1App", "Download Import/Export Multi-line Plot", 
                                                style = "white-space: normal; width: 100%; font-size: 14px"),
                                 div(style = "margin-top: 10px"),
                                 downloadButton("downloadWiki2App", "Download Import/Export Barplot", 
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
                                 downloadButton("downloadKasia1App", "Download Import/Export Map", 
                                                style = "white-space: normal; width: 100%; font-size: 14px"),
                                 div(style = "margin-top: 10px"),
                                 downloadButton("downloadKasia2App", "Download Trade Imbalance Graph", 
                                                style = "white-space: normal; width: 100%; font-size: 14px"),
                                 div(style = "margin-top: 10px"),
                                 downloadButton("downloadKasia3App", "Download Global Spread of Trade Graph", 
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
