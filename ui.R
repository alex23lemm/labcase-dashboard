
# Purpose: ui.R defines the HTML page for the Shiny app 'LabCase Dashboard'


library(shiny)
library(rCharts)


shinyUI(fluidPage(
  
  tags$head(tags$link(rel="stylesheet", type="text/css", href="custom.css")),
  
  fluidRow(
   column(4,    
      h3(
        img(src = 'labcase_bin.png', width = 35, height = 35),
        "LabCase Dashboard"
      )
   ),
   
   column(4, offset=1, style = 'margin-top: 14.5px',  
     textOutput('date')
   ),
   
   column(3,
     div(class = 'pull-right', style = 'margin-top: 2.5px',
      downloadButton('downloadReport', 'Download report', class='btn-primary') 
     )
   )
  ),
                  
  fluidRow(
    column(12,
                           
      tabsetPanel(position = 'above',
              
        tabPanel('Project distribution',
             
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
                 
                fluidRow(
                  column(12,
                         
                    wellPanel(
                      
                      fluidRow(
                        column(4,
                          uiOutput('selectDepartment')
                        ),
                        
                        column(4,
                          uiOutput('selectCountry')
                        ),
                        
                        column(4,
                          numericInput('numbOfProjects','Specify number of projects',10) 
                        )
                      )
                    )    
                  )
                ),
                   
                fluidRow(
                  column(12,  
                    textOutput('distributionCaption')
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
             column(8,
               h5('Weekly growth'),
               hr(),
               
               fluidRow(
                 column(6,
                        showOutput('projectWeekProgessPlot','highcharts')
                 ),
                 
                 column(6,
                  div(style='font-size:11.5px',
                    HTML("<div style='font-weight: bold;' 
                         class='text-center'>Created projects in the last 7 days</div>"),
                    dataTableOutput('projectsOfLast7DaysTable'),
                    # Get rid of the within-column filters
                    tags$style('#projectsOfLast7DaysTable tfoot {display:none;}') 
                  )
                 )
               )
             )
          ),
                       
          fluidRow(
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
              
              h5('User activity'),
              hr(),
                
              fluidRow(
                column(7,
                  "Users active today:",
                  br(),
                  "Users active in last 7 days:",
                  br(),
                  "Users active in last 30 days:",
                  br(),
                  "Users active in last 60 days:",
                  br(),
                  "Users active in last 12 months:",
                  br() 
                ),
                
                column(5,
                  div(class = 'pull-right', textOutput('userActivityToday')),
                  br(),
                  div(class = 'pull-right', textOutput('userActivitylast7Days')),
                  br(),
                  div(class = 'pull-right', textOutput('userActivitylast30Days')),
                  br(),
                  div(class = 'pull-right', textOutput('userActivitylast60Days')),
                  br(),
                  div(class = 'pull-right', textOutput('userActivitylast12Months')),
                  br()
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
                   
            column(7,
              h5('Disk space usage distribution'),
              hr(),
                          
              showOutput('diskspaceUsagePlot', 'highcharts')
            )      
          )
        )    
      )               
    )
  ),
  
  fluidRow(
    column(12, class = 'text-center',
      hr(),
      HTML("<h6 ><small>Software AG LabCase Dashboard, powered by <a href = 'http://www.rstudio.com/shiny/'>Shiny</a> © 2013 RStudio, Inc. <a href = 'https://plan.io/'>
          Cheerfully deployed by <img width = '41', height = '10', src = 'planio_logo_gray_82x20.png'></a>.</small></h6>")
    )
  )
  
))