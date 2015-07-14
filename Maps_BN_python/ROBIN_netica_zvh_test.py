# -*- coding: utf-8 -*-
"""
Created on Fri Jul 10 19:26:09 2015

@author: Miguel
"""
import os
import platform
import re
import numpy as np
from numpy import array
import pythonNeticaConstants as pnC
import cthelper as cth
import logging
from numpy.ctypeslib import ndpointer
logger = logging.getLogger(__name__)

# import ctypes for wrapping netica.dll
import ctypes as ct
from ctypes.util import find_library
from ctypes import windll, c_char, c_char_p, c_void_p, c_int, c_double
from ctypes import create_string_buffer, c_bool, POINTER,byref
c_double_p = POINTER(c_double)

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
LAST_ENTRY = -10 

# find and load the library, assuming in a relative path closeby
netica_dir = os.path.abspath("../Netica/")
libN = windll.LoadLibrary(find_library(netica_dir + "/netica"))
licensefile = netica_dir + "/inecol_netica.txt"
licensia = open(licensefile, 'r').readlines()[0].strip().split()[0]

# env = NewNeticaEnviron_ns (NULL, NULL, NULL);
# res = InitNetica2_bn (env, mesg);
# Initialize a pynetica instance/env using password in a text file
env_p = c_void_p(libN.NewNeticaEnviron_ns(licensia, None, None))

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
res = c_int(libN.InitNetica2_bn(env_p, mesg))
logger.info(mesg.value)
print '\n'*2 + '#' * 40 + '\nOpening Netica:'
print mesg.value

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
zerochar_type = c_char*0
# (const net_bn* net, const char options[])
nl_p = c_void_p(libN.GetNetNodes2_bn(net_p, zerochar_type())) # nl_p

"""
get number of nodes
"""
# (const nodelist_bn* nodes)
nnodes = c_int(libN.LengthNodeList_bn(nl_p)) # nnodes

# Collect all node names in network
node_names = {"gral":{}, "pp":{}, "pt":{}, "tm":{}, "tr":{}, "tx":{}}
for i in range(nnodes.value):
    node_p = c_void_p(libN.NthNode_bn(nl_p, i)) # node_p
    name = c_char_p(libN.GetNodeName_bn(node_p)) # name
    if re.search("^[xyZd]", name.value):
        node_names["gral"][name.value] = node_p
    elif re.search("^[ppt0-1]{4}", name.value):
        node_names["pp"][name.value] =   node_p
    elif re.search("^[pptm]{4}", name.value):
        node_names["pt"][name.value] =   node_p
    elif re.search("^[tma]{3}", name.value):
        node_names["tx"][name.value] =   node_p
    elif re.search("^[tmi]{3}", name.value):
        node_names["tm"][name.value] =   node_p
    else:
        node_names["tr"][name.value] =   node_p   
        
# Test with cases
# first call NewNetTester_bn, passing in a list of the test nodes.
# you also pas in a list of them as the unobsv_nodes
# Then you call TestWithCaseset_bn, passing in the case file containing 
# the real-world data. If you want, you can call TestWithCaseset_bn 
# several times with different files to generate statistics for 
# the combined data set.
# Finally, you call functions to retrieve the actual performance 
# statistics you desire. You can obtain the error rate with 
# GetTestErrorRate_bn, the logarithmic loss with GetTestLogLoss_bn, 
# the quadratic loss with GetTestQuadraticLoss_bn and the whole 
# confusion matrix with GetTestConfusion_bn
#
# Function as in C API
# void TestWithCaseset_bn (tester_bn* test, caseset_cs* cases)
# void AddNodeToList_bn (node_bn* node, nodelist_bn* nodes, int index)
# void RetractNetFindings_bn (net_bn* net)
# tester_bn* NewNetTester_bn (nodelist_bn* test_nodes, nodelist_bn* unobsv_nodes, int tests)
# caseset_cs* NewCaseset_cs (const char* name, environ_ns* env)
# void AddFileToCaseset_cs (caseset_cs* cases, const stream_ns* file, double degree, const char* control)
# double GetTestErrorRate_bn (tester_bn* test, node_bn* node)
# nodelist_bn* NewNodeList2_bn (int length, const net_bn* net)
#
# The observed nodes are the factors known during diagnosis:
# AddNodeToList_bn (Cancer, test_nodes, LAST_ENTRY);
# RetractNetFindings_bn (net); // IMPORTANT: Otherwise any findings will be part of tests
# CompileNet_bn (net);
# tester = NewNetTester_bn (test_nodes, unobsv_nodes, -1);
# CHKERR
# casefile = NewFileStream_ns ("Data Files\\ChestClinic.cas", env, NULL);
#
# caseset = NewCaseset_cs ("ChestClinicCases", env);
# AddFileToCaseset_cs (caseset, casefile, 1.0, NULL);
# TestWithCaseset_bn (tester, caseset);
# CHKERR
# GetTestErrorRate_bn (tester, Cancer) * 100.0);
#

nl_test_p = c_void_p(libN.NewNodeList2_bn(c_int(0), net_p))
zvh_nd = node_names["gral"]["Zvh"]
libN.AddNodeToList_bn(zvh_nd, nl_test_p, LAST_ENTRY)
libN.RetractNetFindings_bn(net_p)
libN.CompileNet_bn(net_p)

net_tester_p = c_void_p(libN.NewNetTester_bn(nl_test_p, nl_test_p, c_int(-1)))
cases_dsk = dir_robin + dir_datos + "/test.csv"
name_cases = create_string_buffer(cases_dsk)
cases_file_p = c_void_p(libN.NewFileStream_ns (name_cases, env_p, None))
cases_set_p = c_void_p(libN.NewCaseset_cs("ZVH_BN", env_p))
libN.AddFileToCaseset_cs(cases_set_p, cases_file_p, c_double(1.0), None)

libN.TestWithCaseset_bn(nl_test_p, cases_set_p)
error_clas = c_double(libN.GetTestErrorRate_bn(net_tester_p, zvh_nd))
error_clas.value

cases_dsk_B = dir_robin + dir_datos +"/tesB.csv"
name_cases_B = create_string_buffer(cases_dsk)
cases_file_B_p = c_void_p(libN.NewFileStream_ns (name_cases_B, env_p, None))
libN.WriteCaseset_cs (cases_set_p, cases_file_B_p, None)
libN.DeleteCaseset_cs(cases_set_p)








libN.CloseNetica_bn(env_p)





