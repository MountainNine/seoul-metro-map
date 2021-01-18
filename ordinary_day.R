library(ggmap)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)
library(rgdal)
Sys.setlocale("LC_ALL",".1251")

map <- shapefile("./map/TL_SCCO_SIG.shp")
map <- spTransform(map, CRSobj = CRS('+proj=longlat + ellps=WGS84 +datum=WGS84 +no_defs'))
new_map <- fortify(map, region = 'SIG_CD')
new_map$id <- as.numeric(new_map$id)
metro_map <- subset(new_map, new_map$id <= 11740 | (new_map$id >= 41000 & new_map$id < 42000)
   | (id >= 28000 & id < 29000 & long >= 126))

station <- read.csv("./station_coordinate.csv",
                    na.strings = c("", " ", NA),
                    as.is = TRUE,
                    encoding = "UTF-8")

theme_set(theme_gray(base_family = 'NanumGothic'))
ggplot() + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') + geom_point(data= station, aes(x=lng, y=lat, colour=station$X.U.FEFF.line))