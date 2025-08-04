# Test basic functionality of mipBarcodeR package

test_that("load_lookup_tables returns expected structure", {
  lookup_tables <- load_lookup_tables()
  
  expect_true(is.list(lookup_tables))
  expect_true("rev_barcode_seq_sheet" %in% names(lookup_tables))
  expect_true("fw_primer_number_lookup_sheet" %in% names(lookup_tables))
  expect_true("fw_primer_seq_lookup_sheet" %in% names(lookup_tables))
  
  expect_true(data.table::is.data.table(lookup_tables$rev_barcode_seq_sheet))
  expect_true(data.table::is.data.table(lookup_tables$fw_primer_number_lookup_sheet))
  expect_true(data.table::is.data.table(lookup_tables$fw_primer_seq_lookup_sheet))
})

test_that("validate_sample_sheet works with valid input", {
  valid_sheet <- data.table::data.table(
    SampleID = c("Sample1", "Sample2"),
    `FW-1` = c("A01", "A02"),
    `REV-4` = c("A01", "A02")
  )
  
  expect_true(validate_sample_sheet(valid_sheet, 1, 4))
})

test_that("validate_sample_sheet fails with missing columns", {
  invalid_sheet <- data.table::data.table(
    SampleID = c("Sample1", "Sample2"),
    SomeOtherColumn = c("A01", "A02")
  )
  
  expect_error(validate_sample_sheet(invalid_sheet, 1, 4))
})

test_that("format_well_positions works correctly", {
  input <- c("A1", "B2", "A01", "B02")
  expected <- c("A01", "B02", "A01", "B02")
  
  result <- format_well_positions(input)
  expect_equal(result, expected)
})

test_that("check_duplicate_barcode_pairs identifies duplicates", {
  # Create sheet with duplicates
  barcode_sheet <- data.table::data.table(
    sample_name = c("Sample1", "Sample2", "Sample3"),
    fw = c("ATCG", "GCTA", "ATCG"),
    rev = c("GCTA", "ATCG", "GCTA")
  )
  
  # Should identify duplicates
  duplicates <- check_duplicate_barcode_pairs(barcode_sheet)
  expect_true(nrow(duplicates) > 0)
})

test_that("check_duplicate_barcode_pairs handles no duplicates", {
  # Create sheet without duplicates
  barcode_sheet <- data.table::data.table(
    sample_name = c("Sample1", "Sample2", "Sample3"),
    fw = c("ATCG", "GCTA", "TAGC"),
    rev = c("GCTA", "ATCG", "CGAT")
  )
  
  # Should not find duplicates
  duplicates <- check_duplicate_barcode_pairs(barcode_sheet)
  expect_true(nrow(duplicates) == 0)
}) 