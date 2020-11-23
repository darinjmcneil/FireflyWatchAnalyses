#################################################
# CUTTING CROPLAND DATA LAYER INTO CHUNKS
#################################################
# The purpose of this code is to:
# Read in the CDL for a given year
# Read in a shapefile of US States
# Overlap the two spatial objects to confirm they align


# install.packages("dplyr")
# install.packages("sf")

library(raster)

# opening and mapping CDL
# qGIS calles the .img extension "Disc Image File"

cdl_2008 <- raster("E:\\FireflyAnalysis_October2020\\CDL_rasters\\2008_30m_cdls\\2008_30m_cdls.img")
crs(cdl_2008)

# CRS arguments:
#  +proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0
#  +units=m +no_defs 

plot(cdl_2008, main="CDL 2008") # this mapped super fast 

# Ok now time to add the state boundaries

library(sf)

us_states1 <- st_read("E:\\FireflyAnalysis_October2020\\states\\us_states.shp") #  read shapefile of US states

crs(us_states1)
# CRS arguments: +proj=longlat +datum=WGS84 +no_defs 

# reproject the shapefile to match the CDL raster
us_states1 <- sf::st_transform(us_states1, crs = crs(cdl_2008))

plot(cdl_2008)
plot(us_states1$geometry, add = TRUE) # they look good!

##################

# Next, in prep for doing the for() loop, process all the state names

# first I need a list of all the states in the FFwatch Dataset
FFWdata <- read.csv("E:\\FireflyAnalysis_October2020\\firefly_data_cleaned_march2020.csv")
unique(FFWdata$state)

# This code is for testing
# StateShape = subset(us_states1, name == "Alabama") # extract a single polygon
# plot(StateShape$geometry) # plot state outline

#

# renaming states from abbreviations to long form
level_key <- c("MA" = "Massachusetts", 
               "RI" = "Rhode Island", 
               "ME" = "Maine",
               "NH" = "New Hampshire",
               "FL" = "Florida",
               "IL" = "Illinois", 
               "CT" = "Connecticut", 
               "NC" = "North Carolina",
               "NY" = "New York",
               "IN" = "Indiana",
               "PA" = "Pennsylvania", 
               "MD" = "Maryland", 
               "VA" = "Virginia",
               "VT" = "Vermont",
               "SC" = "South Carolina",
               "OH" = "Ohio", 
               "MI" = "Michigan", 
               "GA" = "Georgia",
               "LA" = "Louisiana",
               "WI" = "Wisconsin",
               "MO" = "Missouri", 
               "MN" = "Minnesota", 
               "KS" = "Kansas",
               "OK" = "Oklahoma",
               "MS" = "Mississippi",
               "TN" = "Tennessee", 
               "KY" = "Kentucky", 
               "DC" = "District of Columbia",
               "NE" = "Nebraska",
               "NJ" = "New Jersey",
               "SD" = "South Dakota",
               "AR" = "Arkansas",
               "WV" = "West Virginia", 
               "DE" = "Delaware", 
               "TX" = "Texas",
               "IA" = "Iowa",
               "AL" = "Alabama")

library(dplyr)
FFWdata$state <- recode(FFWdata$state, !!!level_key) # re-code using new state names

print(unique(FFWdata$state)) # looks good
FocalStateNames <- unique(FFWdata$state) # looks good

# Ok now we are ready to construct the actual for() loop

CDLraster <- cdl_2008
year <- 2008

for(StateName in FocalStateNames){
  
  # StateName <- "West Virginia" # for troubleshooting purposes
  
  StateBoundary <- subset(us_states1, name == StateName) # extract state boundary polygon
  CroppedCDL <- crop(CDLraster, StateBoundary) # crop CDL using state boundary polygon
  MaskedCDL <- raster::mask(CroppedCDL, StateBoundary) # mask cropped CDL using state bounds
  PathToFolder <- ("I:\\FireflyAnalysis_October2020\\CDL_individual\\2008\\") # this needs to be tweaked for each year
  TifName <- paste0("CDL_", year, "_", StateName, ".tif")
  writeRaster(MaskedCDL, paste0(PathToFolder, TifName))
  
  # StateOutput <- raster(paste0(PathToFolder, TifName)) # for troubleshooting purposes
  # plot(StateOutput) # for troubleshooting purposes

}

##########################################################################################

# IDK why but the for() loop only captured the first 35 states

FocalStateNames2 <- FocalStateNames[36:37] # looks good

# Ok now we are ready to construct the actual for() loop

CDLraster <- cdl_2008
year <- 2008

for(StateName in FocalStateNames2){
  
  # StateName <- "West Virginia" # for troubleshooting purposes
  
  StateBoundary <- subset(us_states1, name == StateName) # extract state boundary polygon
  CroppedCDL <- crop(CDLraster, StateBoundary) # crop CDL using state boundary polygon
  MaskedCDL <- raster::mask(CroppedCDL, StateBoundary) # mask cropped CDL using state bounds
  PathToFolder <- ("C:\\Users\\Doug\\Desktop\\FireflyAnalysis_October2020\\CDL_individual\\2008\\") # this needs to be tweaked for each year
  TifName <- paste0("CDL_", year, "_", StateName, ".tif")
  writeRaster(MaskedCDL, paste0(PathToFolder, TifName))
  
  # StateOutput <- raster(paste0(PathToFolder, TifName)) # for troubleshooting purposes
  # plot(StateOutput) # for troubleshooting purposes
  
}