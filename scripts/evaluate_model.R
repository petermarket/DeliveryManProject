source("R/strategy.R")
source("R/a_star.R")
source("R/main_controller.R")

if (!requireNamespace("DeliveryMan", quietly = TRUE)) {
  dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE, showWarnings = FALSE)
  .libPaths(Sys.getenv("R_LIBS_USER"))
  install.packages("packages/DeliveryMan_1.2.0.tar.gz", repos = NULL, type = "source", lib = Sys.getenv("R_LIBS_USER"))
}

library(DeliveryMan)

cat("Running 500 games to evaluate the model...\n")
cat("Target: Mean score <= 180, Time < 4 minutes (240s)\n\n")

testDM(myFunction, verbose = 1, n = 500)
