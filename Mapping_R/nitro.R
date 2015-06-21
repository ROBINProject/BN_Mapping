# Datos de Nitrógeno en una cuenca (Hugget, 1993) para modelación espacialmente explícita
#
# Exploración del problema. 
# Despliegue en perspectiva de la cuenca
#
# Datos
library(lattice)
lat <- rep(1:8, each=8)
long <- rep(1:8, times=8)
elev <- c(105, 105, 105, 104, 106, 108, 110, 108,
          98, 100,  96,  94,  96, 100, 104, 100,
          82,  90,  82,  80,  85,  90,  95,  90,
          75,  82,  75,  56,  60,  80,  85,  80,
          62,  74,  62,  46,  52,  64,  72,  74,
          60,  66,  60,  42,  40,  52,  62,  62,
          52,  60,  52,  38,  30,  40,  50,  55,
          40,  45,  40,  36,  28,  36,   40,  45)

nitro <- runif(64, 5000,5010)
elev.df <- data.frame(long, lat, elev, nitro)

# Atributos de graficción. Paleta de colores
cols.uno <- unlist(trellis.par.get("regions"), use.names=F)

# Presentación en perspectiva
persp(1:8, 1:8, matrix(elev,8,8), theta=135, phi=5, r=10, expand=0.5,
      xlab="longitud", ylab="latitud", zlab="elevación")

# Presentación sin rellenos
wireframe(elev ~ lat * long, data=elev.df, drape=nitro, 
          screen = list(z = -50, x = -60), col.regions=cols.uno)

wireframe(elev ~ lat * long, data=elev.df, screen = list(z = -50, x = -60), 
          scales=list(arrows=F), col.regions=cols.uno)
at = c(5000, 5002, 5004, 5006, 5008, 5010),
wireframe(elev ~ lat * long, data=elev.df, drape=elev.df$nitro, scales=list(arrows=F), 
          screen = list(z = -50, x = -60), colorkey=list(space="top"), 
          perspective=T, zlab="Elevación", xlab="Latitutd", ylab="Longitud")

# Presentación con rellenos con funciones de la interfase gráfica de SPlus
guiPlot("Filled Data Grid Surface", 
        DataSetValues=data.frame(lat=-elev.df$lat, lon=elev.df$lon, elev=elev.df$elev),
        Projection=TRUE)

# Presentación en 2-D
graphsheet(color.scheme="topographical")
levelplot(elev ~ long * lat, data=elev.df, region=T, 
          colorkey=list(space="bottom"), aspect=1) 

library("mass")
eqscplot(c(1,8), c(1,8), ratio=1, axes=F, type="n", 
         xlim=c(1,10), ylim=c(1,8), ylab = "latitud", xlab = "longitud")
image(1:8, 1:8, matrix(elev, 8, 8), zlim = c(10, 120), add = T)
image.legend(matrix(elev, 8, 8), x = c(9.5, 10), y = c(1, 8), horizontal=F)


# Generación de la clase "cuenca" para representar la estructura espacial y el contenido
# de nitrógeno en celdas.  Para la definición de esta clase se ejemplifica la "extención"
# de otra clase preexistente, en este caso la que contiene las coordenadas de 
# cada celda. Como el flujo de nitrógeno depende fundamentalmente de la pendiente de
# cada celda, es conveniente tener este dato, para cada dirección en cada celda.
# Una clase puede eliminarse con la función "removeClass"

setClass("coordXY", representation(x = "numeric", y = "numeric"))

setClass("cuenca", representation(descripcion = "character", "coordXY", altura = "numeric", 
                                  nitrogeno ="numeric", pendN = "numeric", pendE = "numeric", pendS = "numeric", 
                                  pendW = "numeric", DXcelda = "numeric", DYcelda = "numeric", Nlluvia = "numeric"))
getClass("cuenca")

# Para crear un objeto de esta clase hay que usar la función "new", aunque esta tarea
# suele ser manejada mejor con un método creado a propósito de la funcionalidad de la 
# clase, en este caso notese que sólo interesa tomar los datos de ubicación, elevación
# y contenido de nitrógeno de cada celda.  Los datos de pendiente se calculan a partir 
# de la información proporcionada.  Sin embargo el uso directo de la función "new" sería
# de esta manera.  Por conveniencia se cargan los datos en algunos vectores.

actopan <- new("cuenca", descripcion="Cuenca del río Actopan", x = lon, y = lat, altura = elev, nitrogeno = nitro, 
               DXcelda=100, DYcelda=100, Nlluvia=16)
actopan

# Pero es mejor definir un método apropiado para realizar la tarea.  De paso se pueden 
# calcular los valores de las pendientes en las distintas direcciones.
# Antes de hacerlo hay que experimentar formas de extraer los datos de la cuenca 
# Primero los casos por columnas "X"
alturasX <- function (fila, objeto) split(objeto@altura, objeto@x)[[fila]]

nitrosX <- function (fila, objeto) split(objeto@nitrogeno, objeto@x)[[fila]]

# extrae los datos de la cuenca por filas "Y"
alturasY <- function (fila, objeto) split(objeto@altura, objeto@y)[[fila]]

nitrosY <- function (fila, objeto) split(objeto@nitrogeno, objeto@y)[[fila]]

# Ahora sí, la función para ingresar los datos de la clase cuenca
cuenca <- function (descripcion, longitud, latitud, elevacion, nitrogeno, dx, dy, nlluvia)
{
  cols <- max(longitud)
  filas <- max(latitud)
  
  # Preparación para aplicar cálculos al reccorrer los datos con "sapply"
  inclinacion <- function(i, dato, celda) (dato[[i + 1]] - dato[[i]]) / celda
  
  reciproco <- function(i, direccion, dato) if (direccion == "NS") -dato[i,] else -dato[, i]
  
  enlistar <- function(i, dato)	dato[i, ]		
  
  # calcula las pendientes en la dirección NS
  tmpNS <- split(elevacion, latitud)
  tmp.S <- t(sapply(1:(filas - 1), inclinacion, tmpNS, dy))
  tmp.S <- rbind(tmp.S, tmp.S[(filas - 1),]) # Notese la coma para tomar un renglón
  tmp.N <- t(sapply(c(1,1:(filas - 1)), reciproco, "NS", tmp.S))
  tmp.N [1,] <- tmp.N[1,] # Notese la coma para hacer referencia al renglón completo
  tmp.S <- unlist(lapply(1:filas, enlistar, tmp.S))
  tmp.N <- unlist(lapply(1:filas, enlistar, tmp.N))
  
  # calcula las pendientes en la dirección EW
  tmpEW <- split(elevacion, longitud)
  tmp.E <- sapply(1:(cols - 1), inclinacion, tmpEW, dx)
  tmp.E <- cbind(tmp.E, tmp.E[, cols - 1]) # Notese la coma para tomar una columna
  tmp.W <- sapply(c(1,1:(cols - 1)), reciproco, "EW", tmp.E)
  tmp.W [, 1] <- tmp.W[, 1] # Notese la coma para hacer referencia a la columna completa
  tmp.E <- unlist(lapply(1:filas, enlistar, tmp.E))
  tmp.W <- unlist(lapply(1:filas, enlistar, tmp.W))
  
  new("cuenca", descripcion = descripcion, x = longitud, y = latitud, altura = elevacion, 
      nitrogeno = nitrogeno, pendN = tmp.N, pendE = tmp.E, pendS = tmp.S, pendW = tmp.W, 
      DXcelda = dx, DYcelda = dy, Nlluvia = nlluvia)
}


# Obviamente un problema potencial es que los datos no sean adecuados, por ejemplo
# que tengan la misma longitud.  Si se quiere asegurar que todos los "slots" sean 
# de la misma longitud se puede hacer lo siguiente (notese el uso de "@" para referirse
# a los "slots" por su nombre):

validaCuenca <- function (object)
{
  long <- length(object@x)
  if ((length(object@y) != long) || (length(object@altura) != long) || (length(object@nitrogeno) != long))
    return("Distinto numero de datos en alguna de las variables")
  else
  {
    return(TRUE)
  }
}

setClass("cuenca", representation(descripcion = "character", "coordXY", altura = "numeric", 
                                  nitrogeno ="numeric", pendN = "numeric", pendE = "numeric", pendS = "numeric", 
                                  pendW = "numeric", DXcelda = "numeric", DYcelda = "numeric", Nlluvia = "numeric"),
         validity = validaCuenca)

setValidity("cuenca", validaCuenca)

lat1 <- rep(1:9, each=8)

# Recordemos los datos de nitrógeno en una cuenca según Hugget (1993)
#
lat <- rep(1:8, each=8)
long <- rep(1:8, times=8)
elev <- c(105, 105, 105, 104, 106, 108, 110, 108,
          98, 100,  96,  94,  96, 100, 104, 100,
          82,  90,  82,  80,  85,  90,  95,  90,
          75,  82,  75,  56,  60,  80,  85,  80,
          62,  74,  62,  46,  52,  64,  72,  74,
          60,  66,  60,  42,  40,  52,  62,  62,
          52,  60,  52,  38,  30,  40,  50,  55,
          40,  45,  40,  36,  28,  36,   40,  45)

nitro <- runif(64, 5000,5010)
nitro.0 <- rep(5000, 64)


# Una vez definido la clase puedo crear las instancias particulares del objeto que necesite!!!
actopan.0 <- cuenca("Cuenca del rio Actopan", lon, lat, elev, nitro, 100, 100, 16)
actopan.0

actopan.1 <- cuenca("Cuanca del rio Actopan: copia 1 con nitro homogeneo: 5000", 
                    lon, lat, elev, nitro.0, 100, 100, 16)
actopan.1

actopan <- cuenca("Cuenca del rio Actopan", lon, lat, elev, nitro, 100, 100, 16)
actopan

# Para obtener información sobre una clase se pueden usar "getSlots", "slotNames" y "hasSlot" para
# obtener información sobre los datos que toma la clase (o un objeto).  "dumClass" genera un archivo
# en el directorio de trabajo con la definición completa de la clase.

getSlots("cuenca")
slotNames("cuenca")
hasSlot("cuenca", "x")
dumpClass("cuenca")

getSlots(actopan)
slotNames(actopan)
hasSlot(actopan, "x")


# Métodos para desplegar información sobre la cuenca.
# Creación de un método para mostrar los datos de la cuenca
print.cuenca <- function (object, digitos = 2)
{
  filas <- max(object@y)
  tmp.alt   <- sapply(1:filas, alturasX, object)
  tmp.nitro <- sapply(1:filas, nitrosX, object)
  print(cat("\n\n", object@descripcion, "\n\n"), quote=F)
  print(cat("Longitud de la celda:", object@DXcelda, "\n"), quote=F)
  print(cat("Nitrogeno en la lluvia:", object@Nlluvia, "\n\n"), quote=F)
  print(cat("Elevacion de la cuenca\n"), quote=F)
  print(tmp.alt, quote=F)
  print(cat("\nContenido de nitrogeno en la cuenca\n"), quote=F)
  print(tmp.nitro, quote=F)
}

# Define el método default para desplegar información sobre objetos tipo "cuenca"
setMethod("show", "cuenca", function (object) print.cuenca (object))


#
#  Grafica las direcciones de flujo de nitrogeno de cada punto y en cada orientación
#  Esta presentación puede usarse como una herramienta diagnóstica para visualizar
#  como están operando los supuestos de transporte en el modelo.
#
grafica.flujo <- function (datos, colPunto = 1, colFlecha = 2)
{
  LatMax <- max(datos@y)
  LonMax <- max(datos@x)
  NumCels <- length(datos@x)
  
  # Estima la intensidad de flujo y su dirección como función de la pendiente entre celdas.
  flujo <- function (i, pN, pE, pS, pW, xx, yy, LimPend)
  {
    fc <- min(LimPend) / diff(LimPend) 
    largo <- 0.5
    if (pN[i] < 0)		temp.N <- c(xx[i], yy[i] + largo * (pN[i] / diff(LimPend) - fc), xx[i], yy[i] + 0.1) else 
      if(pN[i] > 0)	temp.N <- c(xx[i], yy[i] + 0.1, xx[i], yy[i] + largo * (pN[i] / diff(LimPend) - fc))
    else 		temp.N <- c(xx[i], yy[i], xx[i], yy[i])
    
    if (pS[i] < 0) 	  	temp.S <- c(xx[i], yy[i] - largo * (pS[i] / diff(LimPend) - fc), xx[i], yy[i] - 0.1) else 
      if(pS[i] > 0)	temp.S <- c(xx[i], yy[i] - 0.1, xx[i], yy[i] - largo * (pS[i] / diff(LimPend) - fc))
    else 		temp.S <- c(xx[i], yy[i], xx[i], yy[i])
    
    if (pE[i] < 0)		temp.E <- c(xx[i] + 0.1, yy[i], xx[i] + largo * (pE[i] / diff(LimPend) - fc), yy[i]) else 
      if(pE[i] > 0)	temp.E <- c(xx[i] + largo * (pE[i] / diff(LimPend) - fc), yy[i], xx[i] + 0.1, yy[i])
    else 		temp.E <- c(xx[i], yy[i], xx[i], yy[i])
    
    if (pW[i] < 0) 	  	temp.W <- c(xx[i] - 0.1, yy[i], xx[i] - largo * (pW[i] / diff(LimPend) - fc), yy[i]) else 
      if(pW[i] > 0)	temp.W <- c(xx[i] - largo * (pW[i] / diff(LimPend) - fc), yy[i], xx[i] - 0.1, yy[i])
    else 		temp.W <- c(xx[i], yy[i], xx[i], yy[i])
    
    temp <- c(temp.N, temp.E, temp.S, temp.W)
    return(temp)
  }
  
  if (class(datos)=="cuenca")
  {
    temp.lims.pend <- range(as.numeric(rbind(datos@pendN, datos@pendE, datos@pendS, datos@pendW)))
    temp <- sapply(1:NumCels, flujo, datos@pendN,datos@pendE,datos@pendS,datos@pendW,
                   datos@x, datos@y, temp.lims.pend) 
    
    # La graficación de las flechas requiere 4 coordenadas (x0, y0) inicia y (x1, y1) termina,  
    # y además los datos cubren 4 orientaciones en cada una de las celdas
    temp <- matrix(temp, 4, 4 * NumCels)
    temp <- data.frame(x0=temp[1,], y0=temp[2,], x1=temp[3,], y1=temp[4,])
    
    plot(c(0, (LonMax + 1)), c(0, (LatMax + 1)), type="n", xlab = "longitud", ylab = "latitud")
    points (datos@x, datos@y, pch=16, col = colPunto)
    arrows (temp$x0, temp$y0, temp$x1, temp$y1, size=0.15, open=T, col = colFlecha)
  }
  else cat('Error: Los datos deben ser de clase \"cuenca\".\n')
}

par (mfrow = c(1, 1))
grafica.flujo(actopan.0)

#size =0.15, 

# Método para graficar el contenido de nitrógeno en la cuenca
# como se está usando como base la función "plot", hay que respetar la
# estructura y nomenclatura de argumentos de esa función.
plot.cuenca <- function (x, y, ...)
{
  dots <- match.call(expand.dots=T)  # para recuperar el parametro gama, recupera la llamada a la función
  hayTipo <- pmatch("tipo", names(dots), 0) > 0 # checa que exista algo al menos parcialmente parecido a "tipo"
  hayGama <- pmatch("gama", names(dots), 0) > 0 # checa que exista algo al menos parcialmente parecido a "gama"
  
  tmp <- data.frame(xx = x@x, yy = x@y, zz = x@altura, nn = x@nitrogeno)
  if (hayGama) gama <- eval(dots$gama) else gama <- NULL # toma los datos correspondientes si existen
  
  if (hayTipo && (pmatch("persp", dots$tipo, 0) > 0))
  {
    if (is.null(gama)) 
      wireframe(zz ~ yy * xx, data = tmp, drape=tmp$nn, scales=list(arrows=F), 
                screen = list(z = -50, x = -60), colorkey=list(space="top"), 
                zlab="Elevación", xlab="Latitutd", ylab="Longitud")
    else
      wireframe(zz ~ yy * xx, data = tmp, drape=tmp$nn, scales=list(arrows=F), 
                at = gama,
                screen = list(z = -50, x = -60), colorkey=list(space="top"), 
                zlab="Elevación", xlab="Latitutd", ylab="Longitud")
  }
  else
  {
    if (is.null(gama)) 
      levelplot(nn ~ xx * yy, data = tmp, ylab = "latitud", xlab = "longitud", 
                colorkey=list(space = "top"), aspect=1, region = T)
    else
      levelplot(nn ~ xx * yy, data = tmp, ylab = "latitud", xlab = "longitud", 
                at = gama, colorkey=list(space = "top"), aspect=1, region = T)
  }
}


# Como sólo se usara relamente el primer parámetro de la función, el hacer la asignación
# de esta manera asegura que el parámetro "y" esté realmente vacío.
# sin embargo se pueden proporcionar parámetros aparte de "y".  En este caso "gama".
# Ahora defino el método default para graficar un objeto de tipo "cuenca"

setMethod("plot", signature(x = "cuenca", y="missing", ...=tipo), plot.cuenca)

# Veamos como se ve la cuenca en sus distintas versiones.
plot(actopan.0, tipo="perspe")
plot(actopan.0, gama=c(1005, 2005, 3005, 4005, 5005, 6005))
plot(actopan.1,  gama=c(1000, 2000, 3000, 4000, 5000, 6000))


#
# Operación de la simulación
#
simula.cuenca <- function (datos, dt = 1, intervalo, Tfinal)
{
  MaxLong <- max(datos@x)
  MaxLat <- max(datos@y)
  nlluv <- datos@Nlluvia
  tmp.N <- matrix(unlist(split(datos@nitrogeno, datos@x)), MaxLong, MaxLat)
  tmp.rango.N <- range(datos@nitrogeno)
  
  # amplia la matriz de nitrogeno en los márgenes repitiendo la celda vecina
  # Las concentraciones de nitrógeno en la frontera toman valores aleatorios
  tmp.N <- cbind(tmp.N[, 1] * runif(MaxLong, 0, 1), tmp.N, tmp.N[, MaxLong] * runif(MaxLong, 0, 1))
  tmp.N <- rbind(tmp.N[1, ] * runif(MaxLat + 2, 0, 1), tmp.N, tmp.N[MaxLat, ] * runif(MaxLat + 2, 0, 1))
  
  pN <- matrix(unlist(split(datos@pendN, datos@x)), MaxLong, MaxLat)
  pE <- matrix(unlist(split(datos@pendE, datos@x)), MaxLong, MaxLat)
  pS <- matrix(unlist(split(datos@pendS, datos@x)), MaxLong, MaxLat)
  pW <- matrix(unlist(split(datos@pendW, datos@x)), MaxLong, MaxLat)
  
  resultados <-c(list(tmp.N[2:(MaxLong + 1), 2:(MaxLat + 1)]))
  serie <- 0
  final <- ceiling(Tfinal / dt)
  for (tiempo in 1:final)
  {
    tmp.N.t1 <- matrix (0, MaxLat, MaxLong)
    for (i in 2:(MaxLat + 1))
      for (j in 2:(MaxLong + 1))
      {
        if (pN[i-1, j-1] <= 0) e1 <- tmp.N[i, j] * pN[i-1, j-1] else e1 <- tmp.N[i-1, j] * pN[i-1, j-1]
        if (pE[i-1, j-1] <= 0) e2 <- tmp.N[i, j] * pE[i-1, j-1] else e2 <- tmp.N[i, j+1] * pE[i-1, j-1]
        if (pS[i-1, j-1] <= 0) e3 <- tmp.N[i, j] * pS[i-1, j-1] else e3 <- tmp.N[i+1, j] * pS[i-1, j-1]
        if (pW[i-1, j-1] <= 0) e4 <- tmp.N[i, j] * pW[i-1, j-1] else e4 <- tmp.N[i, j-1] * pW[i-1, j-1]
        tmp.N.t1[i-1, j-1] <- tmp.N[i,j] + (e1 + e2 + e3 + e4) * dt + nlluv * dt
      }
    if ((ceiling(tiempo * dt) %% intervalo)== 0) 
    {
      serie <- c(serie, tiempo)
      resultados <- c(resultados, list(tmp.N.t1))
    }
    tmp.N <- tmp.N.t1
    tmp.rango.N <- range(c(tmp.rango.N, range(tmp.N.t1)))
    
    # Las concentraciones de nitrógeno en la frontera toman valores aleatorios
    tmp.N <- cbind(tmp.N[, 1] * runif(MaxLong, 0, 1), tmp.N, tmp.N[, MaxLong] * runif(MaxLong, 0, 1))
    tmp.N <- rbind(tmp.N[1, ] * runif(MaxLat + 2, 0, 1), tmp.N, tmp.N[MaxLat, ] * runif(MaxLat + 2, 0, 1))
  }
  resultados <- list(x = datos@x, y = datos@y, GamaNitrogeno = tmp.rango.N, 
                     MaxLat = MaxLat, MaxLong = MaxLong, tiempo = serie, simulacion = resultados)
  return(resultados)
}


# Corro la simulación del modelo por 45 años (Tfinal)
# y reporto resultados cada año (intervalo)
actopan.0.sim.1 <- simula.cuenca(actopan.0, intervalo=5, Tfinal=40)
actopan.1.sim.1 <- simula.cuenca(actopan.1, intervalo=5, Tfinal=85)

# Defino la función que despliega los resultados de la simulación en forma gráfica
grafica.nitro <- function (datos, ratio = 1, tol = 0.04, uin = 1)
{
  MaxLong <- max(datos$MaxLong)
  MaxLat <- max(datos$MaxLat)
  nitro <- datos$simulacion
  nitroInterv <- datos$GamaNitrogeno
  tiempo <- datos$tiempo
  filas <- length(tiempo) / 3
  
  grafica.tmp <- function (i, nitro, tiempo, MaxLong, MaxLat, nitroInterv, xlim, ylim)
  {
    nitro <- matrix(unlist(nitro[i]),MaxLong, MaxLat, byrow=T)
    image(1:MaxLong, 1:MaxLat, matrix(nitro, MaxLong, MaxLat), zlim = nitroInterv, xlim = xlim, ylim = ylim)
    title (main=paste("Tiempo", tiempo[i]))		
  }
  
  # Iguala la longitud de ambos ejes según el algoritmo implementado
  # en la función "eqscplot" de la biblioteca MASS
  graphsheet(color.scheme="topographical")
  par (mfrow = c(3, filas))
  xlim <- range(datos$x[is.finite(datos$x)]) 
  ylim <- range(datos$y[is.finite(datos$y)])
  midx <- 0.5 * (xlim[2] + xlim[1])
  xlim <- midx + (1 + tol) * 0.5 * c(-1, 1) * (xlim[2] - xlim[1])
  midy <- 0.5 * (ylim[2] + ylim[1])
  ylim <- midy + (1 + tol) * 0.5 * c(-1, 1) * (ylim[2] - ylim[1])
  oldpin <- par("pin")
  xuin <- oxuin <- oldpin[1]/diff(xlim)
  yuin <- oyuin <- oldpin[2]/diff(ylim)
  if(missing(uin)) {
    if(yuin > xuin * ratio)
      yuin <- xuin * ratio
    else xuin <- yuin/ratio
  }
  else {
    if(length(uin) == 1)
      uin <- uin * c(1, ratio)
    if(any(c(xuin, yuin) < uin))
      stop("uin is too large to fit plot in")
    xuin <- uin[1]
    yuin <- uin[2]
  }
  xlim <- midx + oxuin/xuin * c(-1, 1) * diff(xlim) * 0.5
  ylim <- midy + oyuin/yuin * c(-1, 1) * diff(ylim) * 0.5
  
  sapply(1:length(tiempo), grafica.tmp, nitro, tiempo, MaxLong, MaxLat, nitroInterv, xlim, ylim)
}

# Muestra gráficamente los resultados de la simulación
grafica.nitro (actopan.0.sim.1)
grafica.nitro (actopan.1.sim.1)

