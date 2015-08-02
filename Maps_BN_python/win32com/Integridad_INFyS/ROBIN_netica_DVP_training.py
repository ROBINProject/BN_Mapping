# -*- coding: utf-8 -*-
"""
Created on Sat Jul 18 13:58:13 2015

Read the DeltaVP(Z network with nodes without links and arranges it
by vairable type by rows

@author: Miguel
"""
from funciones import xl_out, learn_method, pyNetica, Netica_RB_EcoInt
import argparse
import os

# Index for excel writting
xl_row = 1
xl_col = 1
# Variables para definir los parametros de operacion
# usage = "uso: %prog --target --pruebas --base_Network"
# parser = OptionParser(usage=usage, version="%prog version 0.1")
# choices=['rock', 'paper', 'scissors']
parser = argparse.ArgumentParser()
parser.add_argument("-t", "--target", metavar=u"1/2/3", type=int,
                    dest="target", default=1, help=u"Digit to" +
                         u" Chose zvh variable: 1=Zvh_8ph, 2=zvh," +
                         u" 3=zvh_31")
parser.add_argument("-a", u"--analysis", metavar=u"alguna(s) 0,1,2,3",
                    dest=u"pruebas", default=u"2",
                    help=u"What analisis to do, any combination" +
                    u" of 0 (naive), 1, 2, 3")
parser.add_argument("-b", "--base", metavar="File_NETA",
                    dest=u"base", default=u"variables.neta",
                    help=u"read nodes from source BNet: redB.neta")

# Recupera informacion de la linea de comandos y establece los parametros
args = parser.parse_args()
zvh_seleccionado = args.target - 1
net_dsk = args.base
pruebas = set(map(int, args.pruebas.split(",")))
netica_dir = "".join([u"C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/",
                      u"BN_Mapping/Netica/"])
nodos_zvh_dic = {u"Zvh_8ph": u"A01_test.neta", u"zvh": u"A02_test.neta",
                 u"zvh_31": u"A03_test.neta"}
dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
dir_datos = "". join([u"/Datos RoBiN/México/0_Vigente/GIS/",
                      "Mapas_base/2004/train_data_pack/"])
nodo_zvh = nodos_zvh_dic.keys()[zvh_seleccionado]
nodo_objetivo = u"zz_delt_vp"
nueva_red_nombre = "-".join([nodo_objetivo, nodo_zvh])
primerPlano = 1

# Initialize NETICA environment and Excel
netica_app = pyNetica(netica_dir, 1).netica_app
xl_app = xl_out("Resultados_EI", True)
xlwrite = xl_app.xlw

# Open selected Network file
if net_dsk.rfind(".neta") < 0:
    net_dsk = dir_robin + dir_datos + "variables.neta"
else:
    net_dsk = dir_robin + dir_datos + net_dsk
name = netica_app.NewStream(net_dsk)
net_p = netica_app.ReadBNet(name, "")
mez = Netica_RB_EcoInt(netica_app, net_p, learn_method.counting,
                       nodo_zvh, nodo_objetivo, nueva_red_nombre)

# netica_app.visible = primerPlano
# netica_app.UserControl = controlUsuario ----- no se puede cambiar
opciones_str = "".join([str(args.target), " ", args.pruebas, " ", args.base])
xlwrite(2, 1, "".join(["#" * 10, " Abriendo Netica ", "#" * 10]))
xlwrite(3, 1, "Parametros: ")
xlwrite(3, 2, opciones_str)
xlwrite(4, 1, "Netica started: ")
xlwrite(4, 2, netica_app.VersionString)
xlwrite(5, 1, "License searched in: ")
xlwrite(5, 2, netica_dir)
xlwrite(6, 1, "Red abierta: ")
xlwrite(6, 2, net_p.Name)
xlwrite(7, 1, "Archivo seleccionado: ")
xlwrite(7, 2, net_p.FileName.split("/")[-1])
xlwrite(8, 1, "Descripcion de la red: ")
xlwrite(8, 2, net_p.Comment)
xl_row = 9

# Anota en un diccionario los datos de los nodos contenidos en "variables.neta"
# nodos_dic =
mez.lista_nodos_diccionario()

# Selecciona nodos de interes y los copia en una nueva red.
xlwrite(xl_row, 1, "".join(["Nodo de interes seleccionado: ", nodo_objetivo]))
coment_red_origen = net_p.Comment

# nt_nueva, nodosNuevosList_p =
mez.copia_variables_interes()

# Cierra la red de todas las variables.
net_p.Delete()

# Prepara casos para entrenamiento y pruebas
# casos_st =
casos_dsk = u"".join([dir_robin, dir_datos, "bn_train_20150713_sin_NA.csv"])
mez.prepara_casos(casos_dsk)

# Lista usada para organizar el proceso iterativo de prueba
variables_lst = mez.nuevos_nodos["infys"].keys()

if set([0]).issubset(pruebas):
    # Prueba la red con todos los enlaces tipo "naive"
    mez.prueba_RB_naive(xl_row, netica_dir, xlwrite)

if set([1]).issubset(pruebas):
    mez.pruebas_de_1(xl_row, variables_lst, xlwrite)

if set([2]).issubset(pruebas):
    ccc = mez.pruebas_de_2(xl_row, variables_lst, xlwrite)

if set([3]).issubset(pruebas):
    mez.pruebas_de_3(nodo_objetivo, mez.nodosNuevosList_p, variables_lst, xlwrite)


# Anota resultados en la hoja de descripcion
# descripcion_nueva_red(nt_nueva, err_naive, errores, errores2)

# Guarda la nueva
nueva_dsk = dir_robin + dir_datos + nueva_red_nombre + ".neta"
nueva_st = mez.netApp.NewStream(nueva_dsk)
mez.nt_nueva.Write(nueva_st)
xl_row = xl_row + 1
xlwrite(xl_row, 1, "".join(["Nueva red guardada en: ", nueva_red_nombre]))

xl_row = xl_row + 1
xlwrite(xl_row, 1, "procesamiento terminado ***************")
xl_row = xl_row + 1
xlwrite(xl_row, 1, "Cerrando NETICA!")

nueva_st.Delete()
mez.nt_nueva.Delete()
mez.netApp.Quit()
del mez

# Close Excel and get rid of object refering to it
os.chdir(u"".join([dir_robin, dir_datos]))
xl_dsk = u"Resultados_EI_1.xlsx"
xl_app.workbook.SaveAs(xl_dsk)
xl_app.excelapp.Quit()
del xl_app.excelapp
del xl_app
