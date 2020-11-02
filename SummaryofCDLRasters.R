install.packages("raster")
install.packages("rgdal")
library(raster)
library(rgdal)

maps_path <- "E:\\FireflyAnalysis_October2020\\CDL_individual\\2009"
AllFocalRasters1 <- list.files(maps_path, pattern = '\\.tif$')
SummaryTable <- data.frame("State" = NULL, "Size" = NULL)

for(FocalRaster1 in AllFocalRasters1){
  # FocalRaster1 <- "CDL_2009_Rhode Island.tif" # For troubleshooting
  # FocalRaster1 <- "CDL_2009_Connecticut.tif" # For troubleshooting
  cdl <- raster::raster(paste0(maps_path, "\\", FocalRaster1))
  cellcount <- ncell(cdl) # count number of cells
  newrow <- as.data.frame(cbind("State" = FocalRaster1, "Size" = cellcount))
  SummaryTable <- rbind(SummaryTable, newrow)
  rm(cdl)
  gc()
}

View(SummaryTable)
