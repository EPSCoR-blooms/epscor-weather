# written by B. Steele (steeleb@caryinstitute.org)
# last modified 07June2021

# this script scrapes the 4 days of observed weather data from the NOAA website

#load packages
library(tidyverse)
library(rvest)

#set save directory
dir <- 'datastore/obs_weather/'

#set url
sun_url <- "https://w1.weather.gov/data/obhistory/KLEB.html"
aub_url <- "https://w1.weather.gov/data/obhistory/KLEW.html"
grt_url <- "https://w1.weather.gov/data/obhistory/KWVL.html"
# sab_url <- also KLEW
ri_url <- "https://w1.weather.gov/data/obhistory/KOQU.html"
wat_url <-  "https://w1.weather.gov/data/obhistory/KCUB.html"
mur_url <- "https://w1.weather.gov/data/obhistory/KCAE.html"

url_list <- c(sun_url, aub_url, grt_url, ri_url, wat_url, mur_url) 
obs_data_list <- c('sun-obs.csv', 'aub-obs.csv', 'grt-obs.csv', 'ri-obs.csv', 'wat-obs.csv', 'mur-obs.csv') 
station_list <- c('KLEB', 'KLEW', 'KWVL', 'KOQU', 'KCUB', 'KCAE') 

#set TZ
Sys.setenv(TZ='Etc/GMT+5') #force TZ to EST no DST for download

for(i in 1:length(station_list)) {

#read in historical data
collated_weather <- read.csv(file.path(dir,  obs_data_list[i]),
                         colClasses = 'character')

#read html, select table, format to dataframe
weather_now <- as.data.frame(html_table(html_nodes(read_html(url_list[i]), 'table')[4], header = T)) %>% 
    filter(!grepl('date', x = Date, ignore.case = T)) 

#rename columns
for(j in 1:ncol(weather_now)) {
  names(weather_now)[j] = names(collated_weather)[j+2]
}

#add station information and download date
weather_now$station = paste0(station_list[i])
weather_now$download_date = Sys.Date()

#format to proper date stamp; need to deal with end/beg of month issues
daydiff = as.numeric(max(weather_now$day)) - as.numeric(min(weather_now$day))

#initialize column with today's date
weather_now$date = Sys.Date()

# run loop for date
for(k in 1:nrow(weather_now)) {
  if (daydiff < 4) { # if all the days are in the same month
    weather_now$date[k] = as.Date(paste(format(Sys.Date(), '%Y'), format(Sys.Date(), '%m'), weather_now$day[k], sep = '-'))
  } else { #otherwise
    if (as.numeric(weather_now$day[k]) < 5) { #if the day value is < 5
      weather_now$date[k] = as.Date(paste(format(Sys.Date(), '%Y'), format(Sys.Date(), '%m'), weather_now$day[k], sep = '-'))
    } else { #otherwise set sys date to previous month (actual day is irrelevant, so set to greatest month length)
      weather_now$date[k] = as.Date(paste(format(Sys.Date()-31, '%Y'), format(Sys.Date()-31, '%m'), weather_now$day[k], sep = '-'))
    }
  }
}

# mutate all columns to as.character
weather_now <- weather_now %>% 
  mutate(download_date = as.character(download_date),
         date = as.character(date))
str(weather_now)

#join the data together with an indicator of download date, in case data changes
collated_weather <- full_join(collated_weather, weather_now)
write.csv(collated_weather, file.path(dir, paste0(obs_data_list[i])), row.names = F)

}
