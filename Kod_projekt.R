#pakiety do instalacji
install.packages("ggplot2")
library(ggplot2)
install.packages("dplyr")
library(dplyr)
install.packages("tidyverse")
library(tidyverse)
library(readr)
install.packages("corrplot")
library(corrplot)
install.packages("sf")
library(sf)
install.packages("spatialreg")
library(spatialreg)
install.packages("spdep")
library(spdep)


Dane <- read_csv("Dane_zanieczyszczenie.csv")
View(Dane)
#zamiana kolumn na numeric oprócz Kod_powiat
Dane <- Dane %>% mutate(across(-Kod_powiat, as.numeric))
#zmiana nazw kolumn
colnames(Dane) <- c("Kod_powiat", "Wskaznik", "Liczba_pojazdów","Gm_tereny_zieleni","Grunty_lesne","Pow_powiatu","Ludność_na_km2","Srednie_wyn","Drogi")

#Histogram zanieczyszczenia powietrza w 2023 roku
ggplot(Dane, aes(x = `Wskaznik`)) + 
  geom_histogram(binwidth = 1, fill = "steelblue", color = "black", alpha = 0.7) + 
  labs(title = "Rozkład zanieczyszczenia powietrza w 2023 roku", 
       x = "Wskażnik zanieczyszczenia powietrza", 
       y = "Liczba powiatów") +
  theme_minimal()

##KORELACJA

# Wybierz tylko kolumny numeryczne
num_cols <- sapply(Dane, is.numeric)

# Nazwy kolumn, które chcesz wykluczyć
kolumny_do_pominiecia <- c("Kod_powiat", "Wskaznik","Ludność_na_km2")

# Usuń te kolumny z listy numerycznych
num_cols[names(num_cols) %in% kolumny_do_pominiecia] <- FALSE

# Oblicz macierz korelacji
corr_matrix <- cor(Dane[, num_cols])

# Obliczenie korelacji
corrplot(corr_matrix, method = "color", addCoef.col = "black")  # Wizualizacja

##Mapa
mapa <- st_read("counties.shp")  # Plik .shp z granicami powiatów
colnames(mapa)  # Sprawdzenie jakie nagłówki ma plik mapa
#połaczenie danych z mapą
mapa_dane <- merge(mapa, Dane, by.x = "JPT_KOD_JE", by.y = "Kod_powiat")

#Kartogram zmiennej objaśnianej
ggplot(data = mapa_dane) + 
  geom_sf(aes(fill = Wskaznik)) +
  scale_fill_gradient(low = "White", high = "red") +
  labs(title = "Wskaznik zanieczyszczenia powietrza w Polsce") +
  theme_minimal()
#Kartogram Dróg
ggplot(data = mapa_dane) + 
  geom_sf(aes(fill = Drogi)) +
  scale_fill_gradient(low = "White", high = "blue") +
  labs(title = "Długość dróg utwardzonych w kilometrach w podziale na powiaty") +
  theme_minimal()
#Kartogram Gruntów leśnych
ggplot(data = mapa_dane) + 
  geom_sf(aes(fill = Grunty_lesne)) +
  scale_fill_gradient(low = "White", high = "green") +
  labs(title = "Powierzchnia gruntów leśnych w hektarach w podziale na powiaty") +
  theme_minimal()

nb <- poly2nb(mapa)  # Neighbors list
lw <- nb2listw(nb, style = "W", zero.policy=TRUE)

colnames(mapa)    # sprawdzenie nazw kolumn w pliku .shp 
print(mapa$JPT_KOD_JE)   # sprawdzenie kolejności obiektów w pliku .shp
all.equal(mapa$JPT_KOD_JE, Dane$Kod_powiat)

# Moran I test
moran.test(Dane$Wskaznik, lw)


