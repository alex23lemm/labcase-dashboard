
# Author: Alex Lemm
#
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
# For plotting purposes ggplot2 is used exclusively. 



library(shiny)
library(ggplot2)
library(RColorBrewer)
library(lubridate)



shinyServer(function(input,output){
  
  # Source data for user session. Objects in porcessedDataDump.R are defined in 
  # each user session.
  source('./processedData/processedDataDump.R')
  
  
  output$date <- renderText({
    paste('Data as of', date.of.extraction, sep=" ")
  })
  
  
  output$numbOfProjectsOverall <- renderText({
    paste('Total number of projects:', dim(projects.df)[1], sep=" ")
  })
  
   
  output$numbOfUsers <- renderText({
    paste('Total number of users:', dim.users[1], sep=" ")
  })
  
  
  output$numbOfSAGUsers <- renderText({
    paste('Number of SAG users:', sum(suffix.sag.df$Freq), sep=" ")
  })
  
  
  output$numbOfExternalUsers <- renderText({
    paste('Number of external users:', sum(suffix.external.df$Freq), sep=" ")
  })
  
  
  output$summaryUsersPerProject <- renderPrint({
    summary(projects.df$member_count, digits=3)
  })
  
  
  output$numbOfIssues <- renderText({
    paste('Total number of Issues created in projects:', 
          sum(projects.df$issue_count, na.rm=TRUE), sep=" ")
  })
  
  
  output$summaryIssuesPerProject <- renderPrint({
    summary(projects.df$issue_count, digits=2)
  })
  
  
  output$distributionCaption <- renderText({
    paste('Departments/Countries with',
          input$numbOfProjects, 'or more LabCase projects', sep=' ')
  })
  
  
  # Create country ~ projects barchart
  output$countryPlot <- renderPlot({
    
    # Subset according to reactive value and exclude NAs
    proj.created.by.country.df <- subset(proj.created.by.country.df, 
                                         Freq >= input$numbOfProjects )#& Var1 != '<NA>')
    # Do a reorder so that the order in the barchart is flipped
    proj.created.by.country.df <- transform(proj.created.by.country.df,
                                            Var1 = reorder(Var1,Freq))
    
    g <- ggplot(proj.created.by.country.df, aes(x=Var1, y=Freq)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.1, size=4) +
      ylim(0, max(proj.created.by.country.df$Freq) * 1.02) +
      xlab('Countries') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=10)) +
      coord_flip() + 
      ggtitle('Number of LabCase projects per country')
    print(g)
  })
  
  
  # Create department ~ projects barchart
  output$departmentPlot <- renderPlot({
    
    # Subset according to reactive value and exclude NAs
    proj.created.by.department.df <- subset(proj.created.by.department.df,
                                            Freq >= input$numbOfProjects)# & Var1 != '<NA>')
    # Do a reorder so that the order in the barchart is flipped
    proj.created.by.department.df <- transform(proj.created.by.department.df,
                                               Var1 = reorder(Var1, Freq))
    
    g <- ggplot(proj.created.by.department.df, aes(x=Var1, y=Freq)) +
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.1, color='black', size=4) +
      ylim(0, max(proj.created.by.department.df$Freq) * 1.02) +
      xlab('Departments') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=10)) +
      coord_flip() + 
      ggtitle('Number of LabCase projects per department')
    print(g)
  })
  
  
  # Create project growth line graph for last 7 days
  output$projectWeekProgessPlot <- renderPlot({
    
    g <- ggplot(proj.created.in.last.7.days.df, 
                aes(x=proj.created.in.last.7.days, y=Freq, group=1)) +
      geom_line(colour='#3182BD', size=1) + 
      geom_point(size=7, shape=21, fill='white') +
      geom_text(aes(label=Freq), size=4) +
      ylim(0, max(proj.created.in.last.7.days.df$Freq) * 1.02) +
      xlab('Day of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title  =element_text(size=14),
            axis.text=element_text(size=12),
            axis.text.x = element_text(angle=30, hjust=1, vjust=1)) +
      ggtitle(paste0(year(date.of.extraction), ': ',
                     'Number of created projects\n in the last 7 days per day (', 
                      sum(proj.created.in.last.7.days.df$Freq),
                     ' overall)'))
    print(g)
    
  })
  
  
  # Create project growth plot grouped by years
  output$projectProgressPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    proj.created.by.year.df <- proj.created.by.year.df[order(proj.created.by.year.df$Var1),]
    
    g <- ggplot(proj.created.by.year.df, aes(x=Var1, y=Freq)) + 
      geom_bar(width=.5, stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), vjust=-0.3, size=4) +
      ylim(0, max(proj.created.by.year.df$Freq) * 1.03) +
      xlab('Year of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)), 
            axis.title = element_text(size=14), 
            axis.text = element_text(size=12)) +
      ggtitle('Number of created projects\n per year')
    print(g)
  })
  
  
  # Create project growth plot for current year grouped by quarters
  output$projectQuarterProgressPlot <- renderPlot({
    
    g <- ggplot(proj.created.by.quarter.df, aes(x=proj.of.current.year, y=Freq)) + 
      geom_bar(width=.5, stat='identity', fill='#3182BD') +
      geom_text(aes(label = Freq), vjust=-0.3, size=4) +
      ylim(0, max(proj.created.by.quarter.df$Freq) * 1.03) +
      xlab('Quarter of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=12)) +
      ggtitle(paste0(year(date.of.extraction), ': ',
                     'Number of created projects\n per quarter'))
    print(g)
   
  })
   
  
  # Create SAG user distribution plot
  output$userSAGPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    suffix.sag.df <- transform(suffix.sag.df,
                               suffix.sag = reorder(suffix.sag, Freq))
    
    g <- ggplot(suffix.sag.df, aes(x=suffix.sag, y=Freq)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.2, color='black', size=4) +
      ylim(0, max(suffix.sag.df$Freq) * 1.02) +
      xlab('SAG unit') + 
      ylab('Number of users') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=11)) +
      coord_flip() + 
      ggtitle('Number of active SAG users per unit')
    print(g)
    
  })
  
  
  # Create external user distribution plot
  output$userExternalPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    suffix.external.df <- subset(suffix.external.df, Freq > 2)
    suffix.external.df <- transform(suffix.external.df,
                                    suffix.external = reorder(suffix.external, Freq))
    
    g <- ggplot(suffix.external.df, aes(x=suffix.external, y=Freq)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.2, color='black', size=3) +
      xlab('Customers') +
      ylab('Number of users') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=11)) +
      coord_flip() + 
      ggtitle('Customers with more than 2 active users')
    print(g)
  })
  
  
  # Total Alfresco disk space usage
  output$totalDiskSpaceUsage <- renderText({
    paste('Total Alfresco disk space usage: ', 
          round(sum(projects.df$project_size, na.rm=TRUE)/1000), 'GB', sep='')
  })
    
  
  # Alfresco disk space usage summary
  output$diskSpaceUsageSummary <- renderPrint({
    summary(projects.df$project_size, na.rm=T)
  })
    
  
  # Create disk space usage plot
  output$diskspaceUsagePlot <- renderPlot({
    
    #Subset projects
    usage <- subset(projects.df, project_size > 1000, 
                    select=c(identifier, project_size))
    #Reorder so that order in the barchart is flipped
    usage <- transform(usage, identifier = reorder(identifier, project_size))
    
    g <- ggplot(usage, aes(x=identifier, y=project_size)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=project_size), hjust=-0.1, size=4) +
      ylim(0, max(usage$project_size) * 1.02) +
      xlab('Project identifier') + 
      ylab('Alfresco disk space usage (MB)') +
      coord_flip() + 
      ggtitle(paste('Projects consuming more than 1GB of Alfresco disk space ',
                    '(', dim(usage)[1], ' overall)', sep='')) + 
      theme(plot.title = element_text(size=rel(1.3)), 
            axis.title = element_text(size=14),
            axis.text = element_text(size=11))
    print(g)
  })
  
  
  # Number of available templates
  output$numbOfTemplates <- renderText({
    paste('Number of available templates: ', dim(template.usage.df)[1], sep='')
  })
  
  
  # Create template usage plot
  output$templateUsagePlot <- renderPlot({
    
    #Do a reorder so that the order in the barchart is flipped
    template.usage.df <- transform(template.usage.df, name=reorder(name, freq))
    
    g <- ggplot(template.usage.df, aes(x=name, y=freq)) +
      geom_bar(stat='identity', fill='#3182BD') + 
      geom_text(aes(label=freq), hjust=-0.1, size=4) +
      ylim(0, max(template.usage.df$freq) * 1.02) +
      xlab('Template name') + 
      ylab('Number of instances') + 
      coord_flip() + 
      ggtitle('Number of instantiated projects per template') +
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=11))
    print(g)
  })
})