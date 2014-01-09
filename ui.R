
# Author: Alex Lemm
#
# Purpose: ui.R defines the HTML page for the Shiny app 'LabCase Dashboard'


library(shiny)
library(rCharts)


shinyUI(fluidPage( 
  
  fluidRow( 
   column(4,    
      h3(
        img(src = "labcase_bin.png", width=35, height=35, align='top'),
        "LabCase Dashboard"
      )
   ),
   
   column(4,
     textOutput('date')
   ),
   
   column(2, offset = 2,    
     downloadButton('downloadReport', 'Download report', class='btn-primary')    
   )
  ),
  
  fluidRow(
    column(12,
      hr()
   )
  ),
  
  
  tabsetPanel(position = 'left',
              
    tabPanel('Project metrics',
             
      fluidRow(
        column(4,    
          h5('General project metrics'),
          hr(),
               
          'Users per project information:',
          verbatimTextOutput('summaryUsersPerProject'),
          'Issues per project information:',
          verbatimTextOutput('summaryIssuesPerProject'),
          numericInput('numbOfProjects','Specify number of projects',10)
        ),
        
        column(8,    
          h5('Project distribution'),
          hr(),
               
          textOutput('distributionCaption'),
               
            fluidRow(
              column(6,
                showOutput('departmentPlot', 'highcharts')
              ),
              
              column(6,
                showOutput('countryPlot', 'highcharts')
              )
          )
        )
      ),    
             
      fluidRow(
        column(12,
          h5('Project growth'),
          hr(),
               
            fluidRow(
              column(4,
                showOutput('projectWeekProgessPlot','highcharts') 
              ),
              
              column(4,
                showOutput('projectQuarterProgressPlot', 'highcharts')    
              ),
              
              column(4, 
                showOutput('projectProgressPlot', 'highcharts')
              )
            )
        )
      )
    ),
              
    tabPanel('User metrics',
             
      fluidRow(
        column(4,
          h5('General user information'),
          hr(),
               
          textOutput('numbOfUsers'),
          textOutput('numbOfSAGUsers'),
          textOutput('numbOfExternalUsers'),
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
     
    tabPanel('Disk space metrics',
      
      fluidRow(
        column(4,
           h5('General Disk space usage information'),
           hr(),
               
           textOutput('totalDiskSpaceUsage'),
           textOutput('totalAlfrescoDiskSpaceUsage'),
           textOutput('totalRepoDiskSpaceUsage'),                                
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
    ),
              
    tabPanel('Template metrics',
             
      fluidRow(
        column(4,
          h5('General project template information'),
          hr(),
               
          textOutput('numbOfTemplates')
               
               
        ),
        
        column(8,
          h5('Project template usage distribution'),
          hr(),
               
          showOutput('templateUsagePlot', 'highcharts')
        )
      )
    )      
  )
))
       
            
            
#             column(4,
#               h5('Project distribution'),     
#               hr(),     
#               numericInput('numbOfProjects','Specify number of projects',10),
#               helpText),
#               
#               showOutput('countryPlot', 'highcharts')
#             )
          
        #)
      #)
     # )
    #)
    #)
 # )
#)
#                        tabPanel('Project growth',          
#                                 div(class='row-fluid',
#                                     div(class='span5', 
#                                         
#                                     ),
#                                     div(class='span5',
#                                         
#                                     )  
#                                 ),
#                                 div(class='row-fluid', 
#                                     div(class='span5',
#                                         
#                                     ),
#                                     div(class='span5',
#                                         
#                                     )
#                                 )
#                        ),
#                        tabPanel('User distribution',
#                                 div(class='row-fluid',
#                                     div(class='span9',
#                                         ,
#                                         
#                                     )
#                                 )
#                        ),
#                        tabPanel('Disk space usage',
#                                 div(class='row-fluid',
#                                     div(class = 'span9',
#                                         p(
#                                           textOutput('totalDiskSpaceUsage'),
#                                           textOutput('totalAlfrescoDiskSpaceUsage'),
#                                           textOutput('totalRepoDiskSpaceUsage')
#                                         ),
#                                         helpText('Alfresco disk space usage summary (in MB):'),
#                                         verbatimTextOutput('alfrescoSummary'),   
#                                         helpText('Repository disk space usage summary (in MB):'),
#                                         verbatimTextOutput('repositorySummary'),
#                                         
#                                     )
#                                 )
#                        ),
#                        tabPanel('Project templates',
#                                 div(class='row-fluid',
#                                     div(class = 'span9',
#                                         ,
#                                         
#                                     )
#                                 )
#                        ),
#                        navbarMenu("More",
#                                   #tabPanel("Sub-Component A",
#                                   downloadLink('downloadReport', 'Download report')
#                                   #downloadButton('downloadReport', 'Download report', class='btn-primary')
#                                   #)
#                        )
#            )  
#            
#     )
#   )
  
  
  
  #headerPanel('LabCase Dashboard'),

  #fluidRow(
#     column(3,
#       wellPanel(
#         p(
#           textOutput('numbOfProjectsOverall')
#         ),
#         p(
#           ,
#           helpText(),
#           
#         ),
#         p(
#           textOutput('numbOfIssues'),
#           helpText(),
#           
#         ),
#         p(
#           ,
#           helpText('(Info: The \'Project distribution\' tab will show those departments/countries
#                     which have launched equivalent or more projects as specified by the input.)')
#         ),
#       )
#     ),
  
  #column(12,
    
    
  #)
  #)

  