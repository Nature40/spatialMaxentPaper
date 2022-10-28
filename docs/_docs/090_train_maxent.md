---
title: ???????
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---






```r
#'@name 070_train_maxent.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@description SCRIPT TO RUN MAXENT  
#'@param region String of region name
#'@param ncores integer number of cores
#'@param jarPath String Path to java and jar file default="/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar"
#'@param toggleLayer String default "" String with command line togglelayer for region



run_maxent <- function(region = "SA", ncores = 60, 
                      jarPath="/usr/lib/jvm/java-18-openjdk-amd64/bin/java -jar /media/memory01/casestudies/maxent/spatialMaxent_jar/spatialMaxent.jar",
                      toggleLayer=""){
  
  
  dirList <-list.dirs(file.path(envrmt$samples,region), full.name=F, recursive=F)
  epsg=read.table(file.path(envrmt$layers,"epsg_layer.txt"), sep=";",header=T)
  
  cl <- parallel::makeCluster(ncores) 
  doParallel::registerDoParallel(cl)
  foreach(i = 1:length(dirList)) %dopar% {
    species= dirList[i]
    outDir = file.path(envrmt$output,region,"/",species, "/")
    folds = list.dirs(file.path(envrmt$samples, region, "/", species, "/"), full.names = F, recursive = F)
    
    # create temporary raster layer folder and copy layers inside
    if(!dir.exists(file.path(envrmt$layers,region,"/", species,"/"))) {
      dir.create(file.path(envrmt$layers,region,"/", species,"/"))
      # copy files
      listLayers <- list.files(file.path(envrmt$layers,region), ".asc$", full.names = T)
      
      # copy the files to the new folder
      file.copy(listLayers, file.path(envrmt$layers,region,"/", species))
    }
    
    
    for (f in 1:length(folds)) {
      fold = folds[f]
      if(!file.exists(file.path(envrmt$output, region,"/",species,"/", fold,"/",fold, "_results.csv"))){
        
        
        if(!dir.exists(paste0(outDir,"/",fold,"/spatial/"))) {dir.create(paste0(outDir,"/",fold,"/spatial/"), recursive = TRUE) }
        if(!dir.exists(paste0(outDir,"/",fold,"/tuned1/"))) {dir.create(paste0(outDir,"/",fold,"/tuned1/"), recursive = TRUE) }
        if(!dir.exists(paste0(outDir,"/",fold,"/standard/"))) {dir.create(paste0(outDir,"/",fold,"/standard/"), recursive = TRUE) }
        if(!dir.exists(paste0(outDir,"/",fold,"/tuned2/"))) {dir.create(paste0(outDir,"/",fold,"/tuned2/"), recursive = TRUE) }
        
        
        
        
        if(!file.exists(file.path(envrmt$output,region,"/",species,"/",fold,"/spatial/final/",species,"_",species,".asc"))){
          # 1.0 spatial: ffs fvs tune beta and spatial cross-validation
          system(paste0(jarPath, " outputdirectory=", outDir,fold,"/spatial/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", shQuote("replicatetype=spatial crossvalidate")," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv warnings=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ outputGrids=false autorun writeMESS=false writeClampGrid=false askoverwrite=false ", toggleLayer
          ))
        }
        
        # 2.0 spatial random cv : ffs fvs beta tuning and random 5-fold cv
        if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/tuned1/final/",species,"_",species,".asc"))){
          system(paste0(jarPath," outputdirectory=", outDir,fold,"/tuned1/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv warnings=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ autorun writeMESS=false writeClampGrid=false askoverwrite=false ", toggleLayer
          ))
        }
        #3.0 standard beta tuning: beta tuning and ffs and random 5-fold cv
        if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/tuned2/final/",species,"_",species,".asc"))){
          system(paste0(jarPath," outputdirectory=", outDir,fold,"/tuned2/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv ffs=true fvs=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ warnings=false autorun writeMESS=false writeClampGrid=false askoverwrite=false ", toggleLayer
          ))
        }
        #3.0 standard: random 5-fold cv
        if(!file.exists(paste0(root_folder,"/output/",region,"/",species,"/",fold,"/standard/final/",species,"_",species,".asc"))){
          system(paste0(jarPath," outputdirectory=", outDir,fold,"/standard/ samplesfile=",root_folder,"/samples/",region,"/",species,"/",fold,"/",fold,"_train.csv ", "replicates=5"," ", shQuote("decisionParameter=test auc"), " environmentallayers=",root_folder,"/background/",region,"/", species,"_bg.csv ffs=false fvs=false tuneBeta=false outputGrids=false projectionLayers=",root_folder,"/layer/",region,"/",species,"/ warnings=false autorun writeMESS=false writeClampGrid=false askoverwrite=false ", toggleLayer
          ))
        }
        
        
        ################################ Evaluation for 4 models and 1 fold:
        
        
        folderNames= list.dirs(file.path(envrmt$output,region,"/",species,"/", fold,"/"), full.names = F, recursive = F)
        obs_po = sf::read_sf(file.path(envrmt$samples,region,"/",species,"/",fold,"/",fold,"_test.gpkg"))
        obs_po=sf::st_set_crs(obs_po, value=epsg[epsg$region==region,]$epsg_code)
        obs_bg = sf::read_sf(file.path(envrmt$background,region,"/", species,"_bg.gpkg"))
        obs_bg= sf::st_set_crs(obs_bg, value=epsg[epsg$region==region,]$epsg_code)
        #trainPoints = sf::read_sf(paste0("samples/",region,"/",species,"/",fold, "/",fold,"_train.gpkg"))
        
        
        
        
        for(folder in folderNames) {
          
          
          r = raster::raster(file.path(envrmt$output,region,"/",species,"/",fold,"/",folder,"/final/",species,"_",species,".asc"))
          
          raster::crs(r)<- epsg[epsg$region == region,]$proj4s
          resCSV= read.csv(file.path(envrmt$output,region,"/",species,"/",fold,"/",folder,"/final/maxentResults.csv"))
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
          sf::write_sf(extr_df, file.path(envrmt$output,region,"/",species,"/", fold,"/",folder, "/",fold, "_",i,"_results.gpkg"))
          
          df_bg=df_bg%>%dplyr::slice_sample(n=nrow(df_po))
          df = rbind(df_bg, df_po)
          
          MAE= Metrics::mae(df$observed, df$predicted)
          AUC = Metrics::auc(df$observed, df$predicted)
          
          # balanced
          df_bg=df_bg%>%dplyr::slice_sample(n=nrow(df_po))
          df = rbind(df_bg, df_po)
          
          MAE_balanced= Metrics::mae(df$observed, df$predicted)
          AUC_balanced = Metrics::auc(df$observed, df$predicted)
          
          
          
          resCSV= read.csv(file.path(envrmt$output,region,"/",species,"/",fold,"/",folder,"/maxentResults.csv"))
          
          AUC_test = mean(resCSV$Test.AUC)
          AUC_train= mean(resCSV$Training.AUC)
          AUC_sd= mean(resCSV$AUC.Standard.Deviation)
          assign(folder, c(AICC,boyce$cor, MAE,MAE_balanced, AUC,AUC_balanced,AUC_test, AUC_train,AUC_sd, nParams, nPoints))
          
          
        }
        
        results= cbind(spatial ,tuned1,tuned2,standard)
        rownames(results) <- c("AICC","boyce", "MAE","MAE_balanced", "AUC","AUC_balanced","AUC_test", "AUC_train","AUC_sd", "nParams", "nPoints")
        results=as.data.frame(results)
        
        write.csv(results, file.path(envrmt$output,region,"/",species,"/", fold,"/",fold, "_results.csv"))
        
        do.call(file.remove, as.list(list.files(file.path(envrmt$output,region,"/",species,"/", fold,"/"), pattern = ".asc", full.names=T, recursive=T)))
        
      }
    }
    
    unlink(file.path(envrmt$layers,region,"/", species,"/"), recursive = TRUE)
    
  }
  parallel::stopCluster(cl)
  
  
} # end of function
```