#
# create 10000 background points for each raster ans use conditioned latin hypercube sampling to 
# distribute points in the best possible way into space
#
library(sf)
library(clhs)
library(raster)


setwd("D:/maxent/shredder/layer/")

regions = list.dirs(full.names = F, recursive=F)

for(i in 1:length(regions)){
  
  #load raster
  print(regions[i])
  region=regions[i]
  epsg=read.table("epsg_layer.txt",sep=";",header=T)
  r = raster::stack(list.files(paste0(region,"/"), full.names=T, pattern=".asc"))
  raster::crs(r) <- epsg[epsg$region==region,]$proj4s
  epsgCode=epsg[epsg$region==region,]$epsg_code
  
  # do latin hypercube sampling for 10000 points
  bg=clhs::clhs(r, size=10000, use.coords = T, simple=F)
  bg=bg$sampled_data
  bg=sf::st_as_sf(bg)
  sf::write_sf(bg, paste0("../background/", region,"_bg.gpkg"))
  }

