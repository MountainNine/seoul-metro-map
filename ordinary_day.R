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

metro_palette <- c('#003DA5','#77C4A3','#0C8E72', '#0090D2','#A17800','#F5A200','#81A914',
                   '#F5A200','#D4003B','#509F22','#B0CE18','#FDA600','#7CA8D5','#ED8B00',
                   '#0052A4','#009D3E','#EF7C1C','#00A5DE', '#996CAC','#CD7C2F','#747F00',
                   '#EA545D', '#BB8336')

ggplot(station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') +
  geom_point(aes(color=X.U.FEFF.line)) + scale_color_manual(values = metro_palette)