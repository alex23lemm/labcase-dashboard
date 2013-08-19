# LabCase Dashboard

LabCase Dashboard is a web application which visualizes business relevant data from the underlying Planio database.
LabCase Dashboard consists of two parts:
* A separate R script for loading and processing the data. Moreover the script creates a HTML report based on the processed data. (The script needs to be set up as a Cron Job (Linux) or a Task (Windows))
* A Shiny application visualizing the processed data and an option to download the report (Can run in a separate process locally or on Shiny server)

## Installation

Independent of running the application locally on your computer or deploying it to Shiny server, you need the following prerequisites installed:

* [R 2.15.3](http://www.r-project.org)
* You will need the following R libraries:
	* RODBC
	* lubridate
  * yaml
  * plyr
  * reshape2
  * knitr
  * markdown
  * xtable
  * ggplot2
	* shiny
  * devtools
	* rCharts (via install_github('rCharts', 'ramnathv'))

* You have to set up the following folder app structure:
  * `lc_dashboard` (Not included in Git repo. Place Shiny files (`server.R`, `ui.R`) and `config.yml` here)
	  * `processedData` (Included in Git repo. Processed data will get stored here)
	  * `rawData` (Included in Git repo. Downloaded data from the LC database will get stored here)
	  * `rScripts` (Included in Git repo)
* The path in the `setwd()` command in `./lc_dashboard/rScripts/main.R` needs to be changed accordingly.
* Moreover you have to add the LabCase database as a ODBC data source on your operating system and add the necessary credentials to the `config.yml` file
* Set up a Cron Job (Linux) or a Task (Windows)
  * For Windows set up a new Task using `[path to your R installation]/R/R-2.15.2/bin/x64/Rscript.exe` with the following argument `[your path to]/lc_dashboard/rScripts/main.R` 

After having installed all prerequisites you can either run LabCase Dashboard in a separate process locally on your machine or deploy it to a Shiny Server.

### Run LabCase Dashboard in a separate process

You can do this by opening a terminal or console window and executing the following:
```
R -e "shiny::runApp('~/lc_dashboard')"
```
By default runApp starts the application on port 8100. If you are using this default then you can connect to the running application by navigating your browser to [http://localhost:8100](http://localhost:8100).

### Run LabCase Dashboard on a Shiny server

Using Shiny Server software, you can deploy LabCase Dashboard over the web so that users need only a web browser and the application’s URL. You’ll need a Linux server and Shiny Server. Please take a look here how to install [Shiny Server](https://github.com/rstudio/shiny-server). Copy the entire content of the git repo into the main folder of the Shiny application. 


