# -*- coding: utf-8 -*-
"""
Created on Tue Jul 07 19:30:16 2015

Genera nuevas variables para análisis clima y ZVH

@author: Miguel
"""

import os
import re
import pandas as pd

pd.set_option('max_columns', 55)

# Ubicación de los datos de ROBIN
dir_GD = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive"
dir_ROBIN  = u"/2 Proyectos/RoBiN/Datos RoBiN/México/0_Vigente"
dir_clima = u"/GIS/Mapas_base/2004/clima"
os.chdir(dir_GD + dir_ROBIN + u"/GIS/Mapas_base/2004")
archivos = os.listdir(os.curdir)
nombre_archivo = [nombre for nombre in archivos if re.findall("0.+\\.csv$", nombre)][0]

# Lee los datos de clima
datos = pd.read_csv(nombre_archivo)
datos.head()

# Calcula el cociente p/tmax y el intervalo térmico: tmax-tmin
tmx_tmn, pp_tmx = pd.DataFrame(), pd.DataFrame()
for col in range(1,13):
    pp_col  = datos.columns[col + 4]
    tx_col  = datos.columns[col + 16]
    tm_col  = datos.columns[col + 28]
    pp_name = "pptmax%02d" % col
    tt_name = "tmx_tm%02d" % col    
    pp_tmx  = pd.concat([pp_tmx, pd.DataFrame(data={pp_name:datos[pp_col] / datos[tx_col]})], axis=1)
    tmx_tmn = pd.concat([tmx_tmn, pd.DataFrame(data={tt_name:datos[tx_col] - datos[tm_col]})], axis=1)
    
dd = pd.concat([datos, pp_tmx, tmx_tmn], axis=1)

