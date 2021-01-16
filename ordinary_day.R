library(ggmap)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)
library(rgdal)
Sys.setlocale("LC_ALL","C")

map <- shapefile("./map/TL_SCCO_SIG.shp")
map <- spTransform(map, CRSobj = CRS('+proj=longlat + ellps=WGS84 +datum=WGS84 +no_defs'))
new_map <- fortify(map, region = 'SIG_CD')
new_map$id <- as.numeric(new_map$id)
seoul_map <- new_map[new_map$id <= 11740,]

station <- read.csv("./station_coordinate.csv",
                    na.strings = c("", " ", NA),
                    header = TRUE,
                    as.is = TRUE,
                    encoding = "UTF-8")
Sys.setlocale("LC_ALL","Korean")

# ggplot() + geom_polygon(data = seoul_map, aes(x=long, y=lat, group = group),
#                         fill='white', color='black')
#           + geom_point(data=)