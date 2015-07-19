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

class learn_method:
    counting=1
    EM=3
    gradient=4


#
#-------------------- Funciones locales --------------------------
#
def inicia_netica(lic_dir):
    # Vincula la interface COM de NETICA y activa la aplicación
    # Asume que la licencia está en el mismo directorio de la aplicación
    # si no la encuentra arranca en modo limitado
    netica_app = Dispatch("Netica.Application")
    licenseFile = os.path.join (lic_dir, "inecol_netica.txt")
    try:
        licencia = open(licenseFile, 'r').read()
    except IOError as e:
        licencia = ""
        print "error I/O ({0}): {1}".format(e.errno, e.strerror)
    # Initialize a PyNetica instance/env using password in an independent text file
    netica_app.SetPassword(licencia)
    netica_app.SetWindowPosition(status="Hidden") # Regular, Minimized, Maximized, Hidden
    return netica_app

def ordena_nodos (lista_nodos):
    # Function to arrange the nodes in NETICA
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

def prueba_BNet (nodo_obj, casos):
    # Organiza la prueba de la red y calcula la tasa de error
    nodoObjetivo_nl = nodosNuevosList_p[nodo_obj]
    nodoObjetivo_nl.IsSelected = True
    nodo_prueba = nt_nueva.SelectedNodes
    nodoObjetivo_nl.IsSelected = False
    tester = nt_nueva.NewNetTester(nodo_prueba, nodo_prueba, -1)
    tester.TestWithCases(casos)
    valorError = tester.ErrorRate(nodo_prueba[0])
    tester.Delete()
    return valorError

def lista_nodos_diccionario (BNet):
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
    return node_names

def prepara_casos (archivo):
    # Prepara el entrenamiento a partir de casos en archivo
    casos_dsk = dir_robin + dir_datos + archivo
    casos = netica_app.NewStream(casos_dsk)
    casos_st = netica_app. NewCaseset("entrena")
    casos_st.AddCasesFromFile(casos)
    return casos_st

def entrena_BNet (nodos, casos, degree):
    # Aplica el aprendizaje elejido.  Las opciones de aprendizaje son:
    entrenamiento = netica_app.NewLearner(learn_method.counting) 
    entrenamiento.LearnCPTs(nodos, casos, degree) # Degree usualy 1
    nt_nueva.compile()
    
def red_nula(nodo_padre, var_lst):
    nodosNuevosList_p[nodo_padre].DeleteTables()
    nodos_hijos = [n.name for n in nodosNuevosList_p[nodo_padre].Children]
    for pp in var_lst:
        if pp in nodos_hijos:
            nodosNuevosList_p[pp].DeleteLink(nodosNuevosList_p[nodo_padre])
        nodosNuevosList_p[pp].DeleteTables()
    nodosNuevosList_p["dem30_mean1000"].DeleteTables()
    nodos_hijos = [n.name for n in nodosNuevosList_p["dem30_mean1000"].Children]
    for pp in var_lst:
        if pp in nodos_hijos:
            nodosNuevosList_p[pp].DeleteLink(nodosNuevosList_p["dem30_mean1000"])
        nodosNuevosList_p[pp].DeleteTables()
    nodosNuevosList_p["dem30_sd1000"].DeleteTables()
    nodos_hijos = [n.name for n in nodosNuevosList_p["dem30_sd1000"].Children]
    for pp in var_lst:
        if pp in nodos_hijos:
            nodosNuevosList_p[pp].DeleteLink(nodosNuevosList_p["dem30_sd1000"])
        nodosNuevosList_p[pp].DeleteTables()

def copia_variables_interes(nodos_dic):
    nodos_dic["gral"][nodo_objetivo].IsSelected = True
    nodos_dic["gral"]["dem30_mean1000"].IsSelected = True
    nodos_dic["gral"]["dem30_sd1000"].IsSelected = True
    for n, v in nodos_dic["pp"].iteritems():
        v.IsSelected = True
    for n, v in nodos_dic["tx"].iteritems():
        v.IsSelected = True
    for n, v in nodos_dic["tm"].iteritems():
        v.IsSelected = True
    nodos_interes = net_p.SelectedNodes
    # Crea una nueva red con los nodos de interés y los arregla
    nt_nueva = netica_app.NewBNet("nueva_red") 
    nt_nueva.CopyNodes(nodos_interes)
    nodosNuevosList_p = nt_nueva.Nodes
    nuevos_nodos = {"gral":{}, "pp":{}}
    nuevos_nodos["gral"][nodo_objetivo] = nodosNuevosList_p[nodo_objetivo]
    nuevos_nodos["gral"]["dem30_mean1000"] = nodosNuevosList_p["dem30_mean1000"]
    nuevos_nodos["gral"]["dem30_sd1000"] = nodosNuevosList_p["dem30_sd1000"]
    for pp in ["ppt%02d" % (i,) for i in range(1, 13) ]:
        nuevos_nodos["pp"][pp] = nodosNuevosList_p[pp]
    ordena_nodos (nuevos_nodos)
    return nt_nueva, nodosNuevosList_p

def prueba_RB_naive ():
    # Crea todos los links tipo "Naive" del "nodo_objetivo" hacia los demás
    for pp in ["ppt%02d" % (i,) for i in range(1, 13) ]:
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p[nodo_objetivo])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_mean1000"])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_sd1000"])
    for pp in ["tmax%02d" % (i,) for i in range(1, 13) ]:
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p[nodo_objetivo])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_mean1000"])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_sd1000"])
    for pp in ["tmin%02d" % (i,) for i in range(1, 13) ]:
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p[nodo_objetivo])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_mean1000"])
        nodosNuevosList_p[pp].AddLink(nodosNuevosList_p["dem30_sd1000"])
    # Entrena y prueba la nueva red
    entrena_BNet (nodosNuevosList_p, casos_st, 1)
    tasaError = prueba_BNet(nodo_objetivo, casos_st)
    return tasaError

def descripcion_nueva_red (red_nva, err):
    resultados = [u"Netica " + netica_app.VersionString + 
                  u"iniciada con: " + "ROBIN_netica_zvh_training.py"]
    resultados.append(u"Localización licencia: " + netica_dir)
    resultados.append(u"Nodo de interés seleccionado: " + nodo_objetivo)
    resultados.append("Nueva red guardada en: " + nueva_red_nombre)
    resultados.append(u"Tasa de error modelo \"Naive\""
                      u" completo: {:10.4f}\n".format(err_naive))
    for e in sorted(err):
        resultados.append("Tasa de error con la variable " + e +
                           ": {:10.4f}".format(errores[e]))
    resultados.append("\nprocesamiento terminado ***************")
    resultados.append("Cerrando NETICA!")
    red_nva.Comment = u"\n".join(resultados)
#-----------------------------------------------------------------


# Check if there is a file name in the command line
try:
    netica_dir = sys.argv[0]
    net_dsk = sys.argv[1]
except IndexError:
    net_dsk=""
    netica_dir = "C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/BN_Mapping/Netica/"
    print u"No file was given, will search for \"variables.neta\""

# Variables para definir los parámetros de operación
nodo_objetivo = "zvh" # Zvh_8ph, 
nueva_red_nombre = "T02_test.neta"
primerPlano = 1
controlUsuario = False

# Initialize NETICA environment
netica_app = inicia_netica(netica_dir)
netica_app.SetWindowPosition(status="Hidden")
# netica_app.visible = primerPlano
# netica_app.UserControl = controlUsuario ----- no se puede cambiar

print "\n"*2 + "#" * 40 + "\nAbriendo Netica\n" + "#" * 40 
print "Netica iniciada: " + netica_app.VersionString + ""
print "Localización licencia: " + netica_dir
if net_dsk.rfind(".neta") < 0:
    dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
    dir_datos = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004/train_data_pack/"
    net_dsk = dir_robin + dir_datos +"variables.neta"

# Open selected Network file
name = netica_app.NewStream(net_dsk)
net_p = netica_app.ReadBNet(name, "")
print u"Red abierta: " + net_p.Name
print u"Archivo seleccionado: " + net_p.FileName.split("/")[-1]
print u"Descripción de la red: " + net_p.Comment + u" Todas las variables de ROBIN-Mex"

# Anota en un diccionario los datos de los nodos contenidos en "variables.neta"
nodos_dic = lista_nodos_diccionario(net_p)

# Selecciona nodos de interés y los copia en una nueva red.
print u"Nodo de interés seleccionado: " + nodo_objetivo
nt_nueva, nodosNuevosList_p = copia_variables_interes(nodos_dic)

# Cierra la red de todas las variables.
net_p.Delete()

# Prepara casos para entrenamiento y pruebas
casos_st = prepara_casos ("bn_train_20150713_sin_NA.csv")

# Prueba la red con todos los enlaces tipo "naive" 
err_naive = prueba_RB_naive ()
print u"Tasa de error modelo \"Naive\" completo: {:10.4f}".format(err_naive)

# Prueba la red un nodo a la vez tomado de esta lista
variables_lst = ["ppt%02d" % (i,) for i in range(1, 13)]
variables_lst.extend(["tmax%02d" % (i,) for i in range(1, 13)])
variables_lst.extend(["tmin%02d" % (i,) for i in range(1, 13)])

errores = {}
for nodo in sorted(variables_lst):
    red_nula(nodo_objetivo, variables_lst)    
    nodosNuevosList_p[nodo].AddLink(nodosNuevosList_p[nodo_objetivo])
    nodosNuevosList_p[nodo].AddLink(nodosNuevosList_p["dem30_mean1000"])
    nodosNuevosList_p[nodo].AddLink(nodosNuevosList_p["dem30_sd1000"])
    entrena_BNet (nodosNuevosList_p, casos_st, 1)
    tasaError = prueba_BNet(nodo_objetivo, casos_st)
    errores[nodo] = tasaError
    print "Tasa de error <" + nodo +"> : ""{:10.4f}".format(tasaError)
red_nula (nodo_objetivo, variables_lst)    

# Anota resultados en la hoja de descripción y guarda la nueva red
descripcion_nueva_red (nt_nueva, errores)

# Guarda la nueva y prepara pruebas
nueva_dsk = dir_robin + dir_datos +nueva_red_nombre
nueva_st = netica_app.NewStream(nueva_dsk)
nt_nueva.Write(nueva_st)
print "Nueva red guardada en: " + nueva_red_nombre   

print "procesamiento terminado ***************"
print "Cerrando NETICA!"
netica_app.Quit()
    