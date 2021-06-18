# written by B. Steele (steeleb@caryinstitute.org)
# last modified 09June2021

# this script scrapes the 2 days of predicted weather ahead of download day

#load packages
library(magrittr)
library(rvest)
library(tibble)
library(dplyr)

#set save directory
dir <- 'datastore/for_weather/'
tmpdir <- 'datastore/for_weather/tmp/'
locdir <- 'datastore/loc_info/'

#read lat/longs
lat_long <- read.csv(file.path(locdir, 'epscor_shapefile_nhd.csv')) %>% 
  filter(EB_Lake_ID != 'YAG') %>% 
  filter(EB_Lake_ID != 'LNG')
  
#set url
aub_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'AUB'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'AUB'], "&lg=english&&FcstType=digital")
bar_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'BAR'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'BAR'], "&lg=english&&FcstType=digital")
chn_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'CHN'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'CHN'], "&lg=english&&FcstType=digital")
grt_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'GRT'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'GRT'], "&lg=english&&FcstType=digital")
ind_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'IND'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'IND'], "&lg=english&&FcstType=digital")
mur_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'MUR'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'MUR'], "&lg=english&&FcstType=digital")
pan_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'PAN'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'PAN'], "&lg=english&&FcstType=digital")
sab_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'SAB'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'SAB'], "&lg=english&&FcstType=digital")
sun_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'SUN'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'SUN'], "&lg=english&&FcstType=digital")
wat_url <- paste0("https://forecast.weather.gov/MapClick.php?lat=", lat_long$lat_dd[lat_long$EB_Lake_ID == 'WAT'], "&lon=", lat_long$long_dd[lat_long$EB_Lake_ID == 'WAT'], "&lg=english&&FcstType=digital")

url_list <- c(aub_url, bar_url, chn_url, grt_url, ind_url, mur_url, pan_url, sab_url, sun_url, wat_url) 

for_data_list <- list.files(tmpdir)

lat_dd <- as.list(lat_long %>% 
                    arrange(EB_Lake_ID) %>% 
                    select(lat_dd))$lat_dd
long_dd <- as.list(lat_long %>% 
                    arrange(EB_Lake_ID) %>% 
                    select(long_dd))$long_dd

lake_list <- as.list(lat_long %>% 
  select(EB_Lake_ID) %>% 
  arrange(EB_Lake_ID))$EB_Lake_ID

#set TZ
Sys.setenv(TZ='Etc/GMT+5') #force TZ to EST no DST for download

for(i in 1:length(url_list)) {

#read in template
forecast_template <- read.csv(file.path(tmpdir,  for_data_list[i]),
                         colClasses = 'character')
forecast_now = NULL
attempt = 1 #set attempt at first attempt
while(is.null(forecast_now) && attempt <= 3) { #repeat up to 2 more times if the html table aborts
  #read html, select table, format to dataframe
  Sys.sleep(5) #wait 5 seconds
  attempt = attempt + 1
  try(
  forecast_now <- as.data.frame(html_table(html_nodes(read_html(url_list[i]), 'table')[8])) %>% 
    rowid_to_column() %>% 
    filter(X1 != '') %>%  #remove null rows
    filter(X1 != 'Gust') #remove ill-formatted rows
  )
}
  
#break down into two charts and format
forecast_now_a <- forecast_now %>% 
  filter(rowid >=2 & rowid <=14) %>% 
  select(-rowid) %>% 
  t() %>% 
  as.data.frame() 
forecast_now_a <- forecast_now_a[-1,]
for(j in 1:ncol(forecast_now_a)) {
  names(forecast_now_a)[j] = names(forecast_template)[j+3]
}

forecast_now_b <- forecast_now %>% 
  filter(rowid >=16 & rowid <=28) %>% 
  select(-rowid) %>% 
  t() %>% 
  as.data.frame() 
forecast_now_b <- forecast_now_b[-1,]
for(j in 1:ncol(forecast_now_b)) {
  names(forecast_now_b)[j] = names(forecast_template)[j+3]
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
  mutate(lat_dd = as.character(lat_dd[i])) %>% 
  mutate(long_dd = as.character(long_dd[i])) %>% 
  mutate(EB_Lake_ID = lake_list[i]) %>% 
  full_join(forecast_template, .)

# print forecast in lake folder and label with date
write.csv(forecast_now, paste0(dir, lake_list[i], '/', lake_list[i], '-forecast-', Sys.Date(), '.csv'), row.names = F)
}
