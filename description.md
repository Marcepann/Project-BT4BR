---
title: "description.md"
author: "Kaja Lucka"
date: "2025-06-01"
output: html_document
---

## Introduction

This interactive application was created by a group of 3 bioinformatics students finishing their 3rd year of a bachelor's degree. It was developed as part of the course *Basic Toolkit 4 Bioinformatics Research*. The app was built using R Shiny (*shinythemes)* and uses packages such as *markdown*, *plotly*, *readr* and *dplyr*.

## Goals of our project

The main goal of this project was to help us learn how to build interactive applications using real data. We chose to focus on the import and export of ingredients found in popular national dishes - such as pierogi from Poland or lecso from Hungary - and present this information in a more engaging and unconventional way.

## What can I find here?

The application allows users select a dish and view interactive visualisations specific to that dish.

It contains five main tabs:

### Description

This is the first tab that appears after launching the app. It gives an overview of the project and serves as the welcome page. It is the tab that you are currently in.

### Dishes

Here you will find interactive buttons with images and names of various dishes from around the world. When you click on a dish, you’ll be taken to the *Graphs* tab.

### Graphs 

At first, this tab is empty. Once a dish is selected, two interactive graphs will be displayed: a choropleth map and a line chart, each in a separate subtab. You can interact with the graphs by selecting:

-   ingredient
-   country
-   type of data (export or import)
-   year or a range of years (with a map animation showing how values change over time)

Furthermore, the selected dish image and the flag of the country of origin are displayed. On the map, the country of origin is also highlighted with a red border.

### About us

In this tab you can see how we divided the work within our team. There are also buttons to download the code parts used for generating the graphs.

### Resources

This tab lists all the websites we used when building the app.
