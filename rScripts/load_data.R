library(RODBC)
library(lubridate)
library(RCurl)
library(XML)
library(yaml)

config <- yaml.load_file('config.yml')

error <- FALSE

#Open conncection to database
connect <- try(odbcConnect('LabCase', uid=config$odbc$uid, pwd=config$odbc$pwd), silent=TRUE)

if(connect == -1 || class(connect) == 'try-error')
  error <- TRUE
  
#Extract project information and count members per project
if(!error) {
  query <- 'SELECT p.id, p.identifier, p.name, p.created_on, p.updated_on, 
            p.is_public, p.project_size, p.template_project_id, 
  		      COUNT(m.user_id) AS member_count
			      FROM projects AS p
            LEFT OUTER JOIN members AS m
            ON p.id = m.project_id
			      GROUP BY p.id;'
  projects.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(projects.raw == -1 ||
       grepl('^\\[RODBC\\] ERROR', projects.raw[2]) || 
       class(projects.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


#Extract active users (internal + external)
#
#last_login_on != NULL if user used LabCase at least one time
#Account status:
#STATUS_ANONYMOUS  = 0
#STATUS_ACTIVE     = 1
#STATUS_REGISTERED = 2
#STATUS_LOCKED     = 3
if(!error) {
  query <- 'SELECT id, login, last_login_on, status, mail FROM users
            WHERE 
            status = 1
  		      AND
			      last_login_on IS NOT NULL'
  users.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(users.raw == -1 || 
       grepl('^\\[RODBC\\] ERROR', users.raw[2]) || 
       class(users.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}

#Extract issue information grouped by project
if(!error) {
  query <- 'SELECT project_id, COUNT(id) AS issue_count FROM issues
            GROUP BY project_id'
  issues.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  if(issues.raw == -1 || 
       grepl('^\\[RODBC\\] ERROR', users.raw[2]) || 
       class(issues.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


#Extract custom field information
if(!error) {
  #In the LabCase database this is the relevant id - custom fields mapping:
  #12: Use as template
  #13: Customer
  #14: Country
  #15: Business Line
  query <- 'SELECT p.id, c.custom_field_id AS cf_id, c.value AS cf_value
            FROM projects AS p
            INNER JOIN custom_values AS c
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
  dput(issues.raw, file="./rawData/issuesRaw.R")
  dput(customFields.raw, file="./rawData/customFields.R")
  dput(dateOfExtraction, file="./rawData/dateOfExtraction.R")  
}