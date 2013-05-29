# LabCase Dashboard

LabCase Dashboard is a web application which visuals business relevant data from the LabCase database.
LabCase Dashboard consists of two parts:
* A separate R script for loading and pre-processing the data (needs to be set up as a cron job (Linux) or a task (Windows))
* A Shiny application visualising the processed data (can run in a separate process locally or on a Shiny server)

## Installing

Independent of running the application locally on your computer or deploying it to a Shiny server, you need the following prerequisites installed:

* [R 2.15.3](http://www.r-project.org)
* You will need the following R libraries:
	* RODBC
	* lubridate
	* RCurl
	* XML
	* shiny
	* plyr
	* ggplot2
	* RColorBrewer
  * yaml
* You have to set up the following folder structure:
  * `lc_dashboard` (Not included in Git repo. Place config.yml here)
	  * `lc_shiny` (Included in Git repo)
	  * `processedData` (Not included in Git repo. Processed data will get stored here)
	  * `rawData` (Not included in Git repo. Downloaded data from the LC database will get stored here)
	  * `rScripts` (Included in Git repo)
* The path in the `setwd()` command in `./lc_dashboard/rScripts/main.R` needs to be changed accordingly.
* Moreover you have to add the LabCase database as a ODBC data source on your operating system and add the necessary credentials to the `config.yml` file. Please put the config file directly into the `lc_dashboard` folder.
* Set up a cron job (Linux) or a task via the task scheduler (Windows) using `[path to your R installation]/R/R-2.15.2/bin/x64/Rscript.exe` with the following argument `[your path to]/lc_dashboard/rScripts/main.R` 

After having installed all prerequisites you can either run LabCase Dashboard in a separate process locally on your machine or deploy it to a Shiny Server.

### Run LabCase Dashboard in a separate process

You can do this by opening a terminal or console window and executing the following:
```
R -e "shiny::runApp('~/lc_dashboard/lc_shiny')"
```
By default runApp starts the application on port 8100. If you are using this default then you can connect to the running application by navigating your browser to [http://localhost:8100](http://localhost:8100).

### Run LabCase Dashboard on a Shiny server

Using Shiny Server software, you can deploy LabCase Dashboard over the web so that users need only a web browser and the application’s URL. You’ll need a Linux server and Shiny Server. Please take a look here how to install [Shiny Server](https://github.com/rstudio/shiny-server).









