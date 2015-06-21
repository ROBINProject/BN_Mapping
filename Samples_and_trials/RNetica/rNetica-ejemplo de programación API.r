# ----------------------------------------------------------
# Ejemplo de interface con NETICA desde R
# 
#-----------------------------------------------------------
library(RNetica)
source("licencia.txt",echo=FALSE, print.eval=FALSE,verbose=FALSE)

ruta <- "C:\\Program Files\\Netica\\Netica 509\\Programming Examples\\Netica Demo for CLR C++ 8\\"
clinica <- paste(ruta, "ChestClinic.dne", sep="")
red.clinica <- ReadNetworks(clinica)

CompileNetwork(red.clinica)
stopifnot (is.NetworkCompiled(red.clinica))

# En c: belief = GetNodeBelief ("Tuberculosis", "present", net);
nd.tuberculosis <- NetworkFindNode(red.clinica, "Tuberculosis")
belief <- NodeBeliefs(nd.tuberculosis) [["present"]]
cat("The probability of tuberculosis is ", belief, "\n\n")

# En C: 
# EnterFinding ("XRay", "abnormal", net);
# belief = GetNodeBelief ("Tuberculosis", "present", net);
RetractNetFindings(red.clinica)
EnterFindings(red.clinica, findings=c(XRay="abnormal"))
belief <- NodeBeliefs(nd.tuberculosis) [["present"]]
cat("Given an abnormal X-ray, the probability of tuberculosis is",belief, "\n\n")

# En C:
# EnterFinding ("VisitAsia", "visit", net);
# belief = GetNodeBelief ("Tuberculosis", "present", net);
EnterFindings(red.clinica, findings=c(VisitAsia="visit"))
belief <- NodeBeliefs(nd.tuberculosis) [["present"]] 
cat("Given an abnormal X-ray and a visit to Asia,\n",
    "the probability of tuberculosis is: ",belief, "\n\n", sep="")

# En C:
# DeleteNet_bn (net);
# res = CloseNetica_bn (env, mesg);
netd <- DeleteNetwork (red.clinica)
stopifnot(!is.active(netd))
stopifnot(!is.active(red.clinica))

#...................................................
#
# Uso de R para leer el modelo de integridad y
# calcular la probabilidad a posteriori (beleaves)
# se reuiere RNetica, hay que instalarlo desde un 
# paquete zip que se obtiene aquí:
# http://pluto.coe.fsu.edu/RNetica/RNetica.html
# 
#...................................................
#
# inicialización y lectura de la red creada en NETICA
library(RNetica)
setwd("~/0 Versiones controladas/GIT/ROBIN/Redes Bayesianas/Brasil")
rb.integridad.brasil <- ReadNetworks("Amazonia 3 ( vegetación condiciona variables no integridad).neta")
CompileNetwork(rb.integridad.brasil)
stopifnot (is.NetworkCompiled(rb.integridad.brasil))

# Cálculo de la probabilidad que tiene el nodo integridad en su condición "high"
# sin contar con ninguna otra evidencia particular.
nd.integridad <- NetworkFindNode(rb.integridad.brasil, "Integrity")
belief <- NodeBeliefs(nd.integridad) [["high"]] * 100
cat("The prior-probability of high Integrity in general is", belief, "%\n\n")

# Proporciono evidencia en nodos específicos y obtengo la probabilidad 
# de la condición de los atributos del ecosistema: 
# Doy datos para tipo de vegetación y pongo integridad en "high"
nd.density <- NetworkFindNode(rb.integridad.brasil, "density3_br_tif")
nd.vegetacion <- NetworkFindNode(rb.integridad.brasil, "UsoVegetacaoIBGE_tif")
NodeStates(nd.vegetacion)
NodeStateComments(nd.vegetacion)
NodeStateTitles(nd.vegetacion)
NodeLevels(nd.vegetacion)
round(NodeBeliefs(nd.vegetacion)*100, 2)
RetractNetFindings(rb.integridad.brasil)
EnterFindings(rb.integridad.brasil,
              findings=c(Integrity="high", UsoVegetacaoIBGE_tif="Dsu" ))
belief <- NodeBeliefs(nd.density) [[1]] * 100
cat("Dado el tipo de vegetación e integridad high, la densidad es", belief, "\n\n")

# Lectura de casos desde un archivo de datos
RetractNetFindings(rb.integridad.brasil)
archivo.casos <- CaseFileStream("muestraTotalFixed.csv")
nodos.datos <- NetworkAllNodes(rb.integridad.brasil)
lista.nodos <- list(nodos.datos[[1]], nodos.datos[[2]], nodos.datos[[4]],
                    nodos.datos[[5]], nodos.datos[[6]], nodos.datos[[7]],
                    nodos.datos[[8]])
# Primer renglón del archivo: caso 1
datos.leidos <- ReadFindings(lista.nodos, archivo.casos, "FIRST")
integridad <- data.frame(p.high=NodeBeliefs(nd.integridad) [[1]])

# Siguientes casos en el archivo
datos.leidos <- ReadFindings(lista.nodos, archivo.casos, "NEXT")
integridad <- rbind(integridad,NodeBeliefs(nd.integridad) [[1]])

# Resto del archivo
tiempo <- proc.time()
while(!is.na(getCaseStreamPos(datos.leidos)))
{
  datos.leidos <- ReadFindings(lista.nodos, archivo.casos, "NEXT")
  integridad <- rbind(integridad,NodeBeliefs(nd.integridad) [[1]])  
}
tiempo <- proc.time() - tiempo
cat("El proceso tomó: ", tiempo)

  stopifnot(is.CaseFileStream(archivo.casos),
          isCaseStreamOpen(archivo.casos))

# Libera el espacio de memoria usado por la red bayesiana
CloseCaseStream (archivo.casos)
DeleteNetwork(rb.integridad.brasil)

#packages
library(raster)

# Working directory
setwd("~/0 Versiones controladas/GIT/ROBIN/Redes Bayesianas/Brasil")

datos <- read.table("P_int_amazonia-total.txt",sep="\t",header=TRUE)
datos <- as.data.frame(datos)
names(datos) <- c("X","Y","integridad")
head(datos)

coordinates(datos) <- ~ X + Y
gridded(datos) <- TRUE
r <- raster(datos)
plot(r)

writeRaster(r, filename="integridadFinalRedBayes.tif", format="GTiff", overwrite=TRUE)