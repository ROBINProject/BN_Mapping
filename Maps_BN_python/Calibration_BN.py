# -*- coding: utf-8 -*-
"""
Created on Thu Jul 02 00:49:13 2015

@author: Miguel
"""

import os 
import re

# Abrie el archivo y carga en "texto"
rutaBase = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/"
rutaTextos = u"Datos RoBiN/México/0_Vigente/GIS/Mapas_base/"
os.chdir(rutaBase + rutaTextos)
archivosTexto = os.listdir(rutaBase + rutaTextos)
archivo_nombre = [texto for texto in archivosTexto if re.findall("_EM_", texto)]
archivo = open(archivo_nombre[0], "r")
texto = archivo.readlines()
archivo.close()

# Corrige pequeñas imperfecciones de formato en el texto para facilitar 
# la separación de componentes
texto = [re.sub("(\d):(\d)", "\\1: \\2", tx) for tx in texto]

# Analiza el texto
datos = []
for z in texto[1:] :
    items = []
    for x in z.split("|"):
        items.append([item for item in x.split(" ") if item != " " and item != "" and item !="\n"])
        lista_1 = [item for sublist in items for item in sublist]  
    datos.append(lista_1[0])
    if re.findall("[a-zA-Z]{1,}", re.sub(" ", "", lista_1[1])) == []:
        inicio = 1
    else:
        datos[-1] = datos[-1] + " " + lista_1[1]
        inicio = 2
    dat_x, dat_y = [], []
    for y in lista_1[inicio:]:
        if y.find(":") > 0 :
            intervalo = y.rstrip(":").split("-")
            dat_x.append(sum(map(float, intervalo))/2)            
        else:
            dat_y.append(map(float, [y])[0])
    datos.append([dat_x, dat_y])       

datos_dict = {}
for d in datos:
    if isinstance(d, basestring):
        datos_dict.update({d:[]})
        item = d
    else:
        datos_dict[item] = [(x, y) for x in d[0] for y in d[1]]

with open(rutaBase + rutaTextos + u"ZHV_cal_EM_10_DEM.txt", "wb") as f:
    for d in datos_dict.keys():
        f.write(d + "\n")        
        for item in datos_dict[d]:
            f.write(str(item[0]) + ",")
        f.write("\n")
        for item in datos_dict[d]:
            f.write(str(item[1]) + ",")
        f.write("\n")
    f.close()
