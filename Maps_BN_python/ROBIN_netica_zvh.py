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
import logging
logger = logging.getLogger(__name__)

# import ctypes for wrapping netica.dll
from ctypes.util import find_library
from ctypes import windll, c_char, c_char_p, c_void_p, c_int, c_double
from ctypes import create_string_buffer

# constants
MESGLEN = 600
REGULAR_WINDOW=0x70

# Check if there is a file name in the command line
net_dsk = sys.argv[1]

# find and load the library, assuming in a relative path closeby
netica_dir = os.path.abspath("../Netica/")
libN = windll.LoadLibrary(find_library(netica_dir + "/netica"))
licensefile = netica_dir + "/inecol_netica.txt"
licensia = open(licensefile, 'r').readlines()[0].strip().split()[0]

# Initialize a PyNetica instance/env using password in a text file
env_p = c_void_p(libN.NewNeticaEnviron_ns(licensia, None, None))

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
res = c_int(libN.InitNetica2_bn(env_p, mesg))
logger.info(mesg.value)
print '\n'*2 + '#' * 40 + '\nOpening Netica:'
print mesg.value

if net_dsk.rfind(".neta") < 0:
    # Reads a NETICA net from file
    # parameters: (stream_ns* file, int options)
    dir_robin = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN"
    dir_datos = u"/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/2004"
    net_dsk = dir_robin + dir_datos +"/M00_VariablesB.neta"

name = create_string_buffer(net_dsk)
file_p = c_void_p(libN.NewFileStream_ns (name, env_p, None)) # file_p
net_p = c_void_p(libN.ReadNet_bn(file_p, REGULAR_WINDOW)) # net_p

file_name = c_char_p (libN.GetNetFileName_bn (net_p))
net_name = c_char_p (libN.GetNetName_bn(net_p))

"""
get net nodes
"""
# (const net_bn* net, const char options[])
zerochar_type = c_char*0
nl_p = c_void_p(libN.GetNetNodes2_bn(net_p, zerochar_type())) # nl_p

"""
get number of nodes
"""
# (const nodelist_bn* nodes)
nnodes = c_int(libN.LengthNodeList_bn(nl_p)) # nnodes

# Collect all node names in network
node_names = {"gral":{}, "infys":{}, "pp":{}, "pt":{}, "tm":{}, "tr":{}, "tx":{}}
for i in range(nnodes.value):
    node_p = c_void_p(libN.NthNode_bn(nl_p, i)) # node_p
    name = c_char_p(libN.GetNodeName_bn(node_p)) # name
    if re.search(r"^[xyZzdC]", name.value):
        node_names["gral"][name.value] = node_p
    elif re.search(r"(^ntre|^Diam|^Alt|^Ins|^Sin|^prob|^Psn|^Gpp)", name.value):
        node_names["infys"][name.value] =   node_p        
    elif re.search(r"^ppt[0-1]{1}", name.value):
        node_names["pp"][name.value] =   node_p
    elif re.search(r"^pptm", name.value):
        node_names["pt"][name.value] =   node_p
    elif re.search(r"^tma", name.value):
        node_names["tx"][name.value] =   node_p
    elif re.search(r"^tmi", name.value):
        node_names["tm"][name.value] =   node_p
    else:
        node_names["tr"][name.value] =   node_p   


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
        libN.SetNodeVisPosition_bn(node_names[node][k], None, c_double(x), c_double(y))
        items = items + k
        j = j + 1

if net_dsk.rfind(".neta") < 0:
    # Write network on disk
    net_dsk_nuevo = dir_robin + dir_datos +"/M00_VariablesD.neta"
    file_p = c_void_p(libN.NewFileStream_ns(create_string_buffer(net_dsk_nuevo),env_p, None))
    libN.WriteNet_bn(net_p, file_p)
else:
    net_dsk_nuevo = "M00_VariablesD.neta"
    file_p = c_void_p(libN.NewFileStream_ns(create_string_buffer(net_dsk_nuevo),env_p, None))
    libN.WriteNet_bn(net_p, file_p)
    

# Close Netica instance of network before finishing
libN.CloseNetica_bn(env_p)





