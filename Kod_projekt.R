#pakiety do instalacji
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("corrplot")
install.packages("sf")
install.packages("spatialreg")
install.packages("spdep")
install.packages("standardize")
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readr)
library(corrplot)
library(sf)
library(spatialreg)
library(spdep)
library(naniar)
library(standardize)


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

##====================Tutaj zaczynam szpącić==================================

#Identyfikacja braków danych i obserwacji odstających

# Wczytanie niezbędnych pakietów
install.packages("naniar")
install.packages("ggplot2")
install.packages("dplyr")

library(naniar)
library(ggplot2)
library(dplyr)

# Wczytanie danych (jeśli nie wczytane)
Dane <- readr::read_csv("Dane_zanieczyszczenie.csv")
Dane <- Dane %>% mutate(across(-Kod_powiat, as.numeric))

# ---- IDENTYFIKACJA BRAKÓW DANYCH ----

# Podsumowanie braków danych
summary_na <- sapply(Dane, function(x) sum(is.na(x)))
print("Liczba braków danych w każdej kolumnie:")
print(summary_na)

# Procent braków danych
percent_na <- sapply(Dane, function(x) mean(is.na(x))) * 100
print("Procent braków danych:")
print(percent_na)

# Wizualizacja braków danych
vis_miss(Dane) + 
  labs(title = "Wizualizacja braków danych")

# ---- IDENTYFIKACJA OBSERWACJI ODSTAJĄCYCH (OUTLIERS) ----

# Wykresy boxplot dla każdej kolumny numerycznej
Dane_num <- Dane %>% 
  select(where(is.numeric)) 

# Rysuj boxploty automatycznie
for (colname in names(Dane_num)) {
  print(
    ggplot(Dane, aes_string(x = "1", y = colname)) +
      geom_boxplot(fill = "orange", outlier.color = "red", outlier.shape = 8) +
      labs(title = paste("Boxplot -", colname), y = colname, x = "") +
      theme_minimal()
  )
}

# Wykrycie obserwacji odstających za pomocą reguły IQR
outliers_list <- list()

for (col in names(Dane_num)) {
  q1 <- quantile(Dane[[col]], 0.25, na.rm = TRUE)
  q3 <- quantile(Dane[[col]], 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  outliers <- which(Dane[[col]] < lower | Dane[[col]] > upper)
  outliers_list[[col]] <- outliers
}

print("Indeksy obserwacji odstających w poszczególnych zmiennych:")
print(outliers_list)

##Obliczenie podstawowych statystyk opisowych (m.in. średnia, mediana, min, max, odchylenie standardowe, współczynniki asymetrii)

# Wymagane pakiety
install.packages("e1071")  # do obliczania współczynnika asymetrii
library(dplyr)
library(e1071)

# Wybór kolumn numerycznych
Dane_num <- Dane %>% select(where(is.numeric))

# Obliczanie statystyk opisowych
statystyki <- data.frame(
  Zmienna = names(Dane_num),
  Srednia = sapply(Dane_num, mean, na.rm = TRUE),
  Mediana = sapply(Dane_num, median, na.rm = TRUE),
  Minimum = sapply(Dane_num, min, na.rm = TRUE),
  Maksimum = sapply(Dane_num, max, na.rm = TRUE),
  Odchylenie_std = sapply(Dane_num, sd, na.rm = TRUE),
  Asymetria = sapply(Dane_num, skewness, na.rm = TRUE)
)

# Zaokrągl tylko kolumny numeryczne (bez kolumny "Zmienna")
statystyki[ , -1] <- round(statystyki[ , -1], 2)

# Wyświetlenie tabeli
print(statystyki[ , -1])

##Analiza korelacji między zmiennymi ilościowymi

# Wymagane pakiety
install.packages("corrplot")
library(dplyr)
library(corrplot)

# Wybór kolumn numerycznych
Dane_num <- Dane %>% select(where(is.numeric))

# Obliczanie macierzy korelacji (domyślnie metoda Pearsona)
macierz_korelacji <- cor(Dane_num, use = "complete.obs")

# Wyświetlenie macierzy korelacji
print(round(macierz_korelacji, 2))

# Wizualizacja korelacji
corrplot(macierz_korelacji, method = "color", addCoef.col = "black", 
         tl.cex = 0.8, number.cex = 0.7,
         title = "Macierz korelacji zmiennych ilościowych", 
         mar = c(0, 0, 1, 0))

##Wykresy: histogramy, wykresy rozrzutu, gęstości

# Załaduj potrzebne biblioteki
library(ggplot2)
library(dplyr)

# Załaduj dane – zmień ścieżkę jeśli potrzebujesz
Dane <- readr::read_csv("Dane_zanieczyszczenie.csv")

# Zamień kolumny na numeryczne (oprócz Kod_powiat)
Dane <- Dane %>% mutate(across(-Kod_powiat, as.numeric))

# Zmień nazwy kolumn jeśli trzeba
colnames(Dane) <- c("Kod_powiat", "Wskaznik", "Liczba_pojazdów",
                    "Gm_tereny_zieleni", "Grunty_lesne", "Pow_powiatu",
                    "Ludność_na_km2", "Srednie_wyn", "Drogi")

# Posortuj po Kod_powiat
Dane <- Dane[order(Dane$Kod_powiat), ]

# 1. HISTOGRAMY dla zmiennych numerycznych
# Tylko kolumny numeryczne
Dane_num <- Dane %>% select(where(is.numeric))

# Histogramy tylko dla zmiennych ilościowych
for (zm in names(Dane_num)) {
  print(
    ggplot(Dane, aes(x = .data[[zm]])) +
      geom_histogram(binwidth = 1, fill = "steelblue", color = "black", alpha = 0.7) +
      labs(title = paste("Histogram -", zm),
           x = zm, y = "Liczba powiatów") +
      theme_minimal()
  )
}

# 2. WYKRESY GĘSTOŚCI dla zmiennych numerycznych
for (zm in names(Dane_num)) {
  print(
    ggplot(Dane, aes_string(x = zm)) +
      geom_density(fill = "skyblue", alpha = 0.6) +
      labs(title = paste("Wykres gęstości -", zm),
           x = zm, y = "Gęstość") +
      theme_minimal()
  )
}

# 3. WYKRESY ROZRZUTU – relacja względem zmiennej Wskaznik
# Lista zmiennych, które mogą wpływać na zanieczyszczenie
zmienne_x <- c("Liczba_pojazdów", "Gm_tereny_zieleni", "Grunty_lesne", 
               "Pow_powiatu", "Ludność_na_km2", "Srednie_wyn", "Drogi")

for (zm in zmienne_x) {
  print(
    ggplot(Dane, aes_string(x = zm, y = "Wskaznik")) +
      geom_point(color = "darkred", alpha = 0.6) +
      geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
      labs(title = paste("Wskaznik zanieczyszczenia vs", zm),
           x = zm, y = "Wskaznik zanieczyszczenia") +
      theme_minimal()
  )
}

##Identyfikacja przestrzennych skupisk i obserwacji odstających (hot/cold spots)

# Wymagane biblioteki
library(spdep)
library(sf)
library(ggplot2)
library(dplyr)

#Mapa
mapa <- st_read("counties.shp")  # Plik .shp z granicami powiatów
colnames(mapa)  # Sprawdzenie jakie nagłówki ma plik mapa
#Sortowanie danych według kodu powaiatu rosnąco
mapa <- mapa[order(mapa$JPT_KOD_JE), ]
#połaczenie danych z mapą
mapa_dane <- merge(mapa, Dane, by.x = "JPT_KOD_JE", by.y = "Kod_powiat")

# Tworzenie listy sąsiedztwa i wag
nb <- poly2nb(mapa)  # Neighbors list
lw <- nb2listw(nb, style = "W", zero.policy=TRUE)

# Obliczenie lokalnych statystyk Morana
local_moran <- localmoran(mapa_dane$Wskaznik, lw, zero.policy = TRUE)

# Dołączenie wyników do ramki danych
mapa_dane$Ii <- local_moran[, 1]       # lokalny wskaźnik Morana
mapa_dane$E.Ii <- local_moran[, 2]     # wartość oczekiwana
mapa_dane$Var.Ii <- local_moran[, 3]   # wariancja
mapa_dane$Z.Ii <- local_moran[, 4]     # statystyka Z
mapa_dane$P.Ii <- local_moran[, 5]     # p-wartość

# Klasyfikacja skupisk
mapa_dane <- mapa_dane %>%
  mutate(
    klaster = case_when(
      Z.Ii > 1.96 & Wskaznik > mean(Wskaznik, na.rm = TRUE) ~ "Hot Spot",
      Z.Ii > 1.96 & Wskaznik < mean(Wskaznik, na.rm = TRUE) ~ "Cold Spot",
      Z.Ii < -1.96                                           ~ "Outlier",
      TRUE                                                   ~ "Brak istotności"
    )
  )

# Zamiana na factor dla lepszej kolejności w legendzie
mapa_dane$klaster <- factor(mapa_dane$klaster,
                            levels = c("Hot Spot", "Cold Spot", "Outlier", "Brak istotności"))

# Mapa klastrów (hot/cold spots)
ggplot(data = mapa_dane) +
  geom_sf(aes(fill = klaster)) +
  scale_fill_manual(values = c("Hot Spot" = "red",
                               "Cold Spot" = "blue",
                               "Outlier" = "orange",
                               "Brak istotności" = "grey90")) +
  labs(title = "Lokalna autokorelacja przestrzenna (LISA)",
       fill = "Typ klastra") +
  theme_minimal()
#standaryzowanie danych
Dane_std <- Dane %>% mutate(across(where(is.numeric), scale))
print(Dane_std)


mapa_dane_std <- mapa %>%
  left_join(Dane_std, by = c("JPT_KOD_JE" = "Kod_powiat"))



# Klasyczny model liniowy OLS
model_ols <- lm(Wskaznik ~ Liczba_pojazdów +
                  Gm_tereny_zieleni +
                  Grunty_lesne +
                  Pow_powiatu +
                  Ludność_na_km2 +
                  Srednie_wyn +
                  Drogi,
                data = Dane_std)

# Podsumowanie wyników
summary(model_ols)

# Spatial lag model (SAR)

install.packages("spatialreg")
library(spatialreg)

#Model SAR
model_sar <- lagsarlm(Wskaznik ~ Liczba_pojazdów +
                        Gm_tereny_zieleni +
                        Grunty_lesne +
                        Pow_powiatu +
                        Ludność_na_km2 +
                        Srednie_wyn +
                        Drogi,
                      data = mapa_dane_std,listw = lw, method = "eigen", zero.policy = TRUE)

# Podsumowanie wyników
summary(model_sar)


res_squared <- residuals(model_sar)^2
moran.test(res_squared, lw)

#Model SEM
sem_model <- spautolm(
  formula = Wskaznik ~ Liczba_pojazdów + Pow_powiatu + Ludność_na_km2 + Drogi,
  data = Dane_std,
  listw = lw,  # lub "b" w nowszych wersjach
  method = "eigen"
)
summary(sem_model)


res_squared <- residuals(sem_model)^2
moran.test(res_squared, lw)


#Przestrzenny Model Durbina (SDM)
sdm_model <- lagsarlm(
  formula = Wskaznik ~ Liczba_pojazdów +
    Pow_powiatu +
    Ludność_na_km2 +
    Drogi,
    data = Dane_std,
  listw = lw,
  Durbin = TRUE
)

summary(sdm_model)

res_squared <- residuals(sdm_model)^2
moran.test(res_squared, lw)


# Model SLX (Spatial Lag of X)
slx_model <- lmSLX(
  formula = Wskaznik ~ Liczba_pojazdów +
    Pow_powiatu +
    Ludność_na_km2 +
    Drogi,
  data = Dane_std,
  listw = lw
)

summary(slx_model)

res_squared <- residuals(slx_model)^2
moran.test(res_squared, lw)
