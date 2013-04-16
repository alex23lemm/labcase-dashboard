library(RODBC)
library(lubridate)
library(RCurl)
library(XML)

# Connect to database and retrieve projects table
connect <- odbcConnect('LabCase',uid='',pwd='')
query <- 'SELECT * FROM projects'
projects.raw <- sqlQuery(connect,query=query)
query <- 'SELECT * FROM users'
users.raw <- sqlQuery(connect,query=query)
close(connect)

dateOfExtraction = now()

# Get date of last update for each project via ATOM feed
lastUpdates <- rep(NA, dim(projects.raw)[1])


for(i in 1:dim(projects.raw)[1]){
  feedResult <- getURL(paste('https://labcase.softwareag.com/projects/',
                             projects.raw$identifier[i],
                             #'/activity.atom?key=f220b4c70faf568c48a6ba1ca98f757712bf55ea&show_alfresco_documents=1&show_changesets=1&show_issues=1&show_messages=1&show_news=1&show_wiki_edits=1&with_subprojects=0',
                             '/activity.atom?key=f220b4c70faf568c48a6ba1ca98f757712bf55ea&show_alfresco_documents=1&show_issues=1&show_wiki_edits=1',
                             sep=''),
                       ssl.verifypeer = FALSE)
  parsedFeed <- xmlParse(feedResult)
  #Extract first 'updated element' which represents the date of the last update
  lastUpdate <- xpathSApply(parsedFeed,'/descendant::xmlns:updated[1]', namespaces= c(xmlns="http://www.w3.org/2005/Atom"))
  lastUpdate <- xmlValue(lastUpdate[[1]])
  lastUpdates[i] <- lastUpdate
}

projects.raw$last_update <- as.POSIXct(lastUpdates)

#Dump extracted data and current time
dput(projects.raw, file="./rawData/projectsRaw.R")
dput(users.raw, file="./rawData/usersRaw.R")
dput(dateOfExtraction, file="./rawData/dateOfExtraction.R")
