# -*- coding: utf-8 -*-
"""
Created on Thu Jul 16 21:46:50 2015

@author: Miguel

"Demo" program for Netica-COM in C#

Works with  Netica 5.19 or later.

It is best to first get this example project working.
Run the latest version of Netica Application (Netica.exe) as Administrator 
   (e.g. by right-clicking Netica.exe and choosing "Run as Administrator"), 
   and then exit, to register it as the COM server. Then build this project 
   (Build->Build Solution), and run it (Debug->Start Debugging). 
   If it reports the probability of Tuberculosis is 0.0104, then 0.09241, .3377, and .05 your Netica
   installation and C# project appear to all be in good order.

Now you can replace the code below with your own.
Or, to add Netica to a different project:
   From that project, choose Project->Add Reference, then the "COM" tab,
   then double-click "Netica 5.19 Object Library" (or similar).

For documentation on Netica's objects and functions:
   Add Netica to your project, as described above.
   Choose View->Object Browser  (or View->Other Windows->Object Browser)  or  click on the Views 
      multi-purpose tool button down-arrow and choose "Object Browser".
   In the left pane of the Object Browser, one of the top level entries will be "Interop.Netica".  
      You can browse that, but it won't be as good as browsing the Netica library directly, 
      because it won't have a description of each function, and it may not even list the functions at all.
      If there is no entry at the top level for the library named simply "Netica" (with the books icon), 
      choose "Edit Custom Component Set..." from the "Browse" menu on the toolbar of the Object Browser. 
      Choose the COM tab, select the Netica library from  the list, click "Add" or "Select" and then "OK".  
      Now the books icon for the Netica library should appear, and you can browse it.
   Choose a Netica object in the left pane, then click on a member function or property in the top
      right pane to view its short description in the bottom pane.
   For more information on it, find its Netica-C equivalent name at the end of its short description, 
      and look up the function in the Netica-C manual or online at http://www.norsys.com/onLineAPIManual/index.html .
   If you are getting the wrong version of Netica's objects, then you need to run the correct version of 
      Netica.exe first (by right clicking on the Netica.exe icon and choosing "Run as Administrator"), 
      to register its COM definition.

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
nt.Visible = True

# Localiza la red de ejemplo y la abre
net_file_name = u"C:/Program Files/Netica/Netica 519/Programming Examples/Netica Demo for C# VS12/ChestClinic.dne"
streamer = nt.NewStream(net_file_name)
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











