# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 21:07:25 2015

@author: Miguel
"""

import os
import re
from netCDF4 import Dataset as nc

# Ubicación de los datos en formato nc
curr_dir = os.curdir
archivos = os.listdir(os.curdir)
archivos = [nombre for nombre in archivos if re.findall("\\.nc$", nombre)]

# Revisa los archivos en el directorio indicado
for dataset in archivos:
    # Lee el archivo nc seleccionado
    try:
        nc_dataset = nc(dataset, "r", format="NETCDF4")
        print "\tArchivo:  <%s>   parece estar OK !!!!!" %dataset
        nc_dataset.close()
    except RuntimeError:
        print "\t***WARNING:  <%s>   no se puede leer ***" %dataset
