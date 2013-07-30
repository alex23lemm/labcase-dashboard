
# Author: Alex Lemm
#
# Purpose: main.R sources load_data.R and process_data.R. The uploaded, 
# processed and saved data of that workflow serves as the input for the Shiny
# app 'LabCase Dashboard'. Depending on the desired use case and your 
# operating system main.R is either set up as a Cronjob your as a Scheduled Task.

setwd('C:/Users/alem/Documents/labcase_wd/lc_dashboard')
source('./rScripts/load_data.R')
source('./rScripts/process_data.R')
rm(list=ls())