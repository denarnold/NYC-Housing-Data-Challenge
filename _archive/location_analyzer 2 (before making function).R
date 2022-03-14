###  LOAD PACKAGEs INTO LIBRARY  ###

library(shiny)          #used to run the web environment
library(plotly)         #used to create graphs
library(data.table)     #used to import select columns from csv files (fread)
library(readr)          #used to convert currency to numeric data type
library(sf)             #used for importing shapefiles as data frames
library(tmap)           #used for mapping, allows for interactive maps




###  IMPORT AND CLEAN CSV RECORDS  ###

#import cost data
costImport <- fread("Zip_Zhvi_2bedroom.csv",               #file to pull from
                select = c("RegionName", "2017-06"),       #columns to import
                col.names = c("zipcode", "propertyCost"),  #new column names
                data.table = FALSE)                        #import as data frame instead of data table

#import revenue data
revenueImport <- fread("listings.csv",
                select = c("zipcode", "bedrooms", "price"),
                col.names = c("zipcode", "bedrooms", "rentalPrice"),
                data.table = FALSE)

#convert rentalPrice data type from character to numeric
revenueImport$rentalPrice <- parse_number(revenueImport$rentalPrice)




###  PROCESS RECORDS  ###

#create new variables for processing
costData <- costImport
revenueData <- revenueImport

#filter revenueData to only include 2 bedroom properties
revenueData <- revenueData[which(revenueData$bedrooms == 2),]

#calculate the average rental price for each zip code
revenueData <- aggregate(rentalPrice ~ zipcode, revenueData, FUN = mean)

#combine costData and revenueData data frames
combinedRecords <- merge(costData, revenueData, by = "zipcode")

#calculate how many rental days it will take to recoup the cost of the property (breakEven)
combinedRecords$breakEven <- combinedRecords$X2017.06 / combinedRecords$rentalPrice




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