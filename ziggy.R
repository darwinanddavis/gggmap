# ziggy 
# remove stupid ggplot grid lines with geom_sf()
# https://github.com/tidyverse/ggplot2/issues/2071

packages <- c("animation","RColorBrewer","dplyr","ggmap","RgoogleMaps","sp","maptools","scales","rgdal","ggplot2","leaflet","jsonlite","readr","devtools")
if (require(packages)) {
  # suppressPackageStartupMessages(
  install.packages(packages,dependencies = T)
  # )
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

setwd("/Users/malishev/Documents/Data/gggmap/")

# load data
site_names <- c("Cali","Ipiales","Cotopaxi Province","Baños","Quito")
cali <- c(3.4516,-76.5320)
ipiales <- c(0.8255, -77.6395)
quito <- c(-0.1807, -78.4678)
latlon <- t(data.frame(cali,ipiales,quito))
colnames(latlon) <- c("lat", "lng") # need to be named this
latlon <- latlon %>% as.data.frame


###########################################################################
###########################################################################
###########################################################################
# high res map version ----------------------------------------------------

# https://hecate.hakai.org/rguide/mapping-in-r.html

# install.packages("mapdata")
# install.packages("ggsn")
# install.packages("here")
require(mapdata) # high res data
require(ggsn) # north symbols and scale bars
require(mapview)
require(mapproj)
require(here)
require(ggthemes)
require(ggmap)
require(maptools) 
require(rgdal)
require(reshape2)


# to do -------------------------------------------------------------------

# get high res map
# get locations 
# get google path lat lon
# geom_path(data = bike, aes(color = elevation), size = 3, lineend = "round") + 
#   scale_color_gradientn(colours = rainbow(7), breaks = seq(25, 200, by = 25))

# read in data ------------------------------------------------------------
countries <- c("Colombia","Ecuador","Peru","Panama")

# read in kml data from my google maps (drive route)
# https://www.google.com/maps/d/u/0/?hl=en
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
              output = "latlon", # "latlon", "latlona", "more", "all"
              source="google" # "google" or "dsk"
) 
city_secondary <- city_secondary %>% data.frame()


# plot --------------------------------------------------------------------
dput(par(no.readonly=TRUE)) # reset graphical params (doesn't work for ggplot)
par()
require(grid)
# color palette 
# https://studio.mapbox.com/styles/darwinanddavis/cjx3sqa8obnpg1ctdcx5mxan8/edit/#11.15/46.2378/6.1383
bg <- "#f2f0ee"# "#f2f0ee" # "#c1e4f5" 
fg <- "#10163c" #"#7e3030" #10163c"
path_col <- "#f4d29f" # "#fbdbee"      # "#7e3030" #f4d29f"
border_col <- "#c7d2f5" 
city_size <- 5
path_size <- 0.7

ggplot() + 
  geom_polygon(data=d,aes(x=long, y=lat, group = group), fill = fg, col=border_col,size=0.1) +
  # geom_hline(yintercept = 0,linetype="dotted",color=border_col,size=0.5) + # add equator
  # geom_sf(data=secondary_paths[1:3,],color=adjustcolor("red",0.7),size=0.3) + # add second paths
  # geom_sf(data=secondary_paths,color=adjustcolor("white",0.3),size=0.3) + # add second paths
  geom_sf(data=zp,color=path_col,size=path_size) + # add ziggy path
  geom_point(data=city_df,aes(lon,lat),col=path_col,size=city_size) + # add cities
  geom_point(data=city_secondary,aes(lon,lat),shape=21,fill=path_col,color=path_col,size=city_size) + # add secondary cities
  coord_sf(xlim=c(-75,-81),ylim=c(-2,8)) + # zoom window  
  # theme_tufte(ticks=F) +
  theme_nothing() +
  theme(
    panel.grid.major = element_line(colour = bg),
    panel.ontop = F,   ## Note: this is to make the panel grid visible in this example
    plot.background = element_rect(fill = bg)) 
  # theme(plot.margin=unit(c(0,0,0,0),"mm")) +
  # labs(x=NULL,y=NULL)
  # geom_sf_label() # add label
  # geom_sf_text() # add text  
  # coord_map("mercator",xlim=c(-75,-81),ylim=c(-2,8))
  # geom_polygon(col = "blue", fill = NA) # get country borders back
  # coord_fixed(1.5)
# dev.off()
ggsave(paste0("ziggy_",bg,"_",fg,"_",path_col,"_noequator.pdf"), width = 9, height = 15, dpi = "retina",limitsize = F)




# for "conic"
d <- map_data("worldHires", c("Canada", "usa", "Mexico")) 
ggplot(d) + 
  geom_polygon(aes(x=long, y = lat, group = group)) + 
  theme_bw() +
  coord_map("conic", lat0 = 18, xlim=c(210, 237), ylim=c(46,62))




############################ creating maps ############################

# useful help pages
?addCircles

require(leaflet)
### default maps
map <- leaflet() # initiate the leaflet map object
map <- addTiles(map) # add the actual map tiles to the leaflet object
map <- addCircles(map,sample(35,20,replace=T),sample(35,20,replace=T)) # generate some random data around lat/lon 35
map

### custom map 
# add custom base layers 
names(providers) # types of base maps available
# some good custom layers
# 37-48, 97-103, 
provider_type <- names(providers)[43]
provider_type2 <- "CartoDB.Positron"# "Stamen.Toner" # set the above input as the custom base
col_site <- "red" # colour of site marker
radius <- 3 # size of site marker
zoom <- 6 # zoom level
opac <- 1 # transparency of map elements
weight <- 2 # width of poly lines
fill_polygon <- FALSE # FALSE = just draw lines among points 


map <- leaflet() # initiate the leaflet map object

# country level polygons
fh <- "gadm36_KEN_3_sp.rds"
geoJson2 <- readr::read_file(fh)
addGeoJSON(geoJson2,
           group = 'wards', layerId = 'dc-wards')
?addGeoJSON

# find good zoom level 
bl <- NULL # bottom left
tl <- NULL # top left
tr <- NULL # top right 
br <- NULL # bottom right 
map_aerial <- fitBounds(map, bl, tl, tr, br)

# add the site locations 
map <- addCircles(map, 
                  lng = latlon[,"lng"],
                  lat = latlon[,"lat"],
                  radius = radius,
                  stroke = TRUE,
                  weight = weight, 
                  opacity = opac,
                  color = col_site,
                  fillColor = col_site,
                  label=site_names,
                  popup=site_names,
                  data=latlon)

map <- addPolylines(map, 
                    lng = latlon[,"lng"],
                    lat = latlon[,"lat"],
                    color = col_site,
                    fillColor = col_site,
                    fill = fill_polygon,
                    weight = weight
)

map

# add custom map bases 
map <- addProviderTiles(map, provider_type,
                        options = providerTileOptions(opacity = opac) # add opacity to country lines
)
# plot
map


# add more map type layers on top of each other
# !!! need to re-initiate map to see changes because it just stacks maps on top of each other
map <- addProviderTiles(map, provider_type2)
map

##########################################################################################
##########################################################################################
##########################################################################################
# moveVis version 

# http://movevis.org/articles/example-1.html

install.packages("moveVis")
library(moveVis)
library(move)


data("move_data")

unique(timestamps(move_data))
plot(timeLag(move_data, unit = "mins")[[1]])

move_data <- align_move(move_data, res = 240, digit = 0, unit = "secs")
plot(move_data,pch=20)

get_maptypes()
map_service <- "carto"
if(map_service=="carto"){map_type_list <- get_maptypes()$carto;cat("\n\nChoose map_type\n\n");map_type_list}
map_type <- 4 # select index from map_type_list 

# plot
frames <- frames_spatial(move_data, path_colours = c("red", "green", "blue"),
                         map_service = map_service, map_type = map_type_list[map_type], alpha = 0.5)

length(frames) # number of frames
frames[[10]] # display one of the frames

# save to file
animate_frames(frames, out_file = "/Users/malishev/Documents/Data/gggmap/test.gif")

### example 3
# ggmap
# https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html

### example 4
# mapdata

### example 4 
# tmap
# https://geocompr.robinlovelace.net/adv-map.html


### example 5
# rnaturalearth 
# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html
require(ggplot2)
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(scale = "medium", returnclass = "sf")
ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE)

## example 6 
# ggspatial
# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html
install.packages("ggspatial")
library(ggspatial)

ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97))


## example 7
# sf
# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html

library("sf")
world_points<- st_centroid(world)
world_points <- cbind(world, st_coordinates(st_centroid(world$geometry)))

ggplot(data = world) +
  geom_sf() +
  geom_text(data= world_points,aes(x=X, y=Y, label=name),
            color = "darkblue", fontface = "bold", check_overlap = FALSE) +
  annotate(geom = "text", x = -90, y = 26, label = "Gulf of Mexico", 
           fontface = "italic", color = "grey22", size = 6) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE)


#################################### ziggy data
sites <- data.frame( longitude = c(34.8820, 37.7557, 39.3100), 
                     latitude = c(-0.3977, -3.6019, -4.1367))

# ziggy data
site_names <- c("Cali","Ipiales","Cotopaxi","Baños","Quito")
cali <- c(3.4516,-76.5320)
ipiales <- c(0.8255, -77.6395)
quito <- c(-0.1807, -78.4678)
sites <- t(data.frame(cali,ipiales,quito))
colnames(sites) <- c("latitude", "longitude") # need to be named this
sites <- sites[,1:2]


### working sf example
colb <- "light blue"
ggplot(data = world) +
  geom_sf(color = "white", fill = "black") +
  # geom_text(data= world_points,aes(x=X, y=Y, label=name),
  #        color = "darkblue", check_overlap = TRUE, size = 6) +
  # annotate(geom = "text", x = 33.3, y = -2, label = "Lake Victoria",
  #         fontface = "italic", color = "grey22", size = 8) +
  coord_sf(xlim = c(29.3825, 42.0461), ylim = c(-7.037, 1.4724)) +
  geom_point(data = sites, mapping = aes(x = longitude, y = latitude, colour = "red", 
                                         fill = "red", shape = 20, size = 20),
             show.legend = FALSE) + 
  geom_line(data = sites, mapping = aes(x = longitude, y = latitude, colour = "red", 
                                        fill = "red", shape = 20, size = 20),
            show.legend = FALSE) + 
  scale_shape_identity() +
  theme(panel.grid.major = element_line(color = colb, 
                                        linetype = NULL, 
                                        size = 0.5), 
        panel.background = element_rect(fill = colb)) 
# + geom_polygon(data = lakes, aes(x = X, y = Y, fill = colb))

########################################################################


# save the map
ggsave("map.pdf")
ggsave("map_web.png", width = 6, height = 6, dpi = "screen")


### example 8
# rgeos
# http://geog.uoregon.edu/bartlein/courses/geog490/week07-RMaps.html

### example 9
# mapbox
# https://rpubs.com/walkerke/rstudio-mapbox

## example 10
# http://dangoldin.com/2014/02/05/visualizing-gps-data-in-r/
library(plotKML)
library(maps)
