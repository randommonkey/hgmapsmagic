
devtools::document()
devtools::install()

library(hgmapsmagic)


geo <- read_csv(system.file("aux/world-geo.csv",package = "hgchmagic"))
data <- data_frame(country = sample(geo$code))
data$valor <- runif(6)

hgch_map_choro_world_GcdNum(data)



pobl <- data.frame(pais = c("US", "ZW", "FR", "CO"), pob = c(316129,14150, 7978979, 7979))
hgch_map_bubbles_world_GcdNum(pobl, geoinfoPath = "inst/aux/world-cod.csv", geoCodeVar='iso2', geoNameVar = "name")


f <-  data.frame(
code = c('BRA-MGE', "ARG-DFD"),
vartwteuywgdbskjbskdcbskdjf = c(12743845843.7989,3345)
 )




 hgch_map_bubbles_latinAmerican_GcdNum(f,geoinfoPath = "inst/aux/latam-geo.csv",
                   geoCodeVar = "code",
                   geoNameVar = "name", export = TRUE, col_bur = 'black')



 f2 <-  data.frame(
   code = c('ARG-DFD','BRA-MGE', NA),
   xansdjsa = c(12, NA,12),
   yasksas = c(3345, 56.08089,NA)
 )

 hgch_map_bubbles_latinAmerican_GcdNumNum(f2,geoinfoPath = "inst/aux/latam-geo.csv",
                                     geoCodeVar = "code",
                                     geoNameVar = "name", export = TRUE, col_bone = 'orange', col_btwo = 'red')


