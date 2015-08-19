import os

import numpy as np

import pandas as pd

import re

from geotiffio import readtif, createtif, writetif

from win32com.client import Dispatch

"""
  Funciones locales para el cálculo de la IE
"""


def lista_nodos_diccionario(BNet):
    # Get the pointer to the set of nodes
    nodesList_p = BNet.Nodes
    # get number of nodes
    nnodes = nodesList_p.Count
    # Collect all node names in network
    node_names = {"gral": {}, "infys": {}}
    for i in range(nnodes):
        node_p = nodesList_p[i]   # node_p
        name = node_p.name        # name
        if re.search(r"^[xyZzdC]", name):
            node_names["gral"][name] = node_p
        else:
            re.search(r"(^ntre|^Diam|^Alt|^Ins|^Sin|^prob|^Psn|^Gpp)",
                      name)
            node_names["infys"][name] = node_p
    return node_names


def process_on_data_table(lic_arch, net_file_name):
    print "Welcome to Netica API for COM with Python!"

    # Vincula la interface COM de NETICA y activa la aplicación
    nt = Dispatch("Netica.Application")

    # Lee la licensia de activasión de Netica
    lic_arch = lic_arch + "/inecol_netica.txt"
    licencia = open(lic_arch, "rb").read()
    nt.SetPassword(licencia)
    # Window status could be: Regular, Minimized, Maximized, Hidden
    nt.SetWindowPosition(status="Hidden")

    # Display NETICA version
    print "Using Netica version " + nt.VersionString

    # Prepare the stream to read requested BN
    streamer = nt.NewStream(net_file_name)

    # ReadBNet 'options' can be one of "NoVisualInfo", "NoWindow",
    # or the empty string (means create a regular window)
    net = nt.ReadBNet(streamer, "NoVisualInfo")
    net.compile()

    # Read the beleif values under specified conditions
    node_lst = lista_nodos_diccionario(net)
    for nd in node_lst:
        nd.EnterValue(1.5)
    expected_val = node_lst["zz_delt_vp"].GetExpectedValue(sd)
    print "EI mean {:0.4f}".format(expected_val)

    # Se libera el espacio de momoria usado por la red
    net.Delete()

# ----------------------------------------------------

equipo = "lap_m"

if equipo == "lap_m":
    netica_dir = u"".join([
        u"C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/",
        u"BN_Mapping/Netica/"])
    dir_robin =\
        u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
else:
    netica_dir = u"".join([u"C:/Users/miguel.equihua/Documents/0-GIT/",
                          u"Publicaciones y proyectos/BN_Mapping/Netica/"])
    dir_robin = u"C:/Users/miguel.equihua/Documents/1 Nube/" +\
                u"Google Drive/2 Proyectos/RoBiN"

dir_datos = u"". join([u"/Datos RoBiN/México/0_Vigente/GIS/",
                      "Mapas_base/2004/train_data_pack/"])


dir_tif = re.sub("2004/train_data_pack/", "", dir_robin + dir_datos)
files = [f for f in os.listdir(dir_tif) if re.findall("tif$", f)]

# read one image to get metadata
dataset, rows, cols, bands = readtif(dir_tif + files[0])

# image metadata
projection = dataset.GetProjection()
transform = dataset.GetGeoTransform()
driver = dataset.GetDriver()

# prediction table (pixels are rows, columns are variables)
data_table = np.zeros((cols * rows, len(files)))

for b in xrange(len(files)):
    image, rows, cols, bands = readtif(dir_tif + files[b])
    band = image.GetRasterBand(b + 1)
    band = band.ReadAsArray(0, 0, cols, rows).astype(float)
    data_table[:, b] = np.ravel(band)

### insert process to predict using data_table
net_file_name = dir_datos + "BN_test_python.neta"
ie_map = process_on_data_table(netica_dir, net_file_name)

### write ie_map to disk
output_name = dir_tif + "filename.tif"

outData = createtif(driver, rows, cols, 1, output_name)

writetif(outData, ie_map, projection, transform, order='c')

# close dataset properly
outData = None
