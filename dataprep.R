#'---
#' title: "TSCI 5230: Introduction to Data Science"
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
library(pander); # format tables
library(printr); # set limit on number of lines printed
library(broom); # allows to give clean dataset
library(dplyr); #add dplyr library

options(max.print=42);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf);

# load data ----
if(file.exists(ZippedData)){print("exist")}
if(!file.exists(data.R.rdata)){system()}



