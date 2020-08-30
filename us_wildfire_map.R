m <- leaflet::leaflet() %>% 
  leaflet::setView(lng = -112, lat = 39, zoom = 5) %>%
  leaflet::addTiles()


m
for(i in 1:nrow(poly)){
  m <- m %>% leaflet::addPolygons(data = poly$polygon[i][[1]],
                                  color = "red",
                                  popup = paste("IncidentName:",poly$IncidentName[i]))
}


m
