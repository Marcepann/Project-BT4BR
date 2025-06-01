server <- function(input, output, session) {
  # opening the right csv files
  selected_dish <- reactiveVal(NULL)
  
  dish_data <- reactive({
    req(selected_dish())
    filepath <- paste0("data/", selected_dish(), ".csv")
    read.csv(filepath)
  })
  
  df <- reactive({
    req(dish_data())
    data <- dish_data()
    data$iso3 <- countrycode(as.character(data$Area), origin = "country.name", destination = "iso3c", warn = FALSE)
    data
  })
  
  observeEvent(df(), {
    updateSelectInput(session, "map_ingredient", choices = unique(df()$Item), selected = unique(df()$Item)[1])
    updateSelectInput(session, "map_element", choices = unique(df()$Element), selected = unique(df()$Element)[1])
    
    updateSelectInput(session, "plot_ingredient", choices = c("All ingredients", sort(unique(df()$Item))), selected = "All ingredients")
    updateSelectInput(session, "plot_element", choices = unique(df()$Element), selected = unique(df()$Element)[1])
    updateSelectInput(session, "country", choices = unique(df()$Area), selected = unique(df()$Area)[1])
  })
  
  # ===========================================================================
  # KASIA'S PART
  # choosing ingredient
  observe({
    updateSelectInput(session, "map_ingredient", choices = unique(df()$Item))
  })
  
  # choosing a year
  output$map_year_ui <- renderUI({
    req(input$map_ingredient, input$map_element)
    
    available_years <- df() %>%
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
    
    available_years <- df() %>%
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
    
    filtered <- df() %>%
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
    ingredients <- sort(unique(df()$Item))
    updateSelectInput(session, "plot_ingredient", choices = c("All ingredients", ingredients))
    updateSelectInput(session, "country", choices = unique(df()$Area))
  })
  
  output$plot_year_ui <- renderUI({
    available_years <- df() %>%
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
      colorRampPalette(brewer.pal(8, "Paired"))(length(unique(df()$Item))),
      sort(unique(df()$Item))
    )
    
    filtered <- df() %>%
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
      filtered <- df() %>%
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
  # making button to download Kasia's code
  output$downloadKasiaApp <- downloadHandler(
    filename = function() {
      "data/kasia_app.r"
    },
    content = function(file) {
      file.copy("data/kasia_app.r", file)
    },
    contentType = "text/plain"
  )
  
  # making button to download Wiktoria's code
  output$downloadWikiApp <- downloadHandler(
    filename = function() {
      "data/wiktoria_app.r"
    },
    content = function(file) {
      file.copy("data/wiktoria_app.r", file)
    },
    contentType = "text/plain"
  )
  
  # list of dishes and flags
  dish_image_paths <- list(
    "Bibimbap" = list(flag = "South Korea.png", dish = "Bibimbap.jpg"),
    "Biryani" = list(flag = "India.png", dish = "Biryani.jpg"),
    "Bratwurst with sauerkraut" = list(flag = "Germany.png", dish = "Bratwurst with sauerkraut.jpg"),
    "Carbonara" = list(flag = "Italy.png", dish = "Carbonara.jpg"),
    "Falafel" = list(flag = "Egypt.png", dish = "Falafel.jpg"),
    "Kebab" = list(flag = "Turkey.svg", dish = "Kebab.jpg"),
    "Kimchi" = list(flag = "South Korea.png", dish = "Kimchi.jpg"),
    "Lecso" = list(flag = "Hungary.png", dish = "Lecso.jpg"),
    "Moules-frites" = list(flag = "Belgium.png", dish = "Moules-frites.jpg"),
    "Moussaka" = list(flag = "Greece.png", dish = "Moussaka.jpg"),
    "Pad thai" = list(flag = "Thailand.png", dish = "Pad thai.jpg"),
    "Pierogi" = list(flag = "Poland.png", dish = "Pierogi.jpeg"),
    "Sarma" = list(flag = "Turkey.svg", dish = "Sarma.jpg"),
    "Schabowy with potatoes and mizeria" = list(flag = "Poland.png", dish = "Schabowy with potatoes and mizeria.webp"),
    "Spaghetti bolognese" = list(flag = "Italy.png", dish = "Spaghetti bolognese.jpg"),
    "Sushi" = list(flag = "Japan.png", dish = "Sushi.jpg")
  )
  
  # generating food buttons
  lapply(names(dish_image_paths), function(dish) {
    observeEvent(input[[dish]], {
      selected_dish(dish)
      updateNavbarPage(session, inputId = "main_navbar", selected = "Graphs")
    })
  })
  
  # inserting images into the tabpanel
  output$map_dish_image <- renderUI({
    req(selected_dish())
    img_src <- dish_image_paths[[selected_dish()]]$dish
    img(src = img_src, width = "100%")
  })
  
  output$map_dish_flag <- renderUI({
    req(selected_dish())
    img_src <- dish_image_paths[[selected_dish()]]$flag
    img(src = img_src, width = "100%")
  })
  
  output$plot_dish_image <- renderUI({
    req(selected_dish())
    img_src <- dish_image_paths[[selected_dish()]]$dish
    img(src = img_src, width = "100%")
  })
  
  output$plot_dish_flag <- renderUI({
    req(selected_dish())
    img_src <- dish_image_paths[[selected_dish()]]$flag
    img(src = img_src, width = "100%")
  })
}
