#' Write Barcode Sheet to File
#'
#' @description
#' Writes a barcode sheet to a file in TSV format, suitable for nanopore sequencing.
#'
#' @param barcode_sheet A data.table containing the barcode sheet with columns: 
#'        sample_name, fw, and rev.
#' @param output_path Character. Path where the file should be saved.
#' @param filename Character. Name of the output file (without extension).
#' @param project_name Character. Optional project name for the filename.
#'
#' @return The full path to the written file.
#'
#' @export
#'
#' @examples
#' # Create a sample barcode sheet
#' barcode_sheet <- data.table::data.table(
#'   sample_name = c("Sample1", "Sample2"),
#'   fw = c("ATCG", "GCTA"),
#'   rev = c("GCTA", "ATCG")
#' )
#' 
#' # Write to file
#' # output_file <- write_barcode_sheet(barcode_sheet, "output/", "my_project")
write_barcode_sheet <- function(barcode_sheet, output_path, filename, project_name = NULL) {
  
  # Validate input
  if (!data.table::is.data.table(barcode_sheet)) {
    barcode_sheet <- data.table::as.data.table(barcode_sheet)
  }
  
  required_cols <- c("sample_name", "fw", "rev")
  missing_cols <- setdiff(required_cols, names(barcode_sheet))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Build filename
  if (!is.null(project_name)) {
    full_filename <- paste0(filename, "_", project_name, "_barcode_sample_sheet.tsv")
  } else {
    full_filename <- paste0(filename, "_barcode_sample_sheet.tsv")
  }
  
  full_path <- file.path(output_path, full_filename)
  
  # Write the file
  data.table::fwrite(barcode_sheet, file = full_path, sep = "\t", quote = FALSE)
  
  message("✅ Barcode sheet written to: ", full_path)
  message("📊 Sheet contains ", nrow(barcode_sheet), " samples")
  
  return(full_path)
}

#' Write Multiple Barcode Sheets
#'
#' @description
#' Writes multiple barcode sheets to files, useful for combined sheets from multiple FW/REV sets.
#'
#' @param barcode_sheet A data.table containing the combined barcode sheet.
#' @param output_path Character. Path where the file should be saved.
#' @param filename Character. Name of the output file (without extension).
#' @param project_name Character. Optional project name for the filename.
#' @param fw_numbers Numeric vector. The FW plate numbers used (for filename).
#' @param rev_numbers Numeric vector. The REV plate numbers used (for filename).
#'
#' @return The full path to the written file.
#'
#' @export
#'
#' @examples
#' # Write combined barcode sheet
#' # output_file <- write_multiple_barcode_sheets(combined_sheet, "output/", "nanopore_run", 
#' #                                            "project_name", c(1, 5), c(4, 1))
write_multiple_barcode_sheets <- function(barcode_sheet, output_path, filename, project_name = NULL,
                                        fw_numbers, rev_numbers) {
  
  # Validate input
  if (!data.table::is.data.table(barcode_sheet)) {
    barcode_sheet <- data.table::as.data.table(barcode_sheet)
  }
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Build filename for combined sheet
  if (!is.null(project_name)) {
    full_filename <- paste0(filename, "_combined_", project_name, "_barcode_sheet.tsv")
  } else {
    full_filename <- paste0(filename, "_combined_barcode_sheet.tsv")
  }
  
  full_path <- file.path(output_path, full_filename)
  
  # Write the file
  data.table::fwrite(barcode_sheet, file = full_path, sep = "\t", quote = FALSE)
  
  message("✅ Combined barcode sheet written to: ", full_path)
  message("📊 Sheet contains ", nrow(barcode_sheet), " samples from ", 
          length(unique(paste0("FW-", fw_numbers, "_REV-", rev_numbers))), " barcode sets")
  
  return(full_path)
} 