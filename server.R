library(shiny)
library(ggplot2)
library(RColorBrewer)
library(lubridate)


#Shiny server functionality
#
shinyServer(function(input,output){
  
  #Get necessary data
  #
  source('./processedData/processedDataDump.R')

  output$date <- renderText({
    paste('Data as of', dateOfExtraction, sep=" ")
  })
  
  output$numbOfProjectsOverall <- renderText({
    paste('Total number of projects:', dim(projects)[1], sep=" ")
  })
  
  output$numbOfActiveProjectsCurQuart <- renderText({
    paste('Number of active projects in', 
          quarters(dateOfExtraction), year(dateOfExtraction), ':', 
          numbOfActiveProjectsCurQuart, sep=" ")   
  })
  
  output$numbOfUsers <- renderText({
    paste('Total number of active users:', dim(users)[1], sep=" ")
  })
  
  output$numbOfSAGUsers <- renderText({
    paste('Number of SAG users:', length(suffix.sag), sep=" ")
  })
  
  output$numbOfExternalUsers <- renderText({
    paste('Number of external users:', length(suffix.external), sep=" ")
  })
  
 
  output$distributionCaption <- renderText({
    paste('Departments/Countries with',
          input$numbOfProjects,'or more LabCase projects', sep=' ')
  })
  
  # Create country ~ projects barchart
  #
  output$countryPlot <- renderPlot({
    
    # Subset according to reactive value and exclude NAs
    country.df <- subset(country.df, Freq >= input$numbOfProjects )#& Var1 != '<NA>')
    # Do a reorder so that the order in the barchart is flipped
    country.df <- transform(country.df, Var1 = reorder(Var1,Freq))
    
    g <- ggplot(country.df, aes(x=Var1, y=Freq)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.1, size=4) +
      ylim(0, max(country.df$Freq) * 1.02) +
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
  #
  output$departmentPlot <- renderPlot({
    
    #Subset according to reactive value and exclude NAs
    department.df <- subset(department.df,Freq >= input$numbOfProjects)# & Var1 != '<NA>')
    #Do a reorder so that the order in the barchart is flipped
    department.df <- transform(department.df,Var1 = reorder(Var1, Freq))
    
    g <- ggplot(department.df, aes(x=Var1, y=Freq)) +
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.1, color='black', size=4) +
      ylim(0, max(department.df$Freq) * 1.02) +
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
  #
  output$projectWeekProgessPlot <- renderPlot({
    
    g <- ggplot(weeklyProjCreation.df, 
                aes(x=projectsCreatedInCurrentWeek, y=Freq, group=1)) +
      geom_line(colour='#3182BD', size=1) + 
      geom_point(size=7, shape=21, fill='white') +
      geom_text(aes(label=Freq), size=4) +
      ylim(0, max(weeklyProjCreation.df$Freq) * 1.02) +
      xlab('Day of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title  =element_text(size=14),
            axis.text=element_text(size=12),
            axis.text.x = element_text(angle=30, hjust=1, vjust=1)) +
      ggtitle(paste0(year(dateOfExtraction), ': ',
                     'Number of created projects\n in the last 7 days per day'))
    print(g)
    
  })
  
  
  # Create project growth plot grouped by years
  #
  output$projectProgressPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    year.df <- year.df[order(year.df$Var1),]
    
    g <- ggplot(year.df, aes(x=Var1, y=Freq)) + 
      geom_bar(width=.5, stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), vjust=-0.3, size=4) +
      ylim(0, max(year.df$Freq) * 1.03) +
      xlab('Year of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)), 
            axis.title = element_text(size=14), 
            axis.text = element_text(size=12)) +
      ggtitle('Number of created projects\n per year')
    print(g)
  })
  
  # Create project growth plot for current year group by quarters
  #
  output$projectQuarterProgressPlot <- renderPlot({
    
    g <- ggplot(quarter.df,aes(x=pcy,y=Freq)) + 
      geom_bar(width=.5, stat='identity', fill='#3182BD') +
      geom_text(aes(label = Freq),vjust=-0.3,size=4) +
      ylim(0, max(quarter.df$Freq) * 1.03) +
      xlab('Quarter of creation') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)),
            axis.title = element_text(size=14),
            axis.text = element_text(size=12)) +
      ggtitle(paste0(year(dateOfExtraction), ': ', 'Number of created projects\n per quarter'))
    print(g)
   
  })
  
  
  output$numbOfActiveProjects <- renderText({
    paste('Number of projects active in the last 12 months:', 
          length(activeProjects), sep=' ')
  })
  
  output$numbOfInactiveProjects <- renderText({
    paste('Number of projects inactive since 12 months:', 
          dim(projects)[1] - length(activeProjects), sep=' ')
  })
  
  # Create project activity plot for last 4 quarters
  #
  output$projectActivityPlot <- renderPlot({
    
    activeProjects.df
    
    g <- ggplot(activeProjects.df, aes(x=activeProjects, y=Freq)) + 
      geom_bar(width=.5, stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), vjust=-0.3, size=4) +
      ylim(0, max(activeProjects.df$Freq) * 1.03) +
      xlab('Quarter of last activity') + 
      ylab('Number of projects') + 
      theme(plot.title = element_text(size=rel(1.3)), 
            axis.title = element_text(size=14), 
            axis.text = element_text(size=11)) +
      ggtitle('Project activity in the last 12 months\n per quarter')
    print(g)
  })
  
  
  
  # Create internal user distribution plot
  #
  output$userSAGPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    suffix.sag.df <- transform(suffix.sag.df,
                               suffix.sag = reorder(suffix.sag,Freq))
    
    g <- ggplot(suffix.sag.df, aes(x=suffix.sag, y=Freq)) + 
      geom_bar(stat='identity', fill='#3182BD') +
      geom_text(aes(label=Freq), hjust=-0.2,color='black',size=4) +
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
  #
  output$userExternalPlot <- renderPlot({
    
    # Do a reorder so that the order in the barchart is flipped
    suffix.external.df <- subset(suffix.external.df, Freq > 2)
    suffix.external.df <- transform(suffix.external.df,
                                    suffix.external = reorder(suffix.external,Freq))
    
    g <- ggplot(suffix.external.df, aes(x=suffix.external, y=Freq)) + 
      geom_bar(stat='identity',fill='#3182BD') +
      geom_text(aes(label=Freq),hjust=-0.2,color='black',size=3) +
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
  #
  output$totalDiskSpaceUsage <- renderText({
    paste('Total Alfresco disk space usage: ', 
          round(sum(projects$project_size, na.rm=TRUE)/1000), 'GB', sep='')
  })
    
  
  # Alfresco disk space usage summary
  #
  output$diskSpaceUsageSummary <- renderPrint({
    summary(projects$project_size, na.rm=T)
  })
    
  
  # Create disk space usage plot
  #
  output$diskspaceUsagePlot <- renderPlot({
    
    #Subset projects
    usage <- subset(projects, project_size > 1000, 
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
      ggtitle(paste('Projects consuming more than 1GB of Alfresco disk space ', '(', dim(usage)[1], 
                    ' overall)', sep='')) + 
      theme(plot.title = element_text(size=rel(1.3)), 
            axis.title = element_text(size=14),
            axis.text = element_text(size=11))
    print(g)
  })
  
  # Number of available templates
  #
  output$numbOfTemplates <- renderText({
    paste('Number of available templates: ', dim(templateUsage.df)[1], sep='')
  })
  
  
  #Create template usage plot
  #
  output$templateUsagePlot <- renderPlot({
    
    #Do a reorder so that the order in the barchart is flipped
    templateUsage.df <- transform(templateUsage.df, name=reorder(name, freq))
    
    g <- ggplot(templateUsage.df, aes(x=name, y=freq)) +
      geom_bar(stat='identity', fill='#3182BD') + 
      geom_text(aes(label=freq), hjust=-0.1, size=4) +
      ylim(0, max(templateUsage.df$freq) * 1.02) +
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