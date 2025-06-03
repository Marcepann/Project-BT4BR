### BT4BR Project: Interactive Visualisation of Ingredients of Global Dishes and Trade Data

This project presents different data visualisation web app that links traditional dishes from around the world with global ingredient trade data. 
Built using the R Shiny framework, the application enables users to explore how ingredients of national meals are globally imported and exported, 
country by country, over time.

---

## Project structure

-*data* folder - processed .csv files from FAOSTAT

-*www* folder - images of dishes and country flags

-*ui.R* - Shiny user interface

-*server.R* - Shiny server

-*sources.md* - list of resources used

-*README.md*

---

## Data

The data was downloaded, filtered and preprocessed to match the ingredient lists of 16 specific dishes from around the world. For each dish, there is a separate .csv file containing the relevant trade records.

All datasets used in the application are based on data from the [FAOSTAT Trade domain](https://www.fao.org/faostat/en/#data/TCL).

**Each file contains the following columns:**
- `Area` — country name  
- `Item` — ingredient  
- `Year` — year of the record  
- `Value` — trade volume  
- `Element` — trade type (either *Import quantity* or *Export quantity*)

Datasets are available in the `data/` folder.

---

## How to Run the App?

Open the project in RStudio or run in terminal:

```         
shiny::runApp("Project-BT4BR")
```

Make sure you have all required packages installed!

You can download them with this command:

```         
install.packages(c(
  "shiny", "plotly", "readr", "dplyr", "RColorBrewer", "countrycode",
  "shinythemes", "ggplot2","markdown" 
))
```

Have fun exploiting the data!
