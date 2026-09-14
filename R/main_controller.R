myFunction <- function(roads, car, packages) {
  target <- get_next_target(car, packages)
  
  move <- aStar(roads, car$x, car$y, target$x, target$y)
  
  car$nextMove <- move
  
  return(car)
}
