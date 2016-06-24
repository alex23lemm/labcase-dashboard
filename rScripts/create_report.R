
# Purpose: This script creates a HTML report based on the processed data.
# 'lc_report.Rmd' serves as the report template. Note that for reproducibility
# purposes, the knit runs in a separate process and environment
# (rather than using the current workspace). Therefore, the processed data needs
# to get sourced in the lc_report.Rmd file.

render('./report/lc_report.Rmd')

