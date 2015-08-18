import os

import numpy as np

import pandas as pd

from geotiffio import readtif
from geotiffio import createtif
from geotiffio import writetif 

files = list()
for file in os.listdir("/mydir"):
    if file.endswith(".tif"):
        files.append(files)

# read one image to get metadata
dataset,rows,cols,bands = readtif(files[0])

# image metadata
projection = dataset.GetProjection()
transform = dataset.GetGeoTransform()
driver = dataset.GetDriver()

# prediction table (pixels are rows, columns are variables)
    data_table = zeros((cols*rows,len(files)))
   
    for b in xrange(len(files)):
    	image,rows,cols,bands = readtif(files[b])
        band = image.GetRasterBand(b+1)
        band = band.ReadAsArray(0,0,cols,rows).astype(float)
        data_table[:,b] = ravel(band)

### insert process to predict using data_table
ie_map = process_on_data_table

### write ie_map to disk
output_name = outpath + "filename.tif"

outData = createtif(driver, rows, cols, 1, output_name)

writetif(outData, ie_map, projection, transform, order='c')

# close dataset properly
outData = None	