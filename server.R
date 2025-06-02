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
    updateSelectInput(session, "country", choices = unique(df()$Area), selected = unique(df()$Area)[1])
    
    updateSelectInput(session, "kasia1_ingredient", choices = unique(df()$Item), selected = unique(df()$Item)[1])
    updateSelectInput(session, "kasia1_element", choices = unique(df()$Element), selected = unique(df()$Element)[1])
    
    updateSelectInput(session, "wiki1_ingredient", choices = c("All ingredients", sort(unique(df()$Item))), selected = "All ingredients")
    updateSelectInput(session, "wiki1_element", choices = unique(df()$Element), selected = unique(df()$Element)[1])
  })
  
  # ===========================================================================
  # KASIA'S PART
  # FIRST GRAPH
  # choosing ingredient
  observe({
    updateSelectInput(session, "kasia1_ingredient", choices = unique(df()$Item))
  })
  
  # choosing a year
  output$kasia1_year_ui <- renderUI({
    req(input$kasia1_ingredient, input$kasia1_element)
    
    available_years <- df() %>%
      filter(Item == input$kasia1_ingredient,
             Element == input$kasia1_element,
             !is.na(Value)) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    sliderInput("kasia1_year", "Choose Year:",
                min = min(available_years),
                max = max(available_years),
                value = min(available_years),
                step = 1,
                sep = "",
                animate = animationOptions(interval = 1000, loop = TRUE))
  })
  
  
  observeEvent(c(input$kasia1_ingredient, input$kasia1_element), {
    req(input$kasia1_ingredient, input$kasia1_element)
    
    available_years <- df() %>%
      filter(Item == input$kasia1_ingredient,
             Element == input$kasia1_element,
             !is.na(Value)) %>%
      pull(Year) %>%
      unique() %>%
      sort()
    
    updateSliderInput(session, "kasia1_year",
                      min = min(available_years),
                      max = max(available_years),
                      value = min(available_years))
  })
  
  
  # rendering a map
  output$worldMap1 <- renderPlotly({
    req(input$kasia1_ingredient, input$kasia1_year, input$kasia1_element, selected_dish())
    
    # Dane do mapy
    filtered <- df() %>%
      filter(Item == input$kasia1_ingredient,
             Year == input$kasia1_year,
             Element == input$kasia1_element,
             !is.na(Value),
             !is.na(iso3))
    
    # Kraj pochodzenia potrawy
    origin_country <- get_country_from_dish(selected_dish())
    origin_country_iso3 <- countrycode(origin_country, origin = "country.name", destination = "iso3c")
    
    # Dane z wartością tylko dla tego kraju
    highlight_df <- data.frame(
      iso3 = origin_country_iso3,
      highlight = 1
    )
    
    plot_geo(filtered) %>%
      add_trace(
        z = ~Value,
        color = ~Value,
        colors = "Blues",
        text = ~paste(Area, "<br>", Value, "t"),
        hoverinfo = "text",
        locations = ~iso3,
        marker = list(
          line = list(
            color = ifelse(filtered$iso3 == origin_country_iso3, "red", "gray"),
            width = ifelse(filtered$iso3 == origin_country_iso3, 2, 0.5)
          )
        )
      )%>%
      colorbar(title = "Quantity (t)") %>%
      layout(
        title = paste(input$kasia1_element, "of", input$kasia1_ingredient, "in", input$kasia1_year),
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
  # KASIA'S PART
  # SECOND GRAPH
  output$kasia2_ingredient_ui <- renderUI({
    req(df())
    selectInput("kasia2_ingredient", "Select Ingredient:", choices = unique(df()$Item))
  })
  
  # Create a year slider that only shows years with data for the selected ingredient
  output$kasia2_year_ui <- renderUI({
    req(input$kasia2_ingredient)
    years_available <- df() %>%
      filter(Item == input$kasia2_ingredient) %>%
      distinct(Year) %>%
      arrange(Year) %>%
      pull(Year)
    
    sliderInput("kasia2_year", "Select Year:",
                min = min(years_available),
                max = max(years_available),
                value = max(years_available),
                step = 1,
                sep = "",
                ticks = TRUE)
  })
  
  # Prepare the data for the plot: filter by ingredient and year, calculate trade balance, and pick top 15 countries
  trade_balance <- reactive({
    req(input$kasia2_ingredient, input$kasia2_year)
    df() %>%
      filter(Item == input$kasia2_ingredient, Year == input$kasia2_year) %>%
      select(Area, Element, Value) %>%
      pivot_wider(names_from = Element, values_from = Value, values_fill = 0) %>%
      mutate(Balance = `Export quantity` - `Import quantity`) %>%
      group_by(Area) %>%
      summarize(Balance = sum(Balance), .groups = "drop") %>%
      mutate(abs_balance = abs(Balance)) %>%
      arrange(desc(abs_balance)) %>%
      slice_head(n = 15)
  })
  
  # Draw the bar chart showing trade balance, color coded by surplus ++ (green) or deficit -- (red)
  output$balancePlot <- renderPlotly({
    d <- trade_balance()
    
    # nothing to plot if data is empty~
    if (nrow(d) == 0) return(NULL)
    
    plot_ly(d,
            x = ~Balance,
            y = ~reorder(Area, Balance),
            type = "bar",
            orientation = "h",
            marker = list(color = ~ifelse(Balance > 0, "green", "red")),
            hovertemplate = paste('Balance: %{x:,} tons<extra></extra>')
    ) %>%
      layout(
        title = paste("Top 15 Trade Balance Differences for", input$kasia2_ingredient, "in", input$kasia2_year),
        xaxis = list(title = "Trade Balance (Export - Import)"),
        yaxis = list(title = "")
      )
  })
  # ===========================================================================
  # KASIA'S PART
  # THIRD GRAPH
  
  output$yearRange_ui <- renderUI({
    req(df())  # wait for data to become available
    sliderInput("yearRange", "Select time range:",
                min = min(as.integer(df()$Year), na.rm = TRUE),
                max = 2013,
                value = c(min(as.integer(df()$Year), na.rm = TRUE),
                          min(max(as.integer(df()$Year), na.rm = TRUE), 2013)),
                step = 1,
                sep = "")
  })
  
  output$dumbbellPlot <- renderPlotly({
    req(input$yearRange)  
    
    trade_filtered <- df() %>%
      filter(Year %in% c(input$yearRange[1], input$yearRange[2])) %>%
      filter(
        case_when(
          input$tradeType == "Import" ~ Element == "Import quantity",
          input$tradeType == "Export" ~ Element == "Export quantity",
          input$tradeType == "Trade (Import + Export)" ~ Element %in% c("Import quantity", "Export quantity")
        )
      )
    
    summary <- trade_filtered %>%
      group_by(Item, Year) %>%
      summarise(n_countries = n_distinct(Area), .groups = "drop") %>%
      pivot_wider(names_from = Year, values_from = n_countries,
                  names_prefix = "Year_") %>% 
      drop_na() 
    
    year_cols <- grep("^Year_", names(summary), value = TRUE)
    
    summary <- summary %>%
      arrange(!!sym(year_cols[2])) %>%
      mutate(Item = factor(Item, levels = Item))
    
    plot_ly(data = summary) %>%
      add_segments(x = ~get(year_cols[1]),
                   xend = ~get(year_cols[2]),
                   y = ~Item,
                   yend = ~Item,
                   line = list(color = 'gray'),
                   showlegend = FALSE) %>%
      add_markers(x = ~get(year_cols[1]),
                  y = ~Item,
                  marker = list(color = "#0e668b"),
                  text = ~paste0(input$yearRange[1], ": ", get(year_cols[1])),
                  hoverinfo = "text",
                  showlegend = FALSE) %>%
      add_markers(x = ~get(year_cols[2]),
                  y = ~Item,
                  marker = list(color = "#c43c3f"),
                  text = ~paste0(input$yearRange[2], ": ", get(year_cols[2])),
                  hoverinfo = "text",
                  showlegend = FALSE) %>%
      layout(title = paste0("Change in Number of Trading Countries (", 
                            input$yearRange[1], " → ", input$yearRange[2], ") — ", input$tradeType),
             xaxis = list(title = "Number of countries"),
             yaxis = list(title = ""),
             hovermode = "closest")
  })
  
  # ===========================================================================
  # WIKTORIA'S PART - 1
  observe({
    ingredients <- sort(unique(df()$Item))
    updateSelectInput(session, "wiki1_ingredient", choices = c("All ingredients", ingredients))
    updateSelectInput(session, "country", choices = unique(df()$Area))
  })
  
  output$wiki1_year_ui <- renderUI({
    available_years <- df() %>%
      filter(
        Area == input$country,
        Item == input$wiki1_ingredient | input$wiki1_ingredient == "All ingredients",
        Element == input$wiki1_element
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
    req(input$wiki1_ingredient, input$country, input$wiki1_element, input$years)
    
    colors_of_ingredients <- setNames(
      colorRampPalette(brewer.pal(8, "Paired"))(length(unique(df()$Item))),
      sort(unique(df()$Item))
    )
    
    filtered <- df() %>%
      filter(
        Area == input$country,
        Element == input$wiki1_element,
        !is.na(Value), !is.na(Item),
        Year >= input$years[1], Year <= input$years[2]
      )
    
    if (input$wiki1_ingredient == "All ingredients") {
      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line(linewidth = 0.6) +
        geom_point(size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$wiki1_element, "of all ingredients in", input$country),
          x = "Year", y = "Value (t)", color = "Ingredients"
        ) +
        theme_minimal()
    } 
    else {
      filtered <- df() %>%
        filter(
          Area == input$country,
          Element == input$wiki1_element,
          !is.na(Value), !is.na(Item),
          Year >= input$years[1], Year <= input$years[2]
        )
      
      if (input$wiki1_ingredient != "All ingredients") {
        filtered <- filtered %>% filter(Item == input$wiki1_ingredient)
      }
      
      p <- ggplot(filtered, aes(x = Year, y = Value, color = Item)) +
        geom_line(linewidth = 0.6) +
        geom_point(size = 1.5) +
        scale_color_manual(values = colors_of_ingredients) +
        labs(
          title = paste(input$wiki1_element, "of", input$wiki1_ingredient, "in", input$country),
          x = "Year", y = "Value (t)", color = "Ingredient"
        ) +
        theme_minimal()
    }
    
    ggplotly(p, tooltip = c("x", "y", "color")) %>% 
      layout(hovermode = "x unified")
  })
  # ===========================================================================
  # WIKTORIA'S PART - 2
  # Create a year slider that only shows years with data for the selected ingredient and element
  output$wiki2_ingredient_ui <- renderUI({
    req(df())  
    
    selectInput("wiki2_ingredient", "Choose ingredient:",
                choices = unique(df()$Item)) 
  })
  
  output$wiki2_year_ui <- renderUI({
    req(input$wiki2_ingredient, input$wiki2_element)
    years_available <- df() %>%
      filter(Item == input$wiki2_ingredient, Element==input$wiki2_element) %>%
      distinct(Year) %>%
      arrange(Year) %>%
      pull(Year)
    
    sliderInput("year", "Select Year:",
                min = min(years_available),
                max = max(years_available),
                value = max(years_available),
                step = 1,
                sep = "",
                ticks = TRUE)
  })
  
  output$barPlot <- renderPlotly({
    req(input$wiki2_ingredient, input$wiki2_element, input$year)
    
    # Filter data for the selected ingredient, element type (import/export),
    # and years.
    filtered <- df() %>%
      filter(
        Item == input$wiki2_ingredient,
        Element == input$wiki2_element,
        Year == input$year,
        !is.na(Value)
      )
    
    #filter top 10 countries
    top_countries <- filtered %>%
      group_by(Area) %>%
      summarise(value = sum(Value, na.rm = TRUE)) %>%
      arrange(desc(value)) %>%
      ungroup() %>%
      head(10)
    
    if (nrow(top_countries) == 0) {
      return(plotly_empty())
    }
    
    color <- colorRampPalette(brewer.pal(8, "Set2"))(10)
    
    # Draw bar plot showing top 10 countries by import/export of the selected ingredient in the chosen year
    p <- ggplot(top_countries, aes(x = reorder(Area, value), y = value, fill = Area)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = color) +
      labs(
        title = paste(input$wiki2_element, "of", input$wiki2_ingredient, "in" ,input$year),
        x = "Country", y = "Average value (t)", fill = "Country"
      ) +
      theme_minimal()+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = c("x", "y"))
  })
  # ===========================================================================
  # WIKTORIA'S PART - 3
  observe({
    updateSelectInput(session, "wiki3_country", choices = unique(df()$Area))
  })
  output$piePlot <- renderPlotly({
    
    req(input$wiki3_country, input$wiki3_element, input$wiki3_year)
    
    # Filtrowanie danych
    pie_data <- df() %>%
      filter(
        Area == input$wiki3_country,
        Element == input$wiki3_element,
        !is.na(Value), !is.na(Item),
        Year >= input$wiki3_year[1], Year <= input$wiki3_year[2]
      ) %>%
      group_by(Item) %>%
      summarise(total = sum(Value, na.rm = TRUE)) %>%
      arrange(desc(total))
    
    plot_ly(
      pie_data,
      labels = ~Item,
      values = ~total,
      type = "pie",
      textinfo = "percent",
      textposition = "outside",
      hoverinfo = "label+percent+value",
      showlegend = TRUE
    ) %>%
      layout(
        title = list(
          text = paste("Share of", input$wiki3_element, "in", input$wiki3_country, "from", input$wiki3_year[1], "to", input$wiki3_year[2]),
          y = 0.95  # relocating the graph a bit
        ),
        margin = list(t = 100, l = 50)
      )
  })
  # ===========================================================================
  # making buttons to download Kasia's code
  output$downloadKasia1App <- downloadHandler(
    filename = function() {
      "data/kasia1_app.r"
    },
    content = function(file) {
      file.copy("data/kasia1_app.r", file)
    },
    contentType = "text/plain"
  )
  
  output$downloadKasia2App <- downloadHandler(
    filename = function() {
      "data/kasia2_app.r"
    },
    content = function(file) {
      file.copy("data/kasia2_app.r", file)
    },
    contentType = "text/plain"
  )
  
  output$downloadKasia3App <- downloadHandler(
    filename = function() {
      "data/kasia3_app.r"
    },
    content = function(file) {
      file.copy("data/kasia3_app.r", file)
    },
    contentType = "text/plain"
  )
  
  # making button to download Wiktoria's code
  output$downloadWiki1App <- downloadHandler(
    filename = function() {
      "data/wiktoria1_app.r"
    },
    content = function(file) {
      file.copy("data/wiktoria1_app.r", file)
    },
    contentType = "text/plain"
  )
  
  output$downloadWiki2App <- downloadHandler(
    filename = function() {
      "data/wiktoria2_app.r"
    },
    content = function(file) {
      file.copy("data/wiktoria2_app.r", file)
    },
    contentType = "text/plain"
  )
  
  # list of dishes and flags
  dish_image_paths <- list(
    "Bibimbap" = list(flag = "South_Korea.png", dish = "Bibimbap.jpg"),
    "Biryani" = list(flag = "India.png", dish = "Biryani.jpg"),
    "Carbonara" = list(flag = "Italy.png", dish = "Carbonara.jpg"),
    "Falafel" = list(flag = "Egypt.png", dish = "Falafel.jpg"),
    "Kebab" = list(flag = "Turkey.svg", dish = "Kebab.jpg"),
    "Kimchi" = list(flag = "South_Korea.png", dish = "Kimchi.jpg"),
    "Lecso" = list(flag = "Hungary.png", dish = "Lecso.jpg"),
    "Moules-frites" = list(flag = "Belgium.png", dish = "Moules-frites.jpg"),
    "Moussaka" = list(flag = "Greece.png", dish = "Moussaka.jpg"),
    "Pad_thai" = list(flag = "Thailand.png", dish = "Pad_thai.jpg"),
    "Pierogi" = list(flag = "Poland.png", dish = "Pierogi.jpeg"),
    "Sarma" = list(flag = "Turkey.svg", dish = "Sarma.jpg"),
    "Schabowy_with_potatoes_and_mizeria" = list(flag = "Poland.png", dish = "Schabowy_with_potatoes_and_mizeria.webp"),
    "Spaghetti_bolognese" = list(flag = "Italy.png", dish = "Spaghetti_bologneses.jpg"),
    "Sushi" = list(flag = "Japan.png", dish = "Sushi.jpg"),
    "Wurst_with_sauerkraut" = list(flag = "Germany.png", dish = "Wurst_with_sauerkraut.jpg")
  )
  
  # generating food buttons
  lapply(names(dish_image_paths), function(dish) {
    observeEvent(input[[dish]], {
      selected_dish(dish)
      updateNavbarPage(session, inputId = "main_navbar", selected = "Graphs")
    })
  })
  
  # inserting images into the tabpanel
  prefixes <- c("kasia1", "kasia2", "kasia3", "wiki1", "wiki2", "wiki3")
  
  lapply(prefixes, function(prefix) {
    local({
      p <- prefix
      output[[paste0(p, "_dish_image")]] <- renderUI({
        req(selected_dish())
        img_src <- dish_image_paths[[selected_dish()]]$dish
        img(src = img_src, width = "100%")
      })
      
      output[[paste0(p, "_dish_flag")]] <- renderUI({
        req(selected_dish())
        img_src <- dish_image_paths[[selected_dish()]]$flag
        img(src = img_src, width = "100%")
      })
    })
  })
  
  
  # function to get the country's name from the filename
  get_country_from_dish <- function(dish) {
    flag_filename <- dish_image_paths[[dish]]$flag
    country_name <- tools::file_path_sans_ext(basename(flag_filename))
    if (country_name == "South_Korea")
    {
      country_name = "Republic of Korea"
    }
    country_name
  }
}
