
# Purpose: ui.R defines the HTML page for the Shiny app 'LabCase Dashboard'


library(shiny)
library(rCharts)


shinyUI(fluidPage(theme = 'mybootstrap.css', 
  
  fluidRow( 
   column(4,    
      h3(
        img(src = 'labcase_bin.png', width=35, height=35, align='top'),
        "LabCase Dashboard"
      )
   ),
   
   column(4,
     textOutput('date')
   ),
   
   column(4,    
     div(class = 'pull-right',
      downloadButton('downloadReport', 'Download report', class='btn-primary') 
     )
   )
  ),

  tabsetPanel(position = 'above',
              
    tabPanel('Project metrics',
             
      fluidRow(
        column(4,    
          h5('General project information'),
          hr(),
          
          fluidRow(
            column(8,
              'Total number of projects:',
               br(),
               'Total number of issues:'
            ),
            column(4,
              div(class = 'pull-right', textOutput('numbOfProjectsOverall')),
              br(),
              div(class = 'pull-right', textOutput('numbOfIssues'))
            )
          ),
          br(),
          'Issues per project information:',
          verbatimTextOutput('summaryIssuesPerProject'),
          br(),
          'Users per project information:',
          verbatimTextOutput('summaryUsersPerProject')
        ),
        
        column(8,    
          h5('Project distribution'),
          hr(),
               
          textOutput('distributionCaption'),
               
            fluidRow(
              column(12,
                wellPanel(
                  numericInput('numbOfProjects','Specify number of projects',10) 
                )    
              )
            ),
               
               
            fluidRow(
              column(6,
                showOutput('departmentPlot', 'highcharts')
              ),
              
              column(6,
                showOutput('countryPlot', 'highcharts')
              )
          )
        )
      )   
    ),
              
    tabPanel('Project growth',               
      fluidRow(
        column(4,
          h5('Weekly growth'),
          hr(),
          showOutput('projectWeekProgessPlot','highcharts') 
        ),
                  
        column(4,
          h5('Quarterly growth'),
          hr(),
          showOutput('projectQuarterProgressPlot', 'highcharts')    
        ),
                  
        column(4, 
          h5('Yearly growth'),
          hr(),
          showOutput('projectProgressPlot', 'highcharts')
        )
      )    
    ),
              
    tabPanel('User information',
             
      fluidRow(
        column(4,
          h5('General user information'),
          hr(),
               
          fluidRow(
            column(7,
              "Total number of users:",
              br(),
              "Number of SAG users:",
              br(),
              "Number of external users:"
            ),
            
            column(5,
              div(class = 'pull-right', textOutput('numbOfUsers')),
              br(),
              div(class = 'pull-right', textOutput('numbOfSAGUsers')),
              br(),
              div(class = 'pull-right', textOutput('numbOfExternalUsers'))
            )
          ),
          br(),     
               
          h5('Internal user distribution'),
          hr(),
               
          showOutput('userSAGPlot', 'highcharts')
        ),
        
        column(7,
          h5('External user distribution'),
          hr(),
               
          showOutput('userExternalPlot', 'highcharts')
        )
      )
    ),
               
    tabPanel('Project templates',
             
      fluidRow(
        column(3,
          h5('General project template information'),
          hr(),
               
          fluidRow(
            column(9,
              "Number of available templates:"   
            ),
            column(3,
              div(class = 'pull-right', textOutput('numbOfTemplates'))
            )
          )      
        ),
        
        column(9,
          h5('Project template usage distribution'),
          hr(),
               
          showOutput('templateUsagePlot', 'highcharts')
        )
      )
    ),
              
    tabPanel('Disk space usage',
             
      fluidRow(
        column(4,
          h5('General Disk space usage information'),
          hr(),
                      
          fluidRow(
            column(8,
              'Total disk space usage:',
               br(),
               'Total Alfresco disk space usage:',
               br(),
               'Total Repository disk space usage:'
            ),
                        
            column(4,
              div(class = 'pull-right', textOutput('totalDiskSpaceUsage')),
              br(),
              div(class = 'pull-right', textOutput('totalAlfrescoDiskSpaceUsage')),
              br(),
              div(class = 'pull-right', textOutput('totalRepoDiskSpaceUsage'))
            )
          ),    
                      
          br(),
          'Alfresco disk space usage summary (in MB):',
          verbatimTextOutput('alfrescoSummary'),   
          'Repository disk space usage summary (in MB):',
          verbatimTextOutput('repositorySummary')
        ),
               
        column(8,
          h5('Disk space usage distribution'),
          hr(),
                      
          showOutput('diskspaceUsagePlot', 'highcharts')
        )      
      )
    )    
                      
  )
))