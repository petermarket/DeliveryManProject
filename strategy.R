# get_next_target.R
# This function decides which package the car should pick up or deliver next.

get_next_target <- function(car, packages) {
  #  Head straight to its delivery destination if carrying package
  if (car$load > 0) {
    return(list(x = packages[car$load, 3], y = packages[car$load, 4]))
  }
  
  # Else, find closest available package using Manhattan distance
  available <- which(packages[, 5] == 0)
  
  distances <- sapply(available, function(i) {
    abs(car$x - packages[i, 1]) + abs(car$y - packages[i, 2])
  })
  
  closest_pkg <- available[which.min(distances)]
  
  return(list(x = packages[closest_pkg, 1], y = packages[closest_pkg, 2]))
}