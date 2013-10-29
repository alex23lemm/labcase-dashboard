
# Author: Alex Lemm
#
# Purpose: The process.R script loads the previously extracted raw data from the
# LC database into memory and processes it. Its major task is to construct
# tiny data frames based on the raw data which will sourced into the Shiny
# application (server.R) later.
#
# process.data.R consists of four mayor parts:
#  1. Load raw data into memory
#  2. Pre-processing
#  3. Processing
#  4. Save the processed data
#
# Google's R Style Guide (http://bit.ly/12ZBd1J) was applied while writing 
# the code below.


ConstructSAGEmailSuffixRegex <- function(vec) {
  # Constructs a regular expression by concatenating itmes of a character
  # vector. This specific regex is later used to extract email suffixes
  # of SAG users and external users.
  #
  # Args:
  #   list: character vector containing the beginnings of allowed SAG email 
  #         suffixes
  # 
  # Returns:
  #   Regular expression 
  regex <- '^('
  for (i in 1:(length(vec)-1)) {
    regex <- paste0(regex, vec[i], '|')
  }
  regex <- paste0(regex, vec[length(vec)])
  regex <- paste0(regex, ').*')
  return (regex)
}


#-------------------------------------------------------------------------------
# 1. Load raw data into memory

projects <- dget(file="./rawData/projectsRaw.R")
users <- dget(file="./rawData/usersRaw.R")
issues <- dget(file="./rawData/issuesRaw.R")
repos <- dget(file="./rawData/reposRaw.R")
custom.fields <- dget(file="./rawData/customFields.R")
date.of.extraction <- dget("./rawData/dateOfExtraction.R")


#-------------------------------------------------------------------------------
# 2. Pre-processing
#  Create 4 new data frames by extracting data from custom.fields data frame
#  Merge projects data frame with these 4 new data frames, the issues data frame
#  and the repos data frame
#  Convert mail column in users data frame to lower-case


# Extract project id and template classifier from custom.fields data frame
#   id:       project id
#   cf_value: template classifier (boolean)
# In the LC database this is the relevant id - custom fields mapping:
#   12: Use as template
# droplevels() is used to drop unused levels from the cf_value column
template.info <- droplevels(subset(custom.fields, cf_id == 12,
                            select=c(id, cf_value)))
# Rename 'cf_value' column to 'template'
names(template.info)[names(template.info) == 'cf_value'] <- 'template'
# Add template column from template.info data frame to projects data frame.
# In SQL terminology parameter all.x=TRUE gives a left outer join: non matching
# cases of x are appended to the result with NA filled in the corresponding 
# column of y
projects <- merge(projects, template.info, by=('id'), all.x=TRUE)


# Extract project id and customer information from custom.fields data frame
#  id:       project id
#  cf_value: customer name
# In the LC database this is the relevant id - custom fields mapping:
#   13: Customer
customer.info <- droplevels(subset(custom.fields, cf_id == 13, 
                                   select=c(id, cf_value)))
# Rename 'cf_value' column to 'customer'
names(customer.info)[names(customer.info) == 'cf_value'] <- 'customer'
# Add customer column from customer.info data frame to projects data frame.
projects <- merge(projects, customer.info, by=c('id'), all.x=TRUE)


# Extract project id and country information from custom.fields data frame
#  id:       project id
#  cf_value: country name
# In the LC database this is the relevant id - custom fields mapping:
#   14: Country
country.info <- droplevels(subset(custom.fields, cf_id == 14, 
                                  select=c(id, cf_value)))
# Rename 'cf_value' column to 'country'
names(country.info)[names(country.info)=='cf_value'] <- 'country'
# Add country column from country.info data frame to projects data frame.
projects <- merge(projects, country.info, by=c('id'), all.x=TRUE)


# Extract project id and business line information from custom.fields data frame
#  id:       project id
#  cf_value: business line
# In the LC database this is the relevant id - custom fields mapping:
#   15: Business line
businessline.info <- droplevels(subset(custom.fields, cf_id == 15,
                                       select=c(id, cf_value)))
# Rename 'cf_value' column to 'business_line'
names(businessline.info)[names(businessline.info) == 'cf_value'] <- 'business_line'
# Add business line column from businessline.info data frame to projects
# data frame.
projects <- merge(projects, businessline.info, by=c('id'), all.x=TRUE)


# Add issue_count column from issues data frame to projects data frame
projects <- merge(projects, issues,  by.x='id', by.y='project_id', all.x=TRUE)
projects$issue_count[is.na(projects$issue_count)] <- 0


# Add diskspace column from repos data frame to projects data frame
projects <- merge(projects, repos, by.x='id', by.y='project_id', all.x=TRUE)
projects$repo_diskspace[is.na(projects$repo_diskspace)] <- 0
# Transfrom bytes into MB
projects <- transform(projects, repo_diskspace=repo_diskspace/1024/1024)


# Convert entries in mail column to lower-case
users$mail <- tolower(users$mail)


#-------------------------------------------------------------------------------
# 3. Processing
#  Generate smaller data frames which serve as the input for the Shiny
#  application


# Create interger vector which includes dimension of users data frame
users.dim <- dim(users)


# Subset projects data frame
projects.df <- subset(projects, select=c(identifier, project_size, 
                                         repo_diskspace, member_count, 
                                         issue_count))


# Extract email suffix from mail column from users data frame
# regexec returns the indices for parenthesized sub-expression 
regm.suffix.list <- regmatches(users$mail, regexec('.*@(.*)', users$mail))
# Extract the email suffix for each entry
suffix <- sapply(regm.suffix.list, function(x)x[2])


# Extract email suffix of SAG users from suffix vector
suffix.sag <- regmatches(suffix, 
                         regexpr(ConstructSAGEmailSuffixRegex(config$sagEmailSuffixes),
                                 suffix))
suffix.sag.df <- as.data.frame.table(sort(table(suffix.sag), decreasing=TRUE))


# Extract email suffix of external users from suffix vector
# grepl returns logical vector
suffix.external <- suffix[!grepl(ConstructSAGEmailSuffixRegex(config$sagEmailSuffixes),
                                 suffix)]

suffix.external.df <- as.data.frame.table(sort(table(suffix.external), 
                                               decreasing=TRUE))


# Create project frequency table grouped by country
proj.created.by.country.df <- as.data.frame.table(sort(table(projects$country,
                                                             useNA='ifany'), 
                                                       decreasing=TRUE))


# Create project frequency table grouped by department
proj.created.by.department.df <- as.data.frame.table(sort(table(projects$business_line,
                                                  useNA='ifany'), decreasing=TRUE))


# Create project creation table grouped by year
proj.created.by.year.df <- as.data.frame.table(table(year(projects$created_on), 
                                                     useNA='ifany'))


# Create project creation table grouped by quarter for current year
# Extract projects created in current year based on data in created_on column
proj.of.current.year <- projects$created_on[year(projects$created_on) == year(date.of.extraction)]
# Encode proj.of.current.year as factor and include possible unused quarters
# as factor levels (e.g. when data is read in January). Exclude unnecessary data
# which was concatenated to retrieve factor levels
proj.of.current.year <- as.factor(c(quarters(proj.of.current.year),
                   'Q2', 'Q3', 'Q4'))[1:length(proj.of.current.year)]
proj.created.by.quarter.df <- as.data.frame.table(table(proj.of.current.year))


# Create project creation table for the last 7 days
# Construct interval for last 7 days
last.7.days.interval <- new_interval(date.of.extraction - days(6), date.of.extraction)
# Extract projects which were created in last 7 days
proj.created.in.last.7.days <- projects$created_on[projects$created_on %within% last.7.days.interval]
# Convert POSIXct format into '02-Jan-2013'
proj.created.in.last.7.days <- format(proj.created.in.last.7.days, '%d-%b-%Y')
# Construct proxy week so that all of the 7 last days will be included as levels
# in final factor
factor.week <- NULL
for (i in 6:0) {
  factor.week <- c(factor.week, format(date.of.extraction - days(i),'%d-%b-%Y'))
}
# Encode proj.created.in.last.7.days as factor and include possible unused 
# days as factor levels. Exclude unnecessary data which was concatenated to 
# retrieve factor levels
proj.created.in.last.7.days <- factor(c(proj.created.in.last.7.days, factor.week), 
                                       levels=factor.week[1:7])[1:length(proj.created.in.last.7.days)]
proj.created.in.last.7.days.df <- as.data.frame.table(table(proj.created.in.last.7.days))


# Create project template usage distribution table
templates <- droplevels(subset(projects, template == 1, select=c(id, name)))
counted.template.instances <- count(projects, vars ='template_project_id')
template.usage.df <- merge(templates, counted.template.instances, 
                          by.x='id', by.y='template_project_id', all.x=TRUE)
# Replace NA values with 0 for those templates which were not used yet
template.usage.df$freq[is.na(template.usage.df$freq)] <- 0
template.usage.df$id <- NULL


# Create disk pace usage distribution data frame for projects which consume
# more than 1000 MB of disk space (sum of Alfresco and repos)
diskusage.per.project.df <- droplevels(subset(projects, 
                                              repo_diskspace + project_size > 1000,
                                              select=c('identifier', 'repo_diskspace', 
                                                       'project_size')))
# Add total_diskspace column
diskusage.per.project.df <- transform(diskusage.per.project.df, 
                                      total_diskspace=repo_diskspace + project_size)
# reorder identifer column based on total_diskspace values (reorder() changes 
# the order of levels in a factor based on values in the data). This step is 
# necessary for appropriate ordering in stacked bar chart later
diskusage.per.project.df$identifier <- reorder(diskusage.per.project.df$identifier,
                                               diskusage.per.project.df$total_diskspace)
# transform from wide to long data as a prerequiste for stacked bar chart 
# plotting
diskusage.per.project.df <- melt(diskusage.per.project.df, id.vars='identifier',
                                 measure.vars=c('project_size', 
                                                'repo_diskspace'),
                                 variable.name='origin', value.name='diskspace')
# Rename entries in origin column
diskusage.per.project.df$origin <- revalue(diskusage.per.project.df$origin, 
                                           c('project_size' = 'Alfresco', 
                                             'repo_diskspace' = 'Repository'))
diskusage.per.project.df <- transform(diskusage.per.project.df, 
                                      diskspace = round(diskspace, digits=0))

#-------------------------------------------------------------------------------
#  4. Save the processed data

dump(c('date.of.extraction',
       'users.dim', 
       'projects.df',  
       'suffix.sag.df', 
       'suffix.external.df', 
       'proj.created.by.country.df', 
       'proj.created.by.department.df', 
       'proj.created.by.year.df', 
       'proj.created.by.quarter.df',
       'proj.created.in.last.7.days.df',
       'template.usage.df',
       'diskusage.per.project.df'),      
     file='./processedData/processedDataDump.R')
