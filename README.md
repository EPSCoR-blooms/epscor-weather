# epscor-weather
This folder employs github actions to scrape and compile weather data for the nine focus lakes of the EPSCoR project out of Dartmouth College.

Repository contact: B. Steele (steeleb@caryinstitute.org, bsteele@bates.edu) 

These data are intended for use by members of the EPSCoR project, please attribute data and code properly. If you are unsure how to attribute, contact the creator of these code and data, B Steele (steeleb@caryinstitute.org).

[![gather weather daily](https://github.com/steeleb/epscor-weather/actions/workflows/config.yml/badge.svg)](https://github.com/steeleb/epscor-weather/actions/workflows/config.yml)

## Folder Structure

### datastore
All data are stored in the *datastore* folder (both observed and forecasted data). Note that all forecast data are considered preliminary, so any analysis would have to refer back to these data.

Within this folder are a *for_weather* and *obs_weather* folder containing 2-day forecasts per download date for every lake and collated observed weather per NOAA station, respectively.

#### obs_weather

Weather observations are reported by NOAA stations. Note that this is different form the forecasted data, which are specific to a lat/long location. 

|   NOAA Station    |   Lake Name   |   Approximate Distance from Station (km)   |    File Name |
|   ----    |   ----    |   ----    |   ----    |
|   KLEW    |   Auburn    | 10.5    |   *KLEW-obs.csv* |
|   KLEW    |   Panther    |   19.5    |    *KLEW-obs.csv*  | 
|   KLEW    |   Sabattus    |   17.5   |     *KLEW-obs.csv*     |
|   KWVL    |   China    |  14.5   |     *KWVL-obs.csv* |
|   KWVL    |   Great    |   13 |    *KWVL-obs.csv* |
|   KCAE    |   Murray    | 22   |  *KCAE-obs.csv*  |  
|   KOQU    |   Barber    | 16.25  |    *KOQU-obs.csv*  |
|   KOQU    |   Yagoo    | 16.25  | *KOQU-obs.csv*  |
|   KLEB    |   Sunapee    |  33.5 |    *KLEB-obs.csv*  | 
|   KCUB    |   Wateree    |  52.5  |   *KCUB-obs.csv*  |

For each file, the headers and definitions are the same. Note all units are in SAE.

|   Column Name |   Column Description  |   Units   |   Notes   |   
|   ----    |   ----    |   ----    |   ----    |
|   station |   NOAA station ID |   character string    |  see NOAA Station listed above |
|   date    |   date of weather observation, local time, DST observed |   YYYY-MM-DD  |   |
|   time    |   time of weather observation, local time, DST observed   |   HH:MM   |   |
|   wind_mph    |   wind speed  |   milesPerHour    |   |
|   vis_mi  | visibility    |   miles   |   |
|   weather |   general weather observation |   character string    |   see https://w1.weather.gov/glossary/ for definitions    |
|   sky_cond    |   sky conditions  |   character string    |  see https://w1.weather.gov/glossary/  for definitions  |
|   air_temp_F  | air temperature   |   degreesFarenheit    |   |
|   dewpoint_F  |   dewpoint temperature    |   degreesFarenheit    |   |
|   air_temp_max_6h_F   | maximum air temperature over previous 6 hours |   degreesFarenheit    |   |
|   air_temp_min_6h_F   | minimum air temperature over previous 6 hours |   degreesFarenheit    |   |
|   rel_hum_perc    | relative humidity |   percent|    |
|   wind_chill_F    | wind chill temperature    |   degreesFarenheit    |   |
|   heat_indx_F |   heat index temperature  |   degreesFarenheit    |   |
|   pres_alt_in | altimeter pressure    |   inches  |   |
|   pres_sea_mb |sea level pressure |   millibars   |   |
|   precip_1hr_in   | precipitation over previous hour  |   inches  |   |
|   precip_3h_in    | precipitation over previous 3 hours   |   inches  |   |
|   precip_6h_in    |   precipitation over previous 6 hours |   inches  |   |
|   download_date   | date of weather download  |   YYYY-MM-DD  |   |
|   datetime    |   datetime stamp of weather observation, local time, DST observed |   YYYY-MM-DD HH:MM:SS |   |

#### for_weather

Two-day forecasts are specific to lat/long locations that are approximate to the lake, they are not located at the centroid, but to a general area near the lake. See the column 'loc' for the lat and long of the forecasted area or the table in the description of the *for_weather_scrape.R* file below. 

Each lake has it's own folder (by lake abbreviation) of daily forecasts, where the file name has the format:
<LAKE ABBREVIATION>-forecast-<DATE OF FORECAST>.csv

The files in 'tmp' are template files, and contain no data. All forecast files have the same format.

|   Column Name |   Column Description  |   Units   |   Notes   |   
|   ----    |   ----    |   ----    |   ----    |
|   lake    |   name of lake forecast is intended for   |   character string    |   lake abbreviation used  |
|   loc |   lat/long of forecast location   |   character string    |   format: lat=yy.yyyy&lon=xx.xxxx, in some early versions, 'lat=' was cut off from the text string    |
|   date    |   date of weather forecast, local time, DST observed |   YYYY-MM-DD  |   |
|   time    |   time of weather observaforecasttion, local time, DST observed   |   HH:MM   |   |
|   air_temp_F  | air temperature   |   degreesFarenheit    |   |
|   dewpoint_F  |   dewpoint temperature    |   degreesFarenheit    |   |
|   heat_indx_F |   heat index temperature  |   degreesFarenheit    |   |
|   wind_mph    |   wind speed  |   milesPerHour    |   |
|   wind_dir_gust   | direction from which wind gusts occuring  |   interCardinalDirections |   character string    |
|   sky_cover_perc  |   proportion of sky cover |   percent |   |
|   precip_potential_perc   | likelihood of precipitation   |   percent |   |
|   rel_hum_perc    | relative humidity |   percent|    |
|   rain    | likelihood of rain    |   character string |  see https://w1.weather.gov/glossary/ for definition s|
|   thunder | likelihood of thunder |   character string    |  see https://w1.weather.gov/glossary/ for definitions |

### R
All scripts are stored in the *R* folder.

* *obs_weather_scrape.R* scrapes and collates the observed weather at the NOAA stations closest to the EPSCoR focus lakes. All data are exported to the folder *datastore/obs_weather/*

|   File Name    |   NOAA Station   |
|   ----    |   ----    |
|   *KLEW-obs.csv*   |   KLEW    |
|   *KWVL-obs.csv*   |   KWVL    |
|   *KCAE-obs.csv*   |   KCAE    |
|   *KOQU-obs.csv*   |   KOQU    |
|   *KLEB-obs.csv*   |   KLEB    |
|   *KCUB-obs.csv*   |   KCUB    |

* *for_weather_scrape.R* scarpes and creates new forecast files for lat/long locations near each of the EPSCoR focus lakes.

|   Lake Name   |   Forecast Location   |   Folder Name (where data are saved)   |   
|   ----    |   ----    |   ----    |
|   Auburn  |   lat=44.1461&lon=-70.227 |   *datastore/for_weather/aub* |
|   China   |   lat=44.4473&lon=-69.6053    |   *datastore/for_weather/chn* |
|   Great   |   lat=44.5861&lon=-69.864 |   *datastore/for_weather/grt* |
|   Murray  |   lat=34.1205&lon=-81.2645    |   *datastore/for_weather/mur* |
|   Panther |   lat=43.9261&lon=-70.468 |   *datastore/for_weather/pan* |
|   Rhode Island (Yagawoo & Barber)    |    lat=41.484&lon=-71.5522 |   *datastore/for_weather/ri*  |
|   Sabattus    |   lat=44.1152&lon=-70.1027    |   *datastore/for_weather/sab* |
|   Sunapee |   lat=43.3834&lon=-72.0832    |   *datastore/for_weather/sun* |
|   Wateree |   34.4335&lon=-80.8665    |   *datastore/for_weather/wat* |   


