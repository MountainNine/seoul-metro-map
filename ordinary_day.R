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
seoul_map <- new_map[new_map$id <= 11740,]

station <- read.csv("./station_coordinate.csv",
                    na.strings = c("", " ", NA),
                    as.is = TRUE,
                    encoding = "UTF-8")

congestion <- read.csv("./congestion.csv", na.strings = c("", " ", "#DIV/0!"), header = TRUE, encoding = "UTF-8")

seoul_station_names <- unique(congestion["X.U.C5ED..U.BA85."])
seoul_metro <- c('01호선','02호선', '03호선', '04호선', '05호선', '06호선', '07호선', '08호선')

seoul_station <- subset(station, station$X.U.FEFF.line %in% seoul_metro)
seoul_station <- subset(seoul_station,  seoul_station$name %in% seoul_station_names$X.U.C5ED..U.BA85.)

ggplot() + geom_polygon(data = seoul_map, aes(x=long, y=lat, group = group),
                        fill='white', color='black') + geom_point(data= seoul_station, aes(x=lng, y=lat, group=X.U.FEFF.line),
                       fill='black', color='black')