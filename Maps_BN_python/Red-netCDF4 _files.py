# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 17:06:12 2015

@author: Miguel
"""

import os
import re
import numpy as np
from netCDF4 import Dataset as nc
import time
import matplotlib.pyplot as plt
from osgeo import gdal
from osgeo.gdalconst import GA_ReadOnly 
from osgeo.gdalconst import GDT_Float32
from osgeo.gdalconst import GDT_Int16

# Herramientas para leer datos de archivos "NC"
def ncdump(nc_fid, verb=True):
    '''
    ncdump outputs dimensions, variables and their attribute information.
    The information is similar to that of NCAR's ncdump utility.
    ncdump requires a valid instance of Dataset.

    Parameters
    ----------
    nc_fid : netCDF4.Dataset
        A netCDF4 dateset object
    verb : Boolean
        whether or not nc_attrs, nc_dims, and nc_vars are printed

    Returns
    -------
    nc_attrs : list
        A Python list of the NetCDF file global attributes
    nc_dims : list
        A Python list of the NetCDF file dimensions
    nc_vars : list
        A Python list of the NetCDF file variables
    '''
    def print_ncattr(key):
        """
        Prints the NetCDF file attributes for a given key

        Parameters
        ----------
        key : unicode
            a valid netCDF4.Dataset.variables key
        """
        try:
            print "\t\ttype:", repr(nc_fid.variables[key].dtype)
            for ncattr in nc_fid.variables[key].ncattrs():
                print '\t\t%s:' % ncattr,\
                      repr(nc_fid.variables[key].getncattr(ncattr))
        except KeyError:
            print "\t\tWARNING: %s does not contain variable attributes" % key

    # NetCDF global attributes
    nc_attrs = nc_fid.ncattrs()
    if verb:
        print "NetCDF Global Attributes:"
        for nc_attr in nc_attrs:
            print '\t%s:' % nc_attr, repr(nc_fid.getncattr(nc_attr))
    nc_dims = [dim for dim in nc_fid.dimensions]  # list of nc dimensions
    # Dimension shape information.
    if verb:
        print "NetCDF dimension information:"
        for dim in nc_dims:
            print "\tName:", dim 
            print "\t\tsize:", len(nc_fid.dimensions[dim])
            print_ncattr(dim)
    # Variable information.
    nc_vars = [var for var in nc_fid.variables]  # list of nc variables
    if verb:
        print "NetCDF variable information:"
        for var in nc_vars:
            if var not in nc_dims:
                print '\tName:', var
                print "\t\tdimensions:", nc_fid.variables[var].dimensions
                print "\t\tsize:", nc_fid.variables[var].size
                print_ncattr(var)
    return nc_attrs, nc_dims, nc_vars


# Ubicación de los datos en formato nc
robin_GD = u"C:/Users/Miguel/Documents/1 Nube/GoogleDrive/2 Proyectos/RoBiN/"
gis_data = u"Datos RoBiN/México/0_Vigente/GIS/"
lpj_nc = u"LPJ/LU_rcp2p6_gfdl-esm2m_transientCO2_p1"
curr_dir = os.curdir
os.chdir(robin_GD+gis_data+lpj_nc)
archivos = os.listdir(os.curdir)
archivos = [nombre for nombre in archivos if re.findall("\\.nc$", nombre)]

# Revisa los archivos en el directorio indicado
for dataset in archivos:
    # Lee el archivo nc seleccionado
    try:
        nc_dataset = nc(dataset, "r", format="NETCDF4")
        print "\t\Archivo:", repr(dataset)
    except RuntimeError:
        print "\t\tWARNING: %s no se puede leer" % dataset

# ncdump(nc_dataset)
# Nombre de las dimensiones que tienen las variables
nc_dim = [dim for dim in nc_dataset.dimensions]
nc_vars = [var for var in nc_dataset.variables if var not in nc_dim]
numVars = len(nc_vars)

nc_dataset.close()

