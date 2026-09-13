aStar <- function(roads, start_x, start_y, goal_x, goal_y) {
    # when car is already at the goal
    if (start_x == goal_x && start_y == goal_y) {
        return(5)
    }
    # Manhattan distance heuristic
    start_h <- abs(start_x - goal_x) + abs(start_y - goal_y)
    # start node
    start_node <- list(x = start_x, y = start_y, g = 0, h = start_h, f = start_h, first_move = 5) # nolint
    frontier <- list(start_node)
    nodes <- list(start_node)
    
    while (length(frontier) > 0) {
        scores <- sapply(frontier, function(node) node$f)
        current_index <- which.min(scores)
        # remove current node
        current <- frontier[[current_index]]
        frontier <- frontier[-current_index]

        if(current$x == goal_x && current$y == goal_y){
            return(current$first_move)
        }
        #neighbors generation
        neighbours <- getNeighbours(current, roads)
        for (neighbour in neighbours){
            new_g <- current$g + neighbour$cost #this neighbor's actual cost
            new_h <- abs(neighbour$x - goal_x) + abs(neighbour$y - goal_y)
            new_f <- new_g + new_h

            if(current$x == start_x && current$y == start_y){
                new_first_move <- neighbour$move
            } else {
                new_first_move <- current$first_move
            }

            new_node <- list( x = neighbour$x, y = neighbour$y, g = new_g, h = new_h, f = new_f, first_move = new_first_move ) # nolint
            same_position <- sapply(nodes, function(node) node$x == new_node$x && node$y == new_node$y) # nolint
            existing_index <- which(same_position)
            if (length(existing_index) == 0){
                nodes[[length(nodes) + 1]] <- new_node
                frontier[[length(frontier) + 1]] <- new_node
            }else{
                existing_node <- nodes[[existing_index]]
                if (new_node$g < existing_node$g){
                    nodes[[existing_index]] <- new_node

                    frontier_same_position <- sapply(frontier, function(node) node$x == new_node$x && node$y == new_node$y) # nolint
                    frontier_same_index <- which(frontier_same_position)
                    if (length(frontier_same_index) > 0){
                        frontier[[frontier_same_index]] <- new_node
                    } else {
                        frontier[[length(frontier) + 1]] <- new_node
                    }
                }
                
            }
        }
    }
    stop("A* failed to find a path to the goal.")
}
getNeighbours <- function(node, roads) {
  x <- node$x
  y <- node$y
  dimension <- nrow(roads$vroads)
  neighbours <- list()

  if (x < dimension) {
    neighbours[[length(neighbours) + 1]] <- list(
      x = x + 1,
      y = y,
      move = 6,
      cost = roads$hroads[x, y]
    )
  }
  if (x > 1) {
    neighbours[[length(neighbours) + 1]] <- list(
      x = x - 1,
      y = y,
      move = 4,
      cost = roads$hroads[x - 1, y]
    )
  }
  if (y < dimension) {
    neighbours[[length(neighbours) + 1]] <- list(
      x = x,
      y = y + 1,
      move = 8,
      cost = roads$vroads[x, y]
    )
  }
  if (y > 1) {
    neighbours[[length(neighbours) + 1]] <- list(
      x = x,
      y = y - 1,
      move = 2,
      cost = roads$vroads[x, y - 1]
    )
  }
  return(neighbours)
}