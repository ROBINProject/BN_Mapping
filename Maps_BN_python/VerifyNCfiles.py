# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 21:07:25 2015

@author: Miguel
"""
import os
from netCDF4 import Dataset as nc

archivos = [nombre for nombre in os.listdir(".") if ".nc" in nombre]

if len(archivos) <= 0:
    # Ubicación de los datos en formato nc
    direct_ROBIN = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RobiN"
    direct_lpj = u"/Datos RoBiN/México/0_Vigente/GIS/LPJ/LU_rcp2p6_gfdl-esm2m_transientCO2_p1/" 
    os.chdir(direct_ROBIN + direct_lpj)
    archivos = os.listdir(os.curdir)
    archivos = [nombre for nombre in archivos if "nc" in nombre]

# Revisa los archivos en el directorio indicado
resultados = {"bueno" : [], "malo" : []}
for dataset in archivos:
    # Lee el archivo nc seleccionado
    try:
        nc_dataset = nc(dataset, "r", format="NETCDF4")
        resultados["bueno"].append(dataset)
        nc_dataset.close()
    except RuntimeError:
        resultados["malo"].append(dataset)
        

print "\nArchivos con errores  -----  no se pueden leer ***"
for d in resultados["malo"]:
    print "\t<%s>" %d
    
print "\n\nArchivos accesibles -----  parecen estar OK !!!!!"
for d in resultados["bueno"]:
    print "\t<%s>" %d
