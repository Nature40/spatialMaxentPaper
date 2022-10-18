#'@name 040_reduce_bg_per_call.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description reduce background points to one point per raster cell
#'@param regions vector of Strings. Folder names of layers for each region of NCEAS data



'%not_in%' <- purrr::negate(`%in%`)

reduce_bg_per_cell <- function(regions = list.dirs(file.path(envrmt$layers),full.names = F, recursive=F)){

  epsg=read.table(file.path(envrmt$layers, "epsg_layer.txt"), sep=";",header=T)  
  for (region in regions){
    bg=sf::read_sf(file.path(envrmt$background, region,"_bg.gpkg"))
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
    species =list.dirs(file.path(envrmt$samples,region), recursive = F,full.names = F)
    
    for(i in 1:length(species)){
      if(!file.exists(file.path(envrmt$background,region,"/",species[i],"_bg.csv")) || !file.exists(file.path(envrmt$background,region,"/",species[i],"_bg.gpkg"))){
        print(species[i])
        data= sf::read_sf(file.path(envrmt$samples,region, "/",species[i], "/",species[i],".gpkg"))
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
        
        if(!dir.exists(file.path(envrmt$background,region,"/"))) dir.create(file.path(envrmt$background,region,"/"))
        
        write.csv(bg2, file.path(envrmt$background,region,"/",species[i],"_bg.csv"), row.names = F)
        
        bg2_sf = sf::st_as_sf(x = bg2,                         
                              coords = c("lon", "lat"),
                              crs = epsg[epsg$region == region,]$epsg_code)
        sf::write_sf(bg2_sf, file.path(envrmt$background,region,"/",species[i],"_bg.gpkg"))
        # write background points in swd format
      }
    }
  }
  
} # end of function