
# Purpose: server.R defines the server logic for the Shiny app 'LabCase
# Dashboard'. processedDataDump.R is sourced within the function which is passed
# to shinyServer() to make the data available for each separate user session.
#
# processedDataDump.R gets updated regularly by a Cronjob or Scheduled Job (
# depending on your OS). Therefore sourcing for that file needs to take place
# inside shinyServer(). Placing it outside would only load it once, when Shiny
# starts. In that case the objects in the file would be shared across all 
# sessions.
#
# For plotting purposes rCharts is used exclusively. 



library(shiny)
library(rCharts)
library(lubridate)


shinyServer(function(input,output){
  
  # Source data for user session. Objects in porcessedDataDump.R are defined in 
  # each user session.
  source('./processedData/processedDataDump.R')
  
  
  output$date <- renderText({
    paste0('(Data as of ', date.of.extraction, ')')
  })
  
  
  output$numbOfProjectsOverall <- renderText({
    dim(projects.df)[1]
  })
  
   
  output$numbOfUsers <- renderText({
    users.dim[1]
  })
  
  
  output$numbOfSAGUsers <- renderText({
    sum(suffix.sag.df$Freq)
  })
  
  
  output$numbOfExternalUsers <- renderText({
    sum(suffix.external.df$Freq)
  })
  
  
  output$userActivitylast7Days <- renderText({
    user.activity.df$active.obs[user.activity.df$interval.type == '7.day.interval']
  })
  
  output$userActitvitylast14Days <- renderText({
    user.activity.df$active.obs[user.activity.df$interval.type == '14.days.interval']
  })
  
  output$userActivitylast30Days <- renderText({
    user.activity.df$active.obs[user.activity.df$interval.type == '30.day.interval']
  })
  
  output$userActivitylast60Days <- renderText({
    user.activity.df$active.obs[user.activity.df$interval.type == '60.day.interval']
  })
  
  output$userActivitylast12Months <- renderText({
    user.activity.df$active.obs[user.activity.df$interval.type == '12.months.interval']
  })
  
  
  output$summaryUsersPerProject <- renderPrint({
    summary(projects.df$member_count, digits=3)
  })
  
  
  output$numbOfIssues <- renderText({
    sum(projects.df$issue_count, na.rm=TRUE)
  })
  
  
  output$summaryIssuesPerProject <- renderPrint({
    summary(projects.df$issue_count, digits=2)
  })
  
  
  output$distributionCaption <- renderText({
    paste('Chosen Departments/Countries with',  input$numbOfProjects,
          'or more LabCase projects', sep=' ')
  })
  
  
  output$downloadReport <- downloadHandler('LabCase_Report.html',
                                           content = function(file) {
                                             file.copy('report/lc_report.html', 
                                                       file)
                                           }, 
                                           'text/html')
  
  # Used to populate selectInput element with server-generated content
  output$selectDepartment <- renderUI({
    selectInput('selectedDepartment', 'Choose department:', 
                c('All', departments.vec),
                selected = 'All')
  })
  
  # Used to populate selectInput element with server-generated content
  output$selectCountry <- renderUI({
    selectInput('selectedCountry', 'Choose country:', 
                c('All', countries.vec), 
                selected = 'All')
  })
  
  
  # Reactive expression for subsetting projects based on user input (department, 
  # country)
  selectedProjects <- reactive({
    
    # If missing input, return sourced projects.df to avoid error later in 
    # function. Due to the fact that the input list for the selectInput elements 
    # on the UI side is generated on the server side , this reactive expression 
    # has to cope with the 'delay' when reading the reactive values at the start
    # of each new user session (see also https://gist.github.com/wch/4211337)
    if(is.null(input$selectedDepartment)|| is.null(input$selectedCountry)) {
      return (subset(projects.df, select = c(country, business_line)))
    }
     
    if (input$selectedDepartment != 'All') {
      projects.df <- subset(projects.df,
                            business_line == input$selectedDepartment)
    }
    if (input$selectedCountry != 'All') {
      projects.df <- subset(projects.df,
                            country == input$selectedCountry)
    }
    subset(projects.df, select = c(country, business_line))
  })
  
  
  
  # Create department ~ projects barchart
  output$departmentPlot <- renderChart({
    
    projects <- selectedProjects()
    
    # Create project frequency table grouped by department
    proj.created.by.department.df <- as.data.frame.table(sort(table(projects$business_line,
                                                                    useNA = 'ifany'), 
                                                              decreasing=TRUE))
    
    # Subset according to reactive value and exclude NAs
    proj.created.by.department.df <- subset(proj.created.by.department.df,
                                          Freq >= input$numbOfProjects & Var1 != '<NA>')
    # If user input is NULL (max will return -Inf in this case) assign 0 to 
    # avoid empty plot later
    max <- suppressWarnings(max(proj.created.by.department.df$Freq))
    if (max == -Inf) {
      max <- 0
    }
    
    hc <- hPlot(Freq ~ Var1,
                data = proj.created.by.department.df,
                type = 'bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 30)
    # X-axis text lables added via categories again
    hc$xAxis(categories = proj.created.by.department.df$Var1,
             title = list(text = 'Departments'))
    hc$yAxis(title = list(text = 'Number of projects'),
             max = max)
    hc$title(text = '<span style="font-size:12px">Number of projects per department</span>')
    hc$plotOptions(bar = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'departmentPlot')
    hc
  })
  
  
  # Create country ~ projects barchart
  output$countryPlot <- renderChart({
    
    projects <- selectedProjects()
    
    # Create project frequency table grouped by country
    proj.created.by.country.df <- as.data.frame.table(sort(table(projects$country,
                                                                 useNA = 'ifany'), 
                                                           decreasing = TRUE))
    
    # Create project frequency table grouped by country
    proj.created.by.country.df <- subset(proj.created.by.country.df, 
                                         Freq >= input$numbOfProjects & Var1 != '<NA>')
    # If user input is NULL (max will return -Inf in this case) assign 0 to 
    # avoid empty plot later
    max <- suppressWarnings(max(proj.created.by.country.df$Freq))
    if (max == -Inf) {
      max <- 0
    }
    
    hc <- hPlot(Freq ~ Var1, 
                data=proj.created.by.country.df,
                type='bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 25, height = 550)
    # X-axis text labels added via categories again
    hc$xAxis(categories = proj.created.by.country.df$Var1,
             title = list(text = 'Countries'))
    hc$yAxis(title = list(text = 'Number of projects'),
             max = max)
    hc$title(text = '<span style="font-size:12px">Number of projects per country</span>')
    hc$plotOptions(bar = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'countryPlot')
    hc
  })
  
  
  # Create project growth line graph for last 7 days
  output$projectWeekProgessPlot <- renderChart({
    
    hc <- hPlot(Freq ~ Date, 
                data = proj.created.in.last.7.days.vec, type='line')
    # Add data labels to plot
    hc$plotOptions(line = list(dataLabels = list(enabled = T)))
    hc$title(text = paste0('<span style="font-size:12px">',
                           year(date.of.extraction), ': ',
                           'Number of created projects </span><br/>',
                           '<span style="font-size:12px">in the last 7 days per day (',
                           sum(proj.created.in.last.7.days.vec$Freq),
                           ' overall)</span>'))
    hc$subtitle(text = ' ')
    # X-axis text labels added via categories again
    hc$xAxis(categories = proj.created.in.last.7.days.vec$Date,
             title = list(text = 'Day of creation'),
             labels = list(rotation = -30, align = 'right'))
    hc$yAxis(title = list(text = 'Number of projects'),
             min = -0.2,
             startOnTick = FALSE
             )
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'projectWeekProgessPlot')
    hc
  })
  
  output$projectsOfLast7DaysTable <- renderDataTable({
  
    # Convert POSIXct format into '02-Jan-2013'
    proj.created.in.last.7.days.df$created_on <- format(proj.created.in.last.7.days.df$created_on,
                                                        '%d-%b')
    row.names(proj.created.in.last.7.days.df) <- NULL
    names(proj.created.in.last.7.days.df) <- gsub('_', ' ', 
                                                  names(proj.created.in.last.7.days.df))
    proj.created.in.last.7.days.df
  }, options = list(iDisplayLength = 5, sDom = 'ritp'))
  
  
  # Create project growth plot grouped by years
  output$projectProgressPlot <- renderChart({
    
    hc <- hPlot(Freq ~ Var1,
                data = proj.created.by.year.df,
                type = 'column')
    # X-axis text lables added via categories again 
    hc$xAxis(categories = proj.created.by.year.df$Var1,
             title = list(text = 'Year of creation'))
    hc$yAxis(title = list(text = 'Number of projects'))
    
    hc$title(text = paste0('<span style="font-size:12px">Number of created projects </span>',
                  '<br/><span style="font-size:12px">per year</span>'))
    hc$subtitle(text = ' ')
    hc$plotOptions(column = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'projectProgressPlot')
    hc
  })
  
  
  # Create project growth plot for current year grouped by quarters
  output$projectQuarterProgressPlot <- renderChart({
    
    hc <- hPlot(Freq ~ proj.of.current.year,
                data = proj.created.by.quarter.df,
                type = 'column')
    # X-axis text lables added via categories again 
    hc$xAxis(categories = proj.created.by.quarter.df$proj.of.current.year,
             title = list(text = 'Quarter of creation'))
    hc$yAxis(title = list(text = 'Number of projects'))
    
    hc$title(text = paste0('<span style="font-size:12px">',
                           year(date.of.extraction), 
                           ': ',
                           'Number of created projects </span><br/>',
                           '<span style="font-size:12px">per quarter</span>'))
    hc$subtitle(text = ' ')
    hc$plotOptions(column = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'projectQuarterProgressPlot')
    hc
  })
   
  
  # Create SAG user distribution plot
  output$userSAGPlot <- renderChart({
    
    max <- max(suffix.sag.df$Freq)
    
    hc <- hPlot(Freq ~ suffix.sag,
                data = suffix.sag.df,
                type = 'bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 25)
    hc$xAxis(categories = suffix.sag.df$suffix.sag,
             title = list(text = 'SAG unit'))
    hc$yAxis(title = list (text = 'Number of users'),
             max = max)
    hc$title(text = '<span style="font-size:12px">Number of active SAG users per unit</span>')
    hc$plotOptions(bar = list(dataLabels = list(enabled = TRUE)))
    hc$addParams(width = 466)
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'userSAGPlot')
    hc
  })
  
  
  # Create external user distribution plot
  output$userExternalPlot <- renderChart({
    
    suffix.external.df <- subset(suffix.external.df, Freq > 2)
    
    max <- max(suffix.external.df$Freq)
    
    hc <- hPlot(Freq ~ suffix.external,
                data = suffix.external.df,
                type = 'bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 25, height = 750)
    hc$xAxis(categories = suffix.external.df$suffix.external,
             title = list(text = 'Customers'))
    hc$yAxis(title = list(text = 'Number of users'),
             max = max)
    hc$title(text = '<span style="font-size:12px">Customers with more than 2 active users</span>')
    hc$plotOptions(bar = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'userExternalPlot')
    hc
  })
  
  # Total disk space usage
  output$totalDiskSpaceUsage <- renderText({
    paste(round(sum(projects.df$project_size, projects.df$repo_diskspace, 
                    na.rm=TRUE)/1024, digits=2), ' GB', sep='')
  })
  
  # Total Alfresco disk space usage
  output$totalAlfrescoDiskSpaceUsage <- renderText({
    paste(round(sum(projects.df$project_size, na.rm=TRUE)/1024, digits=2),
          ' GB', sep='')
  })
  
  # Total repository disk space usage
  output$totalRepoDiskSpaceUsage <- renderText({
    paste(round(sum(projects.df$repo_diskspace, na.rm=TRUE)/1024, digits=2), 
          ' GB', sep='')
  })
  
    
  # Alfresco disk space usage summary
  output$alfrescoSummary <- renderPrint({
    summary(projects.df$project_size, na.rm=TRUE)
  })
  
  # Repository disk space usage summary
  output$repositorySummary <- renderPrint({
    summary(projects.df$repo_diskspace, na.rm=TRUE)
  })
    
  
  # Create disk space usage plot
  output$diskspaceUsagePlot <- renderChart({
    
    # Reverse the order of levels in identifier factor for Highchart plotting
    diskusage.per.project.df <- transform(diskusage.per.project.df,
                                          identifier = factor(identifier, 
                                                              levels=rev(levels(identifier))))
                            
    hc <- hPlot(diskspace ~ identifier,
                data = diskusage.per.project.df,
                group = 'origin',
                type = 'bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 25, height = 900)
    hc$xAxis(categories = levels(diskusage.per.project.df$identifier),
             title = list(text = 'Project identifier'))
    hc$yAxis(title = list(text = 'Total disk space usage (MB)'))
    hc$title(text = paste0('<span style="font-size:12px">',
                           'Projects consuming more than 1 GB of total disk space ',
                           '(',
                           dim(diskusage.per.project.df)[1]/2,
                           ' overall)</span>'))
    hc$plotOptions(series = list(stacking = 'normal'))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'diskspaceUsagePlot')
    hc
  })
  
  
  # Number of available templates
  output$numbOfTemplates <- renderText({
    dim(template.usage.df)[1]
  })
  
  
  # Create template usage plot
  output$templateUsagePlot <- renderChart({
    
    # Reorder so that the order in the barchart is flipped
    # Reverse the order of levels in name factor for Highchart plotting
    template.usage.df <- transform(template.usage.df, 
                                   name = reorder(name, freq))
    template.usage.df <- transform(template.usage.df,
                                   name = factor(name, levels = rev(levels(name))))
    
    max <- max(template.usage.df$freq)
  
    hc <- hPlot(freq ~ name,
                data = template.usage.df,
                type = 'bar')
    # Add margin to the right to avoid data label cutting
    hc$chart(marginRight = 25)
    hc$xAxis(categories = levels(template.usage.df$name),
             title = list(text = 'Template name'))
    hc$yAxis(title = list(text = 'Number of instances'),
             max = max)
    hc$title(text = '<span style="font-size:12px">Number of instantiated projects per template</span>')
    hc$plotOptions(bar = list(dataLabels = list(enabled = TRUE)))
    # Set dom attribute otherwise chart will not appear on the web page
    hc$set(dom = 'templateUsagePlot')
    hc
  })
  
})