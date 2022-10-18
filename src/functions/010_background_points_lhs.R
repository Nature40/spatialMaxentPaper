#'@name 010_background_clhs.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description create 10000 background points for each raster ans use conditioned latin hypercube sampling to distribute points in the best possible way into space
#'@param regions vector of Strings. Folder names of layers for each region of NCEAS data
#'@param numberPoints integer. Number of background point defaults to 10000



bg_clhs <- function(regions = list.dirs(file.path(envrmt$layers),full.names = F, recursive=F), numberPoints = 10000){
  
  for(i in 1:length(regions)){
    
    #load raster
    print(regions[i])
    region=regions[i]
    epsg=read.table("epsg_layer.txt",sep=";",header=T)
    r = raster::stack(list.files(paste0(region,"/"), full.names=T, pattern=".asc"))
    raster::crs(r) <- epsg[epsg$region==region,]$proj4s
    epsgCode=epsg[epsg$region==region,]$epsg_code
    
    # do latin hypercube sampling for 10000 points
    bg=clhs::clhs(r, size=numberPoints, use.coords = T, simple=F)
    bg=bg$sampled_data
    bg=sf::st_as_sf(bg)
    sf::write_sf(bg, file.path(envrmt$background, region,"_bg.gpkg"))
  }
  
} # end of function