
# Purpose: The load_data.R script extracts the relevant raw data from the LC 
# database using ODBC. Each extracted table is stored in a seperate .R file at 
# the end.
# In total 5 tables are read but only saved as a whole when the entire data
# retrieval was successful. The script aborts without saving anything should an 
# error occur in between.
#
# Google's R Style Guide (http://bit.ly/12ZBd1J) was applied while writing 
# the code below.


connect <- try(dbConnect(RMySQL::MySQL(), 
                     username = config$db$uid, 
                     password = config$db$pwd,
                     host = config$db$host, 
                     port = config$db$port, 
                     dbname = config$db$dbname),
               silent = TRUE)

if (class(connect) == 'try-error') {
 stop("Database connection could not be established") 
}
  

# Extract project information and count members per project
query <- 'SELECT p.id, p.identifier, p.name, p.created_on, 
          p.is_public, p.project_size, p.template_project_id, 
          p.last_updated_on, COUNT(m.user_id) AS member_count
          FROM projects AS p
          LEFT OUTER JOIN members AS m
          ON p.id = m.project_id
          GROUP BY p.id;'

projects.raw <- try(dbGetQuery(connect, statement = query), silent = TRUE)

if (class(projects.raw) == 'try-error') {
    dbDisconnect(connect)
    stop("SQL Query: Project information could not be fetched")
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
query <- 'SELECT id, login, last_login_on, status, mail FROM users
            WHERE 
            status = 1
            AND
            last_login_on IS NOT NULL'
users.raw <- try(dbGetQuery(connect, statement = query), silent = TRUE)
  
if (class(users.raw) == 'try-error') {
  dbDisconnect(connect)
  stop("SQL Query: User information could not be fetched")
}


# Extract number of issues grouped by project
query <- 'SELECT project_id, COUNT(id) AS issue_count FROM issues
          GROUP BY project_id'
issues.raw <- try(dbGetQuery(connect, statement = query), silent = TRUE)
  
if ( class(issues.raw) == 'try-error') {
  dbDisconnect(connect)
  stop("SQL Query: Issue information could not be fetched")
}


# Extract repository disk space usage information. Per project serveral repos
# are allowed.
query <- 'SELECT project_id, SUM(disksize) AS repo_diskspace
          FROM repositories 
          GROUP BY project_id;'
repos.raw <- try(dbGetQuery(connect, statement = query), silent = TRUE)
  
if ( class(repos.raw) == 'try-error') {
  dbDisconnect(connect)
  stop("SQL Query: Repository information could not be fetched")
} 


# Extract custom field information
# In the LC database this is the relevant id - custom fields mapping:
# 12: Use as template
# 13: Customer
# 14: Country
# 15: Business Line
query <- 'SELECT p.id, c.custom_field_id AS cf_id, c.value AS cf_value
          FROM projects AS p
          INNER JOIN custom_values AS c
          ON
          p.id = c.customized_id
          WHERE 
          c.custom_field_id IN (12,13,14,15) 
          AND c.customized_type = \"Project\"'
custom.fields.raw <- try(dbGetQuery(connect, statement = query), 
                         silent = TRUE)
  
if (class(custom.fields.raw) == 'try-error') {
  dbDisconnect(connect) 
  stop("SQL Query: Custom field information could not be fetched")
}


# Only store data if no error occured during data retrieval 
dbDisconnect(connect)
date.of.extraction = now()

# Dump extracted data and current time
dput(projects.raw, file = "./rawData/projectsRaw.R")
dput(users.raw, file = "./rawData/usersRaw.R")
dput(issues.raw, file = "./rawData/issuesRaw.R")
dput(repos.raw, file = "./rawData/reposRaw.R")
dput(custom.fields.raw, file = "./rawData/customFields.R")
dput(date.of.extraction, file = "./rawData/dateOfExtraction.R")  