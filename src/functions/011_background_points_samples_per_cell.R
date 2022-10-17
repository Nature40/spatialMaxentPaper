library(raster)
library(sf)
library(tidyverse)
library(terra)


setwd("D:/maxent/shredder/samples/")
'%not_in%' <- purrr::negate(`%in%`)

regions = list.dirs("D:/maxent/shredder/layer/",full.names = F, recursive=F)
epsg=read.table("../layer/epsg_layer.txt", sep=";",header=T)

for (region in regions){
  bg=sf::read_sf(paste0("../background/", region,"_bg.gpkg"))
  bg=sf::st_transform(bg, epsg[epsg$region==region,]$epsg_code)
  bg=na.omit(bg)
  
  coords=as.data.frame(sf::st_coordinates(bg))
  df=data.frame(species=NA, lon=coords$X,
                lat=coords$Y, spatialBlock=1
  )
  projcrs=crs(bg)
  bg=as.data.frame(bg)
  bg=cbind(df,bg)
  bg$ID=paste0("BG_",1:nrow(bg))
 # bg_org=bg
  bg$geom<-NULL
  
  #list of all species
  species =list.dirs(paste0(region), recursive = F,full.names = F)
  
  for(i in 1:length(species)){
    if(!file.exists(paste0("../background/",region,"/",species[i],"_bg.csv")) || !file.exists(paste0("../background/",region,"/",species[i],"_bg.gpkg"))){
      print(species[i])
      data= sf::read_sf(paste0(region, "/",species[i], "/",species[i],".gpkg"))
      df=data.frame(species=data$species, lon=data$lon, lat=data$lat, spatialBlock=1)
      data=data%>% as.data.frame()%>%dplyr::select( -c("species", "geom","lon","lat", "spatialBlock" ))
      data=cbind(df,data)
      
      
      data$ID=paste("PO_",1:nrow(data))
      df = rbind(data,bg)
      df=df%>%dplyr::select( -c("spatialBlock","species","lon","lat" ))
      dup=df[duplicated(df[, -c(ncol(df))]),]
      ids_dup <- dup$ID
      
      bg2=bg%>%dplyr::filter(ID %not_in% ids_dup)
      bg2$ID<-NULL
      bg2$species<- data$species[1]     
      
      if(!dir.exists(paste0("../background/",region,"/"))) dir.create(paste0("../background/",region,"/"))
      
      write.csv(bg2, paste0("../background/",region,"/",species[i],"_bg.csv"), row.names = F)
      
      bg2_sf = sf::st_as_sf(x = bg2,                         
                              coords = c("lon", "lat"),
                              crs = epsg[epsg$region == region,]$epsg_code)
      sf::write_sf(bg2_sf, paste0("../background/",region,"/",species[i],"_bg.gpkg"))
      # write background points in swd format
    }
  }
}

