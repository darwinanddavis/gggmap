# TO DO 
# get unique latlon and fill in missing vector length to match latlon vectors


#### WORKING 20-9-18
#### converting json data
require(jsonlite)
datacsv <- read.csv("LocationHistory.csv")
data <- fromJSON("/Users/malishev/Documents/Data/GoogleMaps/2019/Takeout/Location History/Semantic Location History/2019/2019_SEPTEMBER.json",simplifyDataFrame=T,flatten=T)
data <- as.data.frame(data)
data %>% glimpse
names(data)


# csv location data -------------------------------------------------------

colnames(data) <- c(
  "TimeStamp","Lat","Lon","Accuracy","Activity","Heading","Velocity","Altitude"
  )
data <- data[!is.na(data$Lat),] # remove NA rows 
data$TimeStamp %>% unique
# with(data,plot(Lat,Lon,type="l",lwd=3,col="steel blue"))

with(data,hist(
  Accuracy %>% unique,breaks = 500)
)

# turn laton into numeric
# do this once 
require(stringi)
stri_sub(data$Lat, 4, 2) <- "."
stri_sub(data$Lon, 4, 2) <- "."
data$Lat <- data$Lat %>% as.numeric
data$Lon <- data$Lon %>% as.numeric
# get smaller dataset
latlon_sub <- data[1:35000,c("Lat","Lon")]
# 3 decimals = min value with detail  
lon <- latlon_sub[,"Lon"] %>% formatC(digits = 3,format = "f") %>% as.numeric()
lat <- latlon_sub[,"Lat"] %>% formatC(digits = 3,format = "f") %>% as.numeric()


# json location data ------------------------------------------------------
lat <- data$timelineObjects.placeVisit.location.latitudeE7
lon <- data$timelineObjects.placeVisit.location.longitudeE7

data <- data[!is.na(data$timelineObjects.placeVisit.location.latitudeE7),] # remove na
# turn laton into numeric
# do this once 
require(stringi)
stri_sub(lat, 3, 2) <- "."
stri_sub(lon, 3, 2) <- "."
lat <- lat %>% as.numeric
lon <- lon %>% as.numeric
# 3 decimals = min value with detail  
lat <-  lat %>% formatC(digits = 3,format = "f") %>% as.numeric()
lon <- lon %>% formatC(digits = 3,format = "f") %>% as.numeric()



# labels ------------------------------------------------------------------
data$timelineObjects.placeVisit.location.address
data$timelineObjects.activitySegment.activityType
data$timelineObjects.placeVisit.location.name %>% unique
labels <- data$timelineObjects.placeVisit.location.address

# plot latlon of my google data 

custom_tile <- "http://c.sm.mapstack.stamen.com/(toner-lite,(mapbox-water,$000[@80]),(parks,$000[@70]),(buildings,$fabe68[hsl-color]))/{z}/{x}/{y}.png"

colv <- "#F90F40"
leaflet() %>% 
  setView(
    0,0,
    # data[,"Lon"][1],
    # data[,"Lat"][1],
    zoom=3) %>% 
  addTiles(custom_tile) %>% 
  addCircleMarkers(
    lon,
    lat,
    radius = 5,
    stroke = TRUE,
    weight = 1, 
    opacity = 0.3,
    color = colv,
    fillColor = colv,
    fillOpacity = 0.3,
    label = data$timelineObjects.placeVisit.location.name,
    popup = paste0("Lat: ", lat, "Lon:", lon)
  )


# convert time stamp
timepoint <- data$TimeStamp[1]
as.POSIXlt(timepoint, format="%Y-%m-%d-%H:%M:%S", 
           origin="1970-01-01",tz="GMT")


# to access activity type in data, e.g. still, tilting, etc ...
## this only uses csv (converts json to csv externally) https://konklone.io/json/
f <- list.files(pattern = "*.csv")[2]
data <- read.csv(f,header=T,sep=",",stringsAsFactors = T)
data <- as.data.frame(data)
colnames(data)[c(1,2,3)] <- c("TimeStamp","Lat","Lon")
data <- data[!is.na(data$Lat),] # remove NA rows 
# make latlon into degrees
require(stringi)
stri_sub(data$Lat, 4, 2) <- "." ; data$Lat <- sapply(data$Lat,as.numeric) 
stri_sub(data$Lon, 4, 2) <- "." ; data$Lon <- sapply(data$Lon,as.numeric) 



# 2019 google data --------------------------------------------------------

require(RCurl)
coffee <- readr::read_csv("/Users/malishev/Documents/Data/GoogleMaps/2019/Takeout/Saved/Coffee.csv")
# get map link to one location  
mapurl <- getURL(coffee$URL[1], ssl.verifypeer = FALSE)
eval(parse(text = mapurl))

