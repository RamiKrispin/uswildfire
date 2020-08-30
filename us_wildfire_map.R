load("./data/wildfire_poly.RData")
m <- leaflet::leaflet() %>% 
  leaflet::setView(lng = -112, lat = 39, zoom = 6) %>%
  leaflet::addTiles()



for(i in 1:nrow(poly)){
  m <- m %>% leaflet::addPolygons(data = poly$polygon[i][[1]],
                                  color = "red",
                                  popup = paste("IncidentName:",poly$IncidentName[i], "<br>",
                                                "Number of Acres:", round(poly$GISAcres[i]), "<br>",
                                                "Object ID:", poly$OBJECTID[i], "<br>",
                                                "Map Method:", poly$MapMethod[i], "<br>"))
}


save(m, file = "./data/us_wildfire_map.RData")
