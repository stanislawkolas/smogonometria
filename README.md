# smogonometria
📘 Analiza zanieczyszczenia powietrza w Polsce z wykorzystaniem modeli przestrzennych (2025)

Autorzy: Miriam Nieslona, Piotr Geremek, Bartosz Kurzyński, Jakub Kołpaczyński, Stanisław Kolas
Data wykonania projektu: 24.06.2025
Język programowania: R

⸻

🎯 Cel badania

Celem niniejszego projektu jest identyfikacja i kwantyfikacja przestrzennych wzorców zanieczyszczenia powietrza w Polsce na poziomie powiatowym, ze szczególnym uwzględnieniem:
	•	autokorelacji przestrzennej wskaźników zanieczyszczenia,
	•	wpływu zmiennych społeczno-ekonomicznych i środowiskowych na jakość powietrza,
	•	porównania klasycznych i przestrzennych modeli ekonometrycznych (OLS, SAR, SEM, SDM, SLX).

⸻

🧩 Pytania badawcze
	1.	Czy poziom zanieczyszczenia powietrza w Polsce ma charakter przestrzenny?
	2.	Które czynniki lokalne i sąsiedzkie wpływają na jego natężenie?
	3.	Który model najlepiej wyjaśnia przestrzenne zależności i strukturę danych?

⸻

🔢 Opis danych

📌 Zmienna objaśniana:
	•	Wskaźnik zanieczyszczenia powietrza (syntetyczny indeks uwzględniający: PM10, PM10_36max, PM2.5, BaP)

🔍 Zmienne objaśniające:

Zmienna                Znaczenie

Liczba_pojazdów        Emisje komunikacyjne
Gm_tereny_zieleni      Udział terenów zieleni w gminach
Grunty_lesne           Powierzchnia gruntów leśnych
Pow_powiatu            Powierzchnia całkowita powiatu (ha)
Ludność_na_km2         Gęstość zaludnienia
Srednie_wyn            Średnie wynagrodzenie miesięczne brutto
Drogi                  Długość dróg o nawierzchni twardej (km)

Zakres danych: Wszystkie powiaty Polski, dane za 2023 r.
Braki danych: Brak — kompletność 100%

⸻

🛠 Wykorzystane metody i techniki
	•	Statystyki opisowe (średnie, mediana, IQR, asymetria)
	•	Analiza korelacji (Pearson)
	•	Wizualizacja danych: histogramy, wykresy gęstości, kartogramy, wykresy rozrzutu
	•	Identyfikacja autokorelacji przestrzennej:
	•	Moran’s I (globalna autokorelacja)
	•	LISA (Local Indicators of Spatial Association) – mapy hot/cold spots
	•	Modelowanie ekonometryczne:
	•	OLS – klasyczny model regresji liniowej
	•	SAR – spatial autoregressive model
	•	SEM – spatial error model
	•	SDM – spatial Durbin model (SAR + SLX)
	•	SLX – spatial lag of X (tylko efekty sąsiedzkie)

⸻

📈 Wyniki

🔹 Statystyki opisowe:
	•	Wskaźnik zanieczyszczenia: średnia = 53.13, asymetria = 1.34
	•	Silna dodatnia korelacja z gęstością zaludnienia (r = 0.63)
	•	Ujemna korelacja z powierzchnią powiatu (r = -0.53)

🔹 Autokorelacja przestrzenna:
	•	Moran’s I = 0.73, p < 0.001 → bardzo silna globalna autokorelacja
	•	Klastry zanieczyszczenia:
	•	Hot spoty: Śląsk, Małopolska
	•	Cold spoty: Podlasie, Warmia, Mazury

🔹 Modele regresyjne:

Mode      R² / AIC      Uwagi

OLS       R² = 0.52     Istotna autokorelacja reszt (I = 0.34) → błędne wnioski
SAR       AIC = 336     Silny efekt sąsiedztwa (rho = 0.80)
SEM       AIC = 350     Dobrze eliminuje autokorelację w resztach
SDM       AIC = 322     Najlepsze dopasowanie – efekty lokalne i spillover
SLX          -          Potwierdza znaczenie zmiennych sąsiedzkich, szczególnie  gęstości zaludnienia

🔍 Wnioski
	•	Zanieczyszczenie powietrza ma wyraźny charakter przestrzenny, z istotnymi klastrami (Moran I = 0.73)
	•	Najsilniejszy predyktor: gęstość zaludnienia (lokalna i sąsiedzka)
	•	Model SDM najlepiej odwzorowuje rzeczywiste procesy, uwzględniając:
	•	Efekty bezpośrednie (lokalne)
	•	Efekty pośrednie (spillover z sąsiednich powiatów)
	•	Polityka środowiskowa powinna być regionalnie skoordynowana – działania lokalne są niewystarczające
	•	Potencjał dalszych badań: Geographically Weighted Regression (GWR)

⸻

💼 Rekomendacje dla decydentów
	•	Tworzyć regionalne strategie antysmogowe z uwzględnieniem otoczenia
	•	Inwestować w zrównoważony transport i zieleń miejską w obszarach gęsto zaludnionych
	•	Monitorować nie tylko emisje lokalne, ale również efekty sąsiedztwa (tzw. efekty spillover)

⸻

🧪 Technologie i pakiety R
	•	spdep, spatialreg, sf – analiza przestrzenna i modele SAR/SEM/SDM/SLX
	•	ggplot2, tmap – wizualizacje i kartogramy
	•	dplyr, tidyverse, car, RColorBrewer, visdat, spData


⸻

📚 Bibliografia wybrana
	•	Elhorst, J.P. (2014). Spatial Econometrics: From Cross-Sectional Data to Spatial Panels. Springer.
	•	Kumar et al. (2024). PNAS, 121(3), e2306200121.
	•	Zhang et al. (2024). Sustainability, 16(21), 9627.
	•	Holnicki et al. (2018). IJERPH, 15(9).
	•	Fotheringham et al. (2002). Geographically Weighted Regression. Wiley.

Pełna bibliografia w raporcie.

⸻

📎 Status projektu

✅ Zakończony (2025-06-24)
🔬 Możliwość dalszego rozwoju: GWR, dane panelowe, sezonowość, modele Bayesowskie


