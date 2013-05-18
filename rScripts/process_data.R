library(lubridate)


#Load raw data into memory
projects.raw <- dget(file="./rawData/projectsRaw.R")
users.raw <- dget(file="./rawData/usersRaw.R")
dateOfExtraction <- dget("./rawData/dateOfExtraction.R")
customFields.raw <- dget(file="./rawData/customFields.R")

#Extract active users (internal + external)
#
#last_login_on != NA if user used LabCase at least one time
#Account status:
#STATUS_ANONYMOUS  = 0
#STATUS_ACTIVE     = 1
#STATUS_REGISTERED = 2
#STATUS_LOCKED     = 3
users <- subset(users.raw, !is.na(last_login_on) & status==1)
users$login <- tolower(users$login)
users$mail <- tolower(users$mail)


#Extract email suffix of SAG users (Software AG, IDS Scheer, itCampus, Terracotta)
#
regex1 <- regexec('.*?@(.*)', as.character(users$mail))
regm1 <- regmatches(users$mail, regex1)
suffix <- sapply(regm1, function(x)x[2])

regex2 <- regexpr('^(softwareag|itcampus|ids-scheer|terracotta).*', suffix)
suffix.sag <- regmatches(suffix, regex2)
suffix.sag.table <- sort(table(suffix.sag), decreasing=TRUE)
suffix.sag.df <- as.data.frame.table(suffix.sag.table)


#Extract email suffix of external users
#
#grepl returns logical vector
indicator <- grepl('^(softwareag|itcampus|ids-scheer|terracotta).*', suffix)
suffix.external <- suffix[!indicator]
suffix.external.table <- sort(table(suffix.external), decreasing=TRUE)
suffix.external.df <- as.data.frame.table(suffix.external.table)


#In the LabCase database this is the relevant id - custom fields mapping:
#13: Customer
#14: Country
#15: Business Line

#Add customer info to projects.raw
customer.info <- droplevels(subset(customFields.raw, cf_id==13, 
                                   select=c(id, cf_value)))
names(customer.info)[names(customer.info)=='cf_value'] <- 'customer'
projects.raw <- merge(projects.raw, customer.info, by=c('id'), all.x=TRUE)

#Add country info to projects.raw
country.info <- droplevels(subset(customFields.raw, cf_id==14, 
                                  select=c(id, cf_value)))
names(country.info)[names(country.info)=='cf_value'] <- 'country'
projects.raw <- merge(projects.raw, country.info, by=c('id'), all.x=TRUE)


#Add business line info to projects.raw
businessline.info <- droplevels(subset(customFields.raw, cf_id==15,
                                       select=c(id,cf_value)))
names(businessline.info)[names(businessline.info)=='cf_value'] <- 'business_line'
projects.raw <- merge(projects.raw, businessline.info, by=c('id'), all.x=TRUE)

#Create new data frame for further analysis
projects <- data.frame(id = projects.raw$id,
                       identifier = projects.raw$identifier,
                       name = projects.raw$name,
                       description = projects.raw$description,
                       customers = projects.raw$customer,
                       countries = toupper(projects.raw$country),
                       departments = projects.raw$business_line,
                       created_on = projects.raw$created_on,
                       updated_on = projects.raw$updated_on,
                       project_size = projects.raw$project_size)




#Create project frequency table grouped by country
#
country.table <- sort(table(projects$countries,useNA='ifany'), decreasing=TRUE)
country.df <- as.data.frame.table(country.table)

#Create project frequency table grouped by department
#
department.table <- sort(table(projects$departments,useNA='ifany'), decreasing=TRUE)
department.df <- as.data.frame.table(department.table)

#Get number of of active projects of current quarter
#
numbOfActiveProjectsCurQuart <- length(projects$updated_on[year(projects$updated_on) == year(dateOfExtraction) & 
                                                             quarter(projects$updated_on) == quarter(dateOfExtraction)])

#Create project creation table grouped by year
#
year.table <- table(year(projects$created_on), useNA='ifany')
year.df <- as.data.frame.table(year.table)

#Create project creation table grouped by quarter for current year
#pcy: projects current year
#
pcy <- projects$created_on[year(projects$created_on) == year(dateOfExtraction)]
pcy <- as.factor(c(quarters(pcy),'Q2','Q3','Q4'))[1:length(pcy)]
quarter.table <- table(pcy)
quarter.df <- as.data.frame.table(quarter.table)

#Create project creation table for the last 7 days
#
#Construct interval for last 7 days
weeklyInterval <- new_interval(dateOfExtraction - days(6), dateOfExtraction)
projectsCreatedInCurrentWeek <- projects$created_on[projects$created_on %within% weeklyInterval]
projectsCreatedInCurrentWeek <- format(projectsCreatedInCurrentWeek,'%d-%b-%Y')
#Construct proxy week so that all last 7 days will be included as levels in final factor
factorWeek <- NULL
for(i in 6:0){
  factorWeek <- c(factorWeek,format(dateOfExtraction - days(i),'%d-%b-%Y'))
}
projectsCreatedInCurrentWeek <- factor(c(projectsCreatedInCurrentWeek, factorWeek), 
                                       levels=factorWeek[1:7])[1:length(projectsCreatedInCurrentWeek)]
weeklyProjCreation.table <- table(projectsCreatedInCurrentWeek)
weeklyProjCreation.df <- as.data.frame.table(weeklyProjCreation.table)


##Create project activity table grouped by the last 4 quarters
#
#
#Create interval for the last 12 months
interval <- new_interval(dateOfExtraction - 31556952, dateOfExtraction)
activeProjects <- projects$updated_on[projects$updated_on %within% interval]
activeProjects <- interaction(quarters(activeProjects), year(activeProjects), drop=TRUE)
#cut first factor level away so that only 4 quarters remain
activeProjects <- factor(activeProjects[activeProjects != levels(activeProjects)[1]])
activeProjects.df <- as.data.frame.table(table(activeProjects))


#Dump all necessary data
#
dump(c('dateOfExtraction', 
       'users', 
       'projects', 
       'suffix.sag', 
       'suffix.external',
       'suffix.sag.df', 
       'suffix.external.df', 
       'country.df', 
       'department.df', 
       'numbOfActiveProjectsCurQuart', 
       'year.df', 
       'quarter.df', 
       'activeProjects', 
       'weeklyProjCreation.df', 
       'activeProjects.df'), 
     file='./processedData/processedDataDump.R')
