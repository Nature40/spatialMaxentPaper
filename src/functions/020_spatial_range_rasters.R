#'@name 020_spatial_range_rasters.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description calculate range of autocorrelation for each region
#'@param regions vector of Strings. Folder names of layers for each region of NCEAS data


spatial_range <- function( regions = list.dirs(file.path(envrmt$layers),full.names = F, recursive=F)){
  
  for(i in 1:length(regions)){
    
    print(regions[i])
    region=regions[i]
    epsg=read.table(file.path(envrmt$layers,"epsg_layer.txt"),sep=";",header=T)
    r = raster::stack(list.files(file.path(envrmt$layers, region), full.names=T, pattern=".asc"))
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
  
} # end of function