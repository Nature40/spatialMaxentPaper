#' Main control script
#'
#' @description Use this script for controlling the processing.
#'
#' @author [Lisa Bald], [bald@staff.uni-marburg.de]
#'
rm(list=ls())

if (Sys.info()[["nodename"]] == "PC19594") {
  root_folder = "D:/Natur40/spatialMaxentPaper/"
}else if(Sys.info()[["nodename"]] == "pc19543"){
  root_folder = "/home/bald/casestudies/spatialMaxentPaper/"
}else {
  library(rprojroot)
  root_folder = find_rstudio_root_file()
}
library(envimaR)
source(paste0(root_folder, "src/functions/000_setup.R"))


#---------------------------------
# execute pipeline

