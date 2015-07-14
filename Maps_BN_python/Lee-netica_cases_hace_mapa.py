# -*- coding: utf-8 -*-
"""
Created on Wed Jun 17 13:40:59 2015

@author: Miguel
"""
import os
import re
import numpy as np
import matplotlib.pyplot as plt
from osgeo import gdal
from osgeo.gdalconst import GA_ReadOnly 
from osgeo.gdalconst import GDT_Float32
from osgeo.gdalconst import GDT_Int16
import pandas as pn

# Define función para hacer la converción de arreglo a raster 
# Fuente: http://gis.stackexchange.com/questions/58517/python-gdal-save-array-as-raster-with-projection-from-other-file
def array_to_raster(array, ref_map):
    """Array > Raster
    Save a raster from a C order array.

    :param array: ndarray
    """
    dst_filename = 'name.tiff'


    # You need to get those values like you did.
    geoTransf = ref_map.GetGeoTransform()
    x_pixels = ref_map.RasterXSize  # number of pixels in x
    y_pixels = ref_map.RasterYSize  # number of pixels in y
    PIXEL_SIZE = geoTransf[1]  # size of the pixel...        
    # x_min & y_max are like the "top left" corner.
    x_min = geoTransf[0] # Top left x  
    y_max = geoTransf[3] # Top left y 
    wkt_projection = ref_map.GetProjection()

    driver = gdal.GetDriverByName('GTiff')

    dataset = driver.Create(
        dst_filename,
        x_pixels,
        y_pixels,
        1,
        gdal.GDT_Float32, )

    dataset.SetGeoTransform((
        x_min,    # 0
        PIXEL_SIZE,  # 1
        0,                      # 2
        y_max,    # 3
        0,                      # 4
        -PIXEL_SIZE))  

    dataset.SetProjection(wkt_projection)
    dataset.GetRasterBand(1).WriteArray(array)
    dataset.FlushCache()  # Write to disk.
    
    # If you need to return, remenber to return  
    # also the dataset because the band doesn`t live without dataset.
    return dataset, dataset.GetRasterBand(1)  

# Ubicación de los mapas
robin_location = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
gis_dir = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004"
archivos = os.listdir(robin_location + gis_dir)

# Lee archivo de datos de netica
archivos = [nombre for nombre in archivos if "OUTPUT" and "4" in nombre]
datos = pn.read_csv(robin_location+gis_dir+"/"+archivos[0], header=0, sep="\t")

# Renombra las columnas
nombres = datos.columns[:]
nombres = [re.search("([xy]|[zvh_0-9]{3,})", n).group(1) for n in nombres ]
datos.columns = nombres

# Lee el mapa de interés
gdal.AllRegister() # register all of the GDAL drivers

inDataset = gdal.Open(robin_location + re.sub("2004", "bov_cbz_km2.tif", gis_dir) + "" ,GA_ReadOnly)
cols = inDataset.RasterXSize
filas = inDataset.RasterYSize
pixel_size = inDataset.PixelSize
bandas = inDataset.RasterCount
banda_elegida = 1
inDataset.GetGeoTransform()
capa = inDataset.GetProjection()
matriz = pn.DataFrame.as_matrix(datos, ["x", "y", "zvh_1"])

da, dg = array_to_raster(matriz, inDataset)

# ---------------------------------

geoTransf = inDataset.GetGeoTransform()
x_pixels = inDataset.RasterXSize  # number of pixels in x
y_pixels = inDataset.RasterYSize  # number of pixels in y
PIXEL_SIZE = geoTransf[1]  # size of the pixel...        
# x_min & y_max are like the "top left" corner.
x_min = geoTransf[0] # Top left x  
y_max = geoTransf[3] # Top left y 
wkt_projection = inDataset.GetProjection()

driver = gdal.GetDriverByName('GTiff')

dataset = driver.Create(
    "test.tif",
    x_pixels,
    y_pixels,
    1,
    gdal.GDT_Float32, )

dataset.SetGeoTransform((
    x_min,    # 0
    PIXEL_SIZE,  # 1
    0,                      # 2
    y_max,    # 3
    0,                      # 4
    -PIXEL_SIZE))  

dataset.SetProjection(wkt_projection)
dataset.GetRasterBand(1).WriteArray(matriz)
dataset.FlushCache()  # Write to disk.


# ---------------------------------


# despliegue simple del mapa
# cmap = mapa de color: 
#   http://matplotlib.org/examples/color/colormaps_reference.html
banda = inDataset.GetRasterBand(banda_elegida)
map_ref = banda.ReadAsArray()
map_ref[map_ref < 0] = float("NaN")
plt.imshow(map_ref, cmap="YlGnBu", aspect="equal")
plt.colorbar(shrink=0.5)
plt.title('Mapa de referencia ROBIN')

