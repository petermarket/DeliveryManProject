# Acceptance gate for Assignment 1 deliverables.
#
# Passing requirements:
#   1. Mean score over n games <= 180
#   2. Total run time strictly under the assignment's time limit
#
# This script fails loudly (non-zero exit via stop()) if either requirement
# is not met, so it can be used for pre-submisison checking.
#
# Run this file from the repository root:
#   Rscript scripts/check_requirements.R
#   Rscript scripts/check_requirements.R --n=500 --time-limit=240 --max-score=180

source("R/strategy.R")
source("R/a_star.R")
source("R/main_controller.R")

if (!requireNamespace("DeliveryMan", quietly = TRUE)) {
  lib_path <- Sys.getenv("R_LIBS_USER")
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


# ------------------------------------------------------------
# Parse optional command line arguments
# ------------------------------------------------------------

parse_arg <- function(flag, default) {
  args <- commandArgs(trailingOnly = TRUE)
  match <- grep(paste0("^--", flag, "="), args, value = TRUE)
  if (length(match) == 0) {
    return(default)
  }
  as.numeric(sub(paste0("^--", flag, "="), "", match[1]))
}

n_games <- parse_arg("n", 500)
time_limit_seconds <- parse_arg("time-limit", 240)
max_allowed_score <- parse_arg("max-score", 180)


# ------------------------------------------------------------
# Run the evaluation
# ------------------------------------------------------------

cat("Checking Assignment 1 deliverables:\n")
cat("  Required: mean score <=", max_allowed_score, "\n")
cat("  Required: total time <", time_limit_seconds, "seconds\n")
cat("  Games played:", n_games, "\n\n")

start_time <- Sys.time()

scores <- testDM(
  myFunction,
  verbose = 1,
  returnVec = TRUE,
  n = n_games,
  timeLimit = time_limit_seconds
)

end_time <- Sys.time()
elapsed_seconds <- as.numeric(
  difftime(end_time, start_time, units = "secs")
)


# ------------------------------------------------------------
# Evaluate against the passing requirements
# ------------------------------------------------------------

failures <- c()

if (any(is.na(scores))) {
  failures <- c(
    failures,
    paste0(
      sum(is.na(scores)),
      " of ",
      n_games,
      " games failed to complete (returned NA), ",
      "or the time limit was breached mid-run."
    )
  )
}

mean_score <- mean(scores, na.rm = TRUE)

if (is.na(mean_score) || mean_score > max_allowed_score) {
  failures <- c(
    failures,
    paste0(
      "Mean score ",
      round(mean_score, 3),
      " exceeds the required maximum of ",
      max_allowed_score,
      "."
    )
  )
}

if (elapsed_seconds >= time_limit_seconds) {
  failures <- c(
    failures,
    paste0(
      "Elapsed time ",
      round(elapsed_seconds, 3),
      "s meets or exceeds the ",
      time_limit_seconds,
      "s limit."
    )
  )
}

cat("\n========================================\n")
cat("Mean score:", round(mean_score, 3), "\n")
cat("Std Dev:", round(sd(scores, na.rm = TRUE), 3), "\n")
cat("Elapsed time:", round(elapsed_seconds, 3), "seconds\n")
cat("========================================\n")

if (length(failures) > 0) {
  cat("\nFAILED requirements:\n")
  for (failure in failures) {
    cat(" -", failure, "\n")
  }
  stop("Assignment deliverables were not met. See failures above.")
}

cat("\nPASSED: All Assignment 1 deliverables were met.\n")
