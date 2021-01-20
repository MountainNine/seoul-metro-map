## 개요

우리가 보는 지하철 노선도는 각 노선별 지하철역들을 한 눈에 볼 수 있게 실제 지도와는 다르게 노선도를 표시한다.
그렇다면 실제 지도에서의 지하철 역의 분포는 어떤지, R을 이용해 시각화해보겠다. 
이 작업을 위해 [이 글](https://givitallugot.github.io/articles/2020-03/R-visualization-1-seoulmap) 을 참조했다.

## 데이터셋

먼저 [이 곳](http://www.gisdeveloper.co.kr/?p=2332) 에서 실제 행정구역 공간 데이터를 다운로드할 수 있다. 
이 때, 참조한 글에서는 2017년 시군구 데이터를 다운로드 받으라고 했는데, 최신 데이터의 경우에는 구별로 겹치는 포인트가 있어, 코딩 중 오류가 뜨기 때문이라고 한다.

그 다음, [이 곳](https://observablehq.com/@taekie/seoul_subway_station_coordinate) 에서 실제 지하철역의 위도, 경도 좌표를 다운로드할 수 있다.
여기서 주의할 점으로, 이 csv 데이터에서 5호선 양평역의 좌표가 경의중앙선 양평역의 좌표로 되어 있다는 점이다. 따라서 5호선 양평역의 좌표를 (37.525648,126.885778)으로 수정해줬다.

## 코드 작성

```
library(ggmap)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)
library(rgdal)
Sys.setlocale("LC_ALL",".1251")
```

먼저 위의 라이브러리들을 import한다.
그 다음, 로케일을 위의 마지막 줄 같이 변경하는데, csv를 읽을 때 한글 데이터가 섞여 있어, 제대로 읽어오지 못하거나 한글이 깨지는 현상이 발생했기 때문이다.
이에 관해 여러 가지 해결법을 시도해보았고, 내 경우에는 시스템의 로케일을 바꾸니 해결되었다.

``` 
map <- shapefile("./map/TL_SCCO_SIG.shp")
map <- spTransform(map, CRSobj = CRS('+proj=longlat + ellps=WGS84 +datum=WGS84 +no_defs'))
new_map <- fortify(map, region = 'SIG_CD')
new_map$id <- as.numeric(new_map$id)
metro_map <- subset(new_map, new_map$id <= 11740 | (new_map$id >= 41000 & new_map$id < 42000) | (id >= 28000 & id < 29000 & long >= 126))
```

다운로드 받은 공간 데이터 중, .shp의 경로를 넣어주고, 참조한 글을 토대로 위와 같이 작성했다. 
지하철이 서울에만 운행하는 건 아니기 때문에, 적어도 경기도와 인천은 포함해야 된다. 
시도코드가 경기도는 41, 인천은 28이라는 점을 감안하여, 마지막 줄을 추가하여, 경기도와 인천을 포함시켰다.

```
station <- read.csv("./station_coordinate.csv",
                    na.strings = c("", " ", NA),
                    as.is = TRUE,
                    encoding = "UTF-8")
```

그 다음, 실제 지하철역 좌표 csv를 읽는다. 그냥 읽어오니 인코딩 관련 에러가 발생했고, encoding=UTF-8 파라미터를 추가해주니, 정상적으로 처리되었다.

``` 
ggplot(station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') +
  geom_point(aes(color=X.U.FEFF.line))
```

마지막으로 ggplot 라이브러리로 실제 지하철역들의 위치를 시각화했다. geom_polygon으로 수도권 지도를 그리고, geom_point로 지하철역 위치를 점으로 찍었다.
이 때, 노선별로 다른 색깔의 점을 찍게 했다.

전체 코드와 시각화된 지도는 다음과 같다.
``` 
## 1번 코드
library(ggmap)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)
library(rgdal)
Sys.setlocale("LC_ALL",".1251")

##2번 코드
map <- shapefile("./map/TL_SCCO_SIG.shp")
map <- spTransform(map, CRSobj = CRS('+proj=longlat + ellps=WGS84 +datum=WGS84 +no_defs'))
new_map <- fortify(map, region = 'SIG_CD')
new_map$id <- as.numeric(new_map$id)
metro_map <- subset(new_map, new_map$id <= 11740 | (new_map$id >= 41000 & new_map$id < 42000) | (id >= 28000 & id < 29000 & long >= 126))

##3번 코드
station <- read.csv("./station_coordinate.csv",
                    na.strings = c("", " ", NA),
                    as.is = TRUE,
                    encoding = "UTF-8")

##4번 코드
ggplot(station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') +
  geom_point(aes(color=X.U.FEFF.line))
```

![](https://github.com/MountainNine/seoul-metro-map/blob/develop/picture/seoul-metro.png)

## 더 좋은 시각화

막상 지도를 봐보니, 실제 노선 색깔과 다르며, 어떤 노선인지 구분이 잘 안되었다. 그래서 3번 코드와 4번 코드 사이에, 다음 코드를 추가했다.

``` 
metro_palette <- c('#003DA5','#77C4A3','#0C8E72', '#0090D2','#A17800','#F5A200','#81A914',
                   '#F5A200','#D4003B','#509F22','#B0CE18','#FDA600','#7CA8D5','#ED8B00',
                   '#0052A4','#009D3E','#EF7C1C','#00A5DE', '#996CAC','#CD7C2F','#747F00',
                   '#EA545D', '#BB8336')
```

그리고 4번 코드를 다음과 같이 바꿨다.

```
ggplot(station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') +
  geom_point(aes(color=X.U.FEFF.line)) + scale_color_manual(values = metro_palette)
```

그리고 다시 실행해주면 다음과 같은 지도가 나온다.

![](https://github.com/MountainNine/seoul-metro-map/blob/develop/picture/metro_correct_color.png)

## 서울만 시각화

서울, 인천, 경기 지도를 그려보니, 서울은 작게 나오고 지하철역의 점들로 거의 보이지 않았다. 이번에는 서울만 그리고, 지하철역도 서울 부근만 나오게 했다.

먼저 서울만 그리게 하기 위해, 2번 코드의 마지막 줄을 다음과 같이 바꿨다.

``` 
metro_map <- subset(new_map, new_map$id <= 11740)
```

그 다음 서울 부근의 지하철역만 포함시키기 위해, 3번 코드에 다음 코드를 추가했다.

```
seoul_station <- subset(station, lat>37.41 & lat<37.72 & lng>126.73 & lng<127.27)
```

포함되지 않는 노선이 생기므로, 서울 부근 노선에 맞는 팔레트를 추가해줬다.

```
seoul_metro_palette <- c('#77C4A3','#0C8E72','#0090D2','#A17800','#F5A200','#81A914','#D4003B','#B0CE18',
                         '#7CA8D5','#ED8B00','#0052A4','#009D3E','#EF7C1C','#00A5DE', '#996CAC',
                         '#CD7C2F','#747F00','#EA545D', '#BB8336')

```

마지막으로, 4번 코드를 다음과 같이 수정했다. 이때, geom_point에 size=3을 추가하여, 점 크기도 키워줬다.

```
ggplot(seoul_station, aes(x=lng, y=lat)) + geom_polygon(data = metro_map, aes(x=long, y=lat, group = group), fill='white', color='black') +
  geom_point(aes(color=X.U.FEFF.line), size=3) + scale_color_manual(values = seoul_metro_palette)
```

그리고 실행해주면, 다음과 같은 지도가 나온다.

![](https://github.com/MountainNine/seoul-metro-map/blob/develop/picture/well-sized-metro.png)

## 느낀 점

지도 시각화보다 한글 인코딩 처리 과정에서 가장 힘들었다. 그리고 노선별 색깔 매핑에서 노선명 정보에 맞는 색깔을 매핑시키고 싶었지만, 실패하고 순서대로 색깔을 집어넣었다.
여러 가지로, 아직은 많이 부족함을 느꼈다.