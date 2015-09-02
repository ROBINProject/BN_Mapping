# -*- coding: utf-8 -*-
"""
Created on Sat Jun 20 01:09:47 2015

@author: Miguel

Example of wrapping Netica.dll using ctypes.
"""

# import ctypes for wrapping netica.dll
import ctypes as ct
from ctypes.util import find_library
from ctypes import windll, c_char, c_char_p, c_void_p, c_int, c_double
from ctypes import create_string_buffer, c_bool, POINTER,byref
c_double_p = POINTER(c_double)

# Other libraries
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
CONTINUOUS_TYPE=1
DISCRETE_TYPE = 2
TEXT_TYPE = 3
BELIEF_UPDATE = 0x100

def GetNodeExpectedValue(libN, cnode):
    std_dev = c_double()
    # make a temporary function variable to be able to set the return value
    tmpNeticaFun = libN.GetNodeExpectedValue_bn
    tmpNeticaFun.restype = c_double
    expected_val = tmpNeticaFun(cnode, byref(std_dev), None, None)
    return expected_val, std_dev.value

def EnterNodeValue(libN, cnode, cval):
    libN.EnterNodeValue_bn(cnode, c_double(cval))

def RetractNetFindings(libN, cnet):
    libN.RetractNetFindings_bn(cnet)

def EnterFinding(libN, cnode, cval):
    libN.EnterFinding_bn(cnode, c_double(cval))


# find and load the library
netica_dir = os.path.abspath("../Netica/")
libm = windll.LoadLibrary(find_library(netica_dir + "/netica"))

# benviron_ns *env = NewNeticaEnviron_ns ("your unique license", NULL, NULL);
# parameters: (const char* license, environ_ns* env, const char* locn)
# New NETICA environment
# Initialize a pynetica instance/env using password in a text file
licensefile = netica_dir + "/inecol_netica.txt"
licencia = open(licensefile, 'r').readlines()[0].strip().split()[0]
env_p = c_void_p(libm.NewNeticaEnviron_ns(licencia, None, None))

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
res = c_int(libm.InitNetica2_bn(env_p, mesg))
logger.info(mesg.value)


# Reads a NETICA net from file
# parameters: (stream_ns* file, int options)
dir_inicio = os.environ["homepath"]
dir_inicio = dir_inicio + "\\documents"
netica_net = find("01 - ChestClinic.dne", dir_inicio)[0]
name = create_string_buffer(netica_net)
file_p = c_void_p(libm.NewFileStream_ns (name, env_p, None)) # file_p
net_p = c_void_p(libm.ReadNet_bn(file_p, REGULAR_WINDOW)) # net_p

file_name = c_char_p (libm.GetNetFileName_bn (net_p))
net_name = c_char_p (libm.GetNetName_bn(net_p))

"""
compile net
"""
# (net_bn* net)
libm.CompileNet_bn(netica_net)

# Set autoupdate
saved = libm.SetNetAutoUpdate_bn(net_p, 1)
libm.GetNetAutoUpdate_bn(net_p)


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
index = 1
node_p = c_void_p(libm.NthNode_bn(nl_p, index)) # node_p

#(node_bn*) GetNodeNamed_bn (const char* name, const net_bn* net);
node_p = c_void_p(libm.GetNodeNamed_bn("Tuberculosis", net_p)) # node_p

"""
Returns the node name as string
"""
# (const node_bn* node)
name = c_char_p(libm.GetNodeName_bn(node_p)) # name
name.value


"""
Returns DISCRETE_TYPE if the variable corresponding
to node is discrete (digital), and CONTINUOUS_TYPE
if it is continuous (analog)
"""
# (const node_bn* node)
node_type = c_int(libm.GetNodeType_bn(node_p)) # node_type
if node_type.value == DISCRETE_TYPE:
    print ("Discrete node")
else:
    print("Continuous node")

"""
get number of states
"""
# (const node_bn* node)
nstates = c_int(libm.GetNodeNumberStates_bn(node_p)) # nstates
nstates.value

"""
get node beliefs
"""

# (node_bn* node)
EnterFinding(libm, node_p, 1)
prob_bn = libm.GetNodeBeliefs_bn(node_p) # prob_bn
prob_bn = ct.cast(prob_bn, ct.POINTER(ct.c_float))[0:nstates.value]

# Value for a continuos node
# (node_bn* node, double value)
EnterNodeValue(libm, node_p, 1.5)

"""
Returns the expected real value of node, based on the current beliefs
for node, and if std_dev is non-NULL, *std_dev will be set to the
standard deviation. Returns UNDEF_DBL if the expected value couldn't
be calculated.
"""
# (node_bn* node, double* std_dev, double* x3, double* x4)
expvalue = GetNodeExpectedValue(libm, node_p) # expected value

# Sensitivity
# Type might be: VARIANCE_OF_REAL_SENSV or ENTROPY_SENSV
Qnode_p = libm.NthNode_bn(nl_p, 1) # Target node
Vnode_p = libm.NthNode_bn(nl_p, 2) # Target node

libm.NewSensvToFinding_bn.argtypes = [c_void_p, c_void_p, c_int]
libm.NewSensvToFinding_bn.restype = c_void_p
sensv_bn = libm.NewSensvToFinding_bn(Qnode_p, Vnode_p, ENTROPY_SENSV)



libm.CloseNetica_bn(env_p)



