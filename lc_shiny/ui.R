library(shiny)

#this expression is always used 
shinyUI(pageWithSidebar(
  
  headerPanel('LabCase Dashboard'),

  sidebarPanel(
    
    p(textOutput('date')),
    
    p(textOutput('numbOfProjectsOverall'),
    
    textOutput('numbOfActiveProjectsCurQuart')),
    
    p(textOutput('numbOfUsers'),
    
    textOutput('numbOfSAGUsers'),
    
    textOutput('numbOfExternalUsers')),
    
    p(numericInput('numbOfProjects','Specify number of projects',10),
    
    helpText('Info: The output (\'Project distribution\' tab) will show those departments/countries which have launched equivalent or more projects as
specified by the input.')
    
    )),
  
  mainPanel(
    
    tabsetPanel(
      
      tabPanel('Project distribution',
               helpText(textOutput('distributionCaption')),
               class='span6',plotOutput('departmentPlot',width = "75%", height = "300px"),
               class='span6',plotOutput('countryPlot',width = "75%", height = "300px")
               ),
      tabPanel('Project growth',
                div(class='span6', 
                    plotOutput('projectWeekProgessPlot', width = "90%", height = "280px"),
                    plotOutput('projectProgressPlot', width = "80%", height = "320px")
                    ),
                div(class='span6',plotOutput('projectQuarterProgressPlot', width = "80%", height = "320px"))
               ),
      tabPanel('Project activity',
               div(class='span6', 
                   p(textOutput('numbOfActiveProjects')),
                   textOutput('numbOfInactiveProjects')
                   ),
               div(class='span6', plotOutput('projectActivityPlot', width = '80%', height = '320px'))
               ),
      tabPanel('User distribution',
               plotOutput('userSAGPlot', width = "75%", height = "300px"),
               plotOutput('userExternalPlot', width = "75%", height = "300px")
               )
    ) 
  )
))
  