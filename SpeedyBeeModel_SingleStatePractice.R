# install.packages("devtools")
# install_github("land-4-bees/SpeedyBeeModel")
library(SpeedyBeeModel)
library(raster)
library(devtools)

# read in the reclass table
ReclassTableDir1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table") # location of reclass table
ReclassTablePath1 <- paste0(ReclassTableDir1, "\\beetox_I_cdl_reclass_20200717.csv") # name of reclass table
ReclassTable1 <- read.csv(ReclassTablePath1) # read in reclass table

# subset reclass table for Oklahoma
OK2008_reclasstable <- subset(ReclassTable1, state_alpha == "OK" & year == "2008") # subset table for focal state/year

# export the subsetted reclass table
write.csv(OK2008_reclasstable, paste0(ReclassTableDir1, "\\OK2008.csv"))

# define path to CDL raster file
OK_cdl2008path <- "E:\\FireflyAnalysis_October2020\\CDL_individual\\2008\\CDL_2008_Oklahoma.tif"
plot(raster(OK_cdl2008path))

#####################################################
# convert the CDL to pest map by the subsetted table (via SpeedyBeeModel)
#####################################################

# install.packages("logger")
install.packages("tidyr")
library(logger)
library(tidyr)

SpeedyBeeModel::insecticide_index(
  output_dir = "E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\OK2008", # output loc
  pesticide_path = paste0(ReclassTableDir1, "\\OK2008.csv"), # path to pesticide FILTERED reclass table
  landcover_path = OK_cdl2008path, # path to each landcover CDL map
  forage_range = 500, # range in meters
  guild_table = NA, # No define guild table - not running multi-species stuff
  ins_method = "mean", # mean is default; could do oral/contact or whatev
  agg_factor = NA,
  normalize = F,
  check_pesttable = F # leave useW, and rastertag as default
)

# Did it work??

ok2008map <- raster("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008\\OK2008\\CDL_2008_Oklahoma_insecticide.tif")
plot(ok2008map)
