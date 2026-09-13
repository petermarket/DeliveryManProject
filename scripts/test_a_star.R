# Test suite for the A* implementation
#
# Run this file from the repository root:
# Rscript scripts/test_a_star.R

source("R/a_star.R")


# ------------------------------------------------------------
# Test helpers
# ------------------------------------------------------------

create_test_roads <- function(dimension = 10, cost = 1) {
  return(list(
    hroads = matrix(
      cost,
      nrow = dimension - 1,
      ncol = dimension
    ),
    vroads = matrix(
      cost,
      nrow = dimension,
      ncol = dimension - 1
    )
  ))
}


expect_move <- function(test_name, actual, expected) {
  valid_result <- (
    length(actual) == 1 &&
    !is.na(actual) &&
    actual %in% expected
  )

  if (!valid_result) {
    stop(
      paste0(
        "FAILED: ",
        test_name,
        "\nExpected: ",
        paste(expected, collapse = " or "),
        "\nActual: ",
        paste(actual, collapse = ", ")
      )
    )
  }

  cat(
    "PASSED:",
    test_name,
    "- returned",
    actual,
    "\n"
  )
}


expect_value <- function(test_name, actual, expected) {
  if (length(actual) != 1 || actual != expected) {
    stop(
      paste0(
        "FAILED: ",
        test_name,
        "\nExpected: ",
        expected,
        "\nActual: ",
        actual
      )
    )
  }

  cat(
    "PASSED:",
    test_name,
    "- value",
    actual,
    "\n"
  )
}


# ------------------------------------------------------------
# 1. Basic movement tests
# ------------------------------------------------------------

cat("\n1. Basic movement tests\n")

roads <- create_test_roads()

expect_move(
  "Start equals goal",
  aStar(roads, 1, 1, 1, 1),
  5
)

expect_move(
  "Move right",
  aStar(roads, 1, 1, 4, 1),
  6
)

expect_move(
  "Move left",
  aStar(roads, 5, 5, 2, 5),
  4
)

expect_move(
  "Move up",
  aStar(roads, 1, 1, 1, 4),
  8
)

expect_move(
  "Move down",
  aStar(roads, 5, 5, 5, 2),
  2
)


# ------------------------------------------------------------
# 2. Boundary tests
# ------------------------------------------------------------

cat("\n2. Boundary tests\n")

roads <- create_test_roads()

expect_move(
  "Bottom-left corner moving right",
  aStar(roads, 1, 1, 2, 1),
  6
)

expect_move(
  "Bottom-left corner moving up",
  aStar(roads, 1, 1, 1, 2),
  8
)

expect_move(
  "Top-right corner moving left",
  aStar(roads, 10, 10, 9, 10),
  4
)

expect_move(
  "Top-right corner moving down",
  aStar(roads, 10, 10, 10, 9),
  2
)


# ------------------------------------------------------------
# 3. Equal-cost path test
# ------------------------------------------------------------

cat("\n3. Equal-cost path test\n")

roads <- create_test_roads()

# Both right and up can begin an optimal route.
expect_move(
  "Multiple optimal paths",
  aStar(roads, 1, 1, 4, 3),
  c(6, 8)
)


# ------------------------------------------------------------
# 4. Weighted road tests
# ------------------------------------------------------------

cat("\n4. Weighted road tests\n")

# The direct right road costs 10.
# Going up, right, down costs 3.
roads <- create_test_roads()
roads$hroads[1, 1] <- 10

expect_move(
  "Avoid expensive horizontal road",
  aStar(roads, 1, 1, 2, 1),
  8
)


# The direct upward road costs 10.
# Going right, up, left costs 3.
roads <- create_test_roads()
roads$vroads[1, 1] <- 10

expect_move(
  "Avoid expensive vertical road",
  aStar(roads, 1, 1, 1, 2),
  6
)


# A direct route should still be used when it is cheapest.
roads <- create_test_roads()
roads$hroads[1, 2] <- 10

expect_move(
  "Use cheap direct horizontal road",
  aStar(roads, 1, 1, 2, 1),
  6
)


# ------------------------------------------------------------
# 5. Neighbour generation tests
# ------------------------------------------------------------

cat("\n5. Neighbour generation tests\n")

roads <- create_test_roads()

bottom_left_neighbours <- getNeighbours(
  list(x = 1, y = 1),
  roads
)

expect_value(
  "Bottom-left corner has two neighbours",
  length(bottom_left_neighbours),
  2
)

bottom_left_moves <- sapply(
  bottom_left_neighbours,
  function(node) node$move
)

if (!setequal(bottom_left_moves, c(6, 8))) {
  stop("FAILED: bottom-left neighbour directions are incorrect")
}

cat("PASSED: bottom-left neighbour directions\n")


top_right_neighbours <- getNeighbours(
  list(x = 10, y = 10),
  roads
)

expect_value(
  "Top-right corner has two neighbours",
  length(top_right_neighbours),
  2
)

top_right_moves <- sapply(
  top_right_neighbours,
  function(node) node$move
)

if (!setequal(top_right_moves, c(4, 2))) {
  stop("FAILED: top-right neighbour directions are incorrect")
}

cat("PASSED: top-right neighbour directions\n")


middle_neighbours <- getNeighbours(
  list(x = 5, y = 5),
  roads
)

expect_value(
  "Middle position has four neighbours",
  length(middle_neighbours),
  4
)

middle_moves <- sapply(
  middle_neighbours,
  function(node) node$move
)

if (!setequal(middle_moves, c(2, 4, 6, 8))) {
  stop("FAILED: middle neighbour directions are incorrect")
}

cat("PASSED: middle neighbour directions\n")


# ------------------------------------------------------------
# 6. Road-cost indexing tests
# ------------------------------------------------------------

cat("\n6. Road-cost indexing tests\n")

roads <- create_test_roads()

roads$hroads[5, 5] <- 10
roads$hroads[4, 5] <- 20
roads$vroads[5, 5] <- 30
roads$vroads[5, 4] <- 40

cost_neighbours <- getNeighbours(
  list(x = 5, y = 5),
  roads
)

moves <- sapply(
  cost_neighbours,
  function(node) node$move
)

costs <- sapply(
  cost_neighbours,
  function(node) node$cost
)

expect_value(
  "Right road cost",
  costs[which(moves == 6)],
  10
)

expect_value(
  "Left road cost",
  costs[which(moves == 4)],
  20
)

expect_value(
  "Up road cost",
  costs[which(moves == 8)],
  30
)

expect_value(
  "Down road cost",
  costs[which(moves == 2)],
  40
)


# ------------------------------------------------------------
# 7. Reference shortest-path implementation
# ------------------------------------------------------------

# This is a small Dijkstra implementation used only for testing.
# It calculates the true minimum cost between two positions.

reference_shortest_cost <- function(
  roads,
  start_x,
  start_y,
  goal_x,
  goal_y
) {
  dimension <- nrow(roads$vroads)

  distances <- matrix(
    Inf,
    nrow = dimension,
    ncol = dimension
  )

  visited <- matrix(
    FALSE,
    nrow = dimension,
    ncol = dimension
  )

  distances[start_x, start_y] <- 0

  for (iteration in seq_len(dimension * dimension)) {
    candidates <- which(
      !visited & is.finite(distances),
      arr.ind = TRUE
    )

    if (nrow(candidates) == 0) {
      break
    }

    candidate_costs <- distances[candidates]
    best_candidate <- which.min(candidate_costs)

    x <- candidates[best_candidate, 1]
    y <- candidates[best_candidate, 2]

    if (x == goal_x && y == goal_y) {
      return(distances[x, y])
    }

    visited[x, y] <- TRUE
    current_cost <- distances[x, y]

    if (x < dimension) {
      distances[x + 1, y] <- min(
        distances[x + 1, y],
        current_cost + roads$hroads[x, y]
      )
    }

    if (x > 1) {
      distances[x - 1, y] <- min(
        distances[x - 1, y],
        current_cost + roads$hroads[x - 1, y]
      )
    }

    if (y < dimension) {
      distances[x, y + 1] <- min(
        distances[x, y + 1],
        current_cost + roads$vroads[x, y]
      )
    }

    if (y > 1) {
      distances[x, y - 1] <- min(
        distances[x, y - 1],
        current_cost + roads$vroads[x, y - 1]
      )
    }
  }

  stop("Reference algorithm could not find a path")
}


# Follow the moves returned by A* and calculate their total cost.

astar_route_cost <- function(
  roads,
  start_x,
  start_y,
  goal_x,
  goal_y
) {
  dimension <- nrow(roads$vroads)

  x <- start_x
  y <- start_y
  total_cost <- 0

  maximum_steps <- dimension * dimension * 4

  for (step in seq_len(maximum_steps)) {
    if (x == goal_x && y == goal_y) {
      return(total_cost)
    }

    move <- aStar(
      roads,
      x,
      y,
      goal_x,
      goal_y
    )

    if (!(move %in% c(2, 4, 6, 8))) {
      stop(
        paste(
          "A* returned an invalid move:",
          move
        )
      )
    }

    if (move == 6) {
      if (x >= dimension) {
        stop("A* attempted to move right outside the map")
      }

      total_cost <- total_cost + roads$hroads[x, y]
      x <- x + 1

    } else if (move == 4) {
      if (x <= 1) {
        stop("A* attempted to move left outside the map")
      }

      total_cost <- total_cost + roads$hroads[x - 1, y]
      x <- x - 1

    } else if (move == 8) {
      if (y >= dimension) {
        stop("A* attempted to move up outside the map")
      }

      total_cost <- total_cost + roads$vroads[x, y]
      y <- y + 1

    } else if (move == 2) {
      if (y <= 1) {
        stop("A* attempted to move down outside the map")
      }

      total_cost <- total_cost + roads$vroads[x, y - 1]
      y <- y - 1
    }
  }

  stop("A* did not reach the goal within the step limit")
}


# ------------------------------------------------------------
# 8. Random optimality tests
# ------------------------------------------------------------

cat("\n7. Random optimality tests\n")

set.seed(21)

number_of_random_tests <- 50
random_failures <- 0

random_test_start <- Sys.time()

for (test_number in seq_len(number_of_random_tests)) {
  dimension <- 10

  random_roads <- list(
    hroads = matrix(
      sample(1:5, (dimension - 1) * dimension, replace = TRUE),
      nrow = dimension - 1,
      ncol = dimension
    ),
    vroads = matrix(
      sample(1:5, dimension * (dimension - 1), replace = TRUE),
      nrow = dimension,
      ncol = dimension - 1
    )
  )

  start_x <- sample(seq_len(dimension), 1)
  start_y <- sample(seq_len(dimension), 1)
  goal_x <- sample(seq_len(dimension), 1)
  goal_y <- sample(seq_len(dimension), 1)

  expected_cost <- reference_shortest_cost(
    random_roads,
    start_x,
    start_y,
    goal_x,
    goal_y
  )

  actual_cost <- astar_route_cost(
    random_roads,
    start_x,
    start_y,
    goal_x,
    goal_y
  )

  if (actual_cost != expected_cost) {
    random_failures <- random_failures + 1

    cat(
      "FAILED random test",
      test_number,
      "- start:",
      paste0("(", start_x, ",", start_y, ")"),
      "goal:",
      paste0("(", goal_x, ",", goal_y, ")"),
      "expected cost:",
      expected_cost,
      "actual cost:",
      actual_cost,
      "\n"
    )
  }
}

random_test_end <- Sys.time()

if (random_failures > 0) {
  stop(
    paste(
      random_failures,
      "random optimality tests failed"
    )
  )
}

cat(
  "PASSED:",
  number_of_random_tests,
  "random optimality tests\n"
)

cat(
  "Random test time:",
  round(
    as.numeric(
      difftime(
        random_test_end,
        random_test_start,
        units = "secs"
      )
    ),
    3
  ),
  "seconds\n"
)


# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

cat("\n========================================\n")
cat("ALL A* TESTS PASSED\n")
cat("========================================\n")