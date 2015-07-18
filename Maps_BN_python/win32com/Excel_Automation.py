# -*- coding: utf-8 -*-
"""
Editor de Spyder

Este es un archivo temporal
"""

# Notes for interacting with pyWin32 (http://sourceforge.net/projects/pywin32/)
# Running this script won't do much, instead just look at it for reference

# import the Dispatch library, get a reference to an Excel instance
from win32com.client import Dispatch
xlApp = Dispatch("Excel.Application")

# make Excel visible (1 is True, 0 is False)
xlApp.Visible=1

# make a new Workbook
xlBook = xlApp.Workbooks.Add()
# get a reference to the same workbook - these two do the same thing
xlBook = xlApp.Workbooks(1) 

# get a reference to the first sheet
xlSheet = xlBook.Sheets(1)
# reference a cell and set a value
xlSheet.Cells(1,1).Value="Hola mis amigos queridos!!!!!"

# extract the value from a cell
a_value = xlSheet.Cells(1,1).Value
print a_value

# empty cells have value of None
xlSheet.Cells(1,2).Value == None

# use formula as we would in excel
xlSheet.Cells(3,1).Value = "22"
xlSheet.Cells(5,1).Value = "=a3 * 2"

# change sheet's name
xlSheet.Name = "demo" 

# INDEXING NOTE
xlSheet = xlBook.Sheets(1) # 1 based by default (but apparently can be changed)
xlSheet = xlBook.Sheets[1] # 0 based as per Python
# book recommends using () and using the docs where necessary - usually 1 is first item

#pyWin32 FAQ
#http://starship.python.net/crew/mhammond/win32/FAQ.html
#links to a tutorial which links to the MS docs
#http://www.boddie.org.uk/python/COM.html
#the above also have notes on 0/1 indexing 

# Getting out of Excel cleanly!!!!!
# If excel was launched elsewhere call dispatch to get the application reference
#
# close this workbook without saving it
xlBook.Close(SaveChanges=0)
xlApp.Quit()
del xlApp



