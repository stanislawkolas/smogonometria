#pakiety do instalacji
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("corrplot")
install.packages("sf")
install.packages("spatialreg")
install.packages("spdep")
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readr)
library(corrplot)
library(sf)
library(spatialreg)
library(spdep)


Dane <- read_csv("Dane_zanieczyszczenie.csv")
View(Dane)
#zamiana kolumn na numeric oprócz Kod_powiat
Dane <- Dane %>% mutate(across(-Kod_powiat, as.numeric))
#zmiana nazw kolumn
colnames(Dane) <- c("Kod_powiat", "Wskaznik", "Liczba_pojazdów","Gm_tereny_zieleni","Grunty_lesne","Pow_powiatu","Ludność_na_km2","Srednie_wyn","Drogi")

#Sortowanie danych według kodu powaiatu rosnąco
Dane <- Dane[order(Dane$Kod_powiat), ]

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
#Sortowanie danych według kodu powaiatu rosnąco
mapa <- mapa[order(mapa$JPT_KOD_JE), ]
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
#Moran Plot
moran.plot(Dane$Wskaznik, lw, labels = FALSE, pch = 20,
           xlab = "Zanieczyszczenie powietrza", 
           ylab = "Spatial Lag of Income")

local_moran <- localmoran(Dane$Wskaznik, lw)

Dane$Ii <- local_moran[, 1]
Dane$P.Ii <- local_moran[, 5]
print(Dane)


model_stat <- lm(
  Wskaznik ~ Liczba_pojazdów +
    Gm_tereny_zieleni +
    Grunty_lesne +
    Pow_powiatu +
    Ludność_na_km2 +
    Srednie_wyn +
    Drogi,
  data = Dane)

summary(model_stat)


model_best_stat <- step(model_stat, direction = "backward")

summary(model_best_stat)
