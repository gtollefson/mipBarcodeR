#' Check for Duplicate Barcode Pairs
#'
#' @description
#' Identifies duplicate barcode pairs in a barcode sheet, regardless of order (fw-rev or rev-fw).
#' Prints a message indicating whether duplicates are found and returns the duplicate rows.
#'
#' @param barcode_sheet A data.table containing at least two columns: `fw` and `rev`, 
#'        representing forward and reverse barcode sequences.
#'
#' @return Invisibly returns a data.table of duplicate rows. If no duplicates are found, 
#'         an empty data.table is returned.
#'
#' @export
#'
#' @examples
#' # Create a sample barcode sheet
#' sample_sheet <- data.table::data.table(
#'   sample_name = c("Sample1", "Sample2", "Sample3"),
#'   fw = c("ATCG", "GCTA", "ATCG"),
#'   rev = c("GCTA", "ATCG", "GCTA")
#' )
#' 
#' # Check for duplicates
#' duplicates <- check_duplicate_barcode_pairs(sample_sheet)
check_duplicate_barcode_pairs <- function(barcode_sheet) {
  
  # Validate input
  if (!data.table::is.data.table(barcode_sheet)) {
    barcode_sheet <- data.table::as.data.table(barcode_sheet)
  }
  
  required_cols <- c("fw", "rev")
  missing_cols <- setdiff(required_cols, names(barcode_sheet))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Create unordered pair key
  barcode_sheet$pair_key <- apply(barcode_sheet[, c('fw', 'rev')], 1, function(x) {
    paste(sort(x), collapse = "_")
  })
  
  # Count occurrences of each unique pair
  pair_counts <- table(barcode_sheet$pair_key)
  
  # Identify duplicate pairs
  barcode_sheet$Duplicate_Pair <- barcode_sheet$pair_key %in% names(pair_counts[pair_counts > 1])
  
  # Extract duplicate rows
  duplicate_rows <- barcode_sheet[barcode_sheet$Duplicate_Pair, ]
  
  # Sanity check message
  if (nrow(duplicate_rows) > 0) {
    message("⚠️  Duplicate barcode pairs found:")
    print(duplicate_rows)
  } else {
    message("✅ No duplicate barcode pairs found.")
  }
  
  # Clean up temporary column
  barcode_sheet[, pair_key := NULL]
  barcode_sheet[, Duplicate_Pair := NULL]
  
  # Return duplicates invisibly (so you can capture if needed)
  invisible(duplicate_rows)
} 