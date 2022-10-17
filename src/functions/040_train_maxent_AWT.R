#######################################################
#                                                     #
#                   SCRIPT TO RUN MAXENT              #
#                                                     #
#                                                     #
#######################################################
library(foreach)
library(doParallel)
library(tidyverse)
library(sf)
library(raster)
library(ecospat)
library(Metrics)

root_folder = "/home/bald/maxent"
epsg=read.table("/home/bald/maxent/layer/epsg_layer.txt", sep=";",header=T)
region = "AWT"
dirList <-list.dirs(paste0(root_folder, "/samples/",region,"/"), full.name=F, recursive=F)


cl <- parallel::makeCluster(length(dirList)) 
doParallel::registerDoParallel(cl)
foreach(i = 1:length(dirList)) %dopar% {
  species= dirList[i]
  outDir = paste0(root_folder, "/output/",region,"/",species, "/")
  folds = list.dirs(paste0("/home/bald/maxent/samples/", region, "/", species, "/"), full.names = F, recursive = F)
  
  # create temporary raster layer folder and copy layers inside
  if(!dir.exists(paste0(root_folder, "/layer/",region,"/", species,"/"))) {
    dir.create(paste0(root_folder, "/layer/",region,"/", species,"/"))
    # copy files
    listLayers <- list.files(paste0(root_folder, "/layer/",region,"/"), ".asc$", full.names = T)
    
    # copy the files to the new folder
    file.copy(listLayers, paste0(root_folder, "/layer/",region,"/", species, "/"))
  }
  
  
  for (f in 1:length(folds)) {
    fold = folds[f]
    if(!file.exists(paste0("output/",region,"/",species,"/", fold,"/",fold, "_results.csv"))){
      
      
      if(!dir.exists(paste0(outDir,"/",fold,"/spatial/"))) {dir.create(paste0(outDir,"/",fold,"/spatial/"), recursive = TRUE) }
      if(!dir.exists(paste0(outDir,"/",fold,"/tuned1/"))) {dir.create(paste0(outDir,"/",fold,"/tuned1/"), recursive = TRUE) }
      if(!dir.exists(paste0(outDir,"/",fold,"/standard/"))) {dir.create(paste0(outDir,"/",fold,"/standard/"), recursive = TRUE) }
      if(!dir.exists(paste0(outDir,"/",fold,"/tuned2/"))) {dir.create(paste0(outDir,"/",fold,"/tuned2/"), recursive = TRUE) }
      
      
      
      
      if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/spatial/final/",species,".html"))){
        # 1.0 spatial: ffs fvs tune beta and spatial cross-validation
        system(paste0("/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar outputdirectory=", outDir,fold,"/spatial/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", shQuote("replicatetype=spatial crossvalidate")," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv warnings=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ outputGrids=false autorun writeMESS=false writeClampGrid=false askoverwrite=false"
        ))
      }
      
      # 2.0 spatial random cv : ffs fvs beta tuning and random 5-fold cv
      if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/tuned1/final/",species,".html"))){
        system(paste0("/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar outputdirectory=", outDir,fold,"/tuned1/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv warnings=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ autorun writeMESS=false writeClampGrid=false askoverwrite=false"
        ))
      }
      #3.0 standard beta tuning: beta tuning and ffs and random 5-fold cv
      if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/tuned2/final/",species,".html"))){
        system(paste0("/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar outputdirectory=", outDir,fold,"/tuned2/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv ffs=true fvs=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ warnings=false autorun writeMESS=false writeClampGrid=false askoverwrite=false"
        ))
      }
      #3.0 standard: random 5-fold cv
      if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/standard/final/",species,".html"))){
        system(paste0("/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar outputdirectory=", outDir,fold,"/standard/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv ffs=false fvs=false tuneBeta=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ warnings=false autorun writeMESS=false writeClampGrid=false askoverwrite=false"
        ))
      }
      
      
      ################################ Evaluation for 4 models and 1 fold:
      
      library("tidyverse")
      folderNames= list.dirs(paste0(root_folder,"/output/",region,"/",species,"/", fold,"/"), full.names = F, recursive = F)
      obs_po = sf::read_sf(paste0(root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_test.gpkg"))
      obs_po=sf::st_set_crs(obs_po, value=epsg[epsg$region==region,]$epsg_code)
      obs_bg = sf::read_sf(paste0(root_folder,"/background/",region,"/", species,"_bg.gpkg"))
      obs_bg= sf::st_set_crs(obs_bg, value=epsg[epsg$region==region,]$epsg_code)
      #trainPoints = sf::read_sf(paste0("samples/",region,"/",species,"/",fold, "/",fold,"_train.gpkg"))
      
      
      
      
      for(folder in folderNames) {
        
        
        r = raster::raster(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/",folder,"/final/",species,"_",species,".asc"))
        
        raster::crs(r)<- epsg[epsg$region == region,]$proj4s
        resCSV= read.csv(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/",folder,"/final/maxentResults.csv"))
        nPoints = resCSV$X.Training.samples
        
        extr_po = raster::extract(r, obs_po)
        df_po = data.frame(observed = 1, predicted= extr_po)
        extr_bg = raster::extract(r,obs_bg)
        df_bg = data.frame(observed = 0, predicted= extr_bg)
        
        
        AICC = resCSV$AICC[nrow(resCSV)]
        nParams = resCSV$Number.Parameters[nrow(resCSV)]
        
        # 2. calculate Boyce
        boyce=ecospat::ecospat.boyce(fit = r, obs = obs_po, nclass=0, window.w="default", res=100, PEplot = F, 
                                     rm.duplicate = TRUE, method = 'spearman')
        
        
        # 3. Calculate AUC, MAE
        
        
        extr_bg_df=cbind(obs_bg, df_bg)
        extr_po_df = cbind(obs_po, df_po)
        
        extr_po_df=extr_po_df[c("species","observed","predicted", "geom" )]
        extr_bg_df=extr_bg_df[c("species","observed","predicted", "geom" )]
        colnames(extr_po_df)<-c("species"   ,   "observed",  "predicted", "geom" )
        extr_df = rbind(extr_bg_df, extr_po_df)
        sf::write_sf(extr_df, paste0(root_folder,"/output/",region,"/",species,"/", fold,"/",folder, "/",fold, "_",i,"_results.gpkg"))
        
        df_bg=df_bg%>%dplyr::slice_sample(n=nrow(df_po))
        df = rbind(df_bg, df_po)
        
        MAE= Metrics::mae(df$observed, df$predicted)
        AUC = Metrics::auc(df$observed, df$predicted)
        
        # balanced
        df_bg=df_bg%>%dplyr::slice_sample(n=nrow(df_po))
        df = rbind(df_bg, df_po)
        
        MAE_balanced= Metrics::mae(df$observed, df$predicted)
        AUC_balanced = Metrics::auc(df$observed, df$predicted)
        
        
        
        resCSV= read.csv(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/",folder,"/maxentResults.csv"))
        
        AUC_test = mean(resCSV$Test.AUC)
        AUC_train= mean(resCSV$Training.AUC)
        AUC_sd= mean(resCSV$AUC.Standard.Deviation)
        assign(folder, c(AICC,boyce$cor, MAE,MAE_balanced, AUC,AUC_balanced,AUC_test, AUC_train,AUC_sd, nParams, nPoints))
        
        
      }
      
      results= cbind(spatial ,tuned1,tuned2,standard)
      rownames(results) <- c("AICC","boyce", "MAE","MAE_balanced", "AUC","AUC_balanced","AUC_test", "AUC_train","AUC_sd", "nParams", "nPoints")
      results=as.data.frame(results)
      
      write.csv(results, paste0(root_folder,"/output/",region,"/",species,"/", fold,"/",fold, "_results.csv"))
      
      do.call(file.remove, as.list(list.files(paste0(root_folder,"/output/",region,"/",species,"/", fold,"/"), pattern = ".asc", full.names=T, recursive=T)))
      
    }
  }
  
  unlink(paste0(root_folder, "/layer/",region,"/", species,"/"), recursive = TRUE)
  
}
parallel::stopCluster(cl)



