
# Purpose: main.R sources load_data.R, process_data.R and create_report.R.
# The uploaded, processed and saved data of that workflow serves as the input 
# for the Shiny app 'LabCase Dashboard'. The created report can later be 
# downloaded as a HTML file via the Shiny Web UI. Depending on the desired use 
# case and your operating system main.R is either set up as a Cron Job or as a 
# Scheduled Task.


library(DBI)
library(lubridate)
library(yaml)

library(magrittr)
library(plyr)
library(dplyr)
library(tidyr)
library(stringr)

library(rmarkdown)


# Set working directory
# This the specified path needs to be changed according to your setup
setwd('/srv/shiny-server/labcase-dashboard')

# Load config data
config <- yaml.load_file('config.yml')

source('./rScripts/load_data.R')
source('./rScripts/process_data.R')
source('./rScripts/create_report.R')

rm(list = ls())

