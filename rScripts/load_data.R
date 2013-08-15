
# Author: Alex Lemm
#
# Purpose: The load_data.R script extracts the relevant raw data from the LC 
# database using ODBC. Each extracted table is stored in a seperate .R file at 
# the end.
# In total 5 tables are read but only saved as a whole when the entire data
# retrieval was successful. The script aborts without saving anything should an 
# error occur in between.
#
# Google's R Style Guide (http://bit.ly/12ZBd1J) was applied while writing 
# the code below.




# Initialize error variable
error <- FALSE


# Open conncection to database
connect <- try(odbcConnect('LabCase', uid=config$odbc$uid, pwd=config$odbc$pwd),
               silent=TRUE)


# Error handling
if (connect == -1 || class(connect) == 'try-error')
  error <- TRUE
  

# Extract project information and count members per project
if (!error) {
  query <- 'SELECT p.id, p.identifier, p.name, p.created_on, p.updated_on, 
            p.is_public, p.project_size, p.template_project_id, 
            COUNT(m.user_id) AS member_count
            FROM projects AS p
            LEFT OUTER JOIN members AS m
            ON p.id = m.project_id
            GROUP BY p.id;'
  projects.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  # Error handling: The following three cases are always checked
  # after a read table operation (only explained once here):
  #
  # data.raw == -1: 
  #   sqlQuery returns -1 on error
  # projets.raw[2] begins with "RODBC ERROR": 
  #   Occures when the general connection was established successfully but the
  #   SQL query included an error (e.g. wrongly written column name)
  # class(projects.raw) == 'try-error':
  #   object of class 'try-error' is returned if expression in parenthesis is
  #   evaluated with error
  if (projects.raw == -1 || grepl('^\\[RODBC\\] ERROR', projects.raw[2]) || 
      class(projects.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


# Extract active LC users (internal + external)
# A user is an active user 
#   when he logged in to LabCase at least once
#     last_login_on != NULL 
#   and his status is declared as active
#     status = 1
# Account status description:
#   STATUS_ANONYMOUS  = 0
#   STATUS_ACTIVE     = 1
#   STATUS_REGISTERED = 2
#   STATUS_LOCKED     = 3
if (!error) {
  query <- 'SELECT id, login, last_login_on, status, mail FROM users
            WHERE 
            status = 1
            AND
            last_login_on IS NOT NULL'
  users.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  # Error handling
  if (users.raw == -1 || grepl('^\\[RODBC\\] ERROR', users.raw[2]) || 
      class(users.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


# Extract number of issues grouped by project
if (!error) {
  query <- 'SELECT project_id, COUNT(id) AS issue_count FROM issues
            GROUP BY project_id'
  issues.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  # Error handling
  if (issues.raw == -1 || grepl('^\\[RODBC\\] ERROR', issues.raw[2]) || 
      class(issues.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


# Extract repository disk space usage information. Per project serveral repos
# are allowed.
if (!error) {
  query <- 'SELECT project_id, SUM(disksize) AS repo_diskspace
            FROM repositories 
            GROUP BY project_id;'
  repos.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  # Error handling
  if (repos.raw == -1 || grepl('^\\[RODBC\\] ERROR', repos.raw[2]) || 
        class(repos.raw) == 'try-error') {
    error <- TRUE
    close(connect)
  } 
}


# Extract custom field information
# In the LC database this is the relevant id - custom fields mapping:
# 12: Use as template
# 13: Customer
# 14: Country
# 15: Business Line
if (!error) {
  query <- 'SELECT p.id, c.custom_field_id AS cf_id, c.value AS cf_value
            FROM projects AS p
            INNER JOIN custom_values AS c
            ON
            p.id = c.customized_id
            WHERE 
            c.custom_field_id IN (12,13,14,15) 
            AND c.customized_type = \"Project\"'
  custom.fields.raw <- try(sqlQuery(connect, query=query), silent=TRUE)
  
  # Error handling
  if (custom.fields.raw == -1 || grepl('^\\[RODBC\\] ERROR', 
      custom.fields.raw[2]) || class(custom.fields.raw) == 'try-error') {
    error <- TRUE
    close(connect) 
  }
}

# Only store data if no error occured during data retrieval 
if (!error) {
  close(connect)
  date.of.extraction = now()
  
  # Dump extracted data and current time
  dput(projects.raw, file="./rawData/projectsRaw.R")
  dput(users.raw, file="./rawData/usersRaw.R")
  dput(issues.raw, file="./rawData/issuesRaw.R")
  dput(repos.raw, file="./rawData/reposRaw.R")
  dput(custom.fields.raw, file="./rawData/customFields.R")
  dput(date.of.extraction, file="./rawData/dateOfExtraction.R")  
}