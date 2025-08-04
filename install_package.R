#!/usr/bin/env Rscript
# =============================================================================
# mipBarcodeR - Installation Script
# =============================================================================
# This script installs the mipBarcodeR package from the local directory.
#
# Author: George Bailey
# Date: 2024
# =============================================================================

cat("Installing mipBarcodeR package...\n")

# Check if devtools is available
if (!require(devtools, quietly = TRUE)) {
  cat("Installing devtools...\n")
  install.packages("devtools")
}

# Install the package from the current directory
cat("Installing package from local directory...\n")
devtools::install(".", dependencies = TRUE)

cat("Installation complete!\n")
cat("You can now load the package with: library(mipBarcodeR)\n")
cat("Run the example script with: source('examples/run_example.R')\n") 