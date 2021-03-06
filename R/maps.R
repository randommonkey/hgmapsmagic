#'@name count_pl
#'@export
count_pl <- function(x) {
  if(is.na(x)){return(0)}

  if ((x %% 1) != 0) {
    nchar(strsplit(sub('0+$', '', as.character(x)), ".", fixed=TRUE)[[1]][[2]])
  } else {
    return(0)
  }
}


#' Choropleth's world map
#' @name hgch_map_choro_world_GcdNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num
#' @examples
#' hgch_map_choro_world_GcdNum(sampleData("Gcd-Num",nrow = 10))
#' @export hgch_map_choro_world_GcdNum
hgch_map_choro_world_GcdNum <- function(data, title = NULL,
                                        subtitle = NULL,
                                        xAxisTitle = NULL,
                                        yAxisTitle = NULL,
                                        minColor = "#E63917",
                                        maxColor= "#18941E",
                                        aggregate = "count", theme = NULL,
                                        export = FALSE, ...){

  f <- fringe(data)
  nms <- getClabels(f)

  data(worldgeojson)

  xAxisTitle <- xAxisTitle %||% nms[1]
  yAxisTitle <- yAxisTitle %||% nms[2]
  title <-  title %||% ""
  d <- f$d %>% na.omit()
  d$iso3 <- d$a

  hc <- highchart() %>%
    hc_title(text = title) %>%
    hc_subtitle(text = subtitle) %>%
    #hc_chart(zoomType = "xy") %>%
    hc_add_series_map(worldgeojson, d,value = "b", joinBy = "iso3") %>%
    hc_colorAxis(maxColor = maxColor, minColor = minColor) %>%
    hc_mapNavigation(enabled = TRUE)
  #hc <- hc %>% hc_add_theme(hc_theme(theme))
  if(export) hc <- hc %>% hc_exporting(enabled = TRUE)
  hc
}


#' Bubble world map
#' @name hgch_map_bubbles_world_GcdNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num
#' @examples
#' hgch_map_bubbles_world_GcdNum(sampleData("Gcd-Num",nrow = 10))
#' @export hgch_map_bubbles_world_GcdNum
hgch_map_bubbles_world_GcdNum <- function(data,
                                          title = NULL,
                                          subtitle = NULL,
                                          geoinfoPath = NULL,
                                          geoCodeVar = NULL,
                                          geoNameVar = NULL,
                                          theme = NULL,
                                          export = FALSE,
                                          leg_pos = 'bottom',
                                          leg_col =  "#505053",
                                          leg_alg = 'left',...){


  if(class(data)[1] == "Fringe"){
    ni <- getClabels(data)[-1]
  }else{
    ni <- names(data)[-1]
  }

  f <- fringe(data)
  nms <- getClabels(f)


  geoCodeVar <- geoCodeVar %||% "code"
  geo <- read_csv(geoinfoPath)
  geo$a <- geo[[geoCodeVar]]
  if(is.null(geoNameVar))
    geoNameVar <- geoCodeVar
  geo$name <- geo[[geoNameVar]]
  varLabel <- nms[2]

  dgeo <- f$d %>%
    tidyr::drop_na() %>%
    group_by(a) %>%
    dplyr::summarise(b = mean(b))

  d <- dgeo %>% left_join(geo[c("a","name","lat","lon")],"a")

  data <- d %>% filter(!is.na(b))
  data <- plyr::rename(data, c('b' = 'z'))
  data$nou <- ni

  data$w <- map_chr(data$z, function(x) format(round(x,2), nsmall=(ifelse(count_pl(x)>2, 2, 0)), big.mark=","))

  data(worldgeojson, package = "highcharter")
  mapLam <- jsonlite::fromJSON(system.file("aux/latin-america.json",package = "hgmapsmagic"), simplifyVector = FALSE)
  mapLam <- geojsonio::as.json(mapLam)

  highchart(type = "map") %>%
    #hc_title(text = title) %>%
    #hc_subtitle(text = subtitle) %>%
    hc_chart(backgroundColor = "#CDD2D4") %>%
    hc_add_series(mapData = worldgeojson, showInLegend = FALSE
    ) %>%
    hc_mapNavigation(enabled = TRUE,
                     buttonOptions = list(align = leg_alg,
                                          verticalAlign = leg_pos,
                                          theme = list(
                                            fill = leg_col))
    )%>%
    hc_add_series(data = data, type = "mapbubble", minSize = '3%',
                  maxSize = 30,  showInLegend = TRUE, name = data$nou[1],tooltip= list(
                    headerFormat= '',
                    pointFormat='<b>{point.name}</b>:<br>
                    {point.nou}: {point.w}'
                  ))

}


#' Bubble latam map
#' @name hgch_map_bubbles_latinAmerican_GcdNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num
#' @examples
#' hgch_map_bubbles_latinAmerican_GcdNum(sampleData("Gcd-Num",nrow = 10))
#' @export hgch_map_bubbles_latinAmerican_GcdNum
hgch_map_bubbles_latinAmerican_GcdNum <- function(data,
                                                  title = NULL,
                                                  subtitle = NULL,
                                                  geoinfoPath = NULL,
                                                  geoCodeVar = NULL,
                                                  geoNameVar = NULL,
                                                  theme = NULL,
                                                  col_bur = NULL,
                                                  export = FALSE,
                                                  leg_pos = 'bottom',
                                                  leg_col =  "#505053",
                                                  leg_alg = 'left',
                                                  back_color = "#CDD2D4",...){

  if(class(data)[1] == "Fringe"){
    ni <- getClabels(data)[-1]
  }else{
    ni <- names(data)[-1]
  }

  f <- fringe(data)
  nms <- getClabels(f)

  geoinfoPath <- geoinfoPath %||% system.file("aux/world-geo.csv",package = "hgmapsmagic")
  geoCodeVar <- geoCodeVar %||% "code"
  geo <- read_csv(geoinfoPath)
  geo$a <- geo[[geoCodeVar]]
  if(is.null(geoNameVar))
    geoNameVar <- geoCodeVar
  geo$name <- geo[[geoNameVar]]
  varLabel <- nms[2]

  dgeo <- f$d %>%
    tidyr::drop_na() %>%
    group_by(a) %>%
    dplyr::summarise(b = mean(b))

  d <- dgeo %>% left_join(geo[c("a","name","lat","lon")],"a")

  data <- d %>% filter(!is.na(b))
  data <- plyr::rename(data, c('b' = 'z'))
  data$nou <- ni

  data$w <- map_chr(data$z, function(x) format(round(x,2), nsmall=(ifelse(count_pl(x)>2, 2, 0)), big.mark=","))

  mapLam <- jsonlite::fromJSON(system.file("aux/latin-america.json",package = "hgmapsmagic"), simplifyVector = FALSE)
  mapLam <- geojsonio::as.json(mapLam)

  hc <- highchart(type = "map") %>%
    hc_title(text = title) %>%
    hc_subtitle(text = subtitle) %>%
    hc_chart(backgroundColor = back_color) %>%
    hc_add_series(mapData = mapLam, showInLegend = FALSE, dataLabels = list(
      enabled = TRUE, format='{point.name}'
    )
    ) %>%
    hc_mapNavigation(enabled = TRUE,
                     buttonOptions = list(align = leg_alg,
                                          verticalAlign = leg_pos,
                                          theme = list(
                                            fill = leg_col))
    )%>%
    hc_add_series(data = data, type = "mapbubble", minSize = '3%', color= col_bur,
                  maxSize = 30,  showInLegend = TRUE, name = data$nou[1],tooltip= list(
                    headerFormat= '',
                    pointFormat='<b>{point.name}</b>:<br>
                    {point.nou}: {point.w}'
                  ))

  # if(comma_dec)
  #  hc <- hc  %>% hc_tooltip(formatter=  JS(paste0("function(){
  #          return this.point.name + ': <b>' +Highcharts.numberFormat(this.point.z,1,'.',',')+'</b><br/>';
  #      }")))


  #hc <- hc %>% hc_add_theme(custom_theme(custom=theme))
  if(export) hc <- hc %>% hc_exporting(enabled = TRUE)
  hc

}


#' Bubble latam map
#' @name hgch_map_bubbles_latinAmerican_GcdNumNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num-Num
#' @examples
#' hgch_map_bubbles_latinAmerican_GcdNumNum(sampleData("Gcd-Num-Num",nrow = 10))
#' @export hgch_map_bubbles_latinAmerican_GcdNumNum

hgch_map_bubbles_latinAmerican_GcdNumNum <- function(data,
                                                     title = NULL,
                                                     subtitle = NULL,
                                                     geoinfoPath = NULL,
                                                     geoCodeVar = NULL,
                                                     geoNameVar = NULL,
                                                     theme = NULL,
                                                     col_bone = NULL,
                                                     col_btwo = NULL,
                                                     export = FALSE,
                                                     leg_pos = 'bottom',
                                                     leg_col =  "#505053",
                                                     leg_alg = 'left',
                                                     back_color = "#CDD2D4",...){


  if(class(data)[1] == "Fringe"){
    ni <- getClabels(data)[-1]
  }else{
    ni <- names(data)[-1]
  }
  f <- fringe(data)
  nms <- getClabels(f)

  geoinfoPath <- geoinfoPath %||% system.file("aux/world-geo.csv",package = "hgmapsmagic")
  geoCodeVar <- geoCodeVar %||% "code"
  geo <- read_csv(geoinfoPath)
  geo$a <- geo[[geoCodeVar]]
  if(is.null(geoNameVar))
    geoNameVar <- geoCodeVar
  geo$name <- geo[[geoNameVar]]
  varLabel <- nms[2]
  d1 <- f$d %>% group_by(a) %>% dplyr::summarise(b = mean(b, na.rm = TRUE), c = mean(c,na.rm = TRUE))
  #d2 <- f$d %>% na.omit() %>% group_by(a) %>% dplyr::summarise(b = mean(b), c = mean(c))

  d <- d1 %>% left_join(geo[c("a","name","lat","lon")],"a")
  d <- d %>% tidyr::drop_na(a)

  d$text1 <- map_chr(d$b, function(x) format(round(x,2), nsmall=(ifelse(count_pl(x)>2, 2, 0)), big.mark=","))
  d$text2 <- map_chr(d$c, function(x) format(round(x,2), nsmall=(ifelse(count_pl(x)>2, 2, 0)), big.mark=","))

  d$var1 <- ni[1]
  d$var2 <- ni[2]


  d$z <- d$c
  serie1 <- select(d, -z)
  serie1 <- plyr::rename(serie1, c('b' = 'z'))

  mapLam <- jsonlite::fromJSON(system.file("aux/latin-america.json",package = "hgmapsmagic"), simplifyVector = FALSE)
  mapLam <- geojsonio::as.json(mapLam)

  hc <- highchart(type = "map") %>%
    hc_title(text = title) %>%
    hc_subtitle(text = subtitle) %>%
    hc_chart(backgroundColor = back_color) %>%
    hc_add_series(mapData = mapLam, showInLegend = FALSE, dataLabels = list(
      enabled = TRUE, format='{point.name}'
    )
    ) %>%
    hc_mapNavigation(enabled = TRUE,
                     buttonOptions = list(align = leg_alg,
                                          verticalAlign = leg_pos,
                                          theme = list(
                                            fill = leg_col))
    )%>%
    hc_add_series(data = serie1, type = "mapbubble",minSize = 2, color = col_bone,
                  maxSize = 40, showInLegend = TRUE, name = d$var1[1],tooltip = list(
                    useHTML = TRUE,
                    headerFormat = '<table>',
                    pointFormat ="<b>{point.name}</b> <br>
                    {point.var1}: {point.text1} <br>
                    {point.var2}: {point.text2}",
                    footerFormat= '</table>'
                  )) %>%
    hc_add_series(data = d, type = "mapbubble", minSize = 2, color = col_btwo,
                  maxSize = 40,showInLegend = TRUE, name = d$var2[1],tooltip= list(
                    useHTML = TRUE,
                    headerFormat = '<table>',
                    pointFormat ="<b>{point.name}</b> <br>
                    {point.var1}: {point.text1} <br>
                    {point.var2}: {point.text2}",
                    footerFormat= '</table>'))

  #hc <- hc %>% hc_add_theme(custom_theme(custom=theme))
  if(export) hc <- hc %>% hc_exporting(enabled = TRUE)
  hc

}



#' Choropleth's world map
#' @name hgch_colombia_choro_world_GcdNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num
#' @examples
#' hgch_map_choro_colombia_GcdNum(sampleData("Gcd-Num",nrow = 10))
#' @export hgch_map_choro_colombia_GcdNum
hgch_map_choro_colombia_GcdNum <- function(data, title = NULL,
                                           subtitle = NULL,
                                           xAxisTitle = NULL,
                                           yAxisTitle = NULL,
                                           minColor = "#E63917",
                                           maxColor= "#18941E",
                                           theme = NULL,
                                           export = FALSE, ...){

  f <- fringe(data)
  nms <- getClabels(f)

  xAxisTitle <- xAxisTitle %||% nms[1]
  yAxisTitle <- yAxisTitle %||% nms[2]
  title <-  title %||% ""
  d <- f$d %>% na.omit()



  mapC <- read_csv('inst/aux/dane-codes-departamento.csv')
  mapC <- mapC %>% select(code = `Hc-a2`, a = id, name)
  mapC$a <- as.character(mapC$a)
  mapC$a[mapC$a == '5'] <- '05'
  mapC$a[mapC$a == '8'] <- '08'
  df <- left_join(d, mapC)





  h <- hcmap("countries/co/co-all", data = df, value = "b",
             joinBy = c("hc-a2", "code"), name = names(data)[2],
             dataLabels = list(enabled = TRUE, format = '{point.name}'),
             borderColor = "black", borderWidth = 0.1) %>%
       hc_mapNavigation(enabled = TRUE)

  h <- h %>%
       hc_title(text = title) %>%
       hc_subtitle(text = subtitle) %>%

  if(export) h <- h %>% hc_exporting(enabled = TRUE)
  h
}

#' bubbles's colombia map
#' @name hgch_colombia_bubbles_world_GcdNum
#' @param x A data.frame
#' @return highcharts viz
#' @section ftype: Gcd-Num
#' @examples
#' hgch_map_bubbles_colombia_GcdNum(sampleData("Gcd-Num",nrow = 10))
#' @export hgch_map_bubbles_colombia_GcdNum
hgch_map_bubbles_colombia_GcdNum <- function(data, title = NULL,
                                             subtitle = NULL,
                                             xAxisTitle = NULL,
                                             yAxisTitle = NULL,
                                             theme = NULL,
                                             export = FALSE, ...){

  f <- fringe(data)
  nms <- getClabels(f)

  xAxisTitle <- xAxisTitle %||% nms[1]
  yAxisTitle <- yAxisTitle %||% nms[2]
  title <-  title %||% ""
  d <- f$d %>% na.omit()



  mapC <- read_csv('inst/aux/dane-codes-departamento.csv')
  mapC <- mapC %>% select(code = `Hc-a2`, a = id, lat = latitude, lon = longitude, everything())
  mapC$a <- as.character(mapC$a)
  mapC$a[mapC$a == '5'] <- '05'
  mapC$a[mapC$a == '8'] <- '08'
  df <- left_join(d, mapC)
  df <- plyr::rename(df, c('b' = 'z'))

  h <- hcmap("countries/co/co-all", showInLegend = FALSE) %>%
    hc_title(text = title) %>%
    hc_subtitle(text = subtitle) %>%
    hc_add_series(data = df, type = "mapbubble", name = names(data)[2], maxSize = '15%') %>%
    hc_mapNavigation(enabled = TRUE)

  if(export) h <- h %>% hc_exporting(enabled = TRUE)
  h
}
