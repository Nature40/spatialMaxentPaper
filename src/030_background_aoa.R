#
# CALCULATE AOA FOR BACKGROUND POINTS LHS AND RANDOM
#
#
library(doParallel)
library(parallel)
library(CAST)
library(tidyverse)
library(terra)
library(sf)

setwd("/home/bald/maxent/layer/")

regions=list.dirs("/home/bald/maxent/layer/", recursive=F, full.names = F)

for (region in regions) {
  
  
  # 0 - load raster 
  print(region)
  epsg=read.table("epsg_layer.txt",sep=";",header=T)
  r = raster::stack(list.files(paste0(region,"/"), full.names=T, pattern=".asc"))
  raster::crs(r) <- epsg[epsg$region==region,]$proj4s
  
  
  # 1- calculate aoa for background points with latin hypercube sampling
  if(!file.exists(paste0("../AOA/",region,"_aoa_lhs.RDS"))){
    bg=sf::read_sf(paste0("../background/",region,"_bg.gpkg"))
    bg$geom<-NULL
    bg=as.data.frame(bg)
    bg=na.omit(bg)
    
    cl <- makeCluster(10)
    registerDoParallel(cl)
    AOA <- CAST::aoa(r, train=bg, cl=cl)
    stopCluster(cl)
    
    saveRDS(AOA, paste0("../AOA/",region,"_aoa_lhs.RDS"))
  }
  # 2 - calculate aoa with random points

  if(!file.exists(paste0("../AOA/",region,"_aoa_random.RDS"))){
    
    r=terra::rast(r)
    bg=terra::as.points(r, values=T, na.rm=T)
    bg=sf::st_as_sf(bg)
    
    # randomly sample 10000 points from the raster
    bg = bg %>% dplyr::slice_sample(n=10000)
    bg=na.omit(bg)
    bg$geom<-NULL
    bg$geometry<-NULL
    bg=as.data.frame(bg)
    
    #calculate aoa
    cl <- makeCluster(10)
    registerDoParallel(cl)
    AOA <- CAST::aoa(r, train=bg, cl=cl)
    stopCluster(cl)
    saveRDS(AOA$AOA, paste0("../AOA/",region,"_aoa_random.RDS"))
    saveRDS(AOA$parameters, paste0("../AOA/",region,"_parameters_random.RDS"))
    saveRDS(AOA$DI, paste0("../AOA/",region,"_di_random.RDS"))
    
  }
}
