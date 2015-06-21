### script para hacer una tabla a partir de los *.tifs
### de información de Brasil


# working directory
setwd("~/2_ROBIN/18 brasil Workshop/93brasil Workshop/Dados_clip_limite_PARA")

# packages
library("raster")

# useful functions ###

# function extracts the last n characters from a string 
# without counting the last m 
subs <- function(x, n=1,m=0){ substr(x, nchar(x)-n-m+1, nchar(x)-m) }

#                 ###

# files in working directory
filez <- list.files()

# initialize image name list
imagez <- list()
for (i in 1:length(filez)){
  if(subs(filez[i],3)=="tif"){
   imagez[i]<-filez[i] 
  }
}

# remove nulls
imagez <- unlist(imagez)
imagez
# matrix cols and rows and coordinates
baseimage <- raster(imagez[9])

rows <- nrow(baseimage)
cols <- ncol(baseimage)
proj <- projection(baseimage)

points <- rasterToPoints(baseimage)

datos <- cbind(points)
cord <- cbind(points[,1:2])

for (i in 1:(length(imagez)-1)){
  image <- crop(raster(imagez[i]),baseimage)
  image <- rasterToPoints(image)
  datos <- cbind(datos,image[,3])
  cord <- cbind(cord,image[,1:2])
  }

imagez
remove(coords)
remove(baseimageVec)

## coinciden las coordenadas
head(cord)
tail(cord)


colnames(datos) <- c("X","Y",imagez[9],imagez[-9])

imagez
datoscompletos <- datos[complete.cases(datos),]
colnames(datoscompletos)
head(datoscompletos)

#vcf <- raster("ModisVCF_MOD44B_2010_rec.tif")
#vcf <- as.matrix(vcf)
#vcf <- matrix(vcf,ncol(vcf)*nrow(vcf))
#vcf <- vcf[!is.na(vcf)]
#vcf

#tree cover
datoscompletos <- datoscompletos[datoscompletos[,10]!=128,]

# VCF
datoscompletos <- datoscompletos[datoscompletos[,9]!=200,] # 200 is missing
datoscompletos <- datoscompletos[datoscompletos[,9]!=253,]


# modis vcf missing
datoscompletos <- datoscompletos[datoscompletos[,8]!=65534,] #65534
# gpp missing
datoscompletos <- datoscompletos[datoscompletos[,7]!=32766,]

colnames(datoscompletos) <- c("X","Y",imagez[9],imagez[-9])

datoscompletos[,3:10]<-round(datoscompletos[,3:10],2) #round decimal places

# escribimos los datos completos si así se quisiera.
write.table(datoscompletos,"tabla.csv",sep=",",row.names=FALSE)

dim(datoscompletos)

muestra <- datoscompletos[sample(1:nrow(datoscompletos),30000),]




?which
for (i in 3:11){
  
  agregar <- datoscompletos[which(datoscompletos[,i]==min(datoscompletos[,i]))[1:5],]
  muestra <- rbind(muestra,agregar)
  agregar <- datoscompletos[which(datoscompletos[,i]==min(datoscompletos[,i]))[1:5],]
  muestra <- rbind(muestra,agregar)
}

dim(muestra)

head(muestra)

write.table(muestra,"muestra30090Fixed.csv",sep=",",row.names=FALSE)



### Pruebas
prueba <- data.frame(X=datoscompletos[,1],Y=datoscompletos[,2],data=datoscompletos[,4])

dim(muestra)

imagen <- muestra[,c(1:2,4)]
imagen <- as.data.frame(imagen)
coordinates(imagen)=~X+Y
gridded(imagen)=TRUE
r<-raster(imagen)
plot(r)
projection(r)<-proj
r[is.na(r)] <- -9999
writeRaster(r, filename="test2.tif", format="GTiff", overwrite=TRUE)

