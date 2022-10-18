#'@name 060_background_aoa.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description CALCULATE AOA FOR BACKGROUND POINTS CLHS AND RANDOM
#'@param regions vector of Strings. Folder names of layers for each region of NCEAS data




background_aoa <- function(regions=list.dirs(envrmt$layers, recursive=F, full.names = F)){
  
  for (region in regions) {
    
    
    # 0 - load raster 
    print(region)
    epsg=read.table(file.path(envrmt$layers,"epsg_layer.txt"),sep=";",header=T)
    r = raster::stack(list.files(file.path(envrmt$layers, region), full.names=T, pattern=".asc"))
    raster::crs(r) <- epsg[epsg$region==region,]$proj4s
    epsgCode=epsg[epsg$region==region,]$epsg_code
    
    
    # 1- calculate aoa for background points with latin hypercube sampling
    if(!file.exists(file.path(envrmt$AOA,region,"_aoa_random.tif"))){
      bg=sf::read_sf(file.path(envrmt$background,region,"_bg.gpkg"))
      bg$geom<-NULL
      bg=as.data.frame(bg)
      
      cl <- makeCluster(50)
      registerDoParallel(cl)
      AOA <- CAST::aoa(r, train=bg, cl=cl)
      stopCluster(cl)
      
      terra::writeRaster(AOA, file.path(envrmt$AOA,region,"_aoa_lhs.tif"))
    }
    # 2 - calculate aoa with random points
    
    if(!file.exists(file.path(envrmt$AOA,region,"_aoa_random.tif"))){
      
      r=terra::rast(r)
      bg=terra::as.points(r, values=T, na.rm=T)
      bg=sf::st_as_sf(bg)
      
      # randomly sample 10000 points from the raster
      bg = bg %>% dplyr::slice_sample(n=10000)
      bg=na.omit(bg)
      bg$geom<-NULL
      bg=as.data.frame(bg)
      
      #calculate aoa
      cl <- makeCluster(50)
      registerDoParallel(cl)
      AOA <- CAST::aoa(r, train=initialPoints, cl=cl)
      stopCluster(cl)
      terra::writeRaster(AOA, file.path(envrmt$AOA,region,"_aoa_random.tif"))
      
    }
  }
  
}# end of function