
# Author: Alex Lemm
#
# Purpose: ui.R defines the HTML page for the Shiny app 'LabCase Dashboard'


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
                which have launched equivalent or more projects as specified by the input.)')
    ),
    p(
      downloadButton('downloadReport', 'Download report', class='btn-primary')
    )
  ),
  
  
  mainPanel(
    
    tabsetPanel(
      
      tabPanel('Project distribution',
               div(class='row-fluid',
                 div(class='span9', 
                     helpText(textOutput('distributionCaption')),
                     showOutput('departmentPlot', 'highcharts'),
                     showOutput('countryPlot', 'highcharts')
                 )
               )
      ),
      tabPanel('Project growth',          
               div(class='row-fluid',
                  div(class='span5', 
                      showOutput('projectWeekProgessPlot','highcharts')
                  ),
                  div(class='span5',
                      tableOutput('projectsOfLast7DaysTable')
                  )  
               ),
               div(class='row-fluid', 
                  div(class='span5',
                      showOutput('projectQuarterProgressPlot', 'highcharts')
                  ),
                  div(class='span5',
                      showOutput('projectProgressPlot', 'highcharts')
                  )
               )
      ),
      tabPanel('User distribution',
               div(class='row-fluid',
                 div(class='span9',
                     showOutput('userSAGPlot', 'highcharts'),
                     showOutput('userExternalPlot', 'highcharts')
                 )
               )
      ),
      tabPanel('Disk space usage',
               div(class='row-fluid',
                 div(class = 'span9',
                  p(
                    textOutput('totalDiskSpaceUsage'),
                    textOutput('totalAlfrescoDiskSpaceUsage'),
                    textOutput('totalRepoDiskSpaceUsage')
                  ),
                  helpText('Alfresco disk space usage summary (in MB):'),
                  verbatimTextOutput('alfrescoSummary'),   
                  helpText('Repository disk space usage summary (in MB):'),
                  verbatimTextOutput('repositorySummary'),
                  showOutput('diskspaceUsagePlot', 'highcharts')
                 )
               )
      ),
      tabPanel('Project templates',
               div(class='row-fluid',
                   div(class = 'span9',
                     textOutput('numbOfTemplates'),
                     showOutput('templateUsagePlot', 'highcharts')
                   )
               )
      )
    )
  )
)
)
  