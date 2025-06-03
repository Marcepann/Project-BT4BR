### BT4BR Project: Interactive Visualisation of Ingredients of Global Dishes and Trade Data

This project presents a different data visualisation web app that links traditional dishes from around the world with global ingredient trade data. 
Built using the R Shiny framework, the application enables users to explore how ingredients of national meals are globally imported and exported, 
country by country, over time.

---

## Project structure

-> `data` - folder with processed .csv files from FAOSTAT

-> `www` - folder with images of dishes and country flags 

-> `ui.R` - Shiny user interface

-> `server.R` - Shiny server

-> `sources.md` - list of resources used

-> `README.md`

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

## Graphs

On the app, you must first choose a dish. Once selected, different plots related to that dish will become available.

- **Import / Export Map**: Heat map of ingredients import/export across countries
- **Multi-line Plot**: Line chart showing change of ingredients import/export values over time
- **Barplot**: Top 10 importing/exporting countries of a given ingredient
- **Piechart**: Proportion of ingredients used in the selected dish
- **Trade Imbalance**: Difference between export and import quantities per country
- **Global Spread**: Timeline of how trade of an ingredient spread across countries

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

Have fun exploring the data!
