# Test suite for get_next_target (R/strategy.R) and myFunction (R/main_controller.R)
#
# Focuses on the edge cases called out in the assignment brief:
#   - Deliveries and pickups can be placed on the same square, in which case
#     the car must stay still (move 5) for a turn before it can pick up.
#   - The car must always target its delivery destination while loaded.
#   - The car must always target the nearest available pickup by Manhattan
#     distance when empty.
#
# Run this file from the repository root:
# Rscript scripts/test_strategy.R

source("R/strategy.R")
source("R/a_star.R")
source("R/main_controller.R")


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


# packages matrix columns: pickup_x, pickup_y, delivery_x, delivery_y, status
# status: 0 = not picked up, 1 = picked up, 2 = delivered
make_packages <- function(rows) {
  matrix(unlist(rows), ncol = 5, byrow = TRUE)
}


expect_equal_value <- function(test_name, actual, expected) {
  if (length(actual) != length(expected) || !all(actual == expected)) {
    stop(
      paste0(
        "FAILED: ",
        test_name,
        "\nExpected: ",
        paste(expected, collapse = ", "),
        "\nActual: ",
        paste(actual, collapse = ", ")
      )
    )
  }

  cat("PASSED:", test_name, "\n")
}


# ------------------------------------------------------------
# 1. get_next_target: empty car picks nearest available package
# ------------------------------------------------------------

cat("\n1. get_next_target - nearest pickup selection\n")

car_empty <- list(x = 1, y = 1, load = 0)

packages_simple <- make_packages(list(
  c(5, 5, 9, 9, 0),
  c(2, 2, 8, 8, 0),
  c(9, 1, 1, 9, 2) # already delivered, must be ignored
))

target <- get_next_target(car_empty, packages_simple)

expect_equal_value(
  "Nearest available pickup chosen (ignores delivered package)",
  c(target$x, target$y),
  c(2, 2)
)


# ------------------------------------------------------------
# 2. get_next_target: loaded car targets its own delivery point
# ------------------------------------------------------------

cat("\n2. get_next_target - delivery targeting\n")

car_loaded <- list(x = 3, y = 3, load = 2)

packages_loaded <- make_packages(list(
  c(5, 5, 9, 9, 1), # not the one we're carrying
  c(2, 2, 7, 4, 1), # this is car$load = 2
  c(9, 1, 1, 9, 2)
))

target <- get_next_target(car_loaded, packages_loaded)

expect_equal_value(
  "Loaded car targets its delivery destination, not pickup location",
  c(target$x, target$y),
  c(7, 4)
)


# ------------------------------------------------------------
# 3. get_next_target: pickup and delivery co-located (dangers section)
# ------------------------------------------------------------

cat("\n3. get_next_target - co-located pickup and delivery\n")

# Car just delivered package 1 (now status 2) at (5,5), which is also the
# pickup location for package 2 (still status 0). The car must recognise
# the co-located pickup as its next target.
car_after_delivery <- list(x = 5, y = 5, load = 0)

packages_colocated <- make_packages(list(
  c(1, 1, 5, 5, 2), # delivered here, at (5,5)
  c(5, 5, 9, 9, 0)  # available for pickup, also at (5,5)
))

target <- get_next_target(car_after_delivery, packages_colocated)

expect_equal_value(
  "Co-located pickup is targeted at the car's current position",
  c(target$x, target$y),
  c(5, 5)
)


# ------------------------------------------------------------
# 4. myFunction: must stay still (move 5) to pick up a co-located package
# ------------------------------------------------------------

cat("\n4. myFunction - staying still to collect a co-located pickup\n")

roads <- create_test_roads()

car_state <- list(
  x = 5, y = 5, wait = 0, load = 0, nextMove = NA, mem = list()
)

result_car <- myFunction(roads, car_state, packages_colocated)

expect_equal_value(
  "myFunction returns move 5 (stay) when standing on the next pickup",
  result_car$nextMove,
  5
)


# ------------------------------------------------------------
# 5. myFunction: must stay still when starting on top of a pickup
# ------------------------------------------------------------

cat("\n5. myFunction - staying still on the starting pickup square\n")

packages_start_pickup <- make_packages(list(
  c(1, 1, 9, 9, 0),
  c(6, 6, 2, 2, 0)
))

car_start <- list(
  x = 1, y = 1, wait = 0, load = 0, nextMove = NA, mem = list()
)

result_car <- myFunction(roads, car_start, packages_start_pickup)

expect_equal_value(
  "myFunction returns move 5 (stay) when starting on a pickup square",
  result_car$nextMove,
  5
)


# ------------------------------------------------------------
# 6. myFunction: always returns a valid, in-bounds move code
# ------------------------------------------------------------

# Low-level fuzzing; Unit testing
# 30 random car/board states
# Asserts myFunction always returns a valid move code
# (i.e. 2/4/5/6/8)

cat("\n6. myFunction - valid move codes across many states\n")

valid_moves <- c(2, 4, 5, 6, 8)

# Fix the seed so this fuzz test is deterministic and reproducible
set.seed(7)

# Run 30 randomised trials rather than a handful of hand-picked cases
for (trial in seq_len(30)) {
  dimension <- 10
  # Random car position anywhere on the 10x10 board.
  x <- sample(seq_len(dimension), 1)
  y <- sample(seq_len(dimension), 1)
  # Randomly choose whether the car is empty (0) or carrying a package (1)
  # for this trial, so both branches of get_next_target are tested
  load_flag <- sample(c(0, 1), 1)

  if (load_flag == 0) {
    # Car is empty: build two available (status 0) packages at random
    # pickup/delivery coordinates so get_next_target has a real choice of
    # nearest pickup to make.
    packages_trial <- make_packages(list(
      c(sample(seq_len(dimension), 1), sample(seq_len(dimension), 1),
        sample(seq_len(dimension), 1), sample(seq_len(dimension), 1), 0),
      c(sample(seq_len(dimension), 1), sample(seq_len(dimension), 1),
        sample(seq_len(dimension), 1), sample(seq_len(dimension), 1), 0)
    ))
    load_value <- 0
  } else {
    # Car is carrying package 1 (status 1): build a single package row so
    # car$load = 1 correctly indexes into packages_trial and the car is
    # routed to its delivery destination.
    packages_trial <- make_packages(list(
      c(sample(seq_len(dimension), 1), sample(seq_len(dimension), 1),
        sample(seq_len(dimension), 1), sample(seq_len(dimension), 1), 1)
    ))
    load_value <- 1
  }

  # Assemble a car object in the same shape the game engine passes to carReady
  trial_car <- list(
    x = x, y = y, wait = 0, load = load_value, nextMove = NA, mem = list()
  )

  # Call the function under test exactly as the engine would each turn
  trial_result <- myFunction(
    create_test_roads(dimension = dimension),
    trial_car,
    packages_trial
  )

  # Fail fast with the offending state if an invalid move code slips
  # through, so the trial/coordinates causing it are easy to reproduce.
  if (!(trial_result$nextMove %in% valid_moves)) {
    stop(
      paste0(
        "FAILED: myFunction returned an invalid move ",
        trial_result$nextMove,
        " at (", x, ",", y, ")"
      )
    )
  }

  # Guard against walking off the edge of the board: e.g. moving right (6)
  # is only legal if the car isn't already at the rightmost column,
  # mirroring the boundary checks in processNextMove/getNeighbours.
  if (trial_result$nextMove == 6 && x >= dimension) {
    stop("FAILED: myFunction tried to move right off the board")
  }
  if (trial_result$nextMove == 4 && x <= 1) {
    stop("FAILED: myFunction tried to move left off the board")
  }
  if (trial_result$nextMove == 8 && y >= dimension) {
    stop("FAILED: myFunction tried to move up off the board")
  }
  if (trial_result$nextMove == 2 && y <= 1) {
    stop("FAILED: myFunction tried to move down off the board")
  }
}

cat("PASSED: 30 random states all produced valid, in-bounds moves\n")


# ------------------------------------------------------------
# 7. Full game integration: games must complete, including tricky seeds
# ------------------------------------------------------------

# runDeliveryMan across 15 seeds end-to-end

cat("\n7. Full game integration - runDeliveryMan across many seeds\n")

# Only attempt this if the real game package is installed
if (requireNamespace("DeliveryMan", quietly = TRUE)) {
  library(DeliveryMan)

  # The assignment states that the evaluation seed set deliberately includes
  # a game with pickups and deliveries on the same square. We run a range of
  # seeds so some are likely to trigger this scenario, and require every
  # game to finish (i.e. never return NA) well within the turn limit.

  integration_failures <- 0

  for (seed in 1:15) {
    # set.seed controls both the random board/package layout generated
    # inside runDeliveryMan and the random traffic evolution each turn, so
    # each iteration reproduces a distinct, deterministic game.
    set.seed(seed)
    # Play one full game with our real controller, exactly as testDM does
    # internally: no plotting/pausing (for speed) and no per-turn logging.
    result <- runDeliveryMan(
      myFunction,
      doPlot = FALSE,
      pause = 0,
      verbose = FALSE
    )

    # runDeliveryMan returns the turn count on success, or NA if the game
    # was not completed within the turn limit; that would mean
    # the car got stuck or looped, so we count and report it as a failure.
    if (is.na(result)) {
      integration_failures <- integration_failures + 1
      cat("FAILED: game with seed", seed, "did not complete\n")
    }
  }

  # Abort the whole test file with a non-zero exit if any game failed,
  # rather than silently continuing.
  if (integration_failures > 0) {
    stop(
      paste(integration_failures, "of 15 integration games failed to complete")
    )
  }

  cat("PASSED: 15 full games completed successfully\n")
} else {
  # If package isn't installed locally;
  # point the user at the script that installs it instead.
  cat(
    "SKIPPED: DeliveryMan package not installed;",
    "run scripts/evaluate_model.R first to install it.\n"
  )
}


# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

cat("\n================================================\n")
cat("YIPPIE! ALL STRATEGY / INTEGRATION TESTS PASSED\n")
cat("================================================\n")
