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
  data.table::setDT(plate_map_sheet)
  
  # Validate sample sheet structure and auto-format wells
  plate_map_sheet <- validate_sample_sheet(plate_map_sheet)
  data.table::setDT(plate_map_sheet)
  
  # Clean empty rows
  plate_map_sheet <- plate_map_sheet[
    rowSums(is.na(plate_map_sheet) | plate_map_sheet == "") != ncol(plate_map_sheet)
  ]
  
  # Process each unique FW/REV combination
  final_results <- list()
  
  # Get unique FW/REV combinations
  unique_combinations <- unique(plate_map_sheet[, .SD, .SDcols = c("FW_Plate", "REV_Plate")])
  
  for (i in 1:nrow(unique_combinations)) {
    fw_num <- unique_combinations$FW_Plate[i]
    rev_num <- unique_combinations$REV_Plate[i]
    
    # Filter data for this combination
    subset_data <- plate_map_sheet[plate_map_sheet$FW_Plate == fw_num & plate_map_sheet$REV_Plate == rev_num, ]
    data.table::setDT(subset_data)
    
    # Load appropriate REV barcode sequences
    lookup_tables <- load_lookup_tables(rev_num)
    rev_barcode_seq_sheet <- lookup_tables$rev_barcode_seq_sheet
    fw_primer_number_lookup_sheet <- lookup_tables$fw_primer_number_lookup_sheet
    fw_primer_seq_lookup_sheet <- lookup_tables$fw_primer_seq_lookup_sheet
    
    # Merge REV sequence
    subset_data <- data.table::merge.data.table(
      subset_data, 
      rev_barcode_seq_sheet[, .SD, .SDcols = c("Well Position", "Sequence")],
      by.x = "REV_Well", 
      by.y = "Well Position", 
      all.x = TRUE
    )
    
    data.table::setnames(subset_data, "Sequence", "REV.Sequence")
    
    # Extract Column and Row from FW wells
    data.table::set(subset_data, j = "Column", value = as.integer(sub("^[A-Z]", "", subset_data$FW_Well)))
    data.table::set(subset_data, j = "Row", value = sub("([A-Z]+)[0-9]+", "\\1", subset_data$FW_Well))
    
    # Filter lookup table for this FW/REV combination
    fw_lookup_filtered <- fw_primer_number_lookup_sheet[
      fw_primer_number_lookup_sheet$`Stock_Plate-Rev` == rev_num & fw_primer_number_lookup_sheet$Shift_Plate == fw_num, 
    ]
    
    if (nrow(fw_lookup_filtered) == 0) {
      stop("No entries found in the FW primer number lookup sheet for REV-", 
           rev_num, " and FW-", fw_num, " combination.")
    }
    
    # Merge FW primer number
    subset_data <- data.table::merge.data.table(
      subset_data, 
      fw_lookup_filtered[, .SD, .SDcols = c("Column", "Row", "Primer-Fw")],
      by = c("Column", "Row"), 
      all.x = TRUE
    )
    
    if (!"Primer-Fw" %in% names(subset_data)) {
      stop("Error: Primer-Fw not found after merge. Possible lookup failure.")
    }
    
    # Format primer number and create primer name
    data.table::set(subset_data, j = "Primer-Fw", value = sprintf("%03d", subset_data$`Primer-Fw`))
    data.table::set(subset_data, j = "FW_Primer_Name", value = paste0("hybrid_dual_fw_", subset_data$`Primer-Fw`))
    
    # Merge FW sequence
    subset_data <- data.table::merge.data.table(
      subset_data, 
      fw_primer_seq_lookup_sheet[, .SD, .SDcols = c("Name", "Sequence")],
      by.x = "FW_Primer_Name", 
      by.y = "Name", 
      all.x = TRUE
    )
    
    data.table::setnames(subset_data, "Sequence", "FW.Sequence")
    
    # Add to results
    final_results[[i]] <- subset_data[, .SD, .SDcols = c("SampleID", "FW.Sequence", "REV.Sequence")]
    data.table::setnames(final_results[[i]], c("sample_name", "fw", "rev"))
  }
  
  # Combine all results
  final_plate_map_sheet <- data.table::rbindlist(final_results, use.names = TRUE, fill = TRUE)
  
  # Check for duplicates if requested
  if (check_duplicates) {
    duplicates <- check_duplicate_barcode_pairs(final_plate_map_sheet)
  }
  
  return(final_plate_map_sheet)
}

 