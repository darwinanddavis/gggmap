# Mining Google Maps data for manipulation and plotting in `R`    
## Matthew Malishev<sup>1*</sup>

##### <sup>1</sup> _Department of Biology, Emory University, 1510 Clifton Road NE, Atlanta, GA, USA, 30322_

##### *Corresponding author: matthew.malishev@gmail.com      

Versions:  
 - R 3.5.0  
 - RStudio 1.1.453  

******

This document converts __.json__ Google Maps data into useable `R` data for mining and plotting with `ggmap` and related packages. It also has links to obtaining Google API keys for using Google-protected data.  

[**See it in action.**](http://htmlpreview.github.com/?https://github.com/darwinanddavis/ggmap/blob/master/ggmap.html)  

File extensions:   
.R  
.Rmd
.Rproj     
.json      
.pdf    
.html  

******  

### :pig: Troubleshooting :pig:     
If problems persist, feel free to contact me at matthew.malishev@gmail.com     
  
For Mac OSX > 10 (El Capitan)  

:one: Converting .json to .csv: [https://konklone.io/json/](https://konklone.io/json/)  

:two: [Troubleshooting with `ggmap` package installation](https://stackoverflow.com/questions/40642850/ggmap-error-geomrasterann-was-built-with-an-incompatible-version-of-ggproto)      

:three: For installing `.Rdb` files when encountering [fetch(key) : lazy-load database](https://stackoverflow.com/questions/30424608/error-in-fetchkey-lazy-load-database) error      

:four: [Getting **OVER QUERY LIMIT** after one request with geocode error](https://stackoverflow.com/questions/36175529/getting-over-query-limit-after-one-request-with-geocode)  

:five: [Error: map grabbing failed - see details in ?get_openstreetmap](https://stackoverflow.com/questions/23572996/ggmap-gives-error-when-using-open-street-map-as-source) when using `osm` source in `getmap()`  

:six: [Applying `get_map` functions](https://github.com/dkahle/ggmap/blob/master/R/get_map.R)  

:seven: [Unexpected character 'L'](https://stackoverflow.com/questions/32461293/unexpected-character-error-when-importing-a-json-file-into-r) error when reading in .json file for `fromJSON` function in `rjson` package 
