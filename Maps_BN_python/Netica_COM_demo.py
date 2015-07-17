# -*- coding: utf-8 -*-
"""
Created on Thu Jul 16 19:22:13 2015

@author: Miguel
"""

import comtypes.client as com

# Vincula la interface COM de NETICA y activa la aplicación
netica = com.CreateObject("Netica.Application")

# Hace visible a NETICA
netica.Visible = True




