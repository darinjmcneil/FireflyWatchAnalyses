install.packages("devtools")
library(devtools)
# install.packages("RTools") # Not availbale for R version 4.0.2...?
# need to download from here: https://cran.r-project.org/bin/windows/Rtools/
# maybe those aren't needed?

install_github("land-4-bees/SpeedyBeeModel")
library(SpeedyBeeModel)

# working directory
setwd("D:\\Desktop Files November 2019\\fireflies\\insecticide_code")

library(raster)
# Memory problems -- give R a bit more memory # not sure if this is necessary
# rasterOptions(memfrac=0.8, tmptime=4)

# read in the reclass table
ReclassTablePath1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table\\beetox_I_cdl_reclass_20200717.csv")
ReclassTable1 <- read.csv(ReclassTablePath1)
head(ReclassTable1)

# filter recalss table for focal year/state
# Filter reclass table AND export
# grab path to filtered table
# NOTE - Mel is going to try and tweak insecticide_index so it accepts an R object
# instead of a pathway :-)

OK2008_reclasstable <- subset(ReclassTable1, state_alpha == "OK" & year == "2008") # subset table for focal state/year
head(OK2008_reclasstable)
ReclassTableDir1 <-("E:\\FireflyAnalysis_October2020\\insecticide_reclass_table\\beetox_I_cdl_reclass_20200717")
write.csv(OK2008_reclasstable, paste0(ReclassTableDir1, "\\OK2008.csv")) # Mel is a GD genius!

# define path to CDL raster file
OK_cdl2008path <- "E:\\FireflyAnalysis_October2020\\CDL_individual\2008\\CDL_2008_Oklahoma.tif"

#####################################################
# convert the CDL to pest map by the subsetted table (via SpeedyBeeModel)
#####################################################

# Yes set foraging range

# also see ?insecticide_index !!

SpeedyBeeModel::insecticide_index(
  output_dir = "E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\2008", # output loc
  pesticide_path = paste0(ReclassTableDir1, "\\OK2008.csv"), # path to pesticide FILTERED reclass table
  landcover_path = OK_cdl2008path, # path to each landcover CDL map
  forage_range = 500, # range in meters
  guild_table = NA, # No define guild table - not running multi-species stuff
  ins_method = "mean", # mean is default; could do oral/contact or whatev
  agg_factor = NA,
  normalize = F,
  check_pesttable = F # leave useW, and rastertag as default
)

# This fails on large states (ME) but works for smaller states (RI). Error says:
# Error: cannot allocate vector of size 3.0 Gb



