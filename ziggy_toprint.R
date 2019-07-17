# ziggy 
# install packages --------------------------------------------------------
packages <- c("animation","RColorBrewer","dplyr","ggmap","RgoogleMaps","sp","maptools",
              "scales","rgdal","ggplot2","leaflet","jsonlite","readr","devtools",
              "mapdata","ggsn","mapview","mapproj","ggthemes","reshape2","grid")
if (require(packages)) {
  install.packages(packages,dependencies = T)
  require(packages)
  # install RgoogleMaps and OpenStreetMap separately, for some reason  
  install.packages("RgoogleMaps"); library(RgoogleMaps)
  install.packages("OpenStreetMap"); library(OpenStreetMap)
  install.packages("leaflet"); library(leaflet)
  install.packages("googleway") ; library(googleway)
  # install geojsonio from github and source
  devtools::install_github("ropensci/geojsonio"); library(geojsonio)
}
ppp <- lapply(packages,require,character.only=T)
if(any(ppp==F)){cbind(packages,ppp);cat("\n\n\n ---> Check packages are loaded properly <--- \n\n\n")}
setwd(wd)

# read in data ------------------------------------------------------------
countries <- c("Colombia","Ecuador","Peru","Panama")
# read in kml data from my google maps (drive route)
zp <- sf::st_read("ziggy.kml")
secondary_paths <- sf::st_read("secondary_paths.kml")
# get city coords
city_df <- c()
for(ll in 2:length(zp$Name)){
  city <- unlist(subset(zp,Name==as.character(zp$Name[ll]))$geometry)
  city <- city[2:1] # remove stupid zero
  city_df <- rbind(city_df,city)
  city_df <- city_df %>% data.frame()
}
colnames(city_df) <- c("lat","lon")
# high res map
d <- map_data("worldHires", countries)
# get latlon
# uses api key 
location <- c("Medellin","Bogotá")
city_secondary <- geocode(location, 
                          output = "latlon", 
                          source="google"
                          ) 
city_secondary <- city_secondary %>% data.frame()

# plot --------------------------------------------------------------------
dput(par(no.readonly=TRUE)) # reset graphical params
par()
# colour palettes 
bg <- "#f2f0ee" 
fg <- "#10163c" 
path_col <- "#f4d29f" 
border_col <- "c7d2f5" 
city_size <- 5
path_size <- 0.7

# plot 
ggplot() + 
  geom_polygon(data=d,aes(x=long, y=lat, group = group), fill = fg, col=border_col,size=0.1) +
  geom_sf(data=zp,color=path_col,size=path_size) + # add ziggy path
  geom_point(data=city_df,aes(lon,lat),col=path_col,size=city_size) + # add cities
  geom_point(data=city_secondary,aes(lon,lat),shape=21,fill=path_col,color=path_col,size=city_size) + # add secondary cities
  coord_sf(xlim=c(-75,-81),ylim=c(-2,8)) + # zoom window  
  theme_nothing() +
  theme(
    panel.grid.major = element_line(colour = bg),
    panel.ontop = F, # Note: this is to make the panel grid visible in this example
    plot.background = element_rect(fill = bg)) 
# save to dir
ggsave(paste0("ziggy_",bg,"_",fg,"_",path_col,".pdf"), width = 9, height = 15, dpi = "retina", limitsize = F)
