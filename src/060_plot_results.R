###################################################
#                                                 #
#                                                 #
# RESULT PLOTS FOR MAXENT AND NCEAS               #
#                                                 #  
#                                                 #
###################################################

# 1 - load libraries and data
#----------------------------
library(ggplot2)
library(tidyverse)
library(tidyverse)
library(hrbrthemes)
library(viridis)

data= read.csv("D:/maxent/shredder/output/NSW_results_all_folds.csv")
data= read.csv("D:/maxent/shredder/output/AWT_results_all_folds.csv")
data$label=paste("Points:",round(data$npoints_median,0))
data[data$method %in% c("standard", "tuned1", "tuned2"),]$label <- NA
data$boyce_scaled=scales::rescale(data$boyce_median,to=c(0,1))
data$auc_scaled=scales::rescale(data$boyce_median,to=c(0,1))
data$mae_scaled=1-scales::rescale(data$mae_median, to=c(0,1))
data$nparam_scaled <- 1-scales::rescale(data$nparam_median, to=c(0,1))


# 2 - auc mea plot nach Konowalik & Nosol (2021)
#-----------------------------------------------
dat$region=substr(dat$species, 1,2)
data2=dplyr::filter(dat, region =="sw")

ggplot2::ggplot(data2, aes(y=auc_median, x=mae_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab(expression("MAE"["PO"]))+ylab(expression("AUC "["PO"]))+
  geom_point(aes(y=auc_median, x=mae_median),size=3,shape=4,colour="black",
             dplyr::filter(data2, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data2,
             mapping = aes(x=0.35, y=min(auc_median),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# 3 - plot boyce index with number parameters
#--------------------------------------------

ggplot2::ggplot(data2, aes(y=boyce_median, x=nparam_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab("Number Parameters")+ylab("Boyce-Index")+
  geom_point(aes(y=boyce_median, x=nparam_median),size=3,shape=4,colour="black",
             dplyr::filter(data2, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data2,
             mapping = aes(x=150, y=min(boyce_median),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


# 4 - scale all data and calculate index for plotting
#----------------------------------------------------

data$index=data$auc_scaled+data$boyce_scaled+data$nparam_scaled+data$mae_scaled

dat$region=substr(dat$species, 1,2)
data2=dplyr::filter(dat, region =="sw")
ggplot2::ggplot(data2, aes(y=index, x=index, color=method))+
  geom_point(size=3)+
  geom_point(aes(y=index, x=index),size=3,shape=4,colour="black",
             dplyr::filter(data2, npoints_median <= nparam_median))+ scale_colour_viridis_d()+facet_wrap(vars(species))+
  geom_text( size=3,
             data    = data2,
             mapping = aes(x=3, y=0.5,label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)

# 5 - data for histogram best metrics
#--------------------------------------

setwd("/home/bald/maxent/output/")
listFiles = list.files(pattern = "_results_all_folds.csv", recursive=T)

res = lapply(1:length(listFiles),  function(i){
  x= read.csv(listFiles[i])
  return(x)})
dat = do.call(rbind, res)  

boyce = dat %>% group_by(species) %>% slice(which.max(boyce_median)) 
auc = dat %>% group_by(species) %>% slice(which.max(auc_median)) 
nparam = dat %>% group_by(species) %>% slice(which.min(nparam_median)) 
mae = dat %>% group_by(species) %>% slice(which.min(mae_median)) 

results=data.frame(method=as.data.frame(table(auc$method))$Var1,
                   auc=as.data.frame(table(auc$method))$Freq, mae=as.data.frame(table(mae$method))$Freq, 
                   boyce=as.data.frame(table(boyce$method))$Freq)
results$nparam<-0
nparam2 <- as.data.frame(table(nparam$method))
results[results$method=="spatial",]$nparam <- nparam2[nparam2$Var1=="spatial",]$Freq
results[results$method=="standard",]$nparam <- nparam2[nparam2$Var1=="standard",]$Freq
results[results$method=="tuned1",]$nparam <- nparam2[nparam2$Var1=="tuned1",]$Freq
results[results$method=="tuned2",]$nparam <- nparam2[nparam2$Var1=="tuned2",]$Freq

write.csv(results, "count_best_method.csv")



dat$species_method <- paste0(dat$species, "_",dat$method)

dat$auc_difference <- abs(dat$auc_test_median - dat$auc_median)

# Plot

ggplot(dat, aes(x=method, y=auc_difference, fill=method)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  #geom_jitter(color="black", size=0.4, alpha=0.9)+
  xlab("Method")+ylab("Difference Maxent test AUC & AUC on independent data")#+
hrbrthemes::theme_ipsum()


# 6 - violin plot index
#-----------------------


dat$label=paste("Points:",round(dat$npoints_median,0))
dat[data$method %in% c("standard", "tuned1", "tuned2"),]$label <- NA
dat$boyce_scaled=scales::rescale(dat$boyce_median,to=c(0,1))
dat$auc_scaled=scales::rescale(dat$boyce_median,to=c(0,1))
dat$mae_scaled=1-scales::rescale(dat$mae_median, to=c(0,1))
dat$nparam_scaled <- 1-scales::rescale(dat$nparam_median, to=c(0,1))




dat$index=dat$auc_scaled+dat$boyce_scaled+dat$nparam_scaled+dat$mae_scaled


# Most basic violin chart
ggplot(data=dat, aes(x=method, y=index, fill=method)) + # fill=name allow to automatically dedicate a color for each group
  geom_violin() + scale_fill_viridis(discrete = TRUE, alpha=0.6) +
 geom_boxplot(width=0.2, color="black", fill="white", alpha=0.6)#+theme_ipsum()
  

# Most basic violin chart
ggplot(dat, aes(x=method, y=index, fill=method)) + scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_boxplot()#+geom_jitter(color="black", size=0.4, alpha=0.9)#+theme_ipsum() 


# 7 - count best method per metric #####
#--------------------------------------#

boyce = dat %>% group_by(species) %>% slice(which.max(boyce_median)) 
dat$bestModel <- 0

for (i in 1:nrow(boyce)){
  dat[dat$method == boyce$method[i] & dat$species == boyce$species[i],]$bestModel <- 
    dat[dat$method == boyce$method[i] & dat$species == boyce$species[i],]$bestModel+1
}
table(boyce$method)

auc = dat %>% group_by(species) %>% slice(which.max(auc_median)) 
table(auc$method)
for (i in 1:nrow(boyce)){
  dat[dat$method == auc$method[i] & dat$species == auc$species[i],]$bestModel <- 
    dat[dat$method == auc$method[i] & dat$species == auc$species[i],]$bestModel+1
}

nparam = dat %>% group_by(species) %>% slice(which.min(nparam_median)) 
table(nparam$method)

for (i in 1:nrow(nparam)){
  dat[dat$method == nparam$method[i] & dat$species == nparam$species[i],]$bestModel <- 
    dat[dat$method == nparam$method[i] & dat$species == nparam$species[i],]$bestModel+1
}

mae = dat %>% group_by(species) %>% slice(which.min(mae_median)) 
table(mae$method)

for (i in 1:nrow(mae)){
  dat[dat$method == mae$method[i] & dat$species == mae$species[i],]$bestModel <- 
    dat[dat$method == mae$method[i] & dat$species == mae$species[i],]$bestModel+1
}


dat%>%group_by(method)%>%summarise_at(vars(bestModel), list(sum =sum), na.rm=T)

dat%>%dplyr::filter(bestModel==4)%>%group_by(method)%>%count()
dat%>%dplyr::filter(bestModel==3)%>%group_by(method)%>%count()
dat%>%dplyr::filter(bestModel==2)%>%group_by(method)%>%count()
dat%>%dplyr::filter(bestModel==1)%>%group_by(method)%>%count()
dat%>%dplyr::filter(bestModel==0)%>%group_by(method)%>%count()


# best index
dat$bestIndex <- 0

bestIndex = dat %>% group_by(species) %>% slice(which.max(index)) 


for (i in 1:nrow(bestIndex)){
  dat[dat$method == bestIndex$method[i] & dat$species == bestIndex$species[i],]$bestIndex <- 
    dat[dat$method == bestIndex$method[i] & dat$species == bestIndex$species[i],]$bestIndex+1
}
table(bestIndex$method)


dat%>%dplyr::filter(bestIndex==1)%>%group_by(method)%>%count()



# 9 - plot with random species ####
#---------------------------------#

species = unique(dat$species)
sa<- sample(species, 20)
data3=dplyr::filter(dat, species%in%sa)

# auc_mae plot
ggplot2::ggplot(data3, aes(y=auc_median, x=mae_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab(expression("MAE"["PO"]))+ylab(expression("AUC "["PO"]))+
  geom_point(aes(y=auc_median, x=mae_median),size=3,shape=4,colour="black",
             dplyr::filter(data3, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data3,
             mapping = aes(x=0.35, y=min(auc_median),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

#plot boyce
ggplot2::ggplot(data3, aes(y=boyce_median, x=nparam_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab("Number Parameters")+ylab("Boyce-Index")+
  geom_point(aes(y=boyce_median, x=nparam_median),size=3,shape=4,colour="black",
             dplyr::filter(data3, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data3,
             mapping = aes(x=150, y=min(boyce_median),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


# 4 - scale all data and calculate index for plotting
#----------------------------------------------------


ggplot2::ggplot(data3, aes(y=index, x=index, color=method))+
  geom_point(size=3)+
  geom_point(aes(y=index, x=index),size=3,shape=4,colour="black",
             dplyr::filter(data3, npoints_median <= nparam_median))+ scale_colour_viridis_d()+facet_wrap(vars(species))+
  geom_text( size=3,
             data    = data3,
             mapping = aes(x=2.5, y=0.5,label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)




