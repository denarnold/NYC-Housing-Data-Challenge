# Location Analyzer ReadMe
Developed by Dennis Arnold, March 2020
R version: 3.6.3

## About
The purpose of this R script is to assist in determining which zip codes within a region will be most profitable to invest in. This is currently achieved by calculating and comparing Capitalization Rates for zip codes using property cost and rental revenue figures.

All linked visualizations in this ReadMe can be found in `\output`.

## Setup
**STEP 1:** Ensure the following source files are located in `\source_files` and are named correctly:
* New York City shapefile: `\source_files\ZIP_CODE_040114` *(included)*
   * This script utilizes a shapefile containing the location and boundary information for New York City zip codes. The shapefile is included in this distribution.
   * File origin: <https://data.cityofnewyork.us/Business/Zip-Code-Boundaries/i8iw-xf4u>
* Zillow csv file: `\source_files\Zip_Zhvi_2bedroom.csv` *(not included)*
* AirBnB csv file: `\source_files\listings.csv` *(not included)*

**STEP 2:** Install the following R packages:
* plotly
* data.table
* readr
* sf
* tmap

**STEP 3:** Run location_analyzer.R

## Data Quality Insights
The Zillow dataset is visually represented in [this scatter plot](<output/Property Cost Distribution (scatter).png>) and [this boxplot](<output/Property Cost Distribution (boxplot).png>). While there are 704 outliers, all values appear to be in within the speculative range of what 2 bedroom properties might cost, and as such it will be assumed that that these values are accurate and are to be retained.

The AirBnB dataset is visually represented in [this scatter plot](<output/Rental Price Distribution (scatter).png>) and [this boxplot](<output/Rental Price Distribution (boxplot).png>). This dataset appears to be a bit more messy with 2,972 outliers, which is understandable given its larger size and the fact that it is comprised of individual records as opposed to calculated averages. It will be assumed that rental prices of $0 are not valid and that rental prices above $2,000 are likely either erroneous or uniquely special properties. As such, records meeting either of these conditions will not be retained.

Finally, it is worth noting that the Zillow and AirBnB records being used are from different dates (June 2017 and July 2019 respectively), which may affect the accuracy of resulting calculations.

## Results
### Outputs
Capitalization Rates resulting from the provided Zillow and AirBnB datasets are visually represented in [this chart](<output/NYC 2 Bedroom Cap Rates by Zip Code (chart).html>), [this boxplot](<output/Cap Rate Distribution (boxplot).png>), and [this map](<output/NYC 2 Bedroom Cap Rates by Zip Code (map).html>).

### Observations
Upon viewing the map, it is apparent that more property value data will be needed in order to account for all of New York City's zip codes. In general, zip codes bordering the Lower New York Bay appear to offer relatively favorable returns.

In these results, zip code 11003 appears to stand out as being the most profitable zip code with a Capitalization Rate of 14.2% (unfortunately this zip code was not included with the provided shapefile and as a result does not appear on the map). Seeing as how this figure is an outlier ([see boxplot](<output/Cap Rate Distribution (boxplot).png>)), it would be prudent to gather more information on this zip code and those surrounding it to confirm the accuracy of this measurement.

## Considerations for Future Development
Future development of this script would primarily be guided by factors such as what other datasets will need to be accommodated, who the end users will be, if there is a greater desire for customization or standardization, and what additional outputs may be desired.

A few thoughts:

* If standardized results are of interest, it may be worth considering wrapping everything up into a Shiny dashboard, allowing the user to import datasets and easily specify various parameters such as property sizes (room counts).
* Depending on what other potential datasets look like, it may be helpful to further automate the data munging process.
* Considering that the provided Zillow dataset contains historical records, perhaps it would be of interest to assess historical trends within the market.
* It may be more visually pleasing to format Capitalization Rates as rounded percentages.
* It may be worth considering breaking out the csv importing and cleaning operations into a separate R document.

## Metadata
### costImport - Column Level Metadata
Field | Description | Data Type
--- | --- | ---
zipcode | Zip code where property is located | Integer
propertyCost | The most recent average property cost per zip code | Double
bedrooms | Number of bedrooms in each property being considered in the dataset (Though the current dataset from Zillow is already filtered, including this field would allow for the processing of larger datasets containing metrics for properties with multiple bedroom sizes) | Integer

### revenueImport - Column Level Metadata
Field | Description | Data Type
--- | --- | ---
zipcode | Zip code where unit is located | Integer
rentalPrice | The nightly rental price per unit | Double
bedrooms | Unit bedroom count for dataset | Integer

### capRates - Column Level Metadata
Field | Description | Data Type
--- | --- | ---
zipcode | List of unique zip codes being considered | Integer
propertyCost | The most recent average property cost per zip code | Double
rentalPrice | The average nightly rental price per zip code | Double
aoi | Annual Operating Income (rental price * days in a year * occupancy rate). Used to calculate Capitalization Rate. | Double
capRate | Capitalization Rate (annual operating income / property market value) | Double

### shpMap & capRateMap - Dataset Level Metadata
Data Frames | Description
--- | ---
shpMap | Information on each zip code in New York City, including mappable geographic boundary data
capRateMap | A combination of the shpMap and capRates data frames