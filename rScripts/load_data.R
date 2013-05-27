library(RODBC)
library(lubridate)
library(RCurl)
library(XML)

error <- FALSE

# Connect to database and retrieve projects table
connect <- try(odbcConnect('LabCase', uid='', pwd=''), silent=TRUE)

if(connect == -1 || class(connect) == 'try-error')
  error <- TRUE
  
if(!error) {
  query <- 'SELECT * FROM projects'
  projects.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(projects.raw == -1 ||
       grepl('^\\[RODBC\\] ERROR', projects.raw[2]) || 
       class(projects.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}

if(!error) {
  query <- 'SELECT * FROM users'
  users.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(users.raw == -1 || 
       grepl('^\\[RODBC\\] ERROR', users.raw[2]) || 
       class(users.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}

if(!error) {
  #In the LabCase database this is the relevant id - custom fields mapping:
  #12: Use as template
  #13: Customer
  #14: Country
  #15: Business Line
  query <- 'SELECT p.id, c.custom_field_id AS cf_id, c.value AS cf_value
            FROM projects AS p
            INNER JOIN
            custom_values AS c
            ON
            p.id = c.customized_id
            WHERE 
            c.custom_field_id IN (12,13,14,15) AND c.customized_type = \"Project\"'
  customFields.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(customFields.raw == -1 || 
       grepl('^\\[RODBC\\] ERROR', customFields.raw[2]) || 
       class(customFields.raw) == 'try-error') {
    error <- TRUE
    close(connect) 
  }
}

if(!error) {
  close(connect)
  dateOfExtraction = now()
  
  #Dump extracted data and current time
  dput(projects.raw, file="./rawData/projectsRaw.R")
  dput(users.raw, file="./rawData/usersRaw.R")
  dput(customFields.raw, file="./rawData/customFields.R")
  dput(dateOfExtraction, file="./rawData/dateOfExtraction.R")  
}