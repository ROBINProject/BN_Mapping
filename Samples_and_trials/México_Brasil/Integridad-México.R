
# Integridad Ecológica nacional - México ----------------------------------

# importación de datos desde google drive.
carpeta.datos <- "~/1 Nube/Google Drive/2 Proyectos/RoBiN/Datos RoBiN/Datos MEX/"
completos_mapa_MXintegridad_28092013 <- read.csv(paste(carpeta.datos, 
                                                "completos_mapa_MXintegridad_28092013.csv", sep=""), header=T)
incompletos_mapa_MXintegridad_28092013 <- read.csv(paste(carpeta.datos, 
                                                "incompletos_mapa_MXintegridad_28092013.csv", sep=""), header=T))

# todos los datos
todo.MXintegridad <- rbind(completos_mapa_MXintegridad_28092013, incompletos_mapa_MXintegridad_28092013)

# valores extremos de las variables
apply(todo.MXintegridad, 2, range, na.rm = TRUE)