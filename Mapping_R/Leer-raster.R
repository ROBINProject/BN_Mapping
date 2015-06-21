library (raster)
source("ROBIN - código reutilizable.R")

# Resuelve ubicación de directorios de datos y mapas
dir <- ubica.trabajo("miguel_tab")

# Puedo ver que tengo en el directorio 
dir(dir$mapas, pattern=".tif$")

# Leo y grafico el tiff deseado. En este caso altura de fustes
imagen <- raster(paste(dir$mapas,"biomasa_media.tif",sep=""))
plot(imagen)


# Metadatos ---------------------------------------------------------------
# datos de proyección
mex.proj <- projection (imagen)

# datos de extensi?n
extent (imagen)
base_extent <- extent(imagen)

# Hacer una tabla de datos para trabajar en R ------------------------------
# asocia el centro de cada pixel con su valor y crea una matrÃ?z.
datos.temp <- rasterToPoints(imagen)
nrow(datos.temp)
class(datos)


# Creación de un raster multicapa -----------------------------------------
# así? puedo acumular variables en una sola estructura con mucha eficiencia.
raster.multiple <- stack()  # inicialización de la estructura
lista.archivos <- list.files(path=dir$mapas, pattern="\\.tif$")
 
for (i in 1:length(lista.archivos))
{
  print(i)
  image <- raster(paste(dir$mapas,lista.archivos[i], sep=""))
  image <- crop(image,base_extent)
  extent(image) <- base_extent
  raster.multiple <- addLayer(raster.multiple, image)
}

dim(raster.multiple)
names(raster.multiple)

# genero una tabla de datos con todas las capas
datos <- rasterToPoints(raster.multiple)
datos <- datos[complete.cases(datos),]
length(datos[,1])
head (datos)
dimnames(datos)

write.table(datos, "all_variables.csv", sep=",", row.names=FALSE)


# Grafica matriz de correlaciones entre las variables ---------------------
library(reshape2)
datos.cor <- cor(datos[,4:15])
datos.cor.m <- melt(datos.cor)
mi.ids <- subset(datos.cor.m, Var1 == Var2)
mi.lower <- subset(datos.cor.m[lower.tri(datos.cor),], Var1 != Var2)
mi.upper <- subset(datos.cor.m[upper.tri(datos.cor),], Var1 != Var2)


p <- ggplot(datos.cor.m, aes(Var1, Var2, fill=value)) + theme_bw() + geom_tile()
p

p1 <- p +  geom_tile(data=mi.lower) + 
  geom_text(data=mi.lower, aes(label=round(value,3))) + 
  geom_text(data=mi.ids, aes(label=Var1, colour="grey40"))

meas <- as.character(unique(datos.cor.m$Var2))
p2 <- p1 + scale_colour_identity() + 
  scale_fill_gradientn(colours= c("red", "white", "blue"), limits=c(1.0,-1.0)) +
  scale_x_discrete(limits=meas[length(meas):1]) + #flip the x axis 
  scale_y_discrete(limits=meas)
p2

# Generar_mapa_dive_estructural -------------------------------------------

# cargar datos
datos_div_estruc <- read.table("datos-julian (integridad - estructural).txt",sep="\t",header=TRUE)
datos_div_estruc <- read.table("RB-estructure TAN (salida).txt",sep="\t",header=TRUE)


# cabecera de los datos
head(datos_div_estruc)

# Si se requiere voltear probabilidad
 datos_div_estruc[,3]<- (1-datos_div_estruc[,3])

# crear un spatial data frame a partir de tabla con coordenadas
coordinates(datos_div_estruc)=~finding.x+finding.y
gridded(datos_div_estruc)=TRUE
rast_es <- raster(datos_div_estruc)
plot(rast_es)

# asignar proyeccion y extent correctos
projection(rast_es)<-projection(imagen)
extent(rast_es)<-extent(rast_es)

# div estruc
rf <- writeRaster(rast_es, filename="estructura_v2.tif", format="GTiff", overwrite=TRUE)


# Desplegar sobrepuesto en google earth -----------------------------------

# load raster
r <- raster("estructura_v1.tif")

# convert to appropiate projection
rlatlong <- projectRaster(r, crs=CRS('+proj=longlat'))

# write as KML
KML(rlatlong, filename='browse.kml',maxpixels=2000000)


# Muestra estratificada por zvh -------------------------------------------
library (sampling)

colnames(datos)
# Variable de estratificaciÃ³n
estratos <- datos[, 17]
# vector de casos
casos <- cbind(datos)
# Vector de probabilidades de inclusiÃ³n
elige <- inclusionprobastrata (estratos, 80)
s <- balancedstratification(casos, estratos, elige, comment=TRUE)
# la muestra es
(datos[, 17])[s==1]


# Muestra estratificada por zvh a mano ------------------------------------

# cabecera
head(datos)
variables <- colnames(datos)
colnames(datos)

# variable para estratificar es la 24
# Â¿TamaÃ±o de las clases?
# table(datos[, 24])

# seleccionemos 50 al azar de la clase dos que es la chica
# y luego aleatoriamente 30,000 del resto de manera aleatoria
muestra_clase_chica <- datos[datos[, 24]==2,]
muestra_clase_chica <- muestra_clase_chica[sample((1:nrow(muestra_clase_chica)),50),] 

muestra_clases_grandes <- datos[datos[, 24]!=2,]
muestra_clases_grandes <- muestra_clases_grandes[sample((1:nrow(muestra_clases_grandes)),30000),] 

muestra <- rbind(muestra_clase_chica,muestra_clases_grandes)
colnames(muestra)
head(muestra)

write.table(muestra,"all_variables_muestra_(30k_50).csv",sep=",",row.names=FALSE)

table(muestra[,17])

getwd()

# Leer ShapeFile ----------------------------------------------------------

library(rgdal)
dir.mexbio <- "C:/Users/equih_000/Documents/0 Nubes/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Datos MEX/MEXBIO/"
shapefile <- paste(dir.mexbio, "VARSIEMX_MEXBIO_relleno.shp", sep="")
ogrListLayers(shapefile)
mexbio <- readOGR(shapefile, "VARSIEMX_MEXBIO_relleno")
names(mexbio)

mexbio.raster <- rasterize(x=mexbio, y=imagen, field="FIMP_RELLE")
plot(mexbio.raster)
writeRaster(mexbio.raster, filename="mexbio.tif", format="GTiff", overwrite=TRUE)
(mex)

# Ensayo para llamar NETICA desde R ---------------------------------------

library(RNetica)
StopNetica()
StartNetica(license="+EquihuaM/InstEco_MX/120,310-6-A/64347")
LearnCPTs()

red.julian <- ReadNetworks("Modelo estructural.dne")
CompileNetwork(red.julian)
RetractNetFindings(red.julian)

# Procesamiento de casos "en memoria"
# evidencia.en.memoria <- MemoryCaseStream(datos)
archivo.casos <- CaseFileStream("datos-julian-2.csv")
nodos.datos <- NetworkAllNodes(red.julian)

nodo.integridad <- nodos.datos[[3]]
lista.nodos <- list(nodos.datos[[1]], nodos.datos[[2]],
                    nodos.datos[[4]], nodos.datos[[5]], nodos.datos[[6]],
                    nodos.datos[[7]], nodos.datos[[8]], nodos.datos[[9]],
                    nodos.datos[[10]], nodos.datos[[11]], nodos.datos[[12]],
                    nodos.datos[[13]], nodos.datos[[14]], nodos.datos[[15]])

# Primer renglón del archivo: caso 1
archivo.casos <- ReadFindings(lista.nodos, archivo.casos, "FIRST")
integridad <- data.frame(p.alta=NodeBeliefs(nodo.integridad) [[1]])

NodeFinding(nodos.datos[[1]])

# Resto del archivo
tiempo <- proc.time()
while(!is.na(getCaseStreamPos(archivo.casos)))
{
  archivo.casos <- ReadFindings(lista.nodos, archivo.casos, "NEXT")
  integridad <- rbind(integridad, NodeBeliefs(nodo.integridad) [[1]])  
}
tiempo <- proc.time() - tiempo
cat("El proceso tom?: ", tiempo)

# Libera el espacio de memoria usado por la red bayesiana
CloseCaseStream (archivo.casos)
DeleteNetwork(red.julian)


# Base enorme -------------------------------------------------------------
library (raster)
library(rgdal)

# Tablet Miguel
# dir$mapas <- "C:/Users/equih_000/Documents/0 Nubes/GoogleDrive/2 Proyectos/RoBiN/Datos RoBiN/Exp Julian/0 BD-vigente/"

# Escritorio Miguel
dir$mapas <- "C:/Users/miguel.equihua/Documents/1 Nube/Google Drive/2 Proyectos/RoBiN/Datos RoBiN/Exp Julian/0 BD-vigente/"
base_enorme <- stack(paste(dir$mapas, "raster_base_total_16_05_2014.tif", sep=""))

# luego a puntos
base_enorme <- rasterToPoints(base_enorme) # esto se va a tardar



# si pierdes los nombres de las capas carga una de las muestras e.g.

muestra <- read.table(paste(dir$mapas, "data_set_1_.csv", sep=""),sep=",",header=TRUE)

# y le asignas esos nombres a la base enterior

names(base_enorme) <- names(muestra) # a lo mejor sirve colnames(base_enorme) <- names(muestra)
head (base_enorme)

# si no te deja a?n as?? a lo mejor tienes que hacerla propiamente un data frame antes
# base_enorme <- as.data.frame(base_enorme)

# luego la guardas en un texto, csv or whatever
arch.enorme <- paste(dir$mapas, "Base_Enorme.csv", sep="")
write.table(base_enorme, arch.enorme, sep=",", row.names=FALSE)

# Para eliminar casos con datos faltantes uso completecases
base.enorme.cc <- base_enorme[complete.cases(base_enorme), ]
head (base.enorme.cc)

arch.enorme.cc <- paste(dir$mapas, "Base_Enorme_cc.csv", sep="")
write.table(base.enorme.cc, arch.enorme.cc, sep=",", row.names=FALSE)

