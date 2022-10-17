library(raster)
library(sf)
library(tidyverse)
library(blockCV)


setwd("D:/maxent/shredder/samples/")

regions = list.dirs("D:/maxent/shredder/layer/",full.names = F, recursive=F)
spatialRange=read.table("spatialBlock_range.txt", sep=";",header = T)
# get epsg code and proj4string for region:
epsg=read.table("../layer/epsg_layer.txt",sep=";",header=T)

for (region in regions){
  
  #download PO data
  
  species = list.dirs(region,recursive = F, full.names = F)
  
  
  for (i in 1:length(species)){
    print(species[i])
    data = sf::read_sf(paste0(region,"/",species[i],"/",species[i],".gpkg"))
    
    
    if (nrow(data)>=35){
      
      
      df_4326 <- sf::st_transform(data, "epsg:4326")
      
      
      # 4. spatial block cv ####
      
      sb <- blockCV::spatialBlock(speciesData = df_4326,
                                  species = "species",
                                  # rasterLayer = awt,
                                  k = 7,
                                  theRange = spatialRange[spatialRange$region == region,]$range,
                                  # rows=14,
                                  selection = "random",
                                  iteration=200
      )
      
      data$spatialBlock <- sb$foldID
      
      #cluster=data_sf%>%dplyr::group_by(spatialBlock)%>%summarise(n = n())
      data=na.omit(data)
      
      allFoldCombinations = combn(c(1:7), 2)
      
      
      for (f in 1:length(allFoldCombinations[1,])){
        
        nameFold = paste0(species[i],"_",formatC(f, width = 2, flag = "0"))
        if(!dir.exists(paste0(region, "/", species[i], "/", nameFold,"/"))) dir.create(paste0(region,"/", species[i], "/", nameFold,"/"))
        
        fold = allFoldCombinations[,f]
        
        '%not_in%' <- purrr::negate(`%in%`)
        trainData = data%>%dplyr::filter(spatialBlock  %not_in% fold)
        testData = data%>%dplyr::filter(spatialBlock %in% fold)
        
        outPath = paste0(region,"/", species[i], "/", nameFold,"/")
        sf::write_sf(trainData, paste0(outPath, nameFold,"_train.gpkg"))
        sf::write_sf(testData, paste0(outPath, nameFold,"_test.gpkg"))
        
        
        df = as.data.frame(trainData)
        df$geom<-NULL
        df$geometry<-NULL
        df$locations<-NULL
        df$x<-NULL
        df$y<-NULL
        df=df %>% dplyr::select(c("species","lon","lat","spatialBlock"), everything())
        
        # safe files
        write.csv(df, paste0(outPath, nameFold,"_train.csv"), row.names = F)
      }
      
    } else {
      print(paste(i, "number of points:",nrow(data)))
      unlink(paste0(getwd(),"/",region,"/",species[i]), recursive = T)
    }
  }
  
  
}


