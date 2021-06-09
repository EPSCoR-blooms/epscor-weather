# written by B. Steele (steeleb@caryinstitute.org)
# last modified 09June2021

# this script scrapes the 2 days of predicted weather ahead of download day

#load packages
library(tidyverse)
library(rvest)

#set save directory
dir <- 'datastore/for_weather/'

#read lat/longs

#set url
sun_url <- "https://forecast.weather.gov/MapClick.php?lat=43.3834&lon=-72.0832&lg=english&&FcstType=digital"
aub_url <- "https://forecast.weather.gov/MapClick.php?lat=44.1461&lon=-70.227&lg=english&&FcstType=digital"
grt_url <- "https://forecast.weather.gov/MapClick.php?lat=44.5861&lon=-69.864&lg=english&&FcstType=digital"
sab_url <- "https://forecast.weather.gov/MapClick.php?lat=44.1152&lon=-70.1027&lg=english&&FcstType=digital"
pan_url <- "https://forecast.weather.gov/MapClick.php?lat=43.9261&lon=-70.468&lg=english&&FcstType=digital"
ri_url <- "https://forecast.weather.gov/MapClick.php?lat=41.484&lon=-71.5522&lg=english&&FcstType=digital"
wat_url <-  "https://forecast.weather.gov/MapClick.php?lat=34.4335&lon=-80.8665&lg=english&&FcstType=digital"
mur_url <- "https://forecast.weather.gov/MapClick.php?lat=34.1205&lon=-81.2645&lg=english&&FcstType=digital"

url_list <- c(sun_url, aub_url, grt_url, sab_url, pan_url, ri_url, wat_url, mur_url) 
for_data_list <- c('sun-for.csv', 'aub-for.csv', 'grt-for.csv', 'sab-for.csv', 'pan-for.csv', 'ri-for.csv', 'wat-for.csv', 'mur-for.csv') 
loc_list <- c('lat=43.3834&lon=-72.0832', 
              'lat=44.1461&lon=-70.227', 
              'lat=44.5861&lon=-69.864', 
              'lat=44.1152&lon=-70.1027', 
              'lat=43.9261&lon=-70.468', 
              'lat=41.484&lon=-71.5522', 
              'lat=34.4335&lon=-80.8665', 
              'lat=34.1205&lon=-81.2645')
lake_list <- c('sun', 'aub', 'grt', 'sab', 'pan', 'ri', 'wat', 'mur')

#set TZ
Sys.setenv(TZ='Etc/GMT+5') #force TZ to EST no DST for download

for(i in 1:length(url_list)) {

#read in historical data
forecast_template <- read.csv(file.path(dir,  for_data_list[i]),
                         colClasses = 'character')

#read html, select table, format to dataframe
forecast_now <- as.data.frame(html_table(html_nodes(read_html(url_list[i]), 'table')[8])) %>% 
  rowid_to_column() %>% 
  filter(X1 != '') %>%  #remove null rows
  filter(X1 != 'Gust') #remove ill-formatted rows
  
#break down into two charts and format
forecast_now_a <- forecast_now %>% 
  filter(rowid >=2 & rowid <=14) %>% 
  select(-rowid) %>% 
  t() %>% 
  as.data.frame() 
forecast_now_a <- forecast_now_a[-1,]
for(j in 1:ncol(forecast_now_a)) {
  names(forecast_now_a)[j] = names(forecast_template)[j+2]
}

forecast_now_b <- forecast_now %>% 
  filter(rowid >=16 & rowid <=28) %>% 
  select(-rowid) %>% 
  t() %>% 
  as.data.frame() 
forecast_now_b <- forecast_now_b[-1,]
for(j in 1:ncol(forecast_now_b)) {
  names(forecast_now_b)[j] = names(forecast_template)[j+2]
}

forecast_now <- full_join(forecast_now_a, forecast_now_b) 
rm(forecast_now_a, forecast_now_b)

for(l in 1:nrow(forecast_now)) {
  if (forecast_now$date[l] == '') {
    forecast_now$date[l] = forecast_now$date[l-1]
  } else {
    forecast_now$date[l] = forecast_now$date[l]
  }
}

# format date and add additional information
forecast_now <- forecast_now %>% 
  mutate(date = as.character(as.Date(paste(date, format(Sys.Date(), '%Y'), sep = '-'), format = '%m/%d-%Y'))) %>% 
  mutate(loc = loc_list[i]) %>% 
  mutate(lake = lake_list[i]) %>% 
  full_join(forecast_template, .)

# print forecast in lake folder and label with date
write.csv(forecast_now, paste0(dir, lake_list[i], '/', lake_list[i], '-forecast-', Sys.Date(), '.csv'), row.names = F)

#add a rest of 10 seconds to not overload NOAA
Sys.sleep(10)
}
