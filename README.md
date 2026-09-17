# Delivery Man A* Solver

This repository contains our R implementation of the A* algorithm to optimize routing in the Delivery Man game. The goal is to consistently achieve a score $\le 180$ in under 4 minutes.

## Directory Structure

To prevent merge conflicts and spaghetti code, this project strictly separates algorithmic logic from execution scripts. 

### 1. The `R/` Directory (Core Logic)
This directory is exclusively for reusable functions. **Do not put execution code here.**

### 2. The `scripts/` Directory (Execution & Testing)
This directory is for running the code and benchmarking performance. 

## How to Run the Project

Because the game environment is provided as a local archive rather than a CRAN package, you must install it directly from the `packages/` folder.

**1. Install the Package**
Open your terminal, ensure you are in the root directory of this repository, launch the R console, and run:
```R
install.packages("./packages/DeliveryMan_1.2.0.tar.gz", repos = NULL, type = "source")
```

Alternatively, running any script under `scripts/` (e.g. `Rscript scripts/evaluate_model.R`) will install the package automatically if it is not already available.

## Testing

Run these from the repository root:

| Script | Purpose |
| --- | --- |
| `Rscript scripts/test_a_star.R` | Unit tests for `aStar`/`getNeighbours`: movement, boundaries, weighted roads, and randomised optimality checks against a reference Dijkstra implementation. |
| `Rscript scripts/test_strategy.R` | Unit and integration tests for `get_next_target`/`myFunction`: nearest-pickup selection, delivery targeting, the co-located pickup/delivery edge case ("Dangers" in the assignment brief), valid/in-bounds move codes, and full `runDeliveryMan` games across multiple seeds. |
| `Rscript scripts/check_requirements.R` | Acceptance gate for the assignment's passing requirements. Runs `testDM` and fails (non-zero exit) unless the mean score is `<= 180` **and** the total run time is under the time limit. Accepts optional `--n=`, `--time-limit=`, and `--max-score=` flags, e.g. `Rscript scripts/check_requirements.R --n=500 --time-limit=240 --max-score=180`. |
| `Rscript scripts/evaluate_model.R` | Runs the full 500-game `testDM` benchmark with verbose output, for manual inspection of mean/sd/time. |

Before submitting, run all three test/check scripts and confirm they pass:
```bash
Rscript scripts/test_a_star.R
Rscript scripts/test_strategy.R
Rscript scripts/check_requirements.R
```