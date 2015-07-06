# -*- coding: utf-8 -*-
"""
Created on Fri Jul 03 23:47:51 2015

@author: Miguel
"""

import os
import re
import pandas as pd
import matplotlib.pyplot as plt
from pandas.tools.plotting import andrews_curves

pd.set_option('max_columns', 55)

# Ubicación de los datos de ROBIN
dir_GD = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive"
dir_ROBIN  = u"/2 Proyectos/RoBiN/Datos RoBiN/México/0_Vigente"
dir_clima = u"/GIS/Mapas_base/2004/clima"
os.chdir(dir_GD + dir_ROBIN + u"/GIS/Mapas_base/2004")
archivos = os.listdir(os.curdir)
nombre_archivo = [nombre for nombre in archivos if re.findall(".+clima-mx\\.csv$", nombre)][0]

# Lee los datos de clima
datos = pd.read_csv(nombre_archivo)
datos.head()

# Selected items in pandas dataframe
datos.iloc[1:5,3]

# the histogram of the data with histtype='step'
fig1 = plt.figure(figsize=(4,3))
datos.iloc[:,3].plot(kind="hist", alpha=0.5, bins = 100)
datos.iloc[:,4].plot(kind="hist", alpha=0.5, bins = 100)

pp_vars = list(datos.columns[2:3])
zvh_var = [datos.columns[38]]
melted = pd.DataFrame(pd.melt(datos, id_vars=zvh_var, value_vars=pp_vars))
pp_melted = melted[["value", "Zvh_observed"]]
plt.figure()
andrews_curves(melted[["value", "Zvh_observed"]], 'Zvh_observed')
melted.head()

    
    