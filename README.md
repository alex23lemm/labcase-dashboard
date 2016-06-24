# LabCase Dashboard

LabCase Dashboard is a web application which visualizes business relevant data from the underlying Planio database.

LabCase Dashboard consists of two parts:

* A separate R script for loading and processing the data. Moreover, the script creates a HTML report based on the processed data. (The script needs to be set up as a Cron Job (Linux) or a Scheduled Task (Windows))
* A Shiny application visualizing the processed data including an option to download the data as a HTML report (Can run in a separate process locally or on Shiny Server)

## Installation

### Installation on local machine

**R and R libraries**

You need to install the following prerequisites:

* [R 3.1.0](http://www.r-project.org) or higher

R libraries:

* DBI
* RMySQL
* lubridate
* yaml
* plyr
* dplyr
* scales
* reshape2
* stringr
* knitr
* knitrBootstrap
* markdown
* ggplot2
* RColorBrewer
* shiny
* devtools
* rCharts (via install_github('rCharts', 'ramnathv'))

**Shiny app**

Simply git clone this repo which will set up the following folder app structure:


  * `lc-dashboard`: App root folder that contains `server.R`, `ui.R` and `config.yml`
	  * `processedData`: Processed data will get stored here
	  * `rawData`: Downloaded data from the LC database will get stored here
	  * `rScripts`: Scripts for downloading and processing the data from the LC database


**Configuration**
	  
* Change the path in the `setwd()` command in `lc-dashboard/rScripts/main.R`  accordingly
* Add the necessary credentials to `config.yml`

**Cron Job or Scheduled Task**

* Set up a Cron Job (Linux) or a Scheduled Task (Windows)
* For Windows set up a new Task using `[path to your R installation]/R/R-[version number]/bin/x64/Rscript.exe` with the following argument `[your path to]/lc_dashboard/rScripts/main.R` 

**Running the app**

Assuming that the new folder will be your R working directory, use the `runApp` command to launch the app. Open a console window and excecute the following command:

    R -e "shiny::runApp('.')"



### Installation on Ubuntu server

If you would like to install the application together with Shiny Server on a fresh Ubuntu server (e.g. a T2.micro Amazon EC2 instance) you can excute the bash script `setup.sh` that is part of this repo. The script will install the following:

Create and enable swap file: necessary when running on a T2.mirco EC2 instance. You won't be able to install certain R packages (e.g. `dplyr`, `tidyr`) without the additional allocated memory from the swap file
* The latest R distribution for Ubuntu Trusty
* Git
* Shiny server
* The devtools package including the necessary Linux packages
* R GitHub packages necessary to run the Shiny app
* R CRAN packages necessary to run the Shiny app
* The Shiny app (via git clone)

After running the script the LabCase Dashboard app will be available at `http://[server IP address]:3838/labcase-dashboard`

