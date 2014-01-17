
# Purpose: This script creates a HTML report based on the processed data.
# 'lc_report.Rmd' serves as the report template. Note that for reproducibility
# purposes, the knit runs in a separate process and environment
# (rather than using the current workspace). Therefore the processed data needs
# to get sourced in the lc_report.Rmd file.



# Why change the working directory?
#
# Answer: Workaround to fix the issue regarding "figure" folder generation 
# through the knit command. 
#
# Although the knit runs in its own process (by default the directory the .Rmd 
# resides), the figure folder gets created in the working directory of the 
# overall R session the knit command was started in.
#
# Therefore the relative paths of the figures in the created .md file would point
# to figure/ instead to report/figure/ should we not switch the working directory.
# In the next step markdownToHTML could not reference the figures because a 
# figure/ folder would not exist in /report.
setwd("report/")

knit('lc_report.Rmd', 'lc_report.md')
knit_bootstrap_md('lc_report.md', 'lc_report.html', boot_style = 'Cerulean')

setwd("..")
