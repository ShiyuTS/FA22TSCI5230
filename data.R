#'---
#' title: "Data Extraction
#' author: 'Shiyu Li'
#' abstract: |
#'  | Provide a summary of objectives, study design, setting, participants,
#'  | sample size, predictors, outcome, statistical analysis, results,
#'  | and conclusions.
#' documentclass: article
#' description: 'Manuscript'
#' clean: false
#' self_contained: true
#' number_sections: false
#' keep_md: true
#' fig_caption: true
#' output:
#'  html_document:
#'    toc: true
#'    toc_float: true
#'    code_folding: show
#' ---
#'
#+ init, echo=FALSE, message=FALSE, warning=FALSE
# init ----
# This part does not show up in your rendered report, only in the script,
# because we are using regular comments instead of #' comments
debug <- 0;
knitr::opts_chunk$set(echo=debug>-1, warning=debug>0, message=debug>0);

library(ggplot2); # visualisation
library(GGally);
library(rio);# simple command for importing and exporting
library(pander); # format tables
library(printr); # set limit on number of lines printed
library(broom); # allows to give clean dataset
library(dplyr); # add dplyr library
library(fs)
library(R.utils) # error message for "for loop"

options(max.print=42);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf);
whatisthis <- function(xx){
  list(class=class(xx),info=c(mode=mode(xx),storage.mode=storage.mode(xx)
                              ,typeof=typeof(xx)))};

#' # Import the data
InputData <- 'https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip'
dir.create("data", showWarnings = FALSE)
ZippedData <- file.path("data", "temptdata.zip")

if(!file.exists(ZippedData)){download.file(InputData,
                                           destfile = ZippedData)}


#' ## in case we don't need to download data multiple times
#'

#' # Unzip the data
UnzippedData <- unzip(ZippedData, exdir = "data") %>%
  grep("gz", ., value = TRUE)
Transfers <- import(UnzippedData[3])
TableNames <- basename(UnzippedData) %>%
  fs::path_ext_remove() %>%
  path_ext_remove()

assign(TableNames[3], import(UnzippedData[3], fread = FALSE))

#' ## Use a For Loop to repeat particular set of steps to get the tables
# for(ii in seq_along(TableNames)){
  #assign(TableNames[ii], # assign file names as table names for the to-be-extracted tables
         #import(UnzippedData[ii], format = 'csv'),
         #inherits = TRUE)
#}

#' ## Use mapply
Junk <- mapply(
  function(xx, yy){
  #browser()
  assign(xx,
         import(yy, format = 'csv'),
         inherits = TRUE)
    },
  TableNames,
  UnzippedData)

#' # saving the data
save(list = TableNames, file = "data.R.rdata")



#'
#'



#' ##
# %>%
# grep("gz", UnzippedData)  # positions in the vector where the pattern "gz" has been found
# grep("gz", UnzippedData, value = TRUE) # return the actual strings






