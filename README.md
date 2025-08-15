# 🌍 Spatial Analysis of Air Pollution in Poland

## 📌 Project Overview
This repository presents a **comprehensive spatial analysis of air pollution in Poland**, combining environmental, demographic, and infrastructure data.  
The study leverages **spatial econometric techniques** to uncover patterns, spatial dependencies, and key factors influencing air quality disparities across administrative units.

**Core components:**
- **Data preprocessing & integration** from official sources (GUS, GIOŚ, Eurostat)  
- **Exploratory Spatial Data Analysis (ESDA)**: Moran’s I, LISA  
- **Spatial econometric modelling**: OLS, SAR, SEM, SDM, SLX  
- **Publication-ready visualisations**: choropleth maps, spatial clusters, diagnostic plots  

The workflow is fully reproducible in **R Markdown**, with export options to **PDF** and **LaTeX**.

---

## 📂 Repository Structure

├── analiza_zanieczyszczenia.Rmd    # Main R Markdown analysis script
├── analiza_zanieczyszczenia.tex    # LaTeX output
├── analiza_zanieczyszczenia.log    # LaTeX compilation log
├── Dane_zanieczyszczenie.csv       # Air pollution dataset (county level)
├── Gęstość zaludnienia.xlsx        # Population density data
├── drogi i transport-…zip        # Transport & road infrastructure data
└── img/                            # Folder with generated plots and maps

---

## 📊 Data Sources
1. **Air pollution levels** – annual average concentrations of selected pollutants at the county level  
2. **Population density** – demographic data by county  
3. **Transport infrastructure** – road length, traffic intensity, and related indicators  

**Primary sources:** Statistics Poland (**GUS**), Chief Inspectorate of Environmental Protection (**GIOŚ**), **Eurostat**.

---

## 📈 Example Outputs
- **Spatial distribution** of air pollution  
- **Local Indicators of Spatial Association (LISA)** maps  
- **Spatial autocorrelation** diagnostics  
- **Spatial econometric model** summaries  

---

## 🧠 Key Insights
- Distinct **regional clustering** of high- and low-pollution areas  
- Strong, statistically significant **positive spatial autocorrelation** (Moran’s I)  
- **SAR** and **SDM** models outperform OLS, highlighting the importance of spatial effects  
- Pollution levels are strongly associated with **transport infrastructure** and **population density**  

---

## ⚙️ Requirements
- **R** ≥ 4.0.0  
- **RStudio** (recommended for `.Rmd` workflows)  
- Required packages:
```r
install.packages(c(
  "tidyverse", "sf", "spdep", "rgdal", "readxl",
  "tmap", "ggplot2", "dplyr", "car", "spatialreg"
))

## 📊 Data Sources
1. **Air pollution levels** – annual average pollutant concentrations at county level  
2. **Population density** – demographic data by county  
3. **Transport infrastructure** – road length, traffic intensity, etc.

**Sources:** Statistics Poland (GUS), Chief Inspectorate of Environmental Protection (GIOŚ), Eurostat

---

## 📈 Example Results
- Spatial Distribution of Air Pollution
- Local Indicators of Spatial Association (LISA)
- Spatial Autocorrelation Diagnostics
- Model Output Summary

## 🧠 Interpretation Highlights
- Clear regional clustering of high and low pollution values
- Significant positive spatial autocorrelation (Moran’s I)
- SAR and SDM models outperform OLS, indicating spatial dependence is critical
- Transport infrastructure and population density show strong correlation with pollution levels

---

## ⚙️ Requirements
- **R** ≥ 4.0.0  
- **RStudio** (recommended)  
- Required packages:
```r
install.packages(c(
  "tidyverse", "sf", "spdep", "rgdal", "readxl",
  "tmap", "ggplot2", "dplyr", "car", "spatialreg"
))
