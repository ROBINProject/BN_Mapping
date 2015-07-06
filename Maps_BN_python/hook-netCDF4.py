# -*- coding: utf-8 -*-
"""
Created on Fri Jun 26 20:43:57 2015

@author: Miguel
"""
from PyInstaller.hooks.hookutils import collect_submodules
hiddenimports = collect_submodules("numpy")
