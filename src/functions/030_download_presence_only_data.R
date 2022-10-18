#'@name 030_download_presence_only_data.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description download presence points with package disdat from PO and PA data
#'@param regions vector of Strings. Folder names of layers for each region of NCEAS data



download_po <-function(regions = c("AWT", "CAN", "NSW","NZ","SWI","SA"), ){
  
  epsg=read.table(file.path(envrmt$layers,"epsg_layer.txt"),sep=";",header=T)
  
  for (region in regions){
    print(region)
    
    epsgCode = epsg[epsg$region==region,]$epsg_code
    
    ############################
    
    # 1. get Presence only (Pa) points
    poAll = disdat::disPo(region)
    # get list of all species
    species = unique(poAll$spid)
    for (i in species){
      print(i)
      # 2. get presence absence points
      po = poAll%>%dplyr::filter(spid == i)
      
      if (region == "NSW"| region== "AWT"){
        pa = disdat::disPa(region, group=unique(po$group))
        paEnvironment = disdat::disEnv(region, group=unique(po$group))
      } else{
        pa = disdat::disPa(region)
        paEnvironment = disdat::disEnv(region)
      }
      pa=data.frame(species=pa[[i]], lon=pa$x, lat=pa$y)
      
      pa = cbind(pa, paEnvironment[,c(5:(ncol(paEnvironment)))])
      
      pa= pa%>%dplyr::filter(species==1);rm(paEnvironment)
      
      
      poClean= data.frame(species=po$spid, lon=po$x, lat=po$y)
      po = cbind(poClean, po[,c(7:(ncol(po)))]);rm(poClean)
      
      
      
      allPoints = rbind(pa, po);rm(pa,po)
      # convert finished dataframe to sf object
      pol = data.frame(species=i, lat= allPoints$lat, lon=allPoints$lon, spatialBlock=NA)
      pol$lon <- as.numeric(allPoints$lon)
      pol$lat <- as.numeric(allPoints$lat)
      pol$longitude <- as.numeric(pol$lon)
      pol$latitude <- as.numeric(pol$lat)
      
      
      sp::coordinates(pol)<-c("longitude","latitude")
      sp::proj4string(pol) <- epsg[epsg$region==region,]$proj4s 
      pol = sf::st_as_sf(pol)
      
      pol=cbind(pol, allPoints[,c(4:ncol(allPoints))])
      
      if(!dir.exists(file.path(envrmt$samples,region,"/",i,"/"))) dir.create(file.path(envrmt$samples,region,"/",i,"/"), recursive = T);
      sf::write_sf(pol, file.path(envrmt$samples,region,"/",i,"/",i,".gpkg"))
      
    }
    
  }
  
}# end of function
