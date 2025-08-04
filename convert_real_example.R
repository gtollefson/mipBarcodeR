#!/usr/bin/env Rscript
# =============================================================================
# Convert Real Example Files to New Format
# =============================================================================

library(data.table)

# Read the original files
fw1_rev4 <- fread("inst/extdata/example_data/real_example_fw1_rev4.csv")
fw5_rev1 <- fread("inst/extdata/example_data/real_example_fw5_rev1.csv")

# Convert FW-1, REV-4 to new format
fw1_rev4_new <- fw1_rev4[, .(
  SampleID = SampleID,
  FW_Plate = 1,
  REV_Plate = 4,
  FW_Well = `FW-1`,
  REV_Well = `REV-4`
)]

# Convert FW-5, REV-1 to new format
fw5_rev1_new <- fw5_rev1[, .(
  SampleID = SampleID,
  FW_Plate = 5,
  REV_Plate = 1,
  FW_Well = `FW-5`,
  REV_Well = `REV-1`
)]

# Combine both datasets
combined_example <- rbind(fw1_rev4_new, fw5_rev1_new)

# Write the combined file
fwrite(combined_example, "inst/extdata/example_data/real_example_combined_new_format.csv")

cat("Converted files:\n")
cat("- FW-1/REV-4 samples:", nrow(fw1_rev4_new), "\n")
cat("- FW-5/REV-1 samples:", nrow(fw5_rev1_new), "\n")
cat("- Total samples:", nrow(combined_example), "\n")
cat("Output file: inst/extdata/example_data/real_example_combined_new_format.csv\n") 