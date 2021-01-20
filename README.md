## 개요

우리가 보는 지하철 노선도는 각 노선별 지하철역들을 한 눈에 볼 수 있게 실제 지도와는 다르게 노선도를 표시한다.
그렇다면 실제 지도에서의 지하철 역의 분포는 어떤지, R을 이용해 시각화해보겠다. 
이 작업을 위해 [이 글](https://givitallugot.github.io/articles/2020-03/R-visualization-1-seoulmap) 을 참조했다.

## 데이터셋

먼저 [이 곳](http://www.gisdeveloper.co.kr/?p=2332) 에서 실제 행정구역 공간 데이터를 다운로드할 수 있다. 
이 때, 참조한 글에서는 2017년 시군구 데이터를 다운로드 받으라고 했는데, 최신 데이터의 경우에는 구별로 겹치는 포인트가 있어, 코딩 중 오류가 뜨기 때문이라고 한다.

그 다음, [이 곳](https://observablehq.com/@taekie/seoul_subway_station_coordinate) 에서 실제 지하철역의 위도, 경도 좌표를 다운로드할 수 있다.
여기서 주의할 점으로, 이 csv 데이터에서 5호선 양평역의 좌표가 경의중앙선 양평역의 좌표로 되어 있다는 점이다. 따라서 5호선 양평역의 좌표를 (37.525648,126.885778)으로 수정해줬다.

## 코딩

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
metro_map <- subset(new_map, new_map$id <= 11740)
| (new_map$id >= 41000 & new_map$id < 42000) | (id >= 28000 & id < 29000 & long >= 126))
```

다운로드 받은 공간 데이터 중, .shp의 경로를 넣어주고, 참조한 글을 토대로 위와 같이 작성했다. 
지하철이 서울에만 운행하는 건 아니기 때문에, 적어도 경기도와 인천은 포함해야 된다. 
시도코드가 경기도는 41, 인천은 28이라는 점을 감안하여, 마지막 줄을 추가하여, 경기도와 인천을 포함시켰다.
