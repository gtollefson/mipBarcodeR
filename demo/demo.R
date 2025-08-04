#!/usr/bin/env Rscript
# Simple demo showing how to use mipBarcodeR
# This is exactly how users will run the tool

library(mipBarcodeR)
library(data.table)

# Step 1: Generate barcode sheet
barcode_sheet <- generate_barcode_sheet("demo/example_input.csv")

# Step 2: Write to file
write_barcode_sheet(barcode_sheet, "demo/", "my_project", "demo_run")

cat("Done! Check demo/my_project_demo_run_barcode_sample_sheet.tsv\n")
