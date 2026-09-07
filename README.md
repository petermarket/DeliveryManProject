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