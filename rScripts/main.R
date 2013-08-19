
# Author: Alex Lemm
#
# Purpose: main.R sources load_data.R, process_data.R and create_report.
# The uploaded, processed and saved data of that workflow serves as the input 
# for the Shiny app 'LabCase Dashboard'. The created report can later be 
# downloaded as a HTML file the the Shiny Web UI. Depending on the desired use 
# case and your operating system main.R is either set up as a Cronjob your as a 
# Scheduled Task.


library(RODBC)
library(lubridate)
library(yaml)

library(plyr)
library(reshape2)

library(knitr)
library(markdown)
library(xtable)

# Set working directory
# This the specified path needs to be changed according to your setup
setwd('~/labcase_wd/lc_dashboard')


# Load config data
config <- yaml.load_file('config.yml')

source('./rScripts/load_data.R')
source('./rScripts/process_data.R')
source('./rScripts/create_report.R')

rm(list=ls())

