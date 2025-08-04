# mipBarcodeR

A self-contained R package for generating barcode sheets for demultiplexing basecalled fastq files using Bailey Lab custom MIP sample barcodes. Users only need to provide their sample sheet with SampleID, FW_Plate, REV_Plate, FW_Well, and REV_Well columns. The package includes built-in lookup tables for REV plates (1-4) and FW primers (1-96), making it easy for users to generate barcode sheets with minimal setup.

## Features

- **Self-contained**: Includes all necessary lookup tables
- **Easy to use**: Only requires a sample sheet from the user
- **Duplicate checking**: Automatically identifies duplicate barcode pairs
- **Multiple barcode sets**: Support for combining multiple FW/REV combinations in a single sample sheet
- **Professional output**: Generates properly formatted TSV files for sample demultiplexing using Bailey Lab MIP sample barcodes

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



## Function Reference

### `generate_barcode_sheet()`

Generates a barcode sheet for multiple FW/REV combinations in a single sample sheet.

**Parameters:**
- `sample_sheet_path`: Path to the sample sheet CSV file
- `check_duplicates`: Whether to check for duplicate barcode pairs (default: TRUE)

**Returns:** A data.table with columns: sample_name, fw, rev



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
- `project_name`: Optional project name (for filename)

**Returns:** Full path to the written file

## Example Data

The package includes a demo script and example input file:

```r
# Run the demo script
Rscript demo/demo.R

# Or use the example input file directly
barcode_sheet <- generate_barcode_sheet("demo/example_input.csv")
```

## Testing the Package

You can run the complete demo script to test all functionality:

```r
# Run the demo script
Rscript demo/demo.R
```

The demo will:
1. Load the example input file (`demo/example_input.csv`)
2. Generate barcode sequences for 4 samples
3. Save the output to `demo/demo_output/`
4. Show you the expected format

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
- Validates well format (A01, B02, etc.)
- Validates plate number ranges (FW: 1-96, REV: 1-4)

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