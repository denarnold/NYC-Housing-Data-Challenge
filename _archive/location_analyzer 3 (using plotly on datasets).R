##---------------------------------------------------------------
##                LOAD PACKAGES INTO LIBRARY                   --
##---------------------------------------------------------------

library(plotly)         #used to create graphs
library(data.table)     #used to import select columns from csv files (fread)
library(readr)          #used to convert currency string to numeric data type
library(sf)             #used to import shapefiles as data frames
library(tmap)           #used to create maps




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
##                     IMPORT CSV RECORDS                      --
##---------------------------------------------------------------

#import cost data
costImport <- fread("source_files/Zip_Zhvi_2bedroom.csv",  #file to pull from
                select = c("RegionName", "2017-06"),       #columns to import
                col.names = c("zipcode", "propertyCost"),  #new column names
                data.table = FALSE)                        #import as data frame instead of data table

#import revenue data
revenueImport <- fread("source_files/listings.csv",
                select = c("zipcode", "price", "bedrooms"),
                col.names = c("zipcode", "rentalPrice", "bedrooms"),
                data.table = FALSE)




##---------------------------------------------------------------
##                CLEAN AND PROCESS CSV RECORDS                --
##---------------------------------------------------------------

#convert rentalPrice data type from character to numeric
revenueImport$rentalPrice <- parse_number(revenueImport$rentalPrice)

#add a bedrooms column to costImport(currently serving as a placeholder,
# would import if the dataset was not already filtered)
costImport$bedrooms <- propertyBedroomCount




## assess costImport data quality and manage outliers ##

#create a scatter plot of propertyCosts
plot_ly(data = costImport[order(costImport$propertyCost), ], 
        y = ~propertyCost, 
        type = 'scatter', 
        mode = 'markers')

#create a box plot of propertyCosts and return outlier count
boxplot(costImport$propertyCost)$out %>% length

#assume all outliers should be retained (aka no edits needed)




## assess revenueImport data quality and manage outliers ##

#create a scatter plot of rentalPrice
plot_ly(data = revenueImport[order(revenueImport$rentalPrice), ],
        y = ~rentalPrice,
        type = 'scatter',
        mode = 'markers')

#create a scatter plot of rentalPrice
plot(sort(revenueImport$rentalPrice))

#create a box plot of rentalPrice and return outlier count
boxplot(revenueImport$rentalPrice)$out %>% length

#assume rentals equal to 0 or above $2,000 should not be retained (aka remove them)
revenueImport <- revenueImport[!(revenueImport$rentalPrice == 0 | revenueImport$rentalPrice > 2000), ]




#find capitalization rates for imported records
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