# install.packages("devtools")
# install_github("land-4-bees/SpeedyBeeModel")
# install.packages("logger")
# install.packages("tidyr")
library(logger); library(tidyr); library(SpeedyBeeModel); library(raster); library(devtools)

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

# plot one to see how it looks
NorthMN2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\North Minnesota_SpeedyBee_2008\\CDL_2008_North Minnesota_insecticide.tif")
plot(NorthMN2008map) # looks good!

##########################################################################
#
#
# NOTE - CODE BELOW THIS POINT WAS FOR COMBINING FILES INTO A SINGLE MAP
# HOWEVER I BELIEVE THIS IS NOT NECESSARY SO THIS CODE CAN BE IGNORED
#
#
##########################################################################

list.files("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008") # seems like it worked??

# we can leverage the above "PseudostateNamesList" to open these and stitch them together

#########################

# Actually I might need to break this into chunks. Here are some chunks:

texaschunk <- c('Northeast Texas', 'North Texas', 'Northcentral Texas', 'Northwest Texas', 'East Texas', 'Central Texas', 'South Texas', 'Southcentral Texas', 'Southeast Texas', 'Southwest Texas')
midwestchunk <- c('North Minnesota', 'South Minnesota', 'Wisconsin', 'North Michigan', 'South Michigan', 'Illinois', 'Indiana', 'Ohio')
centralUSchunk <- c('North Dakota', 'South Dakota', 'Nebraska', 'Kansas', 'Oklahoma', 'Iowa', 'Missouri', 'Arkansas', 'Louisiana', 'Alabama', 'Mississippi')
eastcoastchunk <- c('Tennessee', 'Kentucky', 'North Carolina', 'South Carolina', 'Georgia', 'North Florida', 'South Florida', 'West Virginia', 'Virginia')
newenglandchunk <- c('Maine', 'Vermont', 'New Hampshire', 'Connecticut', 'Massachusetts', 'Rhode Island', 'New York', 'New Jersey', 'Delaware', 'District of Columbia', 'Pennsylvania') #Maryland is base


#################
# for loop - New England Chunk

# make one map to start the loop
compiledmap1 <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\Maryland_SpeedyBee_2008\\CDL_2008_Maryland_insecticide.tif")
plot(compiledmap1)

for(ID in newenglandchunk){
  # identify the file
  # ID <- "Pennsylvania"
  rasterpath1 <- paste0("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\", ID, "_SpeedyBee_2008\\CDL_2008_", ID, "_insecticide.tif")
  newraster1 <- raster(rasterpath1)
  compiledmap1 <- raster::mosaic(compiledmap1, newraster1, fun = sum) # add new raster to larger raster
}
# export
writeRaster(compiledmap1, "E:\\FireflyAnalysis_October2020\\regional_pesticide_maps\\NewEnglandChunk2008insecticides.tif")

