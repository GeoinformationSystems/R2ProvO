#---- Load required packages
if (!require("raster")) install.packages("raster")
library("raster")
if (!require("rgdal")) install.packages("rgdal")
library("rgdal")

# get data
poll_url <- "https://geokur-dmp.geo.tu-dresden.de/dataset/1383628b-633b-401d-9277-977b90fc83a0/resource/eeecaa00-4da4-4022-9ae6-8a7849e9d5c1/download/3b_visitprob.tif"
pollination <- raster(poll_url)

rapeseed_url <- "https://geokur-dmp.geo.tu-dresden.de/dataset/6f99ba93-ad5a-4841-9b56-fa4edda9f3b9/resource/945acf8d-925f-44c5-8f45-4b6354f1734d/download/rapeseed_yieldperhectare.tif"
yieldRapeseed <- raster(rapeseed_url)

# project raster
pollinationProj <- projectRaster(pollination, crs = "+proj=longlat +datum=WGS84 +no_defs")

# resample to 5 arcmin
pollinationRes <- resample(pollinationProj, yieldRapeseed)

# raster to DFs
yieldRapeseed_df <- as.data.frame(yieldRapeseed)
pollinationRes_df <- as.data.frame(pollinationRes)


# combine pollination and yield data in common table
outputTable <- cbind(yieldRapeseed_df, pollinationRes_df)
names(outputTable) <- c("yieldRapeseed", "pollination")

# remove 0 yields and NAs
outputTableFinal <- outputTable[which(outputTable$yieldRapeseed > 0 & !is.na(outputTable$pollination)), ]

write.csv(outputTableFinal, "myOutputTable.csv")