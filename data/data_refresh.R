# Pulling geometry data from National Interagency Fire Center 
# API ArcGIS
# Website https://data-nifc.opendata.arcgis.com

`%>%` <- magrittr::`%>%`

cmd <- "curl 'https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Public_Wildfire_Perimeters_View/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json'"
json <- raw <- poly <- NULL
json <- system(command = cmd, intern = TRUE)

if(is.null(json) || !is.character(json)){
  stop("Could not pull the json file")
}
raw <- jsonlite::fromJSON(json)
rm(json)

if(is.null(raw) || length(raw$features$geometry$rings) == 0){
  stop("Could not parse the json file")
}


poly <- lapply(seq_along(raw$features$geometry$rings), function(i){
  print(i)
  df <- raw$features$attributes[i,]
  df$polygon <- NA
  
  
  if(class(raw$features$geometry$rings[[i]]) == "list"){
    p <- lapply(raw$features$geometry$rings[[i]], function(x){
      df_temp <- df
      poly_temp <- x %>% as.data.frame() %>%
        stats::setNames(c("long", "lat")) %>%
        sp::Polygon()
      df_temp$polygon <- list(poly_temp)  
      return(df_temp)
      
    }) %>% dplyr::bind_rows()
  } else if(class(raw$features$geometry$rings[[i]]) == "array"){
    
    poly_temp <- apply(raw$features$geometry$rings[[i]], 3L, c) %>% 
      as.data.frame() %>%
      stats::setNames(c("long", "lat")) %>%
      sp::Polygon()
    p <- df
    p$polygon <- list(poly_temp) 
  }
  
  return(p)
}) %>%
  dplyr::bind_rows()
if(is.null(poly) || nrow(poly) == 0){
  stop("Could not create the data")
} else{
  save(poly, file = "./data/us_wildfire_poly.RData")
}

