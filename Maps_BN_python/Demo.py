# -*- coding: utf-8 -*-
""" 
  Python trial based in Demo.c of Netica API for C
 
  Example use of Netica API Programmer's Library
 
  This is a combination of the first 2 examples in the Netica API
  Reference Manual.  It can be used to test if the installation is successful.
 
  Copyright (C) 1992-2010 by Norsys Software Corp.
  The software in this file may be copied, modified, and/or included in 
  derivative works without charge or obligation.
 
Created on Wed Jun 24 19:36:39 2015
@author: Miguel

For this adaptation I am using part of the code developed 
by Fienen, M.N. and Plant, N.G., as part of CVNetica 
    -- a python software package to perform cross-validation 
       on Bayesian networks using Netica
Version 1.0 --- July 17, 2014
Source: https://github.com/mnfienen-usgs/CVNetica

"""
import os
import platform
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

MESGLEN = 600

# find and load the library, assuming in a relative path closeby
netica_dir = os.path.abspath("../Netica/")
lib_netica = windll.LoadLibrary(find_library(netica_dir + "/netica"))
licensefile = netica_dir + "/inecol_netica.txt"
licensia = open(licensefile, 'r').readlines()[0].strip().split()[0]

#	net_bn *net;
#	node_bn *VisitAsia, *Tuberculosis, *Smoking, *Cancer, *TbOrCa, *XRay;
#	double belief;
#	char mesg[MESG_LEN_ns];
#	int res;

print "\nWelcome to Netica API!"
print "This demo project is from the first 2 examples of the C API"
print "Reference Manual. If it runs successfully (i.e. without generating"
print "errors), then your installation is probably good."
print "Now you can replace the Demo.py file with your own code."
print "--------------------------------------------------------------------\n"


# env = NewNeticaEnviron_ns (NULL, NULL, NULL);
# res = InitNetica2_bn (env, mesg);
# Initialize a pynetica instance/env using password in a text file
env_p = c_void_p(lib_netica.NewNeticaEnviron_ns(licensia, None, None))

# Initialize NETICA environment
mesg = create_string_buffer(MESGLEN)
res = c_int(lib_netica.InitNetica2_bn(env_p, mesg))
logger.info(mesg.value)
print '\n'*2 + '#' * 40 + '\nOpening Netica:'
print mesg.value

# net = NewNet_bn ("ChestClinic", env);  
net_p = c_void_p(lib_netica.NewNet_bn("ChestClinic", env_p))

# VisitAsia =    NewNode_bn ("VisitAsia", 2, net);
# Tuberculosis = NewNode_bn ("Tuberculosis", 2, net);
# Smoking =      NewNode_bn ("Smoking", 2, net);
# Cancer =       NewNode_bn ("Cancer", 2, net);
# TbOrCa =       NewNode_bn ("TbOrCa", 2, net);
# XRay =         NewNode_bn ("XRay", 2, net);
VisitAsia = c_void_p(lib_netica.NewNode_bn("VisitAsia", 2, net_p))
Tuberculosis = c_void_p(lib_netica.NewNode_bn("Tuberculosis", 2, net_p))
Smoking = c_void_p(lib_netica.NewNode_bn("Smoking", 2, net_p))
Cancer = c_void_p(lib_netica.NewNode_bn("Cancer", 2, net_p))
TbOrCa = c_void_p(lib_netica.NewNode_bn("TbOrCa", 2, net_p))
XRay = c_void_p(lib_netica.NewNode_bn("XRay", 2, net_p))

# SetNodeStateNames_bn (VisitAsia,   "visit,   no_visit");
# SetNodeStateNames_bn (Tuberculosis,"present, absent");
# SetNodeStateNames_bn (Smoking,     "smoker,  nonsmoker");
# SetNodeStateNames_bn (Cancer,      "present, absent");
# SetNodeStateNames_bn (TbOrCa,      "true,    false");
# SetNodeStateNames_bn (XRay,        "abnormal,normal");
# SetNodeTitle_bn (TbOrCa, "Tuberculosis or Cancer");
# SetNodeTitle_bn (Cancer, "Lung Cancer");
lib_netica.SetNodeStateNames_bn(VisitAsia, "visit, no_visit")
lib_netica.SetNodeStateNames_bn(Tuberculosis,"present, absent")
lib_netica.SetNodeStateNames_bn(Smoking,     "smoker,  nonsmoker")
lib_netica.SetNodeStateNames_bn(Cancer,      "present, absent")
lib_netica.SetNodeStateNames_bn(TbOrCa,      "true,    false")
lib_netica.SetNodeStateNames_bn(XRay,        "abnormal,normal")
lib_netica.SetNodeTitle_bn (TbOrCa, "Tuberculosis or Cancer")
lib_netica.SetNodeTitle_bn (Cancer, "Lung Cancer")

# AddLink_bn (VisitAsia, Tuberculosis);
# AddLink_bn (Smoking, Cancer);
# AddLink_bn (Tuberculosis, TbOrCa);
# AddLink_bn (Cancer, TbOrCa);
# AddLink_bn (TbOrCa, XRay);
lib_netica.AddLink_bn(VisitAsia, Tuberculosis)
lib_netica.AddLink_bn (Smoking, Cancer)
lib_netica.AddLink_bn (Tuberculosis, TbOrCa)
lib_netica.AddLink_bn (Cancer, TbOrCa)
lib_netica.AddLink_bn (TbOrCa, XRay)

# SetNodeProbs (VisitAsia, 0.01, 0.99);
# SetNodeProbs (Tuberculosis, "visit",    0.05, 0.95);
# SetNodeProbs (Tuberculosis, "no_visit", 0.01, 0.99);
# SetNodeProbs (Smoking, 0.5, 0.5);
# SetNodeProbs (Cancer, "smoker",    0.1,  0.9);
# SetNodeProbs (Cancer, "nonsmoker", 0.01, 0.99);
# SetNodeProbs_bn (node_bn* node, const state_bn* parent_states, const prob_bn* probs);
prob_bn = array([0.01, 0.99])
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (VisitAsia, prob_bn)

prob_bn = array([0.05, 0.95])
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (Tuberculosis, "visit", prob_bn)

prob_bn = array([0.01, 0.99])
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (Tuberculosis, "no_visit", prob_bn)

prob_bn = array([0.5, 0.5])
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (Smoking, prob_bn)

prob_bn = array([0.1, 0.9])
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (Cancer, "smoker", prob_bn)

prob_bn = array([0.01, 0.99], ct.c_float)
prob_bn = prob_bn.ctypes.data_as(ct.POINTER(ct.c_double))
lib_netica.SetNodeProbs_bn (Cancer, "nonsmoker", prob_bn)

lib_netica.GetNodeProbs_bn(Cancer)
prob_bn = ct.cast(prob_bn, ct.POINTER(ct.c_float))[0:2]

lib_netica.EnterFinding_bn (Cancer, lib_netica.GetStateNamed_bn ("present", Cancer))
prob_bn = lib_netica.GetNodeBeliefs_bn(Cancer)
prob_bn = ct.cast(prob_bn, ct.POINTER(ct.c_float))[0:2]


# Assign probabilities
numstates_Cancer = c_int(lib_netica.GetNodeNumberStates_bn (VisitAsia))
numparents_Cancer = c_int(lib_netica.LengthNodeList_bn (lib_netica.GetNodeParents_bn (Cancer)))

# Write network on disk
file_p = c_void_p(lib_netica.NewFileStream_ns(create_string_buffer("ChestClinic.neta"),env_p, None))
lib_netica.WriteNet_bn(net_p, file_p)

np.arange(2)