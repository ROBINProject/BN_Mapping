# -*- coding: utf-8 -*-
"""
Created on Sat Jun 20 01:09:47 2015

@author: Miguel

Example of wrapping Netica.dll using ctypes. 
"""

# import ctypes for wrapping netica.dll
from ctypes.util import find_library
from ctypes import windll, c_char, c_char_p, c_void_p, c_int, c_double
from ctypes import create_string_buffer, c_bool, POINTER,byref
c_double_p = POINTER(c_double)

# Other libraries
import sys
import os
from numpy.ctypeslib import ndpointer
import numpy as np
from numpy import array
import platform
import os.path
import logging
logger = logging.getLogger(__name__)

# Function to find files based on a pattern in any machine
import fnmatch
def find(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result

# constants
MESGLEN = 600
NO_VISUAL_INFO=0
NO_WINDOW=0x10
MINIMIZED_WINDOW=0x30
REGULAR_WINDOW=0x70
ENTROPY_SENSV = 0x02
REAL_SENSV = 0x04
VARIANCE_SENSV = 0x100
VARIANCE_OF_REAL_SENSV = 0x104


# find and load the library
netica_dir = os.path.abspath("../Netica/")
libm = windll.LoadLibrary(find_library(netica_dir + "\\netica"))

# benviron_ns *env = NewNeticaEnviron_ns ("your unique license", NULL, NULL);
# parameters: (const char* license, environ_ns* env, const char* locn)
# New NETICA environment
# Initialize a pynetica instance/env using password in a text file
licensefile = netica_dir + "inecol_netica.txt"
licensia = open(licensefile, 'r').readlines()[0].strip().split()[0]
env_p = c_void_p(libm.NewNeticaEnviron_ns(licensia, None, None))

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
res = c_int(libm.InitNetica2_bn(env_p, mesg))
logger.info(mesg.value)

# Reads a NETICA net from file
# parameters: (stream_ns* file, int options)
netica_net = find("temp*.neta", "c:/users/")[0]
name = create_string_buffer(netica_net)
file_p = c_void_p(libm.NewFileStream_ns (name, env_p, None)) # file_p
net_p = c_void_p(libm.ReadNet_bn(file_p, REGULAR_WINDOW)) # net_p


"""
get net nodes
"""
zerochar_type = c_char*0
# (const net_bn* net, const char options[])
nl_p = c_void_p(libm.GetNetNodes2_bn(net_p, zerochar_type())) # nl_p

"""
get number of nodes
"""
# (const nodelist_bn* nodes)
nnodes = c_int(libm.LengthNodeList_bn(nl_p)) # nnodes

# Pick one node by index number
index = 2
node_p = c_void_p(libm.NthNode_bn(nl_p, index)) # node_p

"""
Returns the node name as string
"""
# (const node_bn* node)
name = c_char_p(libm.GetNodeName_bn(node_p)) # name    

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

# Sensitivity
# Type might be: VARIANCE_OF_REAL_SENSV or ENTROPY_SENSV
Qnode_p = libm.NthNode_bn(nl_p, 1) # Target node
Vnode_p = libm.NthNode_bn(nl_p, 2) # Target node

libm.NewSensvToFinding_bn.argtypes = [c_void_p, c_void_p, c_int]
libm.NewSensvToFinding_bn.restype = c_void_p
sensv_bn = libm.NewSensvToFinding_bn(Qnode_p, Vnode_p, ENTROPY_SENSV)

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






