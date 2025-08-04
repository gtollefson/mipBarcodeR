#!/usr/bin/env Rscript
# Demo script for mipBarcodeR package
# Shows how to generate barcode sheets from sample data

library(mipBarcodeR)

cat("=== mipBarcodeR Demo ===\n\n")

# Load example sample sheet
example_file <- system.file("extdata", "example_data", "example_sample_sheet_new_format.csv", 
                           package = "mipBarcodeR")

cat("Using example file:", example_file, "\n\n")

# Generate barcode sheet
cat("Generating barcode sheet...\n")
barcode_sheet <- generate_barcode_sheet(example_file)

cat("Generated barcode sheet with", nrow(barcode_sheet), "samples\n")
cat("First 3 rows:\n")
print(head(barcode_sheet, 3))

# Write to file
output_dir <- "demo_output"
if (!dir.exists(output_dir)) dir.create(output_dir)

output_file <- write_barcode_sheet(
  barcode_sheet = barcode_sheet,
  output_path = output_dir,
  filename = "demo",
  project_name = "mipBarcodeR_demo"
)

cat("\nBarcode sheet written to:", output_file, "\n")
cat("Output directory:", output_dir, "\n\n")

cat("=== Demo Complete ===\n")
cat("Check the", output_dir, "folder for your generated barcode sheet!\n")
