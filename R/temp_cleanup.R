### temporary script to clean up old observed weather data to remove dupes ####

library(tidyverse)

#read files
aub <- read.csv('datastore/obs_weather/aub-obs.csv')
grt <- read.csv('datastore/obs_weather/grt-obs.csv')
mur <- read.csv('datastore/obs_weather/mur-obs.csv')
ri <- read.csv('datastore/obs_weather/ri-obs.csv')
sun <- read.csv('datastore/obs_weather/sun-obs.csv')
wat <- read.csv('datastore/obs_weather/wat-obs.csv')

#filter duplicated rows
aub_filter <- aub %>% 
  arrange(date, time, download_date)

aub_filter <- aub_filter[!duplicated(aub_filter[,1:20]),]

grt_filter <- grt %>% 
  arrange(date, time, download_date)

grt_filter <- grt_filter[!duplicated(grt_filter[,1:20]),]

mur_filter <- mur %>% 
  arrange(date, time, download_date)

mur_filter <- mur_filter[!duplicated(mur_filter[,1:20]),]

ri_filter <- ri %>% 
  arrange(date, time, download_date)

ri_filter <- ri_filter[!duplicated(ri_filter[,1:20]),]

sun_filter <- sun %>% 
  arrange(date, time, download_date) 

sun_filter <- sun_filter[!duplicated(sun_filter[,1:20]),]

wat_filter <- wat %>% 
  arrange(date, time, download_date) 

wat_filter <- wat_filter[!duplicated(wat_filter[,1:20]),]

#format to datetimstamp
aub_filter <- aub_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

grt_filter <- grt_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

mur_filter <- mur_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

ri_filter <- ri_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

sun_filter <- sun_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

wat_filter <- wat_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))

aub_filter <- aub_filter %>% 
  mutate(datetime = paste(date, time, sep = ' '))


#write new files
aub <- write.csv(aub_filter, 'datastore/obs_weather/aub-obs.csv', row.names = F)
grt <- write.csv(grt_filter, 'datastore/obs_weather/grt-obs.csv', row.names = F)
mur <- write.csv(mur_filter, 'datastore/obs_weather/mur-obs.csv', row.names = F)
ri <- write.csv(ri_filter, 'datastore/obs_weather/ri-obs.csv', row.names = F)
sun <- write.csv(sun_filter, 'datastore/obs_weather/sun-obs.csv', row.names = F)
wat <- write.csv(wat_filter, 'datastore/obs_weather/wat-obs.csv', row.names = F)
