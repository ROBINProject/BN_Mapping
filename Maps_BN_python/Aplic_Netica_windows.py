# -*- coding: utf-8 -*-
"""
Created on Sat Jun 20 01:09:47 2015

@author: Miguel

Example of wrapping cos function from math.h using ctypes. 
"""

import ctypes as ct 
from ctypes import windll
from ctypes.util import find_library

from ctypes import *
libm.NewNeticaEnviron_ns.argtypes

# benviron_ns *env = NewNeticaEnviron_ns ("your unique license", NULL, NULL);

# find and load the library
netica_dir = "C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/Netica/lib/64 bit/"
libm = ctypes.windll.LoadLibrary(find_library(netica_dir + "netica"))

# (const char* license, environ_ns* env, const char* locn)
# New NETICA environment
libm.NewNeticaEnviron_ns.argtypes = [c_char_p, c_void_p, c_char_p]
libm.NewNeticaEnviron_ns.restype = c_void_p
env_p = libm.NewNeticaEnviron_ns(None, None, None) # env_p

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
libm.InitNetica2_bn.argtypes = [c_void_p, c_char_p]
libm.InitNetica2_bn.restype = c_int
res = libm.InitNetica2_bn(env_p, mesg)
logger.info(mesg.value)

"""
Creates and returns a new net, initially having no nodes
"""
# (const char* name, environ_ns* env)
libm.NewNet_bn.argtypes = [c_char_p, c_void_p]
libm.NewNet_bn.restype = c_void_p
net_p = libm.NewNet_bn("prueba", env_p) # net_p

# Reads a NETICA net from file
# (stream_ns* file, int options)
netica_net = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/México/0_Vigente/GIS/Mapas_base/wetransfer-cbc615/Temperatura.neta"
libm.NewFileStream_ns.argtypes = [c_char_p, c_void_p, c_char_p]
libm.NewFileStream_ns.restype = c_void_p
name = create_string_buffer(netica_net)
file_p = libm.NewFileStream_ns (name, env_p, None) # file_p
libm.ReadNet_bn.argtypes = [c_void_p, c_int]
libm.ReadNet_bn.restype = c_void_p
net_p = libm.ReadNet_bn(file_p, REGULAR_WINDOW) # net_p


"""
get net nodes
"""
zerochar_type = c_char*0
# (const net_bn* net, const char options[])
libm.GetNetNodes2_bn.argtypes = [c_void_p, zerochar_type]
libm.GetNetNodes2_bn.restype = c_void_p
nl_p = libm.GetNetNodes2_bn(net_p, zerochar_type()) # nl_p

"""
get number of nodes
"""
# (const nodelist_bn* nodes)
libm.LengthNodeList_bn.argtypes = [c_void_p]
libm.LengthNodeList_bn.restype = c_int
nnodes = libm.LengthNodeList_bn(nl_p) # nnodes

libm.NthNode_bn.argtypes = [c_void_p, c_int]
libm.NthNode_bn.restype = c_void_p
index = 2
node_p = libm.NthNode_bn(nl_p, index) # node_p
"""
Returns the node name as string
"""
# (const node_bn* node)
libm.GetNodeName_bn.argtypes = [c_void_p]
libm.GetNodeName_bn.restype = c_char_p
name = libm.GetNodeName_bn(node_p) # name    

"""
Returns DISCRETE_TYPE if the variable corresponding 
to node is discrete (digital), and CONTINUOUS_TYPE 
if it is continuous (analog)
"""
# (const node_bn* node)
libm.GetNodeType_bn.argtypes = [c_void_p]
libm.GetNodeType_bn.restype = c_int
node_type = libm.GetNodeType_bn(node_p) # node_type      

"""
get number of states
"""
# (const node_bn* node)
libm.GetNodeNumberStates_bn.argtypes = [c_void_p]
libm.GetNodeNumberStates_bn.restype = c_int
nstates = libm.GetNodeNumberStates_bn(node_p) # nstates

"""
get node beliefs
"""
# (node_bn* node)
libm.GetNodeBeliefs_bn.argtypes = [c_void_p]
libm.GetNodeBeliefs_bn.restype = ndpointer('float32', ndim=1, shape=(nstates,),flags='C')
prob_bn = libm.GetNodeBeliefs_bn(node_p) # prob_bn

"""
Returns the expected real value of node, based on the current beliefs
for node, and if std_dev is non-NULL, *std_dev will be set to the 
standard deviation. Returns UNDEF_DBL if the expected value couldn't 
be calculated.
"""
# (node_bn* node, double* std_dev, double* x3, double* x4)
libm.GetNodeExpectedValue_bn.argtypes = [c_void_p, c_double_p, c_double_p, c_double_p]
libm.GetNodeExpectedValue_bn.restype = c_double
stdev = c_double(9999) # standard deviation
x3 = c_double_p()
x4 = c_double_p()
expvalue = libm.GetNodeExpectedValue_bn(node_p, byref(stdev), x3, x4) # expected value


"""
compile net
"""
# (net_bn* net)
libm.CompileNet_bn.argtypes = [c_void_p]
libm.CompileNet_bn.restype = None
libm.CompileNet_bn(net)

# Set autoupdate
auto_update = 1
libm.SetNetAutoUpdate_bn.argtypes = [c_void_p, c_int]
libm.SetNetAutoUpdate_bn.restype = None
libm.SetNetAutoUpdate_bn(net, auto_update)






