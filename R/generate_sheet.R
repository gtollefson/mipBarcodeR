#' Generate Barcode Sheet for Nanopore Sequencing
#'
#' @description
#' Generates a barcode sheet for nanopore sequencing using built-in lookup tables.
#' Supports multiple barcode sets in a single sample sheet using FW_Plate, REV_Plate, FW_Well, REV_Well columns.
#' The function automatically performs barcode sanity checking to identify duplicate barcode pairs.
#'
#' @param sample_sheet_path Character. Path to the sample sheet CSV file.
#' @param check_duplicates Logical. Whether to check for duplicate barcode pairs (default: TRUE).
#'
#' @return A data.table containing the final barcode sheet with columns: 
#'         sample_name, fw (forward barcode sequence), and rev (reverse barcode sequence).
#'
#' @export
#'
#' @examples
#' # Generate barcode sheet with multiple barcode sets
#' # sample_sheet_path <- "path/to/your/sample_sheet.csv"
#' # barcode_sheet <- generate_barcode_sheet(sample_sheet_path)
generate_barcode_sheet <- function(sample_sheet_path, check_duplicates = TRUE) {
  
  # Read sample sheet
  plate_map_sheet <- data.table::fread(sample_sheet_path)
  
  # Validate sample sheet structure
  validate_sample_sheet(plate_map_sheet)
  
  # Clean empty rows
  plate_map_sheet <- plate_map_sheet[
    rowSums(is.na(plate_map_sheet) | plate_map_sheet == "") != ncol(plate_map_sheet)
  ]
  
  # Format well positions
  plate_map_sheet[grepl("^[A-Z]\\d$", FW_Well), FW_Well := 
                   sub("(\\D)(\\d)", "\\10\\2", FW_Well)]
  plate_map_sheet[grepl("^[A-Z]\\d$", REV_Well), REV_Well := 
                   sub("(\\D)(\\d)", "\\10\\2", REV_Well)]
  
  # Process each unique FW/REV combination
  final_results <- list()
  
  # Get unique FW/REV combinations
  unique_combinations <- unique(plate_map_sheet[, .(FW_Plate, REV_Plate)])
  
  for (i in 1:nrow(unique_combinations)) {
    fw_num <- unique_combinations$FW_Plate[i]
    rev_num <- unique_combinations$REV_Plate[i]
    
    # Filter data for this combination
    subset_data <- plate_map_sheet[FW_Plate == fw_num & REV_Plate == rev_num]
    
    # Load appropriate REV barcode sequences
    lookup_tables <- load_lookup_tables(rev_num)
    rev_barcode_seq_sheet <- lookup_tables$rev_barcode_seq_sheet
    fw_primer_number_lookup_sheet <- lookup_tables$fw_primer_number_lookup_sheet
    fw_primer_seq_lookup_sheet <- lookup_tables$fw_primer_seq_lookup_sheet
    
    # Merge REV sequence
    subset_data <- data.table::merge.data.table(
      subset_data, 
      rev_barcode_seq_sheet[, .(`Well Position`, Sequence)],
      by.x = "REV_Well", 
      by.y = "Well Position", 
      all.x = TRUE
    )
    
    data.table::setnames(subset_data, "Sequence", "REV.Sequence")
    
    # Extract Column and Row from FW wells
    subset_data[, Column := as.integer(sub("^[A-Z]", "", FW_Well))]
    subset_data[, Row := sub("(\\D+)\\d+", "\\1", FW_Well)]
    
    # Filter lookup table for this FW/REV combination
    fw_lookup_filtered <- fw_primer_number_lookup_sheet[
      `Stock_Plate-Rev` == rev_num & Shift_Plate == fw_num
    ]
    
    if (nrow(fw_lookup_filtered) == 0) {
      stop("No entries found in the FW primer number lookup sheet for REV-", 
           rev_num, " and FW-", fw_num, " combination.")
    }
    
    # Merge FW primer number
    subset_data <- data.table::merge.data.table(
      subset_data, 
      fw_lookup_filtered[, .(Column, Row, `Primer-Fw`)],
      by = c("Column", "Row"), 
      all.x = TRUE
    )
    
    if (!"Primer-Fw" %in% names(subset_data)) {
      stop("Error: Primer-Fw not found after merge. Possible lookup failure.")
    }
    
    # Format primer number and create primer name
    subset_data[, `Primer-Fw` := sprintf("%03d", `Primer-Fw`)]
    subset_data[, FW_Primer_Name := paste0("hybrid_dual_fw_", `Primer-Fw`)]
    
    # Merge FW sequence
    subset_data <- data.table::merge.data.table(
      subset_data, 
      fw_primer_seq_lookup_sheet[, .(Name, Sequence)],
      by.x = "FW_Primer_Name", 
      by.y = "Name", 
      all.x = TRUE
    )
    
    data.table::setnames(subset_data, "Sequence", "FW.Sequence")
    
    # Add to results
    final_results[[i]] <- subset_data[, .(
      sample_name = SampleID, 
      fw = `FW.Sequence`, 
      rev = `REV.Sequence`
    )]
  }
  
  # Combine all results
  final_plate_map_sheet <- data.table::rbindlist(final_results, use.names = TRUE, fill = TRUE)
  
  # Check for duplicates if requested
  if (check_duplicates) {
    duplicates <- check_duplicate_barcode_pairs(final_plate_map_sheet)
  }
  
  return(final_plate_map_sheet)
}

 