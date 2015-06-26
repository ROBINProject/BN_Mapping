#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 22:25:13 2015

@author: Miguel
"""
import wx
app = wx.App(False)
frame = wx.Frame(None, wx.ID_ANY, "Hello World")

frame.Show(True)
app.MainLoop()