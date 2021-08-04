if (!require("devtools")) install.packages("devtools")
library("devtools")

# ---------------------------------------

# prospective provenance describes the generation of provenance without actually
# executing the described processing steps.
# e.g. workflows that are sketched before implementation can be considered
# prospective provenance.
# by removing the 'eval()'' part from 'eval(prov(quote(...)))'', r2provo can be used
# to generate prospective provenance graphs.

init_prov()

# project raster
prov(quote(
    pollinationProj <- projectRaster(pollination, crs = "+proj=longlat +datum=WGS84 +no_defs")
))

# resample to 5 arcmin
prov(quote(
    pollinationRes <- resample(pollinationProj, yieldRapeseed)
))

# combine pollination and yield data  to table
prov(quote(
    outputTable <- cbind(yieldRapeseed, pollinationRes)
))

# rm zeros and na
prov(quote(
    finalTable <- cleanTable(outputTable)
))

store_prov("use_case_prospective.ttl")