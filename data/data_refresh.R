# Pulling geometry data from National Interagency Fire Center 
# API ArcGIS
`%>%` <- magrittr::`%>%`
cmd <- "curl 'https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Public_Wildfire_Perimeters_View/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json'"

json <- system(command = cmd, intern = TRUE)
rm(json)
raw <- jsonlite::fromJSON(json)

length(raw$features$geometry$rings)


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

save(poly, file = "./data/wildfire_poly.RData")











