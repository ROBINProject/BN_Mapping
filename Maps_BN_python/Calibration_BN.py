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
archivo_nombre = [texto for texto in archivosTexto if re.findall("calibra", texto)]
archivo = open(archivo_nombre[0], "r")
texto = archivo.readlines()
archivo.close()

texto[0]
texto[1].split("|")[0].split(":")
datos = []
for z in texto[1:] :
    items = []
    for x in z.split("|"):
        x = re.sub(":", ": ", x)
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

