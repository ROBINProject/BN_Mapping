# -*- coding: utf-8 -*-
"""
Created on Sat Jul 18 13:58:13 2015

Read the zvh network with nodes without links and arranges it
by vairable type by rows

@author: Miguel
"""
import os
import re

import argparse
from win32com.client import Dispatch


#
#-------------------- Funciones y clases locales --------------------------
#
class learn_method:
    counting=1
    EM=3
    gradient=4

def inicia_netica(lic_dir):
    # Vincula la interface COM de NETICA y activa la aplicacion
    # Asume que la licencia esta en el mismo directorio de la aplicacion
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
    # Crea una nueva red con los nodos de interes y los arregla
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
    # Crea todos los links tipo "Naive" del "nodo_objetivo" hacia los demas
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
    print "Tasa de error modelo \"Naive\" completo: {:10.4f}".format(tasaError)
    #
    # Anota avance del calculo en la seccion de "descripcion" de la red
    resultados = ["#" * 80]
    if len(coment_red_origen) > 0:
        resultados.append (coment_red_origen + "\n" + "#" * 80)
    resultados.append ("".join(["Netica ", netica_app.VersionString, 
                       ". Iniciada con: ", "ROBIN_netica_zvh_training.py"]))
    resultados.append ("".join(["#" * 80, "\n"]))
    resultados.append ("".join(["Licencia buscada en: ", netica_dir]))
    resultados.append ("".join(["Nodo de interes seleccionado: ", nodo_objetivo]))
    resultados.append ("".join(["Nueva red guardada en: ", nueva_red_nombre]))
    resultados.append ("Tasa de error modelo \"Naive\" completo: {:10.4f}".format(tasaError))
    nt_nueva.Comment = "\n".join(resultados)

def pruebas_de_1 (nd_obj, nodos_p, vars_lst):
    # Prueba la red "un-nodo-a-la-vez" tomado de la lista de variables
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n" * 2, "-" * 80])
    errores = {}
    for nodo in sorted(vars_lst):
        red_nula(nodo_objetivo, variables_lst)    
        nodos_p[nodo].AddLink(nodos_p[nd_obj])
        nodos_p[nodo].AddLink(nodos_p["dem30_mean1000"])
        nodos_p[nodo].AddLink(nodos_p["dem30_sd1000"])
        entrena_BNet (nodos_p, casos_st, 1)
        tasaError = prueba_BNet(nd_obj, casos_st)
        errores[nodo] = tasaError
        print "".join(["Tasa de error <", nodo, "> : ""{:10.4f}".format(tasaError)])
        nt_nueva.Comment = "".join([nt_nueva.Comment, "\nTasa de error <",
                                    nodo, "> : ""{:10.4f}".format(tasaError)])
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n", "-" * 80, "\n"])
    red_nula (nd_obj, vars_lst)    

def pruebas_de_2 (nd_obj, nodos_p, vars_lst):
    # Prueba de la red con pares de variables
    nt_nueva.Comment = "".join([nt_nueva.Comment, 
                                "\n\nBloque de pruebas en bloques de 2"])
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n", "-" * 80])
    errores2 = {} 
    for nodo in sorted(vars_lst)[0:-1]:  #  Ajuste según avance
        red_nula(nd_obj, vars_lst)    
        nodos_p[nodo].AddLink(nodos_p[nd_obj])
        nodos_p[nodo].AddLink(nodos_p["dem30_mean1000"])
        nodos_p[nodo].AddLink(nodos_p["dem30_sd1000"])
        i = vars_lst.index(nodo) + 1
        nt_nueva.Comment = "".join([nt_nueva.Comment, "\n"])
        for odon in sorted(vars_lst)[i:]:
            nodos_p[odon].AddLink(nodos_p[nd_obj])
            nodos_p[odon].AddLink(nodos_p["dem30_mean1000"])
            nodos_p[odon].AddLink(nodos_p["dem30_sd1000"])
            entrena_BNet (nodos_p, casos_st, 1)
            tasaError = prueba_BNet(nd_obj, casos_st)
            errores2[nodo + "_" + odon] = tasaError
            print "".join(["Tasa de error <", nodo, "_", odon, 
                           "> : ""{:10.4f}".format(tasaError)])
            nt_nueva.Comment = "".join([nt_nueva.Comment, "Tasa de error <",
                                        nodo, "_", odon, 
                                        "> : ""{:10.4f}\n".format(tasaError)]) 
            red_nula (nd_obj, vars_lst)    
            nodos_p[nodo].AddLink(nodos_p[nd_obj])
            nodos_p[nodo].AddLink(nodos_p["dem30_mean1000"])
            nodos_p[nodo].AddLink(nodos_p["dem30_sd1000"])
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n", "-" * 80 + "\n"])
    red_nula (nd_obj, vars_lst)    

def pruebas_de_3 (nd_obj, nodos_p, vars_lst):
    # Prueba de la red con pares de variables
    nt_nueva.Comment = "".join([nt_nueva.Comment, 
                                "\n\nBloque de pruebas en bloques de 2"])
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n", "-" * 80])
    errores2 = {} 
    for uno in sorted(vars_lst)[:-2]:
        red_nula(nd_obj, vars_lst)    
        nodos_p[uno].AddLink(nodos_p[nd_obj])
        nodos_p[uno].AddLink(nodos_p["dem30_mean1000"])
        nodos_p[uno].AddLink(nodos_p["dem30_sd1000"])
        i = vars_lst.index(uno) + 1
        nt_nueva.Comment = "".join([nt_nueva.Comment, "\n"])
        for dos in sorted(vars_lst)[i:-1]:
            nodos_p[dos].AddLink(nodos_p[nd_obj])
            nodos_p[dos].AddLink(nodos_p["dem30_mean1000"])
            nodos_p[dos].AddLink(nodos_p["dem30_sd1000"])
            j = vars_lst.index(dos) + 1
            j = 35
            for tres in sorted(vars_lst)[j:]:
                nodos_p[tres].AddLink(nodos_p[nd_obj])
                nodos_p[tres].AddLink(nodos_p["dem30_mean1000"])
                nodos_p[tres].AddLink(nodos_p["dem30_sd1000"])
                entrena_BNet (nodos_p, casos_st, 1)
                tasaError = prueba_BNet(nd_obj, casos_st)
                errores2 ["".join([uno, "_", dos, "_", tres])] = tasaError
                print "".join(["Tasa de error <", uno, "_", dos, "_", tres, 
                               "> : {:10.4f}".format(tasaError)])
                nt_nueva.Comment = "".join([nt_nueva.Comment, "Tasa de error <", 
                          uno, "_", dos, "_", tres, 
                          "> : ""{:10.4f}\n".format(tasaError)])
                red_nula (nd_obj, vars_lst)    
                nodos_p[uno].AddLink(nodos_p[nd_obj])
                nodos_p[uno].AddLink(nodos_p["dem30_mean1000"])
                nodos_p[uno].AddLink(nodos_p["dem30_sd1000"])
                nodos_p[dos].AddLink(nodos_p[nd_obj])
                nodos_p[dos].AddLink(nodos_p["dem30_mean1000"])
                nodos_p[dos].AddLink(nodos_p["dem30_sd1000"])
    nt_nueva.Comment = "".join([nt_nueva.Comment, "\n", "-" * 80, "\n"])
    red_nula (nd_obj, vars_lst)    

def descripcion_nueva_red (red_nva, err_nv, err1, err2):
    resultados = red_nva.Comment
    resultados.append ("\n" + "-" * 80)
    resultados.append ("Modelos una variable a la vez")
    for e in sorted(err1):
        resultados.append("".join(["Tasa de error con la variable ", e,
                           ": {:10.4f}".format(err1[e])]))
    resultados.append ("".join(["-" * 80, "\n"*2]))
    resultados.append ("".join(["\n", "-" * 80]))
    resultados.append ("Modelos con dos variable")
    for e in sorted(err2):
        resultados.append("".join(["Tasa de error con la variable ", e,
                           ": {:10.4f}".format(err2[e])]))
    resultados.append ("".join(["-" * 80, "\n"*2]))
    resultados.append ("procesamiento terminado ***************")
    resultados.append ("Cerrando NETICA!")
    red_nva.Comment = "\n".join(resultados)
#-----------------------------------------------------------------


# Variables para definir los parametros de operacion
#usage = "uso: %prog --target --pruebas --base_Network"
#parser = OptionParser(usage=usage, version="%prog version 0.1")
#choices=['rock', 'paper', 'scissors']
parser = argparse.ArgumentParser()
parser.add_argument("-t", "--target", metavar="1/2/3", type = int, 
                  dest = "target", default = 1,
                  help="Digito para elegir variable objetivo: 1=Zvh_8ph, 2=zvh, 3=zvh_31")
parser.add_argument("-p", "--pruebas", metavar="alguna(s) 0,1,2,3",  
                  dest = "pruebas", default = "2", 
                  help="Que pruebas hacer, cualquier combinacion de 0 (naive), 1, 2, 3")
parser.add_argument("-b", "--base", metavar="File_NETA", 
                  dest="base", default="variables.neta",
                  help="Lee los nodos desde la red fuente: redB.dne") 

# Recupera informacion de la linea de comandos y establece los parametros
args = parser.parse_args()
objetivo_seleccionado = args.target - 1
net_dsk = args.base
pruebas = set(map(int, args.pruebas.split(",")))
netica_dir = "C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/BN_Mapping/Netica/"
nodos_obj = {"Zvh_8ph":"A01_test.neta", "zvh":"A02_test.neta", "zvh_31":"A03_test.neta"}
nodo_objetivo = nodos_obj.keys()[objetivo_seleccionado]
nueva_red_nombre = nodos_obj.values()[objetivo_seleccionado]
primerPlano = 1
controlUsuario = False

# Initialize NETICA environment
netica_app = inicia_netica(netica_dir)
netica_app.SetWindowPosition(status="Regular") # Hidden, Regular
# netica_app.visible = primerPlano
# netica_app.UserControl = controlUsuario ----- no se puede cambiar
opciones_str = "".join([str(args.target), " ", args.pruebas, " ", args.base])
print "".join(["\n"*2, "#" * 40, "\nAbriendo Netica\n", "#" * 40]) 
print "".join(["Parametros: ", opciones_str])
print "".join(["Netica iniciada: ", netica_app.VersionString])
print "".join(["Se busco licencia en: ", netica_dir])

dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
dir_datos = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004/train_data_pack/"
if net_dsk.rfind(".neta") < 0:
    net_dsk = dir_robin + dir_datos +"variables.neta"
else:
    net_dsk = dir_robin + dir_datos + net_dsk
# Open selected Network file
name = netica_app.NewStream(net_dsk)
net_p = netica_app.ReadBNet(name, "")
print "".join(["Red abierta: ", net_p.Name])
print "".join(["Archivo seleccionado: ", net_p.FileName.split("/")[-1]])
print "".join(["Descripcion de la red: ", net_p.Comment, 
                " Todas las variables de ROBIN-Mex"])

# Anota en un diccionario los datos de los nodos contenidos en "variables.neta"
nodos_dic = lista_nodos_diccionario(net_p)

# Selecciona nodos de interes y los copia en una nueva red.
print "".join(["Nodo de interes seleccionado: ", nodo_objetivo])
coment_red_origen = net_p.Comment
nt_nueva, nodosNuevosList_p = copia_variables_interes(nodos_dic)

# Cierra la red de todas las variables.
net_p.Delete()

# Prepara casos para entrenamiento y pruebas
casos_st = prepara_casos ("bn_train_20150713_sin_NA.csv")

# Lista usada para organizar el proceso iterativo de prueba
variables_lst = ["ppt%02d" % (i,) for i in range(1, 13)]
variables_lst.extend(["tmax%02d" % (i,) for i in range(1, 13)])
variables_lst.extend(["tmin%02d" % (i,) for i in range(1, 13)])

if set([0]).issubset(pruebas):
    # Prueba la red con todos los enlaces tipo "naive" 
    prueba_RB_naive ()

if set([1]).issubset(pruebas):
    pruebas_de_1 (nodo_objetivo, nodosNuevosList_p, variables_lst)

if set([2]).issubset(pruebas):
    pruebas_de_2 (nodo_objetivo, nodosNuevosList_p, variables_lst)

if set([3]).issubset(pruebas):
    pruebas_de_3 (nodo_objetivo, nodosNuevosList_p, variables_lst)

# Anota resultados en la hoja de descripcion
# descripcion_nueva_red (nt_nueva, err_naive, errores, errores2)

# Guarda la nueva
nueva_dsk = dir_robin + dir_datos + nueva_red_nombre
nueva_st = netica_app.NewStream(nueva_dsk)
nt_nueva.Write(nueva_st)
print "".join(["Nueva red guardada en: ", nueva_red_nombre])   

print "procesamiento terminado ***************"
print "Cerrando NETICA!"

nueva_st.Delete()
nt_nueva.Delete()
netica_app.Quit()
