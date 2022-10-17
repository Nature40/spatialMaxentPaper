library(tidyverse)
library(ggplot2)
setwd("/home/bald/maxent/output/")

region ="SWI"

outputList = list.files(paste0(region,"/"), full.names=F, recursive = F)
outputList=outputList[-c(1)]
#for (out in 1:length(outputList)) {
results=lapply(1:length(outputList),  function(out){
  out2 = outputList[out]
  listFolds = list.files(paste0(region,"/", out2,"/"), full.names=F, recursive = T, pattern="results.csv")
  
  
  
  res = lapply(1:length(listFolds),  function(i){
    
    
    x= read.csv(paste0(region,"/",out2, "/", listFolds[i]))
    x=t(x)
    x = as.data.frame(x)
    dat=x
    colnames(dat) <- dat[1,]
    dat=dat[-c(1),]
    dat$species=out2
    dat$fold= substr(listFolds[i],1,8)
    dat$boyce <- as.numeric(dat$boyce)
    dat$AUC <- as.numeric(dat$AUC)
    dat$nParams <- as.numeric(dat$nParams)
    dat$method <- rownames(dat)
    dat$AICC = as.numeric(dat$AICC)
    
    dat$MAE = as.numeric(dat$MAE)
    dat$AUC_test = as.numeric(dat$AUC_test)
    dat$AUC_train = as.numeric(dat$AUC_train)
    dat$AUC_sd = as.numeric(dat$AUC_sd)
    dat$nPoints=as.numeric(dat$nPoints)
    
    
    
    return(dat)
  }
  )
  res2 = do.call(rbind, res)  
  
  dat = res2
  boyce_median = dat%>% group_by(method)%>%summarise_at(vars(boyce), list(boyce_median = median), na.rm=T)
  boyce_mean = dat%>% group_by(method)%>%summarise_at(vars(boyce), list(boyce_mean = mean), na.rm=T)
  boyce_sd = dat%>% group_by(method)%>%summarise_at(vars(boyce), list(boyce_sd = sd), na.rm=T)
  
  auc_median = dat%>% group_by(method)%>%summarise_at(vars(AUC), list(auc_median = median), na.rm=T)
  auc_mean = dat%>% group_by(method)%>%summarise_at(vars(AUC), list(auc_mean = mean), na.rm=T)
  auc_sd = dat%>% group_by(method)%>%summarise_at(vars(AUC), list(auc_sd = sd), na.rm=T)
  
  aicc_median = dat%>% group_by(method)%>%summarise_at(vars(AICC), list(aicc_median = median), na.rm=T)
  aicc_mean = dat%>% group_by(method)%>%summarise_at(vars(AICC), list(aicc_mean = mean), na.rm=T)
  aicc_sd = dat%>% group_by(method)%>%summarise_at(vars(AICC), list(aicc_sd = sd), na.rm=T)
  
  nparam_median = dat%>% group_by(method)%>%summarise_at(vars(nParams), list(nparam_median = median), na.rm=T)
  nparam_mean = dat%>% group_by(method)%>%summarise_at(vars(nParams), list(nparam_mean = mean), na.rm=T)
  nparam_sd = dat%>% group_by(method)%>%summarise_at(vars(nParams), list(nparam_sd = sd), na.rm=T)
  
  mae_median = dat%>% group_by(method)%>%summarise_at(vars(MAE), list(mae_median = median), na.rm=T)
  mae_mean = dat%>% group_by(method)%>%summarise_at(vars(MAE), list(mae_mean = mean), na.rm=T)
  mae_sd = dat%>% group_by(method)%>%summarise_at(vars(MAE), list(mae_sd = sd), na.rm=T)
  
  auc_train_median = dat%>% group_by(method)%>%summarise_at(vars(AUC_train), list(auc_train_median = median), na.rm=T)
  auc_train_mean = dat%>% group_by(method)%>%summarise_at(vars(AUC_train), list(auc_train_mean = mean), na.rm=T)
  auc_train_sd = dat%>% group_by(method)%>%summarise_at(vars(AUC_train), list(auc_train_sd = sd), na.rm=T)
  
  auc_test_median = dat%>% group_by(method)%>%summarise_at(vars(AUC_test), list(auc_test_median = median), na.rm=T)
  auc_test_mean = dat%>% group_by(method)%>%summarise_at(vars(AUC_test), list(auc_test_mean = mean), na.rm=T)
  auc_test_sd = dat%>% group_by(method)%>%summarise_at(vars(AUC_test), list(auc_test_sd = sd), na.rm=T)
  
  npoints_median = dat%>% group_by(method)%>%summarise_at(vars(nPoints), list(npoints_median = median), na.rm=T)
  npoints_mean = dat%>% group_by(method)%>%summarise_at(vars(nPoints), list(npoints_mean = mean), na.rm=T)
  npoints_sd = dat%>% group_by(method)%>%summarise_at(vars(nPoints), list(npoints_sd = sd), na.rm=T)
  
  data = cbind(boyce_mean[2], boyce_median[2], boyce_sd[2], auc_mean[2], auc_median[2], auc_sd[2], nparam_mean[2], nparam_median[2], nparam_sd[2]
               , aicc_mean[2], aicc_median[2], aicc_sd[2],mae_median[2],mae_mean[2],mae_sd[2],auc_train_median[2],auc_train_mean[2],auc_train_sd[2],
               auc_test_mean[2],auc_test_median[2],auc_test_sd[2], npoints_mean[2],npoints_median[2],npoints_sd[2]
               )
  data$species = dat$species[1]
  data$method = boyce_mean$method
  return(data)
  
  
  
  
}
)


res2 = do.call(rbind, results)  
write.csv(res2, paste0(region,"/",region,"_results_all_folds.csv"))


dat = res2
#dat = read.csv(paste0(region,"/",region,"_results_all_folds.csv"))
dat=dat[dat$npoints_median >= dat$nparam_median,]

ggplot2::ggplot(dat, aes(y=boyce_median, x=nparam_median, color = method)) + 
  geom_point(size=3) + geom_point(aes(y=auc_median, x= nparam_median, color = method), shape = 17, size=3)+
  scale_x_reverse() +ylab("Boyce-Index & AUC")+ facet_wrap(vars(species))+xlab("Number parameters")

ggplot2::ggplot(dat, aes(y=boyce_median, x=mae_median, color = method)) + 
  geom_point(size=3) + geom_point(aes(y=auc_median, x= mae_median, color = method), shape = 17, size=3)+
  scale_x_reverse() +ylab("Boyce-Index & AUC")+ facet_wrap(vars(species))+xlab("MAE")

#MAE und auc yusammen mit AUC test
ggplot2::ggplot(dat, aes(y=auc_median, x=mae_median, color = method)) +geom_point(size=3)+ 
  scale_x_reverse() +ylab(" AUC")+ facet_wrap(vars(species))+xlab("MAE") +
  geom_point(size=3) + geom_point(aes(y=auc_test_median, x= mae_median, color = method), shape = 1, size=3,)


