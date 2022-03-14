##---------------------------------------------------------------
##                LOAD PACKAGES INTO LIBRARY                   --
##---------------------------------------------------------------

library(data.table)     #used to import select columns from csv files (fread)
library(readr)          #used to convert currency string to numeric data type




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
##                        FORMAT DATA                          --
##---------------------------------------------------------------

#convert rentalPrice data type from character to numeric
revenueImport$rentalPrice <- parse_number(revenueImport$rentalPrice)

#add a bedrooms column to costImport(currently serving as a placeholder,
# would import if the dataset was not already filtered)
costImport$bedrooms <- propertyBedroomCount




##---------------------------------------------------------------
##      costImport - ASSESS DATA QUALITY & MANAGE OUTLIERS     --
##---------------------------------------------------------------

#create a scatter plot of propertyCosts
plot(sort(costImport$propertyCost),
     main = "Property Cost Distribution",
     ylab = "propertyCosts")

#create a box plot of propertyCosts and return outlier count
boxplot(costImport$propertyCost)$out %>% length

#assume all outliers should be retained (aka no edits needed)




##---------------------------------------------------------------
##    revenueImport - ASSESS DATA QUALITY & MANAGE OUTLIERS    --
##---------------------------------------------------------------

#create a scatter plot of rentalPrice
plot(sort(revenueImport$rentalPrice),
     main = "Rental Price Distribution",
     ylab = "rentalPrice")

#create a box plot of rentalPrice and return outlier count
boxplot(revenueImport$rentalPrice,
        main = "Rental Price Distribution"
)$out %>% length

#assume rentals equal to 0 or above $2,000 should not be retained (aka remove them)
revenueImport <- revenueImport[!(revenueImport$rentalPrice == 0 | revenueImport$rentalPrice > 2000), ]