#' Load Built-in Lookup Tables
#'
#' @description
#' Loads the built-in lookup tables for REV barcode sequences, FW primer number lookup,
#' and FW primer sequence lookup. These tables are included in the package.
#'
#' @param rev_number Numeric. The REV plate number (1-4) to load the appropriate REV sheet.
#' @return A list containing the loaded lookup tables
#' @export
load_lookup_tables <- function(rev_number = 4) {
  # Load the appropriate REV barcode sequence sheet based on rev_number
  rev_file <- paste0("REV-", rev_number, "_barcode_stock_seq_sheet.csv")
  rev_barcode_seq_sheet <- data.table::fread(
    system.file(paste0("extdata/lookup_tables/", rev_file), 
                package = "mipBarcodeR")
  )
  data.table::setDT(rev_barcode_seq_sheet)
  
  fw_primer_number_lookup_sheet <- data.table::fread(
    system.file("extdata/lookup_tables/shift_plate_fw_lookup_table.csv", 
                package = "mipBarcodeR")
  )
  data.table::setDT(fw_primer_number_lookup_sheet)
  
  # For now, return empty fw_primer_seq_lookup_sheet - this will be loaded dynamically
  # in generate_barcode_sheet based on the actual primer numbers needed
  fw_primer_seq_lookup_sheet <- data.table::data.table()
  
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
#' Automatically converts well positions to double-digit format (e.g., A1 to A01).
#'
#' @param sample_sheet A data.table containing the sample sheet
#'
#' @return The validated (and potentially modified) sample sheet
#' @export
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
  if (!all(sample_sheet$FW_Plate %in% 1:76)) {
    stop("FW_Plate values must be between 1 and 76")
  }
  
  if (!all(sample_sheet$REV_Plate %in% 1:4)) {
    stop("REV_Plate values must be between 1 and 4")
  }
  
  # Auto-format well positions and notify user if conversion was needed
  original_fw_wells <- sample_sheet$FW_Well
  original_rev_wells <- sample_sheet$REV_Well
  
  data.table::setDT(sample_sheet)
  sample_sheet$FW_Well <- format_well_positions(sample_sheet$FW_Well)
  sample_sheet$REV_Well <- format_well_positions(sample_sheet$REV_Well)
  
  # Check if any wells were converted
  fw_converted <- !identical(original_fw_wells, sample_sheet$FW_Well)
  rev_converted <- !identical(original_rev_wells, sample_sheet$REV_Well)
  
  if (fw_converted || rev_converted) {
    converted_wells <- c()
    if (fw_converted) converted_wells <- c(converted_wells, "FW_Well")
    if (rev_converted) converted_wells <- c(converted_wells, "REV_Well")
    
    message("ℹ️  Auto-converting well format to double-digit format (e.g., A1 → A01) for: ", 
            paste(converted_wells, collapse = ", "))
  }
  
  # Validate well format after conversion (A01, B02, etc.)
  well_pattern <- "^[A-Z][0-9]{2}$"
  if (!all(grepl(well_pattern, sample_sheet$FW_Well))) {
    invalid_wells <- sample_sheet$FW_Well[!grepl(well_pattern, sample_sheet$FW_Well)]
    stop("Invalid FW_Well format found: ", paste(unique(invalid_wells), collapse = ", "), 
         "\nWells must be in format A01, B02, etc. (letter followed by 2 digits)")
  }
  
  if (!all(grepl(well_pattern, sample_sheet$REV_Well))) {
    invalid_wells <- sample_sheet$REV_Well[!grepl(well_pattern, sample_sheet$REV_Well)]
    stop("Invalid REV_Well format found: ", paste(unique(invalid_wells), collapse = ", "), 
         "\nWells must be in format A01, B02, etc. (letter followed by 2 digits)")
  }
  
  return(sample_sheet)
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

#' Load Forward Primer Sequences Based on Primer Numbers
#'
#' @description
#' Dynamically loads the appropriate forward primer sequence file(s) based on the
#' primer numbers that are actually needed.
#'
#' @param primer_numbers Numeric vector of primer numbers needed
#'
#' @return A data.table containing the forward primer sequences
#' @keywords internal
#' @noRd
load_fw_primer_sequences <- function(primer_numbers) {
  # Define the primer number ranges for each file
  primer_ranges <- list(
    "hybrid_dual_fw_001-096_seq_sheet.csv" = c(1, 96),
    "hybrid_dual_fw_097-192_seq_sheet.csv" = c(97, 192),
    "hybrid_dual_fw_193-288_seq_sheet.csv" = c(193, 288),
    "hybrid_dual_fw_289-384_seq_sheet.csv" = c(289, 384)
  )
  
  # Determine which files we need to load
  files_to_load <- character(0)
  for (file_name in names(primer_ranges)) {
    range_min <- primer_ranges[[file_name]][1]
    range_max <- primer_ranges[[file_name]][2]
    
    # Check if any of our primer numbers fall in this range
    if (any(primer_numbers >= range_min & primer_numbers <= range_max)) {
      files_to_load <- c(files_to_load, file_name)
    }
  }
  
  # Load the required files
  fw_primer_seq_list <- list()
  for (i in seq_along(files_to_load)) {
    file_path <- system.file(paste0("extdata/lookup_tables/", files_to_load[i]), 
                            package = "mipBarcodeR")
    if (file.exists(file_path)) {
      fw_seq_temp <- data.table::fread(file_path)
      data.table::setDT(fw_seq_temp)
      fw_primer_seq_list[[i]] <- fw_seq_temp
    } else {
      warning("Forward primer sequence file not found: ", files_to_load[i])
    }
  }
  
  # Combine the loaded files
  if (length(fw_primer_seq_list) > 0) {
    fw_primer_seq_lookup_sheet <- data.table::rbindlist(fw_primer_seq_list, use.names = TRUE, fill = TRUE)
  } else {
    fw_primer_seq_lookup_sheet <- data.table::data.table()
  }
  
  return(fw_primer_seq_lookup_sheet)
} 