
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
    )
  ),
  
  mainPanel(
    
    tabsetPanel(
      
      tabPanel('Project distribution',
               div(class='span8', 
                   helpText(textOutput('distributionCaption')),
                   showOutput('departmentPlot', 'highcharts'),
                   showOutput('countryPlot', 'highcharts')
               )
      ),
      tabPanel('Project growth',
                div(class='span5', 
                    showOutput('projectWeekProgessPlot','highcharts'),
                    showOutput('projectProgressPlot', 'highcharts')
                ),
                div(class='span5',
                    showOutput('projectQuarterProgressPlot', 'highcharts')
                )
      ),
      tabPanel('User distribution', 
               div(class='span9',
                   showOutput('userSAGPlot', 'highcharts'),
                   showOutput('userExternalPlot', 'highcharts')
               )
      ),
      tabPanel('Disk space usage',
               div(class = 'span9',
                p(
                  textOutput('totalDiskSpaceUsage')
                ),
                helpText('Alfresco disk space usage summary information (in MB):'),
                verbatimTextOutput('diskSpaceUsageSummary'),              
                showOutput('diskspaceUsagePlot', 'highcharts')
               )
      ),
      tabPanel('Project templates',
               div(class = 'span9',
                   textOutput('numbOfTemplates'),
                   showOutput('templateUsagePlot', 'highcharts')
               )
      )
    )
  )
)
)
  