# Exploración de los intervalos de las variables

# Miguel --- Ubicación de archivos en mi equipo portatil

# Carpetas de trabajo controladas por Git:
# Miguel --- Ubicación de archivos en mi equipo portatil
setwd("~/0 Versiones controladas/GIT/Proyectos y publicaciones/ROBIN/Interp y redes (R)/México_Brasil")
# Miguel --- Ubicación de archivos en mi equipo de escritorio Inecol
setwd("~/0 Versiones controladas/GIT/Proyectos y publicaciones/ROBIN/Interp y redes (R)/México_Brasil")

# Datos en Google drive.
# Miguel - Equipo escritorio Inecol
google.drive.local <- "C:/Users/miguel.equihua/Documents/1 Nubes/Google Drive/2 Proyectos"
# Miguel - Equipo portatil
google.drive.local <- "C:/Users/miguel.equihua/Documents/0 Nubes/Google Drive/2 Proyectos/RoBiN/Datos RoBiN"

# Subdirectorio dentro de GoogleDrive
datos.robin.brasil <- "RoBiN/Datos RoBiN/Brasil/DadosFinais_NETICA_Para" 
carpeta <- file.path(google.drive.local, datos.robin.brasil)
write.csv (datos.brasil, "todo Brasil")
datos.robin.mexico <- "Datos MEX/1 - Integridad - entrenamiento/"

library("foreign")
datos.brasil <- read.dbf(file=file.path(carpeta, "DadosFinais_NETICA_Para.dbf"))
extremos.brasil <- apply(datos.brasil[,c(2:13)], 2, range)
row.names(extremos.brasil) <- c("min", "max") 
t(extremos.brasil)

data.frame(round(data.frame(min=apply(muestra_TodoMX_30000[,1:16],2,min), 
                            max=apply(muestra_TodoMX_30000[,1:16],2,max)),5), 
           round(data.frame(min=apply(muestra_TodoMX_60000[,1:16],2,min), 
                            max=apply(muestra_TodoMX_60000[,1:16],2,max)),5), 
           round(data.frame(min=apply(muestra_TodoMX_100000[,1:16],2,min), 
                            max=apply(muestra_TodoMX_100000[,1:16],2,max)),5))

# despliega valores de intervalo
rangos <- rbind(muestra_TodoMX_30000 [, c(1:9,14:15,20)],
                muestra_TodoMX_60000 [, c(1:9,14:15,20)],
                muestra_TodoMX_100000[, c(1:9,14:15,20)])
t(apply(rangos,2,range))

temp <- tapply(muestra_TodoMX_300000_corregido$dap,
               muestra_TodoMX_300000_corregido$zvh, range)

data.frame(temp)


# muestra_TodoMX_100000_corregido <- muestra_TodoMX_100000_corregido[,c(2:20)]
data.frame(min=apply(muestra_TodoMX_100000_corregido[,c(1:8,13,14,19)], 2, min),
           max=apply(muestra_TodoMX_100000_corregido[,c(1:8,13,14,19)], 2, max))

# muestra_TodoMX_300000_corregido <- muestra_TodoMX_300000_corregido[,c(2:20)]
data.frame(min=apply(muestra_TodoMX_300000_corregido[,c(1:8,13,14,19)], 2, min),
           max=apply(muestra_TodoMX_300000_corregido[,c(1:8,13,14,19)], 2, max))

# muestra_TodoMX_200000_corregido <- muestra_TodoMX_200000_corregido[,c(2:20)]
data.frame(min=apply(muestra_TodoMX_200000_corregido[,c(1:8,13,14,19)], 2, min),
           max=apply(muestra_TodoMX_200000_corregido[,c(1:8,13,14,19)], 2, max))

data.frame(min=apply(muestra_TodoMX_200000_corregido[,c(1:8,13,14,19)], 2, min),
           max=apply(muestra_TodoMX_200000_corregido[,c(1:8,13,14,19)], 2, max))

rangos <- rbind(muestra_TodoMX_100000_corregido[,c(1:8,13,14,19)],
                muestra_TodoMX_200000_corregido[,c(1:8,13,14,19)],
                muestra_TodoMX_300000_corregido[,c(1:8,13,14,19)])
t(apply(rangos,2,range))

temp <- tapply(muestra_TodoMX_300000_corregido$arebsl,
               muestra_TodoMX_300000_corregido$zvh, range)
data.frame(temp)
muestra_TodoMX_300000_corregido$integ <- muestra_TodoMX_300000_corregido.int[,1]
muestra_TodoMX_300000_corregido$integ <- 1-muestra_TodoMX_300000_corregido$integ
cor (muestra_TodoMX_300000_corregido[,c(6,7,20)])
hist (muestra_TodoMX_300000_corregido$dap, breaks=155, xlim=c(5, 25))