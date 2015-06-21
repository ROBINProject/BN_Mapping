# Crea archivo de respaldo de datos de integridad en formato HDF5

# Se puede bajar la biblioteca con los comandos de abajo, si esto no funciona
# intenta bajar el zip directamente e instalarlo.
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)

# Crea el archivo
h5createFile("Mex_integrity.h5")

# Crea la jerarquía de grupos del archivo HDF5
h5createGroup("Mex_integrity.h5","DVH_ZVS_IS_NAIVE_M")
h5createGroup("Mex_integrity.h5","samples")
h5createGroup("Mex_integrity.h5","full_data")

# qué hay en el archivo?
h5ls("Mex_integrity.h5", )

# agrega los datos
# resultados de integridad: DVH_ZVS_IS_NAIVE_M para cada una de las 30 muestras

nombres <- names(datos.integridad)
nombres <- sapply(nombres[1:30], function (nom) sub(".txt", replacement="", x=nom, ), USE.NAMES=F)


# hdf5.empacado.datos function(datos, archivo, grupo, nombres, 
#                               bloque=100000, zipeado=6)


# Agregar contenido a la estructura
for (i in 3:32)
{ grp <- paste("DVH_ZVS_IS_NAIVE_M/", nombres[i], sep="")
  #    h5createGroup("Mex_integrity.h5",grp)
  h5createDataset("Mex_integrity.h5", grp, length(datos.integridad[, i]), 
                  storage.mode = "double", chunk=100000, level=6)
  h5write(datos.integridad [, i], "Mex_integrity.h5", grp)          
}

h5ls("Mex_integrity.h5")

h5ls("integ.h5")
enorme <- h5read("integ.h5", name="full_data")
nombres <- names(enorme)
class(enorme[[1]])

for (i in 1:29)
{ grp <- paste("full_data/", nombres[i], sep="")
  #    h5createGroup("Mex_integrity.h5",grp)
  h5createDataset("Mex_integrity.h5", grp, length(enorme[[i]]), 
                  storage.mode = "double", chunk=10000, level=6)
  h5write(enorme [[i]], "Mex_integrity.h5", grp)          
}



# Muestras

arch.datos <- dir(dir$datos, pattern="^data_set_")
nombres <- sapply(arch.datos[1:30], function (nom) sub("_.csv", replacement="", x=nom, ), USE.NAMES=F)

for (i in 1:30)
{ grp1 <- paste("samples/", nombres[i], sep="")
  datos <- read.table(paste(dir$datos, "/", nombres[1], "_.csv", sep=""), header=T, sep=",")
  h5createGroup("Mex_integrity.h5",grp1)
  nn <- names(datos)
  for (j in 1:28)
  {
    grp2 <- paste(grp1, "/", nn[j], sep="")
    h5createDataset("Mex_integrity.h5", grp2, length(datos[,j]), 
                    storage.mode = "double", chunk=5000, level=6)
    h5write(datos[,j], "Mex_integrity.h5", grp2)          
  }
}

h5ls("integ.h5", "full_data")
enorme <- h5read("integ.h5", name="full_data")
nombres <- names(enorme)

