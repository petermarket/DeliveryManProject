# Delivery Man A* Solver

This repository contains our R implementation of the A* algorithm to optimize routing in the Delivery Man game. The goal is to consistently achieve a score $\le 180$ in under 4 minutes.

## Directory Structure

To prevent merge conflicts and spaghetti code, this project strictly separates algorithmic logic from execution scripts. 

### 1. The `R/` Directory (Core Logic)
This directory is exclusively for reusable functions. **Do not put execution code here.**
*   `a_star.R`: Manages the core pathfinding, node expansion, and frontier lists.
*   `heuristics.R`: Contains the math for Manhattan distances, cost calculations, and traffic degradation probabilities.
*   `main_controller.R`: The wrapper function that integrates the heuristic and pathfinding logic to pass back to the game environment.

### 2. The `scripts/` Directory (Execution & Testing)
This directory is for running the code and benchmarking performance. 
*   `evaluate_model.R`: This is our primary testing script. It loads the environment, sources the functions from the `R/` directory, and runs `testDM()` to measure our implementation against the assignment's time and score constraints.

## How to Run the Project

Because the game environment is provided as a local archive rather than a CRAN package, you must install it directly from the `packages/` folder.

**1. Install the Package**
Open your terminal, ensure you are in the root directory of this repository, launch the R console, and run:
```R
install.packages("./packages/DeliveryMan_1.2.0.tar.gz", repos = NULL, type = "source")