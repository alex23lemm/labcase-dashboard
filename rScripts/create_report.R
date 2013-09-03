
# Author: Alex Lemm
#
# Purpose: This script creates a HTML report based on the processed data.
# 'lc_report.Rmd' serves as the report template. Note that for reproducibility
# purposes, the knit runs in a separate process and environment
# (rather than using the current workspace). Therefore the processed data needs
# to get sourced in the lc_report.Rmd file.



# Why change the working directory?
# Answer: Workaround to fix the issue regarding "figure" folder generation 
# through the knit command. 

# Reason for workaround:
# Although the knit runs in its own process (by default the directory the .Rmd 
# resides), the figure folder gets created in the working directory of the 
# overall R session the knit command was started in. Thus the relative paths
# of the figures in the created .md file point point to figure/ and not to 
# report/figure/. Thus markdownToHTML cannot reference the figures because a 
# figure/ folder does not exist in /report.
setwd("report/")
knit('lc_report.Rmd', 'lc_report.md')
markdownToHTML('lc_report.md', 'lc_report.html')
setwd("..")
