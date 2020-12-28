library(logger); library(tidyr); library(SpeedyBeeModel); library(raster); library(devtools)

# read in the reclass table
ReclassTableDir1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table") # location of reclass table
ReclassTablePath1 <- paste0(ReclassTableDir1, "\\beetox_I_cdl_reclass_20200717.csv") # name of reclass table
ReclassTable1 <- read.csv(ReclassTablePath1) # read in reclass table

# generate list of pseudostates
PathToCDLRasters <- "E:\\FireflyAnalysis_October2020\\CDL_individual_pseudostates\\2016"
PseudostateNames <- data.frame(list.files(PathToCDLRasters, pattern = "\\.tif$")) # read all the files for 2016
names(PseudostateNames) <- c("ID") # add column header

PseudostateNames[] <- lapply(PseudostateNames, gsub, pattern = "CDL_2016_", replacement = "", fixed = TRUE) # tidy the names
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

for(PseudostateID in PseudostateNamesList){
 
  # PseudostateID <- PseudostateNamesList[3]
  
  # create and export the subsetted reclass table
  FocalYear = "2016"
  PseudostateAlpha <- PseudostateNames[PseudostateNames$ID == PseudostateID, 2]
  FocalPseudostate_ReclassTable <- subset(ReclassTable1, state_alpha == PseudostateAlpha & year == FocalYear)
  FocalPseudostate_ReclassTable_Path <- paste0(ReclassTableDir1, "\\", PseudostateID, FocalYear, ".csv") # this is where I'll save the new table
  write.csv(FocalPseudostate_ReclassTable, FocalPseudostate_ReclassTable_Path)
  
  # define path to the cropland data layer for focal pseudostate
  Focal_cdlpath <- paste0("E:\\FireflyAnalysis_October2020\\CDL_individual_pseudostates\\2016\\CDL_2016_", PseudostateID, ".tif")
  
  # define the path where the new pesticide map will go after SpeedyBeeModel is done
  FocalOutputDIr <- paste0("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2016\\", PseudostateID, "_SpeedyBee_", FocalYear)
  
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
  # SpeedyBeeOutput <- raster(paste0(FocalOutputDIr, "\\CDL_2016_East Texas_insecticide.tif"))
  # plot(SpeedyBeeOutput)
  
}

# Did it work??

list.files("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2016") # seems like it worked??

# plot one to see how it looks
NorthMN2016map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2016\\North Minnesota_SpeedyBee_2016\\CDL_2016_North Minnesota_insecticide.tif")
plot(NorthMN2016map) # looks good!
