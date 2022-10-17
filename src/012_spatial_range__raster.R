library(sf)
library(raster)
library(blockCV)
setwd("D:/maxent/shredder/layer/")

regions = list.dirs(full.names = F, recursive=F)

for(i in 1:length(regions)){
  
  print(regions[i])
  region=regions[i]
  epsg=read.table("epsg_layer.txt",sep=";",header=T)
  r = raster::stack(list.files(paste0(region,"/"), full.names=T, pattern=".asc"))
  raster::crs(r) <- epsg[epsg$region==region,]$proj4s
  epsgCode=epsg[epsg$region==region,]$epsg_code
  
  
  
  sac <- spatialAutoRange(rasterLayer = r,
                          sampleNumber = 5000,
                          doParallel = TRUE,
                          nCores = 3,
                          showPlots = TRUE,
                          plotVariograms=TRUE
                          )
  sac$range
  blockCV:::plot.SpatialAutoRange()
}