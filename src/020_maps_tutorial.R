.libPaths("C:/Users/dogbert/")


CAN=sf::read_sf("D:/maxent/SDM_NCEAS/data/Borders/can.gpkg")

mapview::mapview(CAN)

# spatial blocks
can01=df_4326
spatialBlocks=sb$blocks
mapview::mapview(spatialBlocks, zcol ="folds")+can01


can01 <- sf::read_sf("D:/maxentTutorial/data/samples/can01/can01.gpkg")

mapview::mapview(can01)


spatial=raster::stack("D:/maxentTutorial/data/output/can01/can01_01/spatial/final/can01_layers.asc")
raster::crs(spatial) <- "+proj=longlat +ellps=clrk66 +no_defs +type=crs"

spatial=spatial$layer
mapview::mapview(spatial)



default=raster::raster("D:/maxentTutorial/data/output/can01/can01_01/default/final/can01_layers.asc")
raster::crs(default) <- "+proj=longlat +ellps=clrk66 +no_defs +type=crs"


mapview::mapview(default)
