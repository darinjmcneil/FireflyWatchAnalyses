#################################################
# CUTTING CROPLAND DATA LAYER INTO CHUNKS
#################################################
# The purpose of this code is to:
# Read in the CDL for a given year
# Read in a shapefile of US PESUDOSTATES*
# Overlap the two spatial objects to confirm they align
# * Pseudostates are mostly just US states, however
# MN, MI, FL, and TX have been chopped into smaller
# chunks, each of which will be handled separately (e.g.,
# MI's upper and lower penninsulas will be separate polygons)


# install.packages("dplyr")
# install.packages("sf")

library(raster)

# opening and mapping CDL
# qGIS calles the .img extension "Disc Image File"

cdl_2012 <- raster("E:\\FireflyAnalysis_October2020\\CDL_rasters\\2012_30m_cdls\\2012_30m_cdls.img")
crs(cdl_2012)

# CRS arguments:
#  +proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0
#  +units=m +no_defs 

plot(cdl_2012, main="CDL 2012") # this mapped super fast 

# Ok now time to add the state boundaries

library(sf)

pseudostates1 <- st_read("E:\\FireflyAnalysis_October2020\\analysis code\\FireflyWatchAnalyses\\data\\pseudostates\\US_PseudostateBoundaries1.shp")
# us_states1 <- st_read("E:\\FireflyAnalysis_October2020\\states\\us_states.shp") #  read shapefile of US states

# reproject the shapefile to match the CDL raster
pseudostates1 <- sf::st_transform(pseudostates1, crs = crs(cdl_2012))

plot(cdl_2012)
plot(pseudostates1$geometry, add = TRUE) # they look good!

##################

# Next, in prep for doing the for() loop, process all the state names

# first I need a list of all the states in the FFwatch Dataset

print(unique(pseudostates1$StateName)) # looks good but has extra states in the west

FocalStateNames <- unique(unique(pseudostates1$StateName)) # all states
FocalStateNames <- data.frame(FocalStateNames) # convert to data frame
names(FocalStateNames) <- "StateName" # name column header

# get rid of states outside the study
FocalStateNames1 <- FocalStateNames[!(FocalStateNames$StateName == "Wyoming" |
                                       FocalStateNames$StateName == "Washington" |
                                       FocalStateNames$StateName == "Utah" |
                                       FocalStateNames$StateName == "New Mexico" |
                                       FocalStateNames$StateName == "Nevada" |
                                       FocalStateNames$StateName == "Idaho" |
                                       FocalStateNames$StateName == "Hawaii" | 
                                       FocalStateNames$StateName == "Colorado" |
                                       FocalStateNames$StateName == "California" |
                                       FocalStateNames$StateName == "Arizona" |
                                       FocalStateNames$StateName == "Oregon" |
                                       FocalStateNames$StateName == "Montana"),]

# View(FocalStateNames1) # looks good

# Ok now we are ready to construct the actual for() loop

CDLraster <- cdl_2012
year <- 2012

for(PseudostateName in FocalStateNames1){
  
  #PseudostateName <- "West Virginia" # for troubleshooting purposes
  
  StateBoundary <- subset(pseudostates1, StateName == PseudostateName) # extract state boundary polygon
  CroppedCDL <- crop(CDLraster, StateBoundary) # crop CDL using state boundary polygon
  MaskedCDL <- raster::mask(CroppedCDL, StateBoundary) # mask cropped CDL using state bounds
  PathToFolder <- ("E:\\FireflyAnalysis_October2020\\CDL_individual_pseudostates\\2012\\") # this needs to be tweaked for each year
  TifName <- paste0("CDL_", year, "_", PseudostateName, ".tif")
  writeRaster(MaskedCDL, paste0(PathToFolder, TifName))
  
  # StateOutput <- raster(paste0(PathToFolder, TifName)) # for troubleshooting purposes
  # plot(StateOutput) # for troubleshooting purposes

}

