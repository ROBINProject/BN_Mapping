# -*- coding: utf-8 -*-
"""
Created on Thu Jul 16 21:46:50 2015

@author: Miguel Equihua
Instituto de Ecología, AC
Contact: equihuam@gmail.com

"Demo" program for Netica-COM in C#

Works with  Netica 5.19 or later.

It is best to first get this example project working.
   Run the latest version of Netica Application (Netica.exe) as Administrator
   (e.g. by right-clicking Netica.exe and choosing "Run as Administrator"),
   and then exit, to register it as the COM server. Then build this project
   (Build->Build Solution), and run it (Debug->Start Debugging).
   Should report the probability of Tuberculosis as 0.0104, then 0.09241,
   0.3377, and finally 0.050.  If so, your Netica installation and the sample
   "win32com" python project appears to be in good order.

   Now you can replace the code below with your own or, to add Netica to a
   different project, just make sure you include the call to
       from win32com.client import Dispatch

   For documentation on Netica's objects and functions:
   Use help (<pointer to the Dispatch object>)
   For more information on functions find its Netica-C equivalent name in the
   displayed short description, and look up the function in the Netica-C
   manual or online at http://www.norsys.com/onLineAPIManual/index.html. If
   you are getting the wrong version of Netica's objects, then you need to
   run the correct version of Netica.exe first (by right clicking on the
   Netica.exe icon and choosing "Run as Administrator"), to register its
   COM definition.
"""
from win32com.client import Dispatch

print "Welcome to Netica API for COM with Python!"

# Vincula la interface COM de NETICA y activa la aplicación
nt = Dispatch("Netica.Application")

# Lee la licensia de activasión de Netica
lic_arch ="C:/Users/Miguel/Documents/0 Versiones/2 Proyectos/BN_Mapping/Netica/inecol_netica.txt"
licencia = open(lic_arch, "rb").read()
nt.SetPassword(licencia)
nt.SetWindowPosition(status="Hidden") # Regular, Minimized, Maximized, Hidden
# nt.SetWindowPosition(top=10, left=10, width=1000, height=700)

# Muestra la versión de la aplicación
print "Using Netica version " + nt.VersionString

# Hace visible a NETICA
# nt.Visible = True

# Localiza la red de ejemplo y la abre
net_file_name = u"C:/Program Files/Netica/Netica 519/Programming Examples/Netica Demo for C# VS12/ChestClinic.dne"
streamer = nt.NewStream(net_file_name)

# ReadBNet 'options' can be one of "NoVisualInfo", "NoWindow",
# or the empty string (means create a regular window)
net = nt.ReadBNet(streamer, "")
net.compile()

# Lee los valores de creencia que tienen los nodos bajo distintas condiciones
# Creencia en condición "a priori"
TB = net.Node("Tuberculosis")
belief = TB.GetBelief("present")
print "The probability of tuberculosis is {:.4f}".format(belief)

# Creencia en TB cuando el examen de rayos X es abnormal
XRay = net.Node("XRay")
XRay.EnterFinding("abnormal")
belief = TB.GetBelief("present")
print "Given an abnormal X-Ray, the probability of tuberculosis is {:.4f}".format(belief)

# Añade la evidencia de que se visitó Asia recientemente
net.Node("VisitAsia").EnterFinding("visit")
belief = TB.GetBelief("present")
print "Given abnormal X-Ray and visit to Asia, the probability of TB is {:.4f}".format(belief)

# Añade a lo anterior la observación de cancer en el pasiente
net.Node("Cancer").EnterFinding("present")
belief = TB.GetBelief("present")
print "Given abnormal X-Ray, Asia visit, and lung cancer, the probability of TB is  {:.4f}".format(belief)

# Se libera el espacio de momoria usado por la red
net.Delete()

algo = raw_input (r"Press <enter> to quit.")
