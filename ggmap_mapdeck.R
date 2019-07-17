
# file for mapdeck rmd 

# install.packages("mapdeck")
p_load(dplyr,mapdeck,googleway)

# read in data  
url <- url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
flights <- read.csv(url)
glimpse(flights)



# data example ------------------------------------------------------------
# create new info vec for labels  
flights$info <- paste0("<b>",flights$airport1, " - ", flights$airport2, "</b>")


# inputs ------------------------------------------------------------------
usedmapkey <- 1 # 1 = int mapdeck function using mapkey once for each session, 0 = init again (for new r session or map)

my_data = flights
mapkey <- readLines("mb.txt") # read in your mapkey
set_token(mapkey) # set mapdeck globally for future sessions    
# create style #  https://studio.mapbox.com/
my_style <- "mapbox://styles/darwinanddavis/cjy1slolu144l1cr9407s5uep/draft" # draft style  
width <- 1000
height <- 1000
padding <- 0
pitch <- 75

radius <- 5
fill_colour <- "#5ED2DB"
highlight_colour <- "#CC000000" # needs to be hexcode with alpha prefix  
palette <- list(fill_colour = "magma") # see colourvalues::colour_palettes()
fill_opacity <- 20 # 0:255
auto_highlight <- T # highlight on hover
transitions <- list(position = 2000, fill_colour = 1000) # transitions takes this form 

# data 
# needs to be a col so create new cols with more approprite names  
my_data[,"lat"] <-  my_data[,"start_lat"]
my_data[,"lon"] <- my_data[,"start_lon"]
my_data[,"elevation"] <- sample(10000:10000000, size = nrow(my_data),replace=T) 
my_data[,"opacity"] <- sample(1:255, size = nrow(my_data),replace=T) 
id_point <- "point_1" # change with each layer
id_arc <- "arc_1" # change with each layer
id_poly <- "poly_1" # change with each layer



# plot --------------------------------------------------------------------
# save to html to view OR viewer > new window
if(usedmapkey==0){
  p <- mapdeck(my_data, 
               style = my_style,
               width = width,
               height = height,
               padding = padding,
               pitch = pitch)
}

# point cloud
p <- p %>% 
  add_pointcloud(lat = "lat", 
                 lon = "lon",
                 elevation = "elevation",
                 layer_id = id_point,
                 radius = radius, 
                 fill_colour = fill_colour,
                 fill_opacity = "opacity",
                 auto_highlight = auto_highlight, 
                 highlight_colour = highlight_colour,
                 tooltip = "info",
                 palette = palette,
                 update_view = T
                 # ---- extra stuff
                 # light_settings = light
                 # transitions = transitions
  )  
p



# arclines 
p <- p %>%
  add_arc(
    data = flights,
    layer_id = id_arc,
    , origin = c("start_lon", "start_lat")
    , destination = c("end_lon", "end_lat")
    , stroke_from = "airport1"
    , stroke_to = "airport2"
    , tooltip = "info"
    , layer_id = 'arclayer',
  )
p

# extra stuff -------------------------------------------------------------
light <- list(
  lightsPosition = c(15, 2, 0)
  , numberOfLights = 1
  , ambientRatio = 0.2
)


