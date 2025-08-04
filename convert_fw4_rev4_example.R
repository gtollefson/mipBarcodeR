#!/usr/bin/env Rscript
# =============================================================================
# Convert FW-4/REV-4 Example to New Format
# =============================================================================

library(data.table)

# Read the original file
original_file <- "/Users/george/Bailey_lab/k13_hap/nanopore_sequencing/barcode_sheets/barcode_sheet_prep/sample_sheet_fw4_rev4_k13hap_072125_nanopore_seq.csv"
fw4_rev4 <- fread(original_file)

cat("Original file:", original_file, "\n")
cat("Number of samples:", nrow(fw4_rev4), "\n")
cat("Columns:", paste(names(fw4_rev4), collapse = ", "), "\n")

# Convert to new format
fw4_rev4_new <- fw4_rev4[, .(
  SampleID = SampleID,
  FW_Plate = 4,
  REV_Plate = 4,
  FW_Well = `FW-4`,
  REV_Well = `REV-4`
)]

# Write the converted file
output_file <- "inst/extdata/example_data/fw4_rev4_new_format.csv"
fwrite(fw4_rev4_new, output_file)

cat("Converted file:", output_file, "\n")
cat("Number of samples:", nrow(fw4_rev4_new), "\n")
cat("New format columns:", paste(names(fw4_rev4_new), collapse = ", "), "\n") 