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

# Ubicación de los mapas
imagepath = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/México/0_Vigente/GIS/LPJ"
archivos = os.listdir(imagepath)
archivos = [nombre for nombre in archivos if re.findall("\\.tif$", nombre)]
mapa = [re.findall("mx_runoff", nombre) for nombre in archivos]
archivos[re.("mx_runoff", nombre) for nombre in archivos]

# Lee el mapa de interés
gdal.AllRegister()
inDataset = gdal.Open(imagepath + "/" + mapa,GA_ReadOnly)
cols = inDataset.RasterXSize
filas = inDataset.RasterYSize
bandas = inDataset.RasterCount
banda_elegida = 1

# despliegue simple del mapa
# cmap = mapa de color: 
#   http://matplotlib.org/examples/color/colormaps_reference.html
banda = inDataset.GetRasterBand(banda_elegida)
runoff_lpj = banda.ReadAsArray()
runoff_lpj[runoff_lpj < 0] = float("NaN")
plt.imshow(runoff_lpj, cmap="YlGnBu", aspect="equal")
plt.colorbar(shrink=0.5)
plt.title('Runoff')

import folium
map_osm = folium.Map(location=[45.5236, -122.6750])
map_osm.create_map(path='osm.html')

