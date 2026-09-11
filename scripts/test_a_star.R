# Load the A* implementation
source("R/a_star.R")

# Create a 10 x 10 map where every road has cost 1
# roads <- list(
#   hroads = matrix(1, nrow = 9, ncol = 10),
#   vroads = matrix(1, nrow = 10, ncol = 9)
# )

# # Test the first move from (1, 1) to (4, 3)
# result <- aStar(
#   roads,
#   start_x = 1,
#   start_y = 1,
#   goal_x = 4,
#   goal_y = 3
# )
# print(result)

# Test 1: start and goal are the same
result_same <- aStar(
  roads,
  start_x = 1,
  start_y = 1,
  goal_x = 1,
  goal_y = 1
)

print(result_same)
# Expected: 5

# Test 2: different start and goal
result_different <- aStar(
  roads,
  start_x = 1,
  start_y = 1,
  goal_x = 4,
  goal_y = 3
)

print(result_different)