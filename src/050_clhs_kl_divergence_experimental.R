# Script for determining the optimal number of samples to take using conditioned latin hypercube sampling.
# Given a suite of covariates this algorithm will assess an optimal number of samples based on a number of metrics.
# The metrics include:
# 1. Percentage of gird points within sample PC space
# 2. Principal component similarity
# 3. Quantile similarity
# 4. KL Divergence


######
# Note that in manuscript only the KL divergence is reported
# The follow script for each incremental sample size, the sample is repeat 10 times.
# We do this to look at the dispersion of the results resulting from different sample configurations of the same sample size
######


library(raster);library(rgdal);library(tripack);library(SDMTools); library(manipulate);library(clhs);library(entropy)
####################################################################
# Data analysis for the population data



#Quantiles of the population (this is for test 3)
# Number of bins
nb<- 25

# raster to df
df=na.omit(as.data.frame(raster::values(r)))


#quantile matrix (of the covariate data)
q.mat<- matrix(NA, nrow=(nb+1), ncol= ncol(df)) # ncol beacause 4 variables ???
 j=1
for (i in 1:ncol(df)){ #note the index start here
  #get a quantile matrix together of the covariates
  ran1<- max(df[,i]) - min(df[,i])
  step1<- ran1/nb 
  q.mat[,j]<- seq(min(df[,i]), to = max(df[,i]), by =step1)
  j<- j+1}
q.mat



#covariate data hypercube (this is for test 4)
## This takes a while to do so only do it once if you can 

cov.mat<- matrix(1, nrow=nb, ncol=ncol(df))
for (i in 1:nrow(df)){ # the number of pixels
  cntj<- 1 
  for (j in 1:ncol(df)){ #for each column
    dd<- df[i,j]  
    for (k in 1:nb){  #for each quantile
      kl<- q.mat[k, cntj] 
      ku<- q.mat[k+1, cntj] 
      if (dd >= kl & dd <= ku){cov.mat[k, cntj]<- cov.mat[k, cntj] + 1} 
    }
    cntj<- cntj+1
  }
}

cov.mat
####################################################################





#######################################################################
#How many samples do we need?
#beginning of algorithm

#initial settings
#cseq<- seq(10,500,10) # cLHC sample size
cseq=c(100,500,1000,10000,50000,100000)
its<-3  # number internal iterations with each sample size number
mat.seq<- matrix(NA,ncol=8,nrow=length(cseq)) #empty matix for outputs


for (w in 1:length(cseq)){ # for every sample number configuration....
  s.size=cseq[w]  # sample size
  mat.f<- matrix(NA,ncol=8,nrow=its ) # placement for iteration outputs
  
  #internal loop
  for (j in 1:its){ #Note that this takes quite a while to run to completion
    repeat{
      ss <-clhs:: clhs(r, size = s.size, progress = T,simple=F,use.coords = T) # Do a conditioned latin hypercube sample
      s.df<- ss$sampled_data
      s.df=sf::st_as_sf(s.df)
        
        
      if (sum(duplicated(s.df) | duplicated(s.df[nrow(s.df):1, ])[nrow(s.df):1]) < 2)
      {break}}
    
    
    
    
    
    ## Fourth test: Kullback-Leibler (KL) divergence
    ####Compare whole study area covariate space with the slected sample
    #sample data hypercube (essentially the same script as for the grid data but just doing it on the sample data)
    h.mat<- matrix(1, nrow=nb, ncol=ncol(df))
    
    
    s.df=as.data.frame(s.df)
    s.df$geometry<-NULL
   # s.df$ID=1:nrow(s.df)
    #s.df=as.matrix(s.df)
    
    for (ii in 1:nrow(s.df)){ # the number of observations
      cntj<- 1 
      for (jj in 1:(ncol(s.df))){ #for each column
        dd<- s.df[ii,jj]  
        for (kk in 1:nb){  #for each quantile
          kl<- q.mat[kk, cntj] 
          ku<- q.mat[kk+1, cntj] 
          if (dd >= kl & dd <= ku){h.mat[kk, cntj]<- h.mat[kk, cntj] + 1}
        }
        cntj<- cntj+1}}
    
    #h.mat 
    #Kullback-Leibler (KL) divergence
    klo.1<- entropy::KL.empirical(c(cov.mat[,1]), c(h.mat[,1])) #1
    klo.2<- entropy::KL.empirical(c(cov.mat[,2]), c(h.mat[,2])) #2
    klo.3<- entropy::KL.empirical(c(cov.mat[,3]), c(h.mat[,3])) #3
    klo.4<- entropy::KL.empirical(c(cov.mat[,4]), c(h.mat[,4])) #4
    klo.5<- entropy::KL.empirical(c(cov.mat[,5]), c(h.mat[,5])) #5
    klo.6<- entropy::KL.empirical(c(cov.mat[,6]), c(h.mat[,6])) #6
    klo.7<- entropy::KL.empirical(c(cov.mat[,7]), c(h.mat[,7])) #7
    klo.8<- entropy::KL.empirical(c(cov.mat[,8]), c(h.mat[,8])) #8
    klo.9<- entropy::KL.empirical(c(cov.mat[,9]), c(h.mat[,9])) #9
    klo.10<- entropy::KL.empirical(c(cov.mat[,10]), c(h.mat[,10])) #10
    klo.11<- entropy::KL.empirical(c(cov.mat[,11]), c(h.mat[,11])) #11
    
    
    
    klo<- mean(c(klo.1, klo.2,klo.3,klo.4,klo.5,klo.6,klo.7,klo.8,klo.9,klo.10,klo.11))
    mat.f[j,8]<- klo  # value of 0 means no divergence
  } 
  
  
  #arrange outputs
  mat.seq[w,1]<-mean(mat.f[,6])
  mat.seq[w,2]<-sd(mat.f[,6])
  mat.seq[w,3]<-min(mat.f[,1])
  mat.seq[w,4]<-max(mat.f[,1])
  mat.seq[w,5]<-mean(mat.f[,7])
  mat.seq[w,6]<-sd(mat.f[,7])
  mat.seq[w,7]<-mean(mat.f[,8])
  mat.seq[w,8]<-sd(mat.f[,8])} ## END of LOOP

dat.seq<- as.data.frame(cbind(cseq,mat.seq))
names(dat.seq)<- c("samp_nos", "mean_dist","sd_dist", "min_S", "max_S", "mean_PIP","sd_PIP", "mean_KL","sd_KL")
##########################################################



#######################################################  
#plot some outputs
plot(cseq,mat.seq[,1], xlab="number of samples", ylab= "similarity between covariates (entire field) with covariates (sample)",main="Population and sample similarity")
plot(cseq,mat.seq[,2],xlab="number of samples", ylab= "standard deviation similarity between covariates (entire field) with covariates (sample)",main="Population and sample similarity (sd)")
plot(cseq,mat.seq[,3])
plot(cseq,mat.seq[,4])
plot(cseq,mat.seq[,5],xlab="number of samples", ylab= "percentage of total covariate variance of population account for in sample",main="Population and sample similarity")
plot(cseq,mat.seq[,6],xlab="number of samples", ylab= "standard deviation of percentage of total covariate variance of population account for in sample",main="Population and sample similarity")
plot(cseq,mat.seq[,7],xlab="number of samples", ylab= "KL divergence")
plot(cseq,mat.seq[,8],xlab="number of samples", ylab= "standard deviation of percentage of total covariate variance of population account for in sample",main="Population and sample similarity")
write.table(dat.seq, "Nav_datseq_clHC.txt", col.names=T, row.names=FALSE, sep=",")  # Save output to text file
##########################################################



##########################################################
# make an exponetial decay function (of the KL divergence)
x<- dat.seq$samp_nos
y = 1- (dat.seq$mean_PIP-min(dat.seq$mean_PIP))/(max(dat.seq$mean_PIP)-min(dat.seq$mean_PIP)) #PIP


#Parametise Exponential decay function
plot(x, y, xlab="sample number", ylab= "1 - PC similarity")          # Initial plot of the data
start <- list()     # Initialize an empty list for the starting values

#fit 1
manipulate(
  {
    plot(x, y)
    k <- kk; b0 <- b00; b1 <- b10
    curve(k*exp(-b1*x) + b0, add=TRUE)
    start <<- list(k=k, b0=b0, b1=b1)
  },
  kk=slider(0, 5, step = 0.01,  initial = 2),
  b10=slider(0, 1, step = 0.000001, initial = 0.01),
  b00=slider(0,1 , step=0.000001,initial= 0.01))

fit1 <- nls(y ~ k*exp(-b1*x) + b0, start = start)
summary(fit1) 
lines(x, fitted(fit1), col="red")


### Not used ###
#double exponential
#start <- list()
#manipulate(
#{
#  plot(x, y)
#  k <- kk; b0 <- b00; b1 <- b10; b2 <- b20
#  curve(k*(exp(-b1*x) + exp(-b2*x)) + b0, add=TRUE)
#  start <<- list(k=k, b0=b0, b1=b1, b2 = b2)
#},
#kk=slider(0, 5, step = 0.01,  initial = 1),
#b10=slider(0, 0.1, step = 0.000001, initial = 0.001),
#b20 = slider(0, 0.1, step = 0.00001, initial = 0.05),
#b00=slider(0,0.8 , step=0.00001,initial= 0.3))

#fit2 <- nls(y ~ k*(exp(-b1*x) + exp(-b2*x)) + b0, start = start, nls.control(maxiter = 1000))
#summary(fit2)
#lines(x, fitted(fit2), col="red")
#anova(fit1, fit2) 
### NOT USED ###
##############################################################################


#############################################################################
#Apply fit
xx<- seq(1, 500,1)
lines(xx, predict(fit1,list(x=xx)))

jj<- predict(fit1,list(x=xx))
normalized = 1- (jj-min(jj))/(max(jj)-min(jj))

x<- xx
y<- normalized

plot(x, y, xlab="sample number", ylab= "normalised PIP", type="l", lwd=2)          # Initial plot of the data

x1<- c(-1, 500); y1<- c(0.95, 0.95)
lines(x1,y1, lwd=2, col="red")

x2<- c(119, 119); y2<- c(0, 1)
lines(x2,y2, lwd=2, col="red")
#############################################################################

##END






