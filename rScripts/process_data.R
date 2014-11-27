
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

# Define utility functions -----------------------------------------------------

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


calculateActivity <- function(last.updates, date) {
  # Calculates the activity for a number of observations within predefined time 
  # intervals. For the following time intervals activity is calculated:
  #   - today
  #   - last 7 days
  #   - last 14 days
  #   - last 30 days
  #   - last 60 days
  #   - last 12 months
  #
  # Args:
  #   last.updates: POSIXct vector containing the latest date of activity 
  #                 for each observation. NAs will be ignored
  #    date: POSIXct value representing the upper bound for each interval
  # 
  # Returns:
  #   Data frame containing the summarized activity information of the 
  #   observations for each predefined time interval
  activity.df <- data.frame(interval.type = character(), 
                            active.obs = character(), stringsAsFactors = FALSE)
  
  last.updates <- last.updates[!is.na(last.updates)]
  
  tmp.date <- date
  hour(tmp.date) <- 0
  minute(tmp.date) <- 0
  second(tmp.date) <- 0
  
  activity.df[1 , ] <- c('today.interval', 
                         sum(last.updates %within% interval(tmp.date, date)))
  activity.df <- rbind(activity.df, 
                       c('7.day.interval', 
                         sum(last.updates %within% interval(date - ddays(6), 
                                                            date))))
  activity.df <- rbind(activity.df,
                       c('14.days.interval',
                         sum(last.updates %within% interval(date - ddays(13), 
                                                            date))))
  activity.df <- rbind(activity.df, 
                       c('30.day.interval', 
                         sum(last.updates %within% interval(date - ddays(29), 
                                                            date))))
  activity.df <- rbind(activity.df, 
                       c('60.day.interval', 
                         sum(last.updates %within% interval(date - ddays(59), 
                                                            date))))
  activity.df <- rbind(activity.df, 
                       c('12.months.interval', 
                         sum(last.updates %within% interval(date - ddays(364), 
                                                            date))))
  
  return (activity.df)
}




# 1. Load raw data into memory -------------------------------------------------
 
projects <- dget(file="./rawData/projectsRaw.R")
users <- dget(file="./rawData/usersRaw.R")
issues <- dget(file="./rawData/issuesRaw.R")
repos <- dget(file="./rawData/reposRaw.R")
custom.fields <- dget(file="./rawData/customFields.R")
date.of.extraction <- dget("./rawData/dateOfExtraction.R")



# 2. Pre-processing ------------------------------------------------------------

#  Create 4 new data frames by extracting data from custom.fields data frame
#  Merge projects data frame with these 4 new data frames, the issues data frame
#  and the repos data frame
#  Convert mail column in users data frame to lower-case

# Extract project id and template classifier from custom.fields data frame
#   id:       project id
#   cf_value: template classifier (boolean)
# In the LC database this is the relevant id - custom fields mapping:
#   12: Use as template
template.info <- filter(custom.fields, cf_id ==12) %>%
  select(id, cf_value) %>%
  droplevels
# Rename 'cf_value' column to 'template'
template.info <- rename(template.info, template = cf_value)
# Add template column from template.info data frame to projects data frame.
projects <- left_join(projects, template.info, by = 'id')


# Extract project id and customer information from custom.fields data frame
#  id:       project id
#  cf_value: customer name
# In the LC database this is the relevant id - custom fields mapping:
#   13: Customer
customer.info <- filter(custom.fields, cf_id == 13) %>%
  select(id, cf_value) %>%
  droplevels
# Rename 'cf_value' column to 'customer'
customer.info <- rename(customer.info, customer = cf_value)
# Add customer column from customer.info data frame to projects data frame.
projects <- left_join(projects, customer.info, by = 'id')


# Extract project id and country information from custom.fields data frame
#  id:       project id
#  cf_value: country name
# In the LC database this is the relevant id - custom fields mapping:
#   14: Country
country.info <- filter(custom.fields, cf_id == 14) %>%
  select(id, cf_value) %>%
  droplevels
# Rename 'cf_value' column to 'country'
country.info <- rename(country.info, country = cf_value)
# Add country column from country.info data frame to projects data frame.
projects <- left_join(projects, country.info, by = 'id')


# Extract project id and business line information from custom.fields data frame
#  id:       project id
#  cf_value: business line
# In the LC database this is the relevant id - custom fields mapping:
#   15: Business line
businessline.info <- filter(custom.fields, cf_id == 15) %>%
  select(id, cf_value) %>%
  droplevels
# Rename 'cf_value' column to 'business_line'
businessline.info <- rename(businessline.info, business_line = cf_value)
# Add business line column from businessline.info data frame to projects
# data frame.
projects <- left_join(projects, businessline.info, by = 'id')


# Add issue_count column from issues data frame to projects data frame
projects <- merge(projects, issues, by.x = 'id', by.y = 'project_id', 
                  all.x = TRUE)
projects$issue_count[is.na(projects$issue_count)] <- 0


# Add diskspace column from repos data frame to projects data frame
projects <- merge(projects, repos, by.x = 'id', by.y = 'project_id', 
                  all.x = TRUE)
projects$repo_diskspace[is.na(projects$repo_diskspace)] <- 0
# Transfrom bytes into MB
projects <- transform(projects, repo_diskspace = repo_diskspace/1024/1024)

# Replace NAs with 0s in project_size column
projects$project_size[is.na(projects$project_size)] <-0


# Convert entries in mail column to lower-case
users$mail <- tolower(users$mail)



# 3. Processing ----------------------------------------------------------------

#  Generate smaller data frames which serve as the input for the Shiny
#  application

# Create interger vector which includes dimension of users data frame
users.dim <- dim(users)


# Subset projects data frame
projects.df <- select(projects, 
                      identifier, created_on, project_size, country,
                      business_line, repo_diskspace, member_count, issue_count,
                      last_updated_on)
              

# Extract email suffix from mail column from users data frame
# regexec returns the indices for parenthesized sub-expression 
regm.suffix.list <- regmatches(users$mail, regexec('.*@(.*)', users$mail))
# Extract the email suffix for each entry
suffix <- sapply(regm.suffix.list, function(x)x[2])


# Extract email suffix of SAG users from suffix vector
suffix.sag <- regmatches(suffix, 
                         regexpr(ConstructSAGEmailSuffixRegex(config$sagEmailSuffixes),
                                 suffix))
suffix.sag.df <- as.data.frame.table(sort(table(suffix.sag), decreasing = TRUE))


# Extract email suffix of external users from suffix vector
# grepl returns logical vector
suffix.external <- suffix[!grepl(ConstructSAGEmailSuffixRegex(config$sagEmailSuffixes),
                                 suffix)]

suffix.external.df <- as.data.frame.table(sort(table(suffix.external), 
                                               decreasing = TRUE))


# Calculate user activity
user.activity.df <- calculateActivity(users$last_login_on, date.of.extraction)


# Extract list of departments ordered by frequency of created projects
departments.vec <- as.character(as.data.frame.table(sort(table(projects.df$business_line,
                                                  useNA = 'ifany'), 
                                                         decreasing=TRUE))$Var1)


# Extract list of countries ordered by freqency of created projects
countries.vec <- as.character(as.data.frame.table(sort(table(projects.df$country,
                                                              useNA = 'ifany'), 
                                                        decreasing = TRUE))$Var1)


# Create project creation table grouped by year
proj.created.by.year.df <- as.data.frame.table(table(year(projects$created_on), 
                                                     useNA = 'ifany'))


# Create project creation table grouped by quarter for current year
# Extract projects created in current year based on data in created_on column
proj.of.current.year <- projects$created_on[year(projects$created_on) == year(date.of.extraction)]

                         
# Encode proj.of.current.year as factor and include possible unused quarters
# as factor levels (e.g. when data is read in January or when no project has 
# been created so far in current year). Exclude unnecessary data which was 
# concatenated to retrieve factor levels
proj.of.current.year <- factor(c(quarter(proj.of.current.year),
                   1, 2, 3, 4))[0:length(proj.of.current.year)]
proj.of.current.year <- mapvalues(proj.of.current.year,
                                 c(1, 2, 3, 4), c('Q1', 'Q2', 'Q3', 'Q4'))

proj.created.by.quarter.df <- as.data.frame.table(table(proj.of.current.year))



# Create project creation table and project creation data frame for the last 7 
# days
# Construct interval for last 7 days
last.7.days.interval <- new_interval(date.of.extraction - days(6), 
                                     date.of.extraction)

# Extract projects which were created in last 7 days
proj.created.in.last.7.days.df <- filter(projects, 
                                         created_on %within% last.7.days.interval) %>%
  select(name, created_on, member_count, customer, business_line, country) %>%
  droplevels
  

# Construct proxy week so that all of the 7 last days will be included as levels
# in final factor
factor.week <- NULL
for (i in 6:0) {
  factor.week <- c(factor.week, format(date.of.extraction - days(i),'%d-%b'))
}
# Encode proj.created.in.last.7.days.vec as factor and include possible unused 
# days as factor levels. Exclude unnecessary data which was concatenated to 
# retrieve factor levels
# Convert POSIXct format into '02-Jan-2013'
proj.created.in.last.7.days.vec <- factor(c(format(proj.created.in.last.7.days.df$created_on,
                                                   '%d-%b'), factor.week), 
                                          levels = factor.week[1:7])[0:length(proj.created.in.last.7.days.df$created_on)]
proj.created.in.last.7.days.vec <- as.data.frame.table(table(proj.created.in.last.7.days.vec))
proj.created.in.last.7.days.vec <- rename(proj.created.in.last.7.days.vec, 
                                          Date = proj.created.in.last.7.days.vec)

# Calculate project activity
proj.activity.df <- calculateActivity(projects.df$last_updated_on, 
                                      date.of.extraction)
proj.inactive.vec <- projects.df$last_updated_on[!is.na(projects.df$last_updated_on)]
proj.inactive.vec <- sum(proj.inactive.vec < date.of.extraction - ddays(364*2))


# Create project template usage distribution table
templates <- filter(projects, template == 1) %>%
  select(id, name) %>%
  droplevels
counted.template.instances <- plyr::count(projects, vars ='template_project_id')
template.usage.df <- merge(templates, counted.template.instances, 
                          by.x = 'id', by.y = 'template_project_id', all.x = TRUE)
# Replace NA values with 0 for those templates which were not used yet
template.usage.df$freq[is.na(template.usage.df$freq)] <- 0
template.usage.df$id <- NULL


# Create disk pace usage distribution data frame for projects which consume
# more than 1000 MB of disk space (sum of Alfresco and repos)
diskusage.per.project.df <- filter(projects, 
                                   repo_diskspace + project_size > 1000) %>%
  select(identifier, repo_diskspace, project_size) %>%
  droplevels

# Add total_diskspace column
diskusage.per.project.df <- transform(diskusage.per.project.df, 
                                      total_diskspace = repo_diskspace + project_size)
# reorder identifer column based on total_diskspace values (reorder() changes 
# the order of levels in a factor based on values in the data). This step is 
# necessary for appropriate ordering in stacked bar chart later
diskusage.per.project.df$identifier <- reorder(diskusage.per.project.df$identifier,
                                               diskusage.per.project.df$total_diskspace)
# transform from wide to long data as a prerequiste for stacked bar chart 
# plotting
diskusage.per.project.df <- melt(diskusage.per.project.df, 
                                 id.vars = 'identifier',
                                 measure.vars = c('project_size', 
                                                  'repo_diskspace'),
                                 variable.name = 'origin', 
                                 value.name ='diskspace')
# Rename entries in origin column
diskusage.per.project.df$origin <- revalue(diskusage.per.project.df$origin, 
                                           c('project_size' = 'Alfresco', 
                                             'repo_diskspace' = 'Repository'))
diskusage.per.project.df <- transform(diskusage.per.project.df, 
                                      diskspace = round(diskspace, digits = 0))



# 4. Save the processed data----------------------------------------------------

dump(c('date.of.extraction',
       'users.dim', 
       'projects.df',
       'user.activity.df',
       'suffix.sag.df', 
       'suffix.external.df',
       'departments.vec',
       'countries.vec',
       'proj.created.by.year.df', 
       'proj.created.by.quarter.df',
       'proj.created.in.last.7.days.vec',
       'proj.created.in.last.7.days.df',
       'proj.activity.df',
       'proj.inactive.vec',
       'template.usage.df',
       'diskusage.per.project.df'),      
     file='./processedData/processedDataDump.R')
