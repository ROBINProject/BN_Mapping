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

# Check if there is a file name in the command line
try:
    net_dsk = sys.argv[1]
except IndexError:
    net_dsk=""
    print "No file was given, will search for A00_Variables.neta"

# Vincula la interface COM de NETICA y activa la aplicación

# find and load the library, assuming in a relative path closeby
netica_dir = os.path.abspath("../../Netica/")
nt = Dispatch("Netica.Application")
licenseFile = netica_dir + "/inecol_netica.txt"
licencia = open(licenseFile, 'r').read()

# Initialize a PyNetica instance/env using password in an independent text file
nt.SetPassword(licencia)
nt.SetWindowPosition(status="Hidden") # Regular, Minimized, Maximized, Hidden

# Initialize NETICA environment
print '\n'*2 + '#' * 40 + '\nOpening Netica:'
print "Netica iniciado: " + nt.VersionString + ""
net_dsk_nuevo = "M00_VariablesDDD.neta"
if net_dsk.rfind(".neta") < 0:
    # Reads a NETICA net from file
    # parameters: (stream_ns* file, int options)
    dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
    dir_datos = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004/train_data_pack/"
    net_dsk = dir_robin + dir_datos +"A00_Variables.neta"
    net_dsk_nuevo = dir_robin + dir_datos + net_dsk_nuevo

# Open selected Network file
name = nt.NewStream(net_dsk)
net_p = nt.ReadBNet(name, "")
net_p.compile()
print u"Red abierta " + net_p.Name
print u"Archivo seleccionado " + net_p.FileName.split("/")[-1]
print u"Descripción de la red: " + net_p.Comment + u" Todas las variables de ROBIN-Mex"

# Get the pointer to the set of nodes

"""
get net nodes
"""
nl_p = net_p.Nodes

"""
get number of nodes
"""
# (const nodelist_bn* nodes)
nnodes = nl_p.Count

# Collect all node names in network
node_names = {"gral":{}, "infys":{}, "pp":{}, "pt":{}, "tm":{}, "tr":{}, "tx":{}}
for i in range(nnodes):
    node_p = nl_p[i] # node_p
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


"""
Set node position and sort nodes
"""
y = 0
for node in sorted(node_names):
    j, items = 0, "    "
    y = y + 30
    for k in sorted(node_names[node].keys()):
        if len(items) > 100:
            y = y + 30
            j, items = 0, "    "
        # y = 30 * (list(sorted(node_names.keys())).index(node) + 1)
        x = j * 21 + len(items) * 8 + len(k) * 4
        node_names[node][k].VisualPosition = (x, y)
        items = items + k
        j = j + 1

# Write network on disk
file_p = nt.NewStream(net_dsk_nuevo)
net_p.Write(file_p)
    
# Close Netica instance of network before finishing
nt.Quit()





