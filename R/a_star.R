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
        scroes <- sapply(frontier, function(node) node$f)
        current_index <- which.min(scroes)
        # remove current node
        current <- frontier[[current_index]]
        frontier <- frontier[-current_index]
        #temporary debugging
        print(current)
        #neighbors generation
    }
    return(5)
}