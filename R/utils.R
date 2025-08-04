#' Load Built-in Lookup Tables
#'
#' @description
#' Loads the built-in lookup tables for REV barcode sequences, FW primer number lookup,
#' and FW primer sequence lookup. These tables are included in the package.
#'
#' @param rev_number Numeric. The REV plate number (1-4) to load the appropriate REV sheet.
#' @return A list containing the loaded lookup tables
#' @keywords internal
#' @noRd
load_lookup_tables <- function(rev_number = 4) {
  # Load the appropriate REV barcode sequence sheet based on rev_number
  rev_file <- paste0("REV-", rev_number, "_barcode_stock_seq_sheet.csv")
  rev_barcode_seq_sheet <- data.table::fread(
    system.file(paste0("extdata/lookup_tables/", rev_file), 
                package = "mipBarcodeR")
  )
  
  fw_primer_number_lookup_sheet <- data.table::fread(
    system.file("extdata/lookup_tables/shift_plate_fw_lookup_table.csv", 
                package = "mipBarcodeR")
  )
  
  fw_primer_seq_lookup_sheet <- data.table::fread(
    system.file("extdata/lookup_tables/hybrid_dual_fw_001-096_seq_sheet.csv", 
                package = "mipBarcodeR")
  )
  
  return(list(
    rev_barcode_seq_sheet = rev_barcode_seq_sheet,
    fw_primer_number_lookup_sheet = fw_primer_number_lookup_sheet,
    fw_primer_seq_lookup_sheet = fw_primer_seq_lookup_sheet
  ))
}

#' Validate Sample Sheet Structure
#'
#' @description
#' Validates that the provided sample sheet has the required columns and structure.
#' Requires SampleID, FW_Plate, REV_Plate, FW_Well, REV_Well columns.
#'
#' @param sample_sheet A data.table containing the sample sheet
#'
#' @return TRUE if valid, throws error if invalid
#' @keywords internal
#' @noRd
validate_sample_sheet <- function(sample_sheet) {
  required_cols <- c("SampleID", "FW_Plate", "REV_Plate", "FW_Well", "REV_Well")
  
  missing_cols <- setdiff(required_cols, names(sample_sheet))
  if (length(missing_cols) > 0) {
    stop("Missing required columns in sample sheet: ", 
         paste(missing_cols, collapse = ", "), "\n\n",
         "Expected format:\n",
         "SampleID,FW_Plate,REV_Plate,FW_Well,REV_Well\n",
         "Sample_001,1,4,A01,A01\n",
         "Sample_002,5,1,C01,C01")
  }
  
  # Check for empty SampleID
  if (any(is.na(sample_sheet$SampleID) | sample_sheet$SampleID == "")) {
    warning("Some SampleID values are empty or NA")
  }
  
  # Validate FW_Plate and REV_Plate values
  if (!all(sample_sheet$FW_Plate %in% 1:96)) {
    stop("FW_Plate values must be between 1 and 96")
  }
  
  if (!all(sample_sheet$REV_Plate %in% 1:4)) {
    stop("REV_Plate values must be between 1 and 4")
  }
  
  # Validate well format (A01, B02, etc.)
  well_pattern <- "^[A-Z][0-9]{1,2}$"
  if (!all(grepl(well_pattern, sample_sheet$FW_Well))) {
    stop("FW_Well values must be in format A01, B02, etc.")
  }
  
  if (!all(grepl(well_pattern, sample_sheet$REV_Well))) {
    stop("REV_Well values must be in format A01, B02, etc.")
  }
  
  return(TRUE)
}

#' Format Well Positions
#'
#' @description
#' Formats well positions to ensure consistent format (e.g., A01, B02, etc.)
#'
#' @param well_positions Character vector of well positions
#'
#' @return Formatted well positions
#' @keywords internal
#' @noRd
format_well_positions <- function(well_positions) {
  # Format well positions to ensure consistent format
  formatted <- well_positions
  # Add leading zero to single digit numbers (e.g., A1 -> A01)
  formatted[grepl("^[A-Z]\\d$", formatted)] <- 
    sub("(\\D)(\\d)", "\\10\\2", formatted[grepl("^[A-Z]\\d$", formatted)])
  return(formatted)
} 