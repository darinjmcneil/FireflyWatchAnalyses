# load packages

library(raster); library(rgdal); library(dplyr)

############# Prepare the map of pseudostates

# saving projections/datums for later use
LongLatCRS <-'+init=epsg:4326'

# read in US states shapefile
b0 <- rgdal::readOGR("E:\\FireflyAnalysis_October2020\\analysis code\\FireflyWatchAnalyses\\data\\pseudostates\\US_PseudostateBoundaries1.shp")
b1 <- b0[b0$StateName != 'Hawaii',]
plot(b1) # looks nice!

# check CRS
crs(b1) # CRS arguments: +proj=eqdc +lat_0=40 +lon_0=-96 +lat_1=20 +lat_2=60 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs  

# convert to WGS84
b1 <- spTransform(b1, CRS(LongLatCRS))
plot(b1) # looks great!

########### prepare the map of survey locations

# read in the data
ffdata1 <- read.csv("E:\\FireflyAnalysis_October2020\\analysis code\\FireflyWatchAnalyses\\data\\firefly_data_cleaned_march2020.csv")
names(ffdata1)
names(ffdata1)[names(ffdata1) == "X"] <- "surveyID" # fix the column accidentally called "X"

# turn the lat/long columns into a spatial data frame
FFSiteCoords1 <- data.frame(cbind("long" = ffdata1$long, "lat" = ffdata1$lat)) # identify coords
coordinates(FFSiteCoords1) <- FFSiteCoords1 %>% dplyr::select(long, lat)
crs(FFSiteCoords1) <- CRS(LongLatCRS) # define the coordinate system
plot(FFSiteCoords1, pch = 20, add = TRUE)

############ Extract pseudostates at survey locations

overlay1 <- over(FFSiteCoords1, b1) # extract polygon values
nrow(overlay1) # 24686
nrow(ffdata1) # 24686
ffdata2 <- cbind(ffdata1, "PseudoSt" = overlay1$StateName)

################################################################
################################################################ Prepping for() loop
################################################################

# make empty data frame
df <- data.frame(ID = as.numeric(),
                 PesticideValue = as.numeric(),
                 stringsAsFactors=FALSE)

# establish the list of points
FocalSurveyIDList <- ffdata2$surveyID # 24686 rows

################################################################
################################################################ running for() loop
################################################################ with if() statement
################################################################

for(FocalsurveyID in FocalSurveyIDList){
  
  # FocalsurveyID <- FocalSurveyIDList[77] # for troubleshooting
  
  # check if pesudostate = NA
  FocalPseudostate <- ffdata2[ffdata2$surveyID == FocalsurveyID,]$PseudoSt
  
  # ifelse() statement -- 
  if(is.na(FocalPseudostate) == TRUE){ PestValue = 0 # If pseudstate = NA...
         
         ####################################### if pseudostate is legit
           }else{
           
           # define the pseudostate for the survey ID
           FocalPseudostate <- ffdata2[ffdata2$surveyID == FocalsurveyID,]$PseudoSt
           
           # define the survey year for the survey ID
           FocalYear <- ffdata2[ffdata2$surveyID == FocalsurveyID,]$year
           
           # locate the pseudostate map for the ID
           FocalMapLoc <- paste0("E:\\FireflyAnalysis_October2020\\individual_pesticide_maps\\", # folder with all pesticide data
                                 FocalYear, "\\", # folder containing all focal rasters for focal year
                                 FocalPseudostate, "_SpeedyBee_", FocalYear, "\\", # folder containing focal raster
                                 "CDL_", FocalYear, "_", FocalPseudostate, "_insecticide.tif") # name of focal raster file
           
           # extract pesticide value at ID loc within pesudostate map
           FocalRaster <- raster(FocalMapLoc)
           
           ## grab focal coords from above shapefile
           focalCoords <- FFSiteCoords1[FocalsurveyID,]
           
           ## reproject to match focal raster
           focalCoords <- spTransform(focalCoords, proj4string(FocalRaster))
           
           # extract FocalRaster value at focalCoords
           PestValue <- extract(FocalRaster, focalCoords)
         }
   newrow <- c(FocalsurveyID, PestValue)
   df <- rbind(df, newrow)
  colnames(df) <- c("ID", "PesticideValue")
  
}

# re-arranging the final dataset
nrow(df) # 24683
nrow(ffdata1) # 24686
# NOTICE: ffdata1 has three extra rows. Why? There are three data points from 2017 for some reason. 
# these extra rows aren't extracted by the for() loop since I didn't make pest maps for 2017. Let's remove them:
ffdata2 <- ffdata1[1:(nrow(ffdata1) - 3),] # select all rows except last three
ffdata2 <- cbind(ffdata2, "pesticidevalue" = df$PesticideValue)
ffdata3 <- ffdata2
ffdata3$logpest <- log(ffdata3$pesticidevalue + 1)
boxplot(ffdata3$logpest ~ ffdata3$count, xlab = "firefly count", ylab = "log pesticide value")

write.csv(ffdata3, "E:\\FireflyAnalysis_October2020\\analysis code\\FireflyWatchAnalyses\\data\\firefly_data_withPesticides_Dec2020.csv" )
