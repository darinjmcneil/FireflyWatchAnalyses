# install.packages("devtools")
# install_github("land-4-bees/SpeedyBeeModel")
# install.packages("logger")
# install.packages("tidyr")
library(logger)
library(tidyr)
library(SpeedyBeeModel)
library(raster)
library(devtools)

# read in the reclass table
ReclassTableDir1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table") # location of reclass table
ReclassTablePath1 <- paste0(ReclassTableDir1, "\\beetox_I_cdl_reclass_20200717.csv") # name of reclass table
ReclassTable1 <- read.csv(ReclassTablePath1) # read in reclass table

# generate list of pseudostates
PathToCDLRasters <- "E:\\FireflyAnalysis_October2020\\CDL_individual_pseudostates\\2008"
PseudostateNames <- data.frame(list.files(PathToCDLRasters, pattern = "\\.tif$")) # read all the files for 2008
names(PseudostateNames) <- c("ID") # add column header

PseudostateNames[] <- lapply(PseudostateNames, gsub, pattern = "CDL_2008_", replacement = "", fixed = TRUE) # tidy the names
PseudostateNames[] <- lapply(PseudostateNames, gsub, pattern = ".tif", replacement = "", fixed = TRUE) # tidy the names

"state_alpha" = c("AL", "AR", "TX", "CT", "DE", "DC", "TX", "GA", "IL", "IN",
                  "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MS", "MO", "NE",
                  "NH", "NJ", "NY", "NC", "ND", "FL", "MI", "MN", "TX", "TX",
                  "TX", "TX", "OH", "OK", "PA", "RI", "SC", "SD", "FL", "MI",
                  "MN", "TX", "TX", "TX", "TX", "TN", "VT", "VA", "WV", "WI")

PseudostateNames$state_alpha <- state_alpha

#### Items beyond this point in the code should be incorporated into for() loop
######################################################

ReclassTableDir1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table") # location of 'big' reclass table
PseudostateNamesList <- PseudostateNames$ID

for(ID in PseudostateNamesList){
 
  # ID <- "East Texas" # for troubleshooting
  
  # create and export the subsetted reclass table
  FocalYear = "2008"
  PseudostateAlpha <- PseudostateNames[PseudostateNames$ID == PseudostateID, 2]
  FocalPseudostate_ReclassTable <- subset(ReclassTable1, state_alpha == PseudostateAlpha & year == FocalYear)
  FocalPseudostate_ReclassTable_Path <- paste0(ReclassTableDir1, "\\", ID, FocalYear, ".csv") # this is where I'll save the new table
  write.csv(FocalPseudostate_ReclassTable, FocalPseudostate_ReclassTable_Path)
  
  # define path to the cropland data layer for focal pseudostate
  Focal_cdlpath <- paste0("E:\\FireflyAnalysis_October2020\\CDL_individual_pseudostates\\2008\\CDL_2008_", ID, ".tif")
  
  # define the path where the new pesticide map will go after SpeedyBeeModel is done
  FocalOutputDIr <- paste0("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\", ID, "_SpeedyBee_", FocalYear)
  
  # Run the speedy bee model on the focal pseudostate
  SpeedyBeeModel::insecticide_index(
    output_dir =  FocalOutputDIr, # output loc
    pesticide_path =  FocalPseudostate_ReclassTable_Path, # path to pesticide FILTERED reclass table
    landcover_path = Focal_cdlpath, # path to each landcover CDL map
    forage_range = 500, # range in meters
    guild_table = NA, # No define guild table - not running multi-species stuff
    ins_method = "mean", # mean is default; could do oral/contact or whatev
    agg_factor = NA,
    normalize = F,
    check_pesttable = F # leave useW, and rastertag as default
  )
  
  # mapping for troubleshooting purposes
  # SpeedyBeeOutput <- raster(paste0(FocalOutputDIr, "\\CDL_2008_East Texas_insecticide.tif"))
  # plot(SpeedyBeeOutput)
  
}

# Did it work??

list.files("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008") # seems like it worked??

# plot one for practice
NorthMN2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\North Minnesota_SpeedyBee_2008\\CDL_2008_North Minnesota_insecticide.tif")
plot(NorthMN2008map)

## Working on combining them

SouthMN2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\South Minnesota_SpeedyBee_2008\\CDL_2008_South Minnesota_insecticide.tif")
plot(SouthMN2008map)

AllMN2008map <- raster::mosaic(NorthMN2008map, SouthMN2008map, fun = sum)
plot(AllMN2008map)

library(sf)
us_states1 <- st_read("E:\\FireflyAnalysis_October2020\\states\\us_states.shp") #  read shapefile of US states
us_states1 <- sf::st_transform(us_states1, crs = crs(AllMN2008map))
plot(us_states1$geometry, add = TRUE)

NorthMI2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\North Michigan_SpeedyBee_2008\\CDL_2008_North Michigan_insecticide.tif")
SouthMI2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\South Michigan_SpeedyBee_2008\\CDL_2008_South Michigan_insecticide.tif")
WI2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\Wisconsin_SpeedyBee_2008\\CDL_2008_Wisconsin_insecticide.tif")

AllGreatLakes2008map <- raster::mosaic(AllMN2008map, NorthMI2008map, fun = sum) # add UP
AllGreatLakes2008map <- raster::mosaic(AllGreatLakes2008map, SouthMI2008map, fun = sum) # add LP
AllGreatLakes2008map <- raster::mosaic(AllGreatLakes2008map, WI2008map, fun = sum) # add WI
plot(AllGreatLakes2008map)
plot(us_states1$geometry, add = TRUE) 
