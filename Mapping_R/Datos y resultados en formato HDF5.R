# Crea archivo de respaldo de datos de integridad en formato HDF5

# Se puede bajar la biblioteca con los comandos de abajo, si esto no funciona
# intenta bajar el zip directamente e instalarlo.
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)

# Crea el archivo
arch.hdf5 <- paste(dir$datos, "Mex_integrity.h5")
h5createFile(arch.hdf5)

dir(dir$datos, pattern="^Mex_")

# Crea la jerarquía de grupos del archivo HDF5
h5createGroup(arch.hdf5,"integrity")
h5createGroup(arch.hdf5,"samples")
h5createGroup(arch.hdf5,"full_data")

# qué hay en el archivo?
h5ls(arch.hdf5)

# agrega los datos
# resultados de integridad: DVH_ZVS_IS_NAIVE_M para cada una de las 30 muestras

nombres <- names(datos.integridad)
nombres <- sapply(nombres, function (nom) sub(".txt", replacement="", x=nom, ), USE.NAMES=F)


# Agregar contenido a la estructura
# Integridades calculadad
for (i in 3:32)
  { grp <- paste("integrity/", nombres[i], sep="")
    h5createDataset(arch.hdf5, grp, length(datos.integridad[, i]), 
                     storage.mode = "double", chunk=100000, level=6)
    h5write(datos.integridad [, i], arch.hdf5, grp)          
  }

h5ls(arch.hdf5)

# Datos de los atributos
enorme <- h5read("integ.h5", name="full_data", compoundAsDataFrame=T)
nombres <- names(enorme)

names(enorme[1])

for (i in 1:29)
{ grp <- paste("full_data/", nombres[i], sep="")
  h5createDataset(arch.hdf5, grp, length(enorme[[i]]), 
                  storage.mode = "double", chunk=100000, level=6)
  h5write(enorme [[i]], arch.hdf5, grp)          
}


# Muestras

arch.datos <- dir(dir$datos, pattern="^data_set_")
nombres <- sapply(arch.datos, function (nom) sub("_.csv", replacement="", x=nom, ), USE.NAMES=F)

for (i in 1:30)
{ grp1 <- paste("samples/", nombres[i], sep="")
  datos <- read.table(paste(dir$datos, "/", nombres[1], "_.csv", sep=""), header=T, sep=",")
  h5createGroup(arch.hdf5,grp1)
  nn <- names(datos)
  for (j in 1:28)
  {
    grp2 <- paste(grp1, "/", nn[j], sep="")
    h5createDataset(arch.hdf5, grp2, length(datos[,j]), 
                    storage.mode = "double", chunk=5000, level=6)
    h5write(datos[,j], arch.hdf5, grp2)          
  }
}

h5ls(arch.hdf5)
