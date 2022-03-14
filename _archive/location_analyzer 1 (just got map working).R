#load packages into library
library(shiny)          #used to run the web environment
library(plotly)         #used to create graphs
#library(ggmap)
#library(data.table)     #used as enhanced data frames
#library(DT)             #used to create elegant, searchable tables
#library(sqldf)          #used to compare data frames using tsql

library(sf)             #used for importing shapefiles as data frames
#library(ggplot2)        #used for mapping
library(tmap)           #alternative to ggplot for mapping, allows for interactive maps


###  IMPORT CSV RECORDS  ###

#import records into data frames
##future improvement: to improve performance, clean listing.csv to be tab delimited without quotes, then use sqldf package to only import columns/records that are needed
zillow <- read.csv("Zip_Zhvi_2bedroom.csv", header = TRUE)
airbnb <- read.csv("listings.csv", header = TRUE)




###  CLEAN AND PROCESS RECORDS  ###

#remove unnecessary columns to make data frames more manageable
##future improvement: reference the most recent zillowSummary prices by selecting the last column instead of referring to it by name
zillowSummary <- subset(zillow, select = c(RegionName, X2017.06))
airbnbSummary <- subset(airbnb, select = c(zipcode, price, bedrooms))

#filter airbnbSummary to only include 2 bedroom properties
airbnbSummary <- airbnbSummary[which(airbnbSummary$bedrooms == 2),]

#convert airbnbSummary$price data type from factor to numeric
airbnbSummary$price <- as.numeric(airbnbSummary$price)

#calculate the average rental price for each zip code
airbnbSummary <- aggregate(price ~ zipcode, airbnbSummary, FUN = mean)




###  COMBINE AND ANALYZE  ###

#combine zillowSummary and airbnbSummary data frames
combinedRecords <- merge(x = zillowSummary, y = airbnbSummary, by.x = "RegionName", by.y = "zipcode")

#calculate how many rental days it will take to recoup the cost of the property (breakEven)
combinedRecords$breakEven <- combinedRecords$X2017.06 / combinedRecords$price






###  PLOT MAP  ###

#import shapefile
nyMap <- st_read("ZIP_CODE_040114/ZIP_CODE_040114.shp", stringsAsFactors = FALSE)

#append combinedRecords data frame to nyMap
mapAndData <- merge(x = nyMap, y = combinedRecords, by.x = c('ZIPCODE'), by.y = c('RegionName'), all.x = TRUE)

#set tmap mode (view mode is for producing interactive java maps for viewing in a browser)
tmap_mode("view")

#plot mapAndData using tmap
tm_shape(mapAndData) +
  tm_polygons("breakEven", id = "ZIPCODE", palette = "Greens")

#save the map as a standalone html file
tmap_save(tmap_last(), "NY_break_even_analysis.html")

# #plot map with ggplot
# ggplot(mapAndData) +
#   geom_sf(aes(fill = breakEven)) +  #shade by breakEven
#   scale_fill_gradient(low = "#56B1F7", high = "#132B43")  #specify shading