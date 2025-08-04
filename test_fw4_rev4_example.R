#!/usr/bin/env Rscript
# =============================================================================
# Test FW-4/REV-4 Example with mipBarcodeR
# =============================================================================

library(mipBarcodeR)

cat("=== Testing FW-4/REV-4 Example ===\n")

# Get path to the FW-4/REV-4 example file
example_path <- "inst/extdata/example_data/fw4_rev4_new_format.csv"

cat("Using example file:", example_path, "\n")

# Generate barcode sheet with FW-4/REV-4 data
barcode_sheet <- generate_barcode_sheet(
  sample_sheet_path = example_path
)

# Display results
cat("Generated barcode sheet with", nrow(barcode_sheet), "samples\n")
cat("First 5 rows:\n")
print(head(barcode_sheet, 5))

# Create output directory
output_dir <- "fw4_rev4_output"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Write barcode sheet to file
output_file <- write_barcode_sheet(
  barcode_sheet = barcode_sheet,
  output_path = output_dir,
  filename = "fw4_rev4_example",
  project_name = "k13_hap_072125"
)

cat("Barcode sheet written to:", output_file, "\n")

# Show summary
cat("\n=== Summary ===\n")
cat("✅ Successfully processed FW-4/REV-4 example data\n")
cat("✅ Generated barcode sequences for", nrow(barcode_sheet), "samples\n")
cat("✅ Output file created:", output_file, "\n") 