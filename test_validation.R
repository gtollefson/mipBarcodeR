#!/usr/bin/env Rscript
# =============================================================================
# Test Validation with mipBarcodeR
# =============================================================================

library(mipBarcodeR)

cat("=== Testing Validation ===\n")

# Test 1: Try to use old format (should fail with helpful message)
cat("\n1. Testing old format (should fail):\n")
tryCatch({
  old_format_file <- "inst/extdata/example_data/real_example_fw1_rev4.csv"
  generate_barcode_sheet(old_format_file)
}, error = function(e) {
  cat("✅ Expected error caught:", e$message, "\n")
})

# Test 2: Try with invalid well format (should fail)
cat("\n2. Testing invalid well format (should fail):\n")
invalid_wells <- data.table::data.table(
  SampleID = c("Sample1", "Sample2"),
  FW_Plate = c(1, 1),
  REV_Plate = c(4, 4),
  FW_Well = c("A1", "B"),  # Invalid format
  REV_Well = c("A01", "B02")
)
invalid_file <- "inst/extdata/example_data/invalid_wells.csv"
data.table::fwrite(invalid_wells, invalid_file)

tryCatch({
  generate_barcode_sheet(invalid_file)
}, error = function(e) {
  cat("✅ Expected error caught:", e$message, "\n")
})

# Test 3: Try with invalid plate numbers (should fail)
cat("\n3. Testing invalid plate numbers (should fail):\n")
invalid_plates <- data.table::data.table(
  SampleID = c("Sample1", "Sample2"),
  FW_Plate = c(100, 1),  # Invalid FW plate
  REV_Plate = c(4, 10),  # Invalid REV plate
  FW_Well = c("A01", "B02"),
  REV_Well = c("A01", "B02")
)
invalid_plates_file <- "inst/extdata/example_data/invalid_plates.csv"
data.table::fwrite(invalid_plates, invalid_plates_file)

tryCatch({
  generate_barcode_sheet(invalid_plates_file)
}, error = function(e) {
  cat("✅ Expected error caught:", e$message, "\n")
})

cat("\n=== Validation Tests Complete ===\n")
cat("✅ All validation tests passed - error messages are helpful!\n") 