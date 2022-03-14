#import modules
import requests
import io
from zipfile import ZipFile

#download the shapefile zip file
z = requests.get(r'https://data.cityofnewyork.us/download/i8iw-xf4u/application%2Fzip')

#extract to the current working directory (should also be where location_analyzer.R is located)
with ZipFile(io.BytesIO(z.content)) as zipObj:
    zipObj.extractall('ZIP_CODE_040114')