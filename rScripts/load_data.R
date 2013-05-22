library(RODBC)
library(lubridate)
library(RCurl)
library(XML)

# Connect to database and retrieve projects table
connect <- odbcConnect('LabCase', uid='', pwd='')

query <- 'SELECT * FROM projects'
projects.raw <- sqlQuery(connect, query=query)

query <- 'SELECT * FROM users'
users.raw <- sqlQuery(connect, query=query)

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
customFields.raw <- sqlQuery(connect, query=query)

close(connect)

dateOfExtraction = now()

#Dump extracted data and current time
dput(projects.raw, file="./rawData/projectsRaw.R")
dput(users.raw, file="./rawData/usersRaw.R")
dput(customFields.raw, file="./rawData/customFields.R")
dput(dateOfExtraction, file="./rawData/dateOfExtraction.R")
