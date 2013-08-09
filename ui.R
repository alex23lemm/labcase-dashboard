
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
               div(class='span8', 
                   helpText(textOutput('distributionCaption')),
                   #plotOutput('departmentPlot', width="75%", height="300px"),
                   showOutput('departmentPlot', 'highcharts'),
                   #plotOutput('countryPlot', width="75%")
                   showOutput('countryPlot', 'highcharts')
               )
      ),
      tabPanel('Project growth',
                div(class='span5', 
                    #plotOutput('projectWeekProgessPlot', width="90%", height="340px"),
                    showOutput('projectWeekProgessPlot','highcharts'),
                    #plotOutput('projectProgressPlot', width="80%", height="320px")
                    showOutput('projectProgressPlot', 'highcharts')
                ),
                div(class='span5',
                    #plotOutput('projectQuarterProgressPlot', width="80%", height="320px"))
                    showOutput('projectQuarterProgressPlot', 'highcharts')
                )
      ),
      tabPanel('User distribution', 
               div(class='span9',
                   #plotOutput('userSAGPlot', width="75%", height="300px")
                   showOutput('userSAGPlot', 'highcharts'),
                   showOutput('userExternalPlot', 'highcharts')
                   #plotOutput('userExternalPlot', width="75%")
               )
      ),
      tabPanel('Disk space usage',
               div(class = 'span9',
                p(
                  textOutput('totalDiskSpaceUsage')
                ),
                helpText('Alfresco disk space usage summary information (in MB):'),
                verbatimTextOutput('diskSpaceUsageSummary'),
                #plotOutput('diskspaceUsagePlot', width="85%")
                showOutput('diskspaceUsagePlot', 'highcharts')
               )
      ),
      tabPanel('Project templates',
               div(class = 'span9',
                   textOutput('numbOfTemplates'),
                   #plotOutput('templateUsagePlot', width="75%", height="300px")
                   showOutput('templateUsagePlot', 'highcharts')
               )
      )
    )
  )
)
)
  