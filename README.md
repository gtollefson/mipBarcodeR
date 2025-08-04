# mipBarcodeR

A self-contained R package for generating barcode sheets for nanopore sequencing. Users only need to provide their sample sheet with SampleID, FW-X, and REV-X columns. The package includes built-in lookup tables for REV and FW barcode sequences, making it easy for collaborators to generate barcode sheets with minimal setup.

## Features

- **Self-contained**: Includes all necessary lookup tables
- **Easy to use**: Only requires a sample sheet from the user
- **Duplicate checking**: Automatically identifies duplicate barcode pairs
- **Multiple barcode sets**: Support for combining multiple FW/REV combinations
- **Professional output**: Generates properly formatted TSV files for nanopore sequencing

## Installation

### From GitHub (Development Version)

```r
# Install devtools if you haven't already
if (!require(devtools)) install.packages("devtools")

# Install the package
devtools::install_github("gtollefson/mipBarcodeR")
```

### From Local Directory

```r
# Navigate to the package directory and install
devtools::install("path/to/mipBarcodeR_package")

# Or use the provided installation script
Rscript install_package.R
```

## Quick Start

### 1. Install
```r
devtools::install_github("gtollefson/mipBarcodeR")
```

### 2. Prepare Input File
Create a CSV file with columns: `SampleID`, `FW_Plate`, `REV_Plate`, `FW_Well`, `REV_Well`

```csv
SampleID,FW_Plate,REV_Plate,FW_Well,REV_Well
Sample_001,1,4,A01,A01
Sample_002,5,1,C01,C01
```

**Rules:** FW_Plate (1-96), REV_Plate (1-4), Wells (A01, B02, etc.)

### 3. Run
```r
library(mipBarcodeR)
barcode_sheet <- generate_barcode_sheet("your_sample_sheet.csv")
write_barcode_sheet(barcode_sheet, "output/", "project_name")
```

### 4. Output
TSV file with columns: `sample_name`, `fw`, `rev` (ready for nanopore sequencing)

### 4. Generate Multiple Barcode Sheets

```r
# Generate multiple sheets and combine them
sample_sheets <- c("path/to/sheet1.csv", "path/to/sheet2.csv")
fw_numbers <- c(1, 5)
rev_numbers <- c(4, 1)

combined_sheet <- generate_multiple_barcode_sheets(
  sample_sheet_paths = sample_sheets,
  fw_numbers = fw_numbers,
  rev_numbers = rev_numbers
)

# Write combined sheet
output_file <- write_multiple_barcode_sheets(
  barcode_sheet = combined_sheet,
  output_path = "output/",
  filename = "nanopore_run",
  project_name = "combined_project",
  fw_numbers = fw_numbers,
  rev_numbers = rev_numbers
)
```

## Function Reference

### `generate_barcode_sheet()`

Generates a barcode sheet for a single FW/REV combination.

**Parameters:**
- `sample_sheet_path`: Path to the sample sheet CSV file
- `fw_number`: The FW plate number (e.g., 1 for FW-1)
- `rev_number`: The REV plate number (e.g., 4 for REV-4)
- `check_duplicates`: Whether to check for duplicate barcode pairs (default: TRUE)

**Returns:** A data.table with columns: sample_name, fw, rev

### `generate_multiple_barcode_sheets()`

Generates multiple barcode sheets and combines them into a single sheet.

**Parameters:**
- `sample_sheet_paths`: Vector of paths to sample sheet CSV files
- `fw_numbers`: Vector of FW plate numbers
- `rev_numbers`: Vector of REV plate numbers
- `check_duplicates`: Whether to check for duplicate barcode pairs (default: TRUE)

**Returns:** A data.table with the combined barcode sheet

### `check_duplicate_barcode_pairs()`

Identifies duplicate barcode pairs in a barcode sheet.

**Parameters:**
- `barcode_sheet`: A data.table with columns: sample_name, fw, rev

**Returns:** Invisibly returns duplicate rows

### `write_barcode_sheet()`

Writes a barcode sheet to a TSV file.

**Parameters:**
- `barcode_sheet`: The barcode sheet to write
- `output_path`: Directory to save the file
- `filename`: Base filename (without extension)
- `fw_number`: FW plate number (for filename)
- `rev_number`: REV plate number (for filename)
- `project_name`: Optional project name (for filename)

**Returns:** Full path to the written file

## Example Data

The package includes example data that you can use to test the functions:

```r
# Get path to example sample sheet
example_sheet_path <- system.file(
  "extdata/example_data/example_sample_sheet.csv", 
  package = "mipBarcodeR"
)

# Generate barcode sheet using example data
barcode_sheet <- generate_barcode_sheet(
  sample_sheet_path = example_sheet_path,
  fw_number = 1,
  rev_number = 4
)
```

## Testing the Package

You can run the complete example script to test all functionality:

```r
# Run the example script
source(system.file("examples/run_example.R", package = "mipBarcodeR"))

# Or run from command line
Rscript examples/run_example.R
```

## Output Format

The generated barcode sheets are saved as TSV files with the following columns:
- `sample_name`: The sample identifier
- `fw`: Forward barcode sequence
- `rev`: Reverse barcode sequence

This format is compatible with nanopore sequencing platforms.

## Error Handling

The package includes comprehensive error checking:
- Validates sample sheet structure
- Checks for missing required columns
- Identifies duplicate barcode pairs
- Provides informative error messages
- Validates FW/REV combinations against available lookup tables

## Contributing

To contribute to this package:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This package is licensed under the MIT License.

## Support

For issues, questions, or feature requests, please open an issue on the GitHub repository. 