.libPaths("C:/Users/dogbert/")


CAN=sf::read_sf("D:/maxent/SDM_NCEAS/data/Borders/can.gpkg")

mapview::mapview(CAN)

# spatial blocks
can01=df_4326
spatialBlocks=sb$blocks
mapview::mapview(spatialBlocks, zcol ="folds")+can01