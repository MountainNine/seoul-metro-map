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

metro_palette <- c('01호선'='#0052A4', '02호선'='#009D3E', '03호선'='#EF7C1C', '04호선'='#00A5DE',
                   '05호선'='#996CAC', '06호선'='#CD7C2F', '07호선'='#747F00', '08호선'='#EA545D',
                   '09호선'='#BB8336','경강선'='#003DA5', '경의선'='#77C4A3','경춘선'='#0C8E72',
                   '공항철도'='#0090D2','김포도시철도'='#A17800','분당선'='#F5A200','서해선'='#81A914',
                   '수인선'='#F5A200','신분당선'='#D4003B','용인경전철'='#509F22','우이신설경전철'='#B0CE18',
                   '의정부경전철'='#FDA600','인천2호선'='#ED8B00','인천선'='#7CA8D5')

theme_set(theme_gray(base_family = 'NanumGothic'))
ggplot(station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') + geom_point(aes(color=station$X.U.FEFF.line)) + scale_color_manual(values=metro_palette)
# + geom_point(aes(colour=station$X.U.FEFF.line)) + scale_colour_manual(values=metro_palette)