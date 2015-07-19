# -*- coding: utf-8 -*-
"""
Created on Sat Jul 18 13:58:13 2015

@author: Miguel
"""

# -*- coding: utf-8 -*-
"""
Created on Fri Jul 10 19:26:09 2015

Read the zvh network with nodes without links and arranges it
by vairable type by rows

@author: Miguel
"""
import os
import re
import sys
from win32com.client import Dispatch

# Function to arrange the nodes in NETICA
def ordena_nodos (lista_nodos):
    y = 0
    for nodo in sorted(lista_nodos):
        j, items = 0, "    "
        y = y + 30
        for k in sorted(lista_nodos[nodo].keys()):
            if len(items) > 100:
                y = y + 30
                j, items = 0, "    "
            x = j * 21 + len(items) * 8 + len(k) * 4
            lista_nodos[nodo][k].VisualPosition = (x, y)
            items = items + k
            j = j + 1


# Check if there is a file name in the command line
try:
    net_dsk = sys.argv[1]
except IndexError:
    net_dsk=""
    print u"No file was given, will search for \"variables.neta\""

# Vincula la interface COM de NETICA y activa la aplicación

# find and load the library, assuming in a relative path closeby
netica_dir = os.path.abspath("C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/BN_Mapping/Netica/")
netica_app = Dispatch("Netica.Application")
licenseFile = os.path.join (netica_dir, "inecol_netica.txt")
licencia = open(licenseFile, 'r').read()

# Initialize a PyNetica instance/env using password in an independent text file
netica_app.SetPassword(licencia)
netica_app.SetWindowPosition(status="Hidden") # Regular, Minimized, Maximized, Hidden
#netica_app.visible = 1

# Initialize NETICA environment
print "\n"*2 + "#" * 40 + "\nAbriendo Netica\n" + "#" * 40 
print "Netica iniciada: " + netica_app.VersionString + ""
net_dsk_nuevo = "M00_VariablesDDD.neta"
if net_dsk.rfind(".neta") < 0:
    dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
    dir_datos = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004/train_data_pack/"
    net_dsk = dir_robin + dir_datos +"variables.neta"
    net_dsk_nuevo = dir_robin + dir_datos + net_dsk_nuevo

# Open selected Network file
name = netica_app.NewStream(net_dsk)
net_p = netica_app.ReadBNet(name, "")
# net_p.compile()
print u"Red abierta " + net_p.Name
print u"Archivo seleccionado " + net_p.FileName.split("/")[-1]
print u"Descripción de la red: " + net_p.Comment + u" Todas las variables de ROBIN-Mex"

# Get the pointer to the set of nodes
nodesList_p = net_p.Nodes

# get number of nodes
nnodes = nodesList_p.Count

# Collect all node names in network
node_names = {"gral":{}, "infys":{}, "pp":{}, "pt":{}, "tm":{}, "tr":{}, "tx":{}}
for i in range(nnodes):
    node_p = nodesList_p[i] # node_p
    name = node_p.name # name
    if re.search(r"^[xyZzdC]", name):
        node_names["gral"][name] = node_p
    elif re.search(r"(^ntre|^Diam|^Alt|^Ins|^Sin|^prob|^Psn|^Gpp)", name):
        node_names["infys"][name] =   node_p        
    elif re.search(r"^ppt[0-1]{1}", name):
        node_names["pp"][name] =   node_p
    elif re.search(r"^pptm", name):
        node_names["pt"][name] =   node_p
    elif re.search(r"^tma", name):
        node_names["tx"][name] =   node_p
    elif re.search(r"^tmi", name):
        node_names["tm"][name] =   node_p
    else:
        node_names["tr"][name] =   node_p   

# Selecciona nodos de interés
node_names["gral"]["zvh"].IsSelected = True
for n, v in node_names["pp"].iteritems():
    v.IsSelected = True
nodos_interes = net_p.SelectedNodes

# Nueva red con los nodos de interés y los arregla
nt_nueva = netica_app.NewBNet("nuevo") 
nt_nueva.CopyNodes(nodos_interes)
nodosNuevosList_p = nt_nueva.Nodes
nuevos_nodos = {"gral":{}, "pp":{}}
nuevos_nodos["gral"]["zvh"] = nodosNuevosList_p["zvh"]
for pp in ["ppt%02d" % (i,) for i in range(1, 13) ]:
    nuevos_nodos["pp"][pp] = nodosNuevosList_p[pp]
    
ordena_nodos (nuevos_nodos)

# Crea links
for pp in ["ppt%02d" % (i,) for i in range(1, 13) ]:
    nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["zvh"])
nt_nueva.compile()

# Realiza un entrenamiento a partir de casos en archivo
casos_dsk = dir_robin + dir_datos +"bn_train_20150713_sin_NA.csv"
casos = netica_app.NewStream(casos_dsk)
casos_st = netica_app. NewCaseset("entrena")
casos_st.AddCasesFromFile(casos)

# COUNTING_LEARNING=1, EM_LEARNING=3, or GRADIENT_DESCENT_LEARNING=4
entrenamiento = netica_app.NewLearner(1) #
entrenamiento.LearnCPTs(nodosNuevosList_p, casos_st, 1) # Degree usualy 1

# para volver a aprender hay que borrar las CPT o ajustar la "experiencia"
for n in nodosNuevosList_p:
    n.DeleteTables()





