#!/usr/bin/env Rscript
# =============================================================================
# Test Real Example with mipBarcodeR
# =============================================================================

library(mipBarcodeR)

cat("=== Testing Real Example Data ===\n")

# Get path to the real example file
real_example_path <- "inst/extdata/example_data/real_example_combined_new_format.csv"

cat("Using real example file:", real_example_path, "\n")

# Generate barcode sheet with real data
barcode_sheet <- generate_barcode_sheet(
  sample_sheet_path = real_example_path
)

# Display results
cat("Generated barcode sheet with", nrow(barcode_sheet), "samples\n")
cat("First 5 rows:\n")
print(head(barcode_sheet, 5))

# Create output directory
output_dir <- "real_example_output"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Write barcode sheet to file
output_file <- write_barcode_sheet(
  barcode_sheet = barcode_sheet,
  output_path = output_dir,
  filename = "real_example",
  project_name = "k13_hap_june2025"
)

cat("Barcode sheet written to:", output_file, "\n")

# Show summary of barcode combinations used
cat("\n=== Summary ===\n")
cat("✅ Successfully processed real example data\n")
cat("✅ Generated barcode sequences for", nrow(barcode_sheet), "samples\n")
cat("✅ Combined FW-1/REV-4 and FW-5/REV-1 samples\n")
cat("✅ Output file created:", output_file, "\n") 