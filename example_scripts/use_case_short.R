
#---- Load required packages
if (!require("raster")) install.packages("raster")
library("raster")
if (!require("rgdal")) install.packages("rgdal")
library("rgdal")

if (!require("devtools")) install.packages("devtools")
library("devtools")

# ---------------------------------------
init_prov()

# get data
poll_url <- "https://geokur-dmp.geo.tu-dresden.de/dataset/1383628b-633b-401d-9277-977b90fc83a0/resource/eeecaa00-4da4-4022-9ae6-8a7849e9d5c1/download/3b_visitprob.tif"
pollination <- raster(poll_url)

rapeseed_url <- "https://geokur-dmp.geo.tu-dresden.de/dataset/6f99ba93-ad5a-4841-9b56-fa4edda9f3b9/resource/945acf8d-925f-44c5-8f45-4b6354f1734d/download/rapeseed_yieldperhectare.tif"
yieldRapeseed <- raster(rapeseed_url)


# ########################## DATA PREPROCESSING

# project raster
eval(prov(quote(
    pollinationProj <- projectRaster(pollination, crs = "+proj=longlat +datum=WGS84 +no_defs")
)))

# resample to 5 arcmin
eval(prov(quote(
    pollinationRes <- resample(pollinationProj, yieldRapeseed)
)))

# plot(pollinationRes,xlim=c(-20,50),ylim=c(20,70))
# plot(yieldRapeseed,xlim=c(-20,50),ylim=c(20,70))

yieldRapeseed <- as.data.frame(yieldRapeseed)
pollinationRes <- as.data.frame(pollinationRes)

# combine pollination and yield data  to table
eval(prov(quote(
    outputTable <- cbind(yieldRapeseed, pollinationRes)
)))
names(outputTable) <- c("yieldRapeseed", "pollination")

# if this last step should be stored in the graph it has to be rewritten as a method
# (this of course is not a very meaningful method)
# remove 0 yields and NAs
finalTable <- outputTable[which(outputTable$yieldRapeseed > 0 & !is.na(outputTable$pollination)), ]

# cleanTable <- function(inTable) {
#     return(outputTable[which(inTable$yieldRapeseed > 0 & !is.na(inTable$pollination)), ])
# }
# eval(prov(quote(
#     finalTable <- cleanTable(outputTable)
# )))

store_prov("use_case_short_prov.ttl")
write.csv(finalTable, "finalTable.csv")