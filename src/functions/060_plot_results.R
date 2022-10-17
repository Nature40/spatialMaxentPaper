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


ggplot2::ggplot(data, aes(y=auc_median, x=mae_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab(expression("MAE"["PO"]))+ylab(expression("AUC "["PO"]))+
  geom_point(aes(y=auc_median, x=mae_median),size=3,shape=4,colour="black",
             dplyr::filter(data, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data,
             mapping = aes(x=0.43, y=0.4,label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# 3 - plot boyce index with number parameters
#--------------------------------------------

ggplot2::ggplot(data, aes(y=boyce_median, x=nparam_median, color=method))+
  geom_point(size=3)+#geom_point(aes(y=boyce_median, x=mae_median, color=method), size=3, shape=17)+
  scale_x_reverse()+facet_wrap(vars(species))+xlab("Number Parameters")+ylab("Boyce-Index")+
  geom_point(aes(y=boyce_median, x=nparam_median),size=3,shape=4,colour="black",
             dplyr::filter(data, npoints_median <= nparam_median))+
  # add text for number of points
  geom_text( size=3,
             data    = data,
             mapping = aes(x=50, y=min(boyce_median),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)+
  scale_colour_viridis_d()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


# 4 - scale all data and calculate index for plotting
#----------------------------------------------------

data$index=data$auc_scaled+data$boyce_scaled+data$nparam_scaled+data$mae_scaled


ggplot2::ggplot(data, aes(y=index, x=index, color=method))+
  geom_point(size=3)+
  geom_point(aes(y=index, x=index),size=3,shape=4,colour="black",
             dplyr::filter(data, npoints_median <= nparam_median))+ scale_colour_viridis_d()+facet_wrap(vars(species))+
  geom_text( size=3,
             data    = data,
             mapping = aes(x=3, y=min(index),label = label),
             colour="black",
             hjust   = -0.1,
             vjust   = -1)

# 5 - data for histogram best metrics
#--------------------------------------

setwd("D:/maxent/shredder/output/")
listFiles = list.files(pattern = "_results_all_folds.csv", recursive=T)

res = lapply(1:length(listFiles),  function(i){
  x= read.csv(listFiles[i])
  return(x)})
dat = do.call(rbind, res)  

# for poster
dat=dat[dat$method != "tuned1",]


boyce = dat %>% group_by(species) %>% slice(which.max(boyce_median)) 
auc = dat %>% group_by(species) %>% slice(which.max(auc_median)) 
nparam = dat %>% group_by(species) %>% slice(which.min(nparam_median)) 
mae = dat %>% group_by(species) %>% slice(which.min(mae_median)) 

results=data.frame(method=as.data.frame(table(auc$method))$Var1,
                   auc=as.data.frame(table(auc$method))$Freq, mae=as.data.frame(table(mae$method))$Freq, 
                   boyce=as.data.frame(table(boyce$method))$Freq)
results$nparam<-0
results$nparam[[1]] <- as.data.frame(table(nparam$method))$Freq

write.csv(results, "count_best_method.csv")



dat$species_method <- paste0(dat$species, "_",dat$method)

dat$auc_difference <- abs(dat$auc_test_median - dat$auc_median)

# Plot poster index

dat[dat$method %in% c("standard", "tuned1", "tuned2"),]$label <- NA
dat$boyce_scaled=scales::rescale(dat$boyce_median,to=c(0,1))
dat$auc_scaled=scales::rescale(dat$boyce_median,to=c(0,1))
dat$mae_scaled=1-scales::rescale(dat$mae_median, to=c(0,1))
dat$nparam_scaled <- 1-scales::rescale(dat$nparam_median, to=c(0,1))


dat$index=dat$auc_scaled+dat$boyce_scaled+dat$nparam_scaled+dat$mae_scaled
index = dat %>% group_by(species) %>% slice(which.max(index)) 

table(index$method)


#----------------------------------

dat[dat$method == "standard",]$method <-"default"

ggplot(dat, aes(x=method, y=auc_difference, fill=method)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  #geom_jitter(color="black", size=0.4, alpha=0.9)+
  xlab("Method")+ylab(paste0("Difference Maxent test AUC & AUC on independent data"))#+
hrbrthemes::theme_ipsum()

dat[dat$method == "tuned2",]$method <-"tuned"
dat[dat$method == "standard",]$method <-"default"
#dat$method <- factor(dat$method, levels = c( "spatial", "default", "tuned",   "tuned1"))
levels(dat$method)<- factor(c( "spatial", "default", "tuned",   "tuned1" ))
# plot for poster
ggplot(dat[dat$method %in% c("spatial","default", "tuned"),], aes(x=method, y=auc_difference, fill=method)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  #geom_jitter(color="black", size=0.4, alpha=0.9)+
  xlab("Method")+ylab(paste0("Difference Maxent test AUC & AUC on independent data"))+
  theme(panel.background = element_rect(fill = "#f2efe9",
                                    colour ="#f2efe9" ))+scale_x_discrete (limits=c( "spatial", "default", "tuned"))

awt01 <-dat[dat$species == "awt01",]
# 6 - violin plot index
#-----------------------



# Most basic violin chart
ggplot(data[data$method %in% c("spatial", "standard", "tuned2"),], aes(x=method, y=index, fill=method)) + # fill=name allow to automatically dedicate a color for each group
  geom_violin() + scale_fill_viridis(discrete = TRUE, alpha=0.6) +
 geom_boxplot(width=0.3, color="black", fill="white", alpha=0.6)+#+theme_ipsum()
  theme(panel.background = element_rect(fill = "#f2efe9",
                                        colour ="#f2efe9" ))
  

# Most basic violin chart
ggplot(data, aes(x=method, y=index, fill=method)) + scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_boxplot()+geom_jitter(color="black", size=0.4, alpha=0.9)+theme_ipsum() 








