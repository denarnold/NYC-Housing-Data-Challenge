##---------------------------------------------------------------
##                LOAD PACKAGES INTO LIBRARY                   --
##---------------------------------------------------------------

library(plotly)         #used to create graphs
library(sf)             #used to import shapefiles as data frames
library(tmap)           #used to create maps

#import data using the r script "import_and_clean_data.R"
source("import_and_clean_data.R")	#creates net worth plot object




##---------------------------------------------------------------
##                USER-DEFINED VARIABLES                       --
##---------------------------------------------------------------

#specify the bedroom count of the properties being considered
propertyBedroomCount <- as.integer(2)




##---------------------------------------------------------------
##                CAPITALIZATION RATE FUNCTION                 --
##---------------------------------------------------------------

findCapRates <- function(costData, revenueData, bedroomCount) {
  
  #filter records by number of bedrooms being considered
  costData <- costData[which(costData$bedrooms == bedroomCount),]
  revenueData <- revenueData[which(revenueData$bedrooms == bedroomCount),]
  
  #aggregate data by zip code
  costData <- aggregate(propertyCost ~ zipcode, costData, FUN = mean)
  revenueData <- aggregate(rentalPrice ~ zipcode, revenueData, FUN = mean)
  
  #combine costData and revenueData into a single data frame for further processing
  capRates <- merge(costData, revenueData, by = "zipcode")
  
  #calculate the annual operating income (rental price * days in a year * occupancy rate)
  capRates$aoi <- capRates$rentalPrice * 365 * .75
  
  #calculate the capitalization rate (annual operating income / property market value)
  capRates$capRate <- capRates$aoi / capRates$propertyCost
  
  #sort the data frame by descending capitalization rate
  capRates <- capRates[order(-capRates$capRate), ]
  
  #return the results
  return(capRates)
}




##---------------------------------------------------------------
##            RUN IMPORTED DATA THROUGH FINDCAPRATES           --
##---------------------------------------------------------------

capRates <- findCapRates(costImport, revenueImport, propertyBedroomCount)




##---------------------------------------------------------------
##                       PLOT BAR CHART                        --
##---------------------------------------------------------------

#plot a bar chart to convey the distribution of cap rates by zip code
plot_ly(
  data = capRates,
  x = ~zipcode,
  y = ~capRate,
  name = "Zip Code Capitalization Rates",
  type = "bar"
) %>% layout(xaxis = list(type = 'category'))




##---------------------------------------------------------------
##                          PLOT MAP                           --
##---------------------------------------------------------------

#import shapefile
shpMap <- st_read("source_files/ZIP_CODE_040114/ZIP_CODE_040114.shp", stringsAsFactors = FALSE)

#append capRates data frame to nyMap
capRateMap <- merge(x = shpMap, y = capRates, by = "ZIPCODE", by.y = "zipcode", all.x = TRUE)

#set tmap mode (view mode is for producing interactive java maps for viewing in a browser)
tmap_mode("view")

#plot capRateMap using tmap
tm_shape(capRateMap) +
  tm_polygons("capRate", id = "ZIPCODE", palette = "Greens")