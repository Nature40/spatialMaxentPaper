#
# CONDITIONED LATION HYPERCUBE SAMLING WITH KL-DIVERGENCE FOR OPTIMAL SAMPLING SIZE AS IN MALONE ET AL. 2019 doi: 10.7717/peerj.6451
#



#
# create 10000 background points for each raster ans use conditioned latin hypercube sampling to 
# distribute points in the best possible way into space
#

# 1 - load libraries ####
#-----------------------#
library(sf)
library(clhs)
library(raster)
library(entropy)

setwd("D:/maxent/shredder/layer/")

regions = list.dirs(full.names = F, recursive=F)


# 2 - load raster ####
#--------------------#

#for(i in 1:length(regions)){
  
  #load raster
  print(regions[i])
  region="CAN"#regions[i]
  epsg=read.table("epsg_layer.txt",sep=";",header=T)
  r = raster::stack(list.files(paste0(region,"/"), full.names=T, pattern=".asc"))
  raster::crs(r) <- epsg[epsg$region==region,]$proj4s
  
  
  # 2 - do CLHS with KL divergence nach telefonbuchprinzip :)
  
  # determine three initial vlaues for CLHS
  
  bg= as.data.frame(raster::values(r))
  bg=na.omit(bg)
  CLHSmin=round(nrow(bg)*0.001,0)
  CLHSmax=round(nrow(bg)*0.01,0)
  CLHSMidi=round(CLHSmax/2,0)
  
  #
  # repeat all of this 10 times?!
  #
  
  # do latin hypercube sampling for 10000 points
  bg_clhsMin=clhs::clhs(r, size=CLHSmin, use.coords = T, simple=F)
  bg_clhsMax=clhs::clhs(r, size=CLHSmax, use.coords = T, simple=F)
  bg_clhsMidi=clhs::clhs(r, size=CLHSMidi, use.coords = T, simple=F)
  
  
 # bg=bg$sampled_data
 # bg=sf::st_as_sf(bg)
 # sf::write_sf(bg, paste0("../background/", region,"_bg.gpkg"))
  
  
  # 3 - KL divergence
  
  
  
  
 entropy::KL.empirical() 
  
  
#}

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
