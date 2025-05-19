library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "BT4BR project"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Description", tabName = "description", icon = icon("pen")),
      menuItem("Graphs", tabName = "graphs", icon = icon("chart-bar")),
      menuItem("About us", tabName = "about", icon = icon("user"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "description",
              box(
                title = "What is this project about?", 
                status = "primary",  # colour 
                solidHeader = TRUE,
                "It's a really really cool project, please grade it well :D"
              )
      ),
      tabItem(tabName = "graphs",
              fluidRow(
                infoBoxOutput("infoBoxObs"),
                box(
                  title = "Histogram", 
                  status = "primary",  # colour
                  solidHeader = TRUE,
                  sliderInput("n", "Numbers", min = 10, max = 500, value = 100),
                  plotOutput("hist")
                )
              )
      ),
      tabItem(tabName = "about",
              fluidRow(
              
              box(
                width = 4,
                title = "Kaja", 
                status = "primary",  # colour 
                solidHeader = TRUE,
                div(style = "text-align: center;",img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                br(),  # new line
                "Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats"),
                
                box(
                  width = 4,
                  title = "Wiktoria", 
                  status = "primary",  # colour 
                  solidHeader = TRUE,
                  div(style = "text-align: center;",img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                  br(),  # new line
                  "Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats"),
              
                box(
                  width = 4,
                  title = "Kasia", 
                  status = "primary",  # colour 
                  solidHeader = TRUE,
                  div(style = "text-align: center;",img(src = "Kaja.png", style = "border-radius: 2%; max-width: 80%; height: auto;")),
                  br(),  # new line
                  "Very cool person, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats, cats")
              )
      )
    )
  )
)
