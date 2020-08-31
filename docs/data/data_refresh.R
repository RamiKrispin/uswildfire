# Pulling geometry data from National Interagency Fire Center 
# API ArcGIS
# Website https://data-nifc.opendata.arcgis.com

`%>%` <- magrittr::`%>%`

create_poly <- function(obj){
  
  
  poly <- lapply(seq_along(obj$features$geometry$rings), function(i){
    print(i)
    df <- obj$features$attributes[i,]
    df$polygon <- NA
    
    
    if(class(obj$features$geometry$rings[[i]]) == "list"){
      p <- lapply(obj$features$geometry$rings[[i]], function(x){
        df_temp <- df
        poly_temp <- x %>% as.data.frame() %>%
          stats::setNames(c("long", "lat")) %>%
          sp::Polygon()
        df_temp$polygon <- list(poly_temp)  
        return(df_temp)
        
      }) %>% dplyr::bind_rows()
    } else if(class(obj$features$geometry$rings[[i]]) == "array"){
      
      poly_temp <- apply(obj$features$geometry$rings[[i]], 3L, c) %>% 
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
  } 
  
  return(poly)
  
}




# Inital pull
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

id <- raw$features$attributes$OBJECTID %>% max

poly1 <- create_poly(obj = raw)

if(nrow(raw$features$attributes) == 1000){
  cmd2 <- paste("curl 'https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Public_Wildfire_Perimeters_View/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json&resultOffset=1000&resultRecordCount=1000&definitionExpression=ObjectID>",
                id,"'", sep = "")
  json2 <- system(command = cmd2, intern = TRUE)
  
  raw2 <- jsonlite::fromJSON(json2)
  
  poly2 <- create_poly(obj = raw2)
  
  poly <- dplyr::bind_rows(poly1, poly2)
} else {
  poly <- poly1
}


if(is.null(poly) || nrow(poly) == 0){
  stop("Could not create the data")
} else{
  
  run_time <- Sys.time()
  attributes(run_time)$tzone <- "America/Los_Angeles" 
  save(poly, run_time, file = "./data/us_wildfire_poly.RData")
}

