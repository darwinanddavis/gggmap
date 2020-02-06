
# file for mapdeck rmd 

# install.packages("mapdeck")
pacman::p_load(dplyr,mapdeck,googleway,here,geojsonsf,jsonlite,stringi)


# read in data ------------------------------------------------------------
# my google timeline data
set_here("/Users/malishev/Documents/Data/gggmap/")
hwd <- here("GoogleMaps","Takeout_June2019","LocationHistory")

# flight data
url <- url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
flights <- read.csv(url)
flights$info <- paste0("<b>",flights$airport1, " - ", flights$airport2, "</b>") # create new info vec for labels  
my_data = flights
glimpse(flights)
# data needs to be a col so create new cols with more approprite names  
my_data[,"lat"] <-  my_data[,"start_lat"]
my_data[,"lon"] <- my_data[,"start_lon"]

# my google maps timeline data  
my_data <- fromJSON("LocationHistory.json",simplifyDataFrame=T,flatten=T)
my_data <- my_data %>% as.data.frame()
my_data %>% na.omit() -> my_data
colnames(my_data)[c(1,2,3)] <- c("timestamp","lat","lon") # rename cols
# convert latlon to right format
stri_sub(my_data$lat, 4, 2) <- "." ; my_data$lat <- sapply(my_data$lat,as.numeric) 
stri_sub(my_data$lon, 4, 2) <- "." ; my_data$lon <- sapply(my_data$lon,as.numeric) 
my_data %>% glimpse()


# inputs ------------------------------------------------------------------
usedmapkey <- 1 # 1 = already initiated mapdeck function using mapkey once for each session, 0 = init again (for new r session or map)
mapkey <- readLines("mb.txt") # read in your mapkey
set_token(mapkey) # set mapdeck globally for future sessions    
# create style #  https://studio.mapbox.com/
my_style <- "mapbox://styles/darwinanddavis/cjy1slolu144l1cr9407s5uep/draft" # draft style  
width <- 300 # 1000
height <- 300 # 1000
padding <- 0
pitch <- 75
cell_size <- 10 # size of cells for screen grid (heatmap)

radius <- 5
fill_colour <- "#5ED2DB"
highlight_colour <- "#CC000000" # needs to be hexcode with alpha prefix  
col_pal <- list(fill_colour = "magma") # see colourvalues::colour_palettes()
fill_opacity <- 20 # 0:255
auto_highlight <- T # highlight on hover
transitions <- list(position = 2000, fill_colour = 1000) # transitions takes this form 

# data 
my_data[,"elevation"] <- sample(10000:10000000, size = nrow(my_data),replace=T) 
my_data[,"opacity"] <- sample(1:255, size = nrow(my_data),replace=T) 
id_point <- "point_1" # change with each layer
id_arc <- "arc_1" # change with each layer
id_line <- "line_1" # change with each layer
id_poly <- "poly_1" # change with each layer
id_scatter <- "scatter_1" # change with each layer
id_screengrid <- "screengrid_1" # change with each layer

# plot --------------------------------------------------------------------
# save to html to view OR viewer > new window
if(usedmapkey==0){
  p <- mapdeck(my_data, 
               style = mapdeck_style("dark"), # my_style, 
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
                 palette = col_pal,
                 update_view = T
                 # ---- extra stuff
                 # light_settings = light
                 # transitions = transitions
  )  
p

# lines
p <- p %>% 
   add_line(
    data = my_data, 
    layer_id = id_line,
    origin = c("lon", "lat"), 
    destination = c("lon", "lat"), 
    stroke_colour = fill_colour,
    stroke_width = "stroke"
  )
p

# path
p <- p %>%
  add_path(
    data = roads
    , stroke_colour = "RIGHT_LOC"
    , layer_id = "path_layer"
  )
p

# arclines 
p <- p %>%
  add_arc(
    layer_id = id_arc, 
    origin = c("lon", "lat"),
    destination = c("end_lon", "end_lat"),
    stroke_from = "airport1",
    stroke_to = "airport2",
    tooltip = "info"
  )
p

# polygons 
sf <- geojson_sf("https://symbolixau.github.io/data/geojson/SA2_2016_VIC.json")
sf %>% glimpse()
p <- p %>%
  add_polygon(
    data = sf,
    layer = "polygon_layer", 
    fill_colour = "SA2_NAME16",
    palette = "magma"
  )
p

# scatter
capitals %>% glimpse() %>% class
p <- p %>% 
  add_scatterplot(
    data = capitals,
    lat = "lat",
    lon = "lon",
    radius = 100000,
    fill_colour = "country",
    layer_id = id_scatter
)
p




# 3d maps -----------------------------------------------------------------
# produces mapdeck_working_20191229.html file 

# https://bookdown.org/robinlovelace/geocompr/adv-map.html
# @mapdeck
# install.packages("mapdeck")
# install.packages("usethis")

require(mapdeck)
require(usethis)
mb_key <- readLines("mb.txt")

set_token(Sys.getenv(mb_key))
df = read.csv("https://git.io/geocompr-mapdeck")
df <- df[ !is.na(df$lng ), ]
df <- df[ !is.na(df$lat ), ]

ms = mapdeck_style("dark")
mapdeck(style = ms, token = mb_key, pitch = 45, location = c(0, 52), zoom = 4) %>%
  add_grid(data = df, lat = "lat", lon = "lng", cell_size = 1000,
           elevation_scale = 50, layer_id = "grid_layer",
           colour_range = viridisLite::plasma(6))



# extra stuff -------------------------------------------------------------
light <- list(
  lightsPosition = c(15, 2, 0)
  , numberOfLights = 1
  , ambientRatio = 0.2
)


