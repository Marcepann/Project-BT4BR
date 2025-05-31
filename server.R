server <- function(input, output, session) {
  # needed data
  df <- read_csv("spaghetti_swiat.csv")
  df$iso3 <- countrycode(df$Area, origin = "country.name", destination = "iso3c", warn = FALSE)
  
  # ===========================================================================
  # KASIA'S PART
  # choosing ingredient
  observe({
    updateSelectInput(session, "map_ingredient", choices = unique(df$Item))
  })
  
  # choosing a year
  output$map_year_ui <- renderUI({
    req(input$map_ingredient, input$map_element)
    
    available_years <- df %>%
      filter(Item == input$map_ingredient,
             Element == input$map_element,
             !is.na(Value)) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    sliderInput("year", "Choose Year:",
                min = min(available_years),
                max = max(available_years),
                value = min(available_years),
                step = 1,
                sep = "",
                animate = animationOptions(interval = 1000, loop = TRUE))
  })
  
  
  observeEvent(c(input$map_ingredient, input$map_element), {
    req(input$map_ingredient, input$map_element)
    
    available_years <- df %>%
      filter(Item == input$map_ingredient,
             Element == input$map_element,
             !is.na(Value)) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    updateSliderInput(session, "year",
                      min = min(available_years),
                      max = max(available_years),
                      value = min(available_years))
  })
  
  
  # rendering a map
  output$worldMap <- renderPlotly({
    req(input$map_ingredient, input$year, input$map_element)
    
    filtered <- df %>%
      filter(Item == input$map_ingredient,
             Year == input$year,
             Element == input$map_element,
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
        title = paste(input$map_element, "of", input$map_ingredient, "in", input$year),
        geo = list(
          showframe = FALSE,
          showcoastlines = FALSE,
          showcountries = TRUE,
          countrycolor = "gray",
          projection = list(type = 'equirectangular')
        ),
        margin = list(t = 80, b = 0, l = 0, r = 0)
      )
  })
  # ===========================================================================
  # WIKTORIA'S PART
  observe({
    ingredients <- sort(unique(df$Item))
    updateSelectInput(session, "plot_ingredient", choices = c("All ingredients", ingredients))
    updateSelectInput(session, "country", choices = unique(df$Area))
  })
  
  output$plot_year_ui <- renderUI({
    available_years <- df %>%
      filter(
        Area == input$country,
        Item == input$plot_ingredient | input$plot_ingredient == "All ingredients",
        Element == input$plot_element
      ) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    if (length(available_years) == 0) {
      return(tags$em("No available years for selected options"))
    }
    
    sliderInput("years", "Years range:",
                min = min(available_years),
                max = max(available_years),
                value = c(min(available_years), max(available_years)),
                step = 1,
                sep = "")
  })
  
  output$linePlot <- renderPlotly({
    req(input$plot_ingredient, input$country, input$plot_element, input$years)
    
    colors_of_ingredients <- setNames(
      colorRampPalette(brewer.pal(8, "Paired"))(length(unique(df$Item))),
      sort(unique(df$Item))
    )
    
    filtered <- df %>%
      filter(
        Area == input$country,
        Element == input$plot_element,
        !is.na(Value), !is.na(Item),
        Year >= input$years[1], Year <= input$years[2]
      )
    
    if (input$plot_ingredient == "All ingredients") {
      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line(size = 0.6) +
        geom_point(size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$plot_element, "of all ingredients in", input$country),
          x = "Year", y = "Value (t)", color = "Ingredients"
        ) +
        theme_minimal()
    } 
    else {
      filtered <- df %>%
        filter(
          Area == input$country,
          Element == input$plot_element,
          !is.na(Value), !is.na(Item),
          Year >= input$years[1], Year <= input$years[2]
        )
      
      if (input$plot_ingredient != "All ingredients") {
        filtered <- filtered %>% filter(Item == input$plot_ingredient)
      }
      
      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line(size = 0.6) +
        geom_point(size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$plot_element, "of", input$plot_ingredient, "in", input$country),
          x = "Year", y = "Value (t)", color = "Ingredient"
        ) +
        theme_minimal()
    }
    
    ggplotly(p, tooltip = c("x", "y", "color")) %>% 
      layout(hovermode = "x unified")
  })
  # ===========================================================================
  output$downloadKasiaApp <- downloadHandler(
    filename = function() {
      "kasia_app.r"
    },
    content = function(file) {
      file.copy("kasia_app.r", file)
    },
    contentType = "text/plain"
  )
  
  output$downloadWikiApp <- downloadHandler(
    filename = function() {
      "wiktoria_app.r"
    },
    content = function(file) {
      file.copy("wiktoria_app.r", file)
    },
    contentType = "text/plain"
  )
  
}
