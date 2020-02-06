# load packages
packages <- c("RCurl","RColorBrewer","viridis","ggplot2","ggthemes","ggExtra","gridExtra","dplyr","tibble","tidyr","scatterplot3d","reshape2","plyr","phaseR") 
if (require(packages)) {
  install.packages(packages,dependencies = T)
  require(packages)
}
ppp <- lapply(packages,require,character.only=T)
if(any(ppp==F)){cat("\n\n\n ---> Check packages are loaded properly <--- \n\n\n")}

# load plot function 
script <- getURL("https://raw.githubusercontent.com/darwinanddavis/plot_it/master/plot_it.R", ssl.verifypeer = FALSE)
eval(parse(text = script))
display.brewer.all()
# Set global plotting parameters
cat("plot_it( \n0 for presentation, 1 for manuscript, \nset colour for background, \nset colour palette 1. use 'display.brewer.all()', \nset colour palette 2. use 'display.brewer.all()', \nset alpha for colour transperancy, \nset font style \n)")
plot_it(0,"blue","Set3","Spectral",0.8,"mono") # set plot function params       
plot_it_gg("blue") # same as above for ggplot     




### example 5
# rnaturalearth 
# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html
require(ggplot2)
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")

library("rnaturalearth")
library("rnaturalearthdata")

# default latlons 
kisumu <- c(-0.0917,34.7680)
lake_jipe <- c(-3.6019,37.7557)
kinango <- c(-4.1393,39.3180)

country <- "kenya"
colv <- "orange"

kenya <- ne_countries(scale = "large", type = "countries", 
                      # continent = "africa",
                      country = country, geounit = NULL, sovereignty = NULL,
                      returnclass = "sf")

ggplot(data = kenya) +
  geom_sf(aes(color=colv,fill=adjustcolor(colv,0.3)),
          show.legend = F) +
  coord_sf(xlim = c(kisumu[1],kisumu[1]+8), ylim = c(kisumu[2],kisumu[2]+8), expand = T) +
  theme_tufte() +
  plot_it_gg("blue")

str(kenya)  
plot(kenya$geometry,col=adjustcolor("steel blue",0.2))


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


# save the map
ggsave("map.pdf")
ggsave("map_web.png", width = 6, height = 6, dpi = "screen")


### example 8
# mapbox
# https://rpubs.com/walkerke/rstudio-mapbox