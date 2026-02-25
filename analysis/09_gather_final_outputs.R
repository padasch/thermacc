#!/usr/bin/env Rscript

# Script to copy the most recent versions of figures to output/final/{date}/
# with standardized names (figure1.pdf, figure2.pdf, etc.)
# and supplementary files to output/final/{date}/si/

library(fs)

# Get current date in YYYY-MM-DD format
current_date <- format(Sys.Date(), "%Y-%m-%d")

# Define the mapping of output names to source file patterns for main figures
figure_mapping <- list(
  figure1 = "modelled-observed-patterns_3x3.pdf",
  figure2 = "mod-obs_topt_3x3.pdf",
  figure3 = "aopt-tgrowth_3x3.pdf",
  figure4 = "traits-both.pdf",
  figure5 = "curve-shape-per-climate-fullacc.pdf",
  figure6 = "jvr-tgrowth_3x3.pdf",
  figure7 = "trajectory-relative-only.pdf"
)

# Define supplementary PDF files to copy (without renaming)
supp_pdf_files <- c(
  "vpd_method_topt_comparison.pdf",
  "inst_vpd_climate_scaled.pdf",
  "000_metrics_comparison.pdf",
  "acc-assumption.pdf",
  "seasonality_noacc-fullacc-facet.pdf",
  "global_map.pdf",
  "modobs_tspan_all_effects.pdf",
  "modtcair_tspan_all_effects.pdf",
  "ftemp_vcmax_jmax.pdf",
  "jvr-topt_3x3.pdf",
  "modtcair_topt_all_effects.pdf",
  "modobs_aopt_all_effects.pdf",
  "response-of-each-site.pdf",
  "sensana_acc.pdf",
  "sensana_growth_forcing.pdf",
  "sensana_inst_forcing.pdf"
)

# Define supplementary CSV files to copy (without renaming)
supp_csv_files <- c(
  "si_site-metadata.csv",
  "trait-temp_clean_topt.csv",
  "trait-temp_full_tspan.csv",
  "trait-temp_full_topt.csv",
  "trait-temp_full_aopt.csv",
  "changes_in_realized_anet.csv"
)

# Base directories
output_dir <- here::here("output")
final_dir <- here::here("output", "final", current_date)
si_dir <- here::here("output", "final", current_date, "si")

# Create directories if they don't exist
dir_create(final_dir, recurse = TRUE)
dir_create(si_dir, recurse = TRUE)

# Function to find the most recent file matching a pattern
find_most_recent <- function(base_dir, filename) {
  # Find all files matching the exact filename
  files <- dir_ls(base_dir, 
                  recurse = TRUE, 
                  regexp = paste0("/", filename, "$"),
                  type = "file")
  
  if (length(files) == 0) {
    warning(paste("No files found for:", filename))
    return(NULL)
  }
  
  # Get file info and sort by modification time
  file_info <- file_info(files)
  most_recent <- files[which.max(file_info$modification_time)]
  
  return(most_recent)
}

# Process each main figure
cat("Finding and copying main figures...\n")
cat(sprintf("Destination: %s\n\n", final_dir))

for (fig_name in names(figure_mapping)) {
  source_pattern <- figure_mapping[[fig_name]]
  
  cat(sprintf("Processing %s (%s)...\n", fig_name, source_pattern))
  
  # Find most recent file
  source_file <- find_most_recent(output_dir, source_pattern)
  
  if (!is.null(source_file)) {
    # Define destination
    dest_file <- path(final_dir, paste0(fig_name, ".pdf"))
    
    # Copy file
    file_copy(source_file, dest_file, overwrite = TRUE)
    
    cat(sprintf("  ✓ Copied from: %s\n", source_file))
    cat(sprintf("  ✓ Copied to:   %s\n", dest_file))
    
    # Show modification time
    mod_time <- file_info(source_file)$modification_time
    cat(sprintf("  ✓ File date:   %s\n", mod_time))
  } else {
    cat(sprintf("  ✗ File not found!\n"))
  }
  
  cat("\n")
}

# Function to copy supplementary files
copy_supp_files <- function(base_dir, file_list, dest_dir, file_type) {
  cat(sprintf("\nFinding and copying supplementary %s files...\n", file_type))
  cat(sprintf("Destination: %s\n\n", dest_dir))
  
  for (filename in file_list) {
    cat(sprintf("Processing %s...\n", filename))
    
    # Find most recent file
    source_file <- find_most_recent(base_dir, filename)
    
    if (!is.null(source_file)) {
      # Define destination
      dest_file <- path(dest_dir, filename)
      
      # Copy file
      file_copy(source_file, dest_file, overwrite = TRUE)
      
      cat(sprintf("  ✓ Copied from: %s\n", source_file))
      cat(sprintf("  ✓ Copied to:   %s\n", dest_file))
    } else {
      cat(sprintf("  ✗ File not found!\n"))
    }
    
    cat("\n")
  }
}

# Copy supplementary PDF files
copy_supp_files(output_dir, supp_pdf_files, si_dir, "PDF")

# Copy supplementary CSV files
copy_supp_files(output_dir, supp_csv_files, si_dir, "CSV")

cat(sprintf("Done! All files copied to: %s\n", final_dir))
