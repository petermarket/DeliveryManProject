source("R/strategy.R")
source("R/a_star.R")
source("R/main_controller.R")

if (!requireNamespace("DeliveryMan", quietly = TRUE)) {
  lib_path <- Sys.getenv("R_LIBS_USER")
  # Possible that R_LIBS_USER is empty (fresh machine)
  # This handles that case so installation doesn't break
  if (identical(lib_path, "")) {
    lib_path <- file.path(Sys.getenv("HOME"), "R", "library")
  }
  dir.create(lib_path, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(lib_path, .libPaths()))
  install.packages(
    "packages/DeliveryMan_1.2.0.tar.gz",
    repos = NULL,
    type = "source",
    lib = lib_path
  )
}

library(DeliveryMan)

cat("Running 500 games to evaluate the model...\n")
cat("Target: Mean score <= 180, Time < 4 minutes (240s)\n\n")

testDM(myFunction, verbose = 1, n = 500)

