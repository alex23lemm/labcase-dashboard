
# Author: Alex Lemm
#
# Purpose: ui.R defines the user interface for the Shiny app 'LabCase Dashboard'


library(shiny)
library(rCharts)


shinyUI(pageWithSidebar(
  
  headerPanel('LabCase Dashboard'),

  sidebarPanel(
    
    p(
      textOutput('date')
      ),
    p(
      textOutput('numbOfProjectsOverall')
      ),
    p(
      textOutput('numbOfUsers'),
      textOutput('numbOfSAGUsers'),
      textOutput('numbOfExternalUsers'),
      helpText('Users per project information:'),
      verbatimTextOutput('summaryUsersPerProject')
    ),
    p(
      textOutput('numbOfIssues'),
      helpText('Issues per project information:'),
      verbatimTextOutput('summaryIssuesPerProject')
      ),
    p(
      numericInput('numbOfProjects','Specify number of projects',10),
      helpText('(Info: The \'Project distribution\' tab will show those departments/countries
                which have launched equivalent or more projects aS specified by the input.)')
    )
  ),
  
  mainPanel(
    
    tabsetPanel(
      
      tabPanel('Project distribution',
               helpText(textOutput('distributionCaption')),
               #class='span6',
               #plotOutput('departmentPlot', width="75%", height="300px"),
               showOutput('departmentPlot', 'highcharts'),
               #class='span6',
               plotOutput('countryPlot', width="75%")
               ),
      tabPanel('Project growth',
                div(class='span6', 
                    #plotOutput('projectWeekProgessPlot', width="90%", height="340px"),
                    showOutput('projectWeekProgessPlot','highcharts'),
                    plotOutput('projectProgressPlot', width="80%", height="320px")
                    ),
                div(class='span6',
                    #plotOutput('projectQuarterProgressPlot', width="80%", height="320px"))
                    showOutput('projectQuarterProgressPlot', 'highcharts'))
               ),
      tabPanel('User distribution',
               plotOutput('userSAGPlot', width="75%", height="300px"),
               plotOutput('userExternalPlot', width="75%")
               ),
      tabPanel('Disk space usage',
                p(
                  textOutput('totalDiskSpaceUsage')
                  ),
                helpText('Alfresco disk space usage summary information (in MB):'),
                verbatimTextOutput('diskSpaceUsageSummary'),
                plotOutput('diskspaceUsagePlot', width="85%")
               ),
      tabPanel('Project templates',
               textOutput('numbOfTemplates'),
               plotOutput('templateUsagePlot', width="75%", height="300px")
               )
      )
    )
  )
)
  