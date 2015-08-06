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
parser = argparse.ArgumentParser()
parser.add_argument("-z", "--zvh", metavar=u"1/2/3", type=int,
                    dest="zvh_type", default=1, help=u"Digit to" +
                         u" Chose zvh variable: 1=Zvh_8ph, 2=zvh," +
                         u" 3=zvh_31")
parser.add_argument("-a", u"--analysis", metavar=u"alguna(s) 0,1,2,3",
                    dest=u"pruebas", default=u"0",
                    help=u"What analisis to do, any combination" +
                    u" of 0 (naive), 1, 2, 3")
parser.add_argument("-b", "--base", metavar="File_NETA",
                    dest=u"base", default=u"variables_2n.neta",
                    help=u"read nodes from source BNet: redB.neta")
parser.add_argument("-e", "--equipo", metavar=u"lap_m/esc_m/otro",
                     dest=u"equipo", default=u"lap_m", 
                     help=u"selecciona la ubicación de archivos según equipo")

# Recupera informacion de la linea de comandos y establece los parametros
args = parser.parse_args()
zvh_seleccionado = args.zvh_type - 1
net_dsk = args.base
pruebas = set(map(int, args.pruebas.split(",")))
equipo = args.equipo

if equipo == "lap_m":
    netica_dir = u"".join([u"C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/",
                           u"BN_Mapping/Netica/"])
    dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
else:
    netica_dir = u"".join([u"C:/Users/miguel.equihua/Documents/0-GIT/", 
                          u"Publicaciones y proyectos/BN_Mapping/Netica/"])
    dir_robin = u"C:/Users/miguel.equihua/Documents/1 Nube/Google Drive/2 Proyectos/RoBiN"
    
dir_datos = u"". join([u"/Datos RoBiN/México/0_Vigente/GIS/",
                      "Mapas_base/2004/train_data_pack/"])
                           
nodos_zvh_dic = {u"Zvh_8ph": u"B01_test.neta", u"zvh": u"B02_test.neta",
                 u"zvh_31": u"B03_test.neta"}

datos_dsk = ["variables_2n.neta", "variables_3n.neta", "variables_4n.neta",
             "variables_5n.neta", "variables_10n.neta"]
nodo_zvh = nodos_zvh_dic.keys()[zvh_seleccionado]
nodo_objetivo = u"zz_delt_vp"
nueva_red_nombre = u"-".join([nodo_objetivo, nodo_zvh])
primerPlano = 1

# Initialize NETICA environment and Excel
netica_app = pyNetica(netica_dir, 1).netica_app
xl_app = xl_out("Resultados_EI", True)
xlwrite = xl_app.xlw

# Open selected Network file
if net_dsk.rfind(".neta") < 0:
    net_dsk = dir_robin + dir_datos + "variables_2.neta"
else:
    net_dsk = dir_robin + dir_datos + net_dsk
name = netica_app.NewStream(net_dsk)
net_p = netica_app.ReadBNet(name, "")
coment_red_origen = net_p.Comment
net_p.Comment = u"Colección de variables con discretización a 2 niveles"
mez = Netica_RB_EcoInt(netica_app, net_p, learn_method.counting,
                       nodo_zvh, nodo_objetivo, nueva_red_nombre)

# netica_app.visible = primerPlano
# netica_app.UserControl = controlUsuario ----- no se puede cambiar
opciones_str = u"".join([str(args.zvh_type), " ", args.pruebas, " ", args.base])
xlwrite(2, 1, u"".join(["#" * 10, " Abriendo Netica ", "#" * 10]))
xlwrite(3, 1, u"Parametros: ")
xlwrite(3, 2, opciones_str)
xlwrite(4, 1, u"Netica iniciada: ")
xlwrite(4, 2, netica_app.VersionString)
xlwrite(5, 1, u"Licencia buscada en: ")
xlwrite(5, 2, netica_dir)
xlwrite(6, 1, u"Red abierta: ")
xlwrite(6, 2, net_p.Name)
xlwrite(7, 1, u"Archivo seleccionado: ")
xlwrite(7, 2, net_p.FileName.split("/")[-1])
xlwrite(8, 1, u"Descripcion de la red: ")
xlwrite(8, 2, coment_red_origen)
xlwrite(9, 1, u"Nodo <ZVH> seleccionado: ")
xlwrite(9, 2, nodo_zvh)
xlwrite(10, 1, u"Probabilidad de error al elegir al azar: ")
xlwrite(10, 2, u"=1-1/18")
xl_row = 11

# Anota en un diccionario los datos de los nodos contenidos en "variables.neta"
# nodos_dic =
mez.lista_nodos_diccionario()

# Selecciona nodos de interes y los copia en una nueva red.
mez.copia_variables_interes(nodos_zvh_dic)
xlwrite(xl_row, 1, u"".join(["Nodo objetivo: ", nodo_objetivo]))
xlwrite(xl_row + 1, 2, u"Error RB")
xl_row = xlwrite(xl_row + 1, 3, u"Mejora")

# Cierra la red de todas las variables.
net_p.Delete()

# Prepara casos para entrenamiento y pruebas
# casos_st =
casos_dsk = u"".join([dir_robin, dir_datos, "bn_train_20150713_sin_NA.csv"])
mez.prepara_casos(casos_dsk)

# Lista usada para organizar el proceso iterativo de prueba
variables_set = set(mez.nuevos_nodos["infys"].keys())

if set([0]).issubset(pruebas):
    # Prueba la red con todos los enlaces tipo "naive"
    for nn in nodos_zvh_dic:
        err = mez.prueba_RB_naive(xl_row, variables_set, nn, netica_dir, xlwrite)
        xl_row = xl_row
        xlwrite(xl_row, 1, u"Error modelo \"Naive\" completo <" + nn + "> : ")
        xlwrite(xl_row, 2, err)
        xl_row = xlwrite(xl_row, 3, "=($B$10 / B{:0d}".format(xl_row) + ") - 1")

if set([1]).issubset(pruebas):
    mez.pruebas_de_1(xl_row, variables_set, xlwrite)

if set([2]).issubset(pruebas):
    ccc = mez.pruebas_de_2(xl_row, variables_set, xlwrite)

if set([3]).issubset(pruebas):
    xl_row, ccc = mez.pruebas_3(xl_row, variables_set, xlwrite)


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
xl_wd = os.getcwdu()
node_niveles = os.path.basename(net_dsk).split("_")[1].split(".")[0]
xl_dsk = xl_wd + u"\\Step_Naive_EI_" + nodo_zvh + "_" + node_niveles + ".xlsx"

xl_app.workbook.SaveAs(xl_dsk)
xl_app.excelapp.Quit()
del xl_app.excelapp
del xl_app
