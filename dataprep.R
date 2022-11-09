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
library(tidyr);
library(purrr);
library(table1);
library(reticulate);



options(max.print=42);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf);

# load data ----
if(!file.exists("data.R.rdata")){system("R -f data.R")}
# send the command to the operator system
load("data.R.rdata")

# Section 2 ----

#' # Introduction to ggplot
ggplot(data = patients, aes(x = anchor_age, fill = gender)) +
  geom_histogram() +
  geom_vline(xintercept = 65)

table(patients$gender)
nrow(patients)
unique(patients$subject_id)
length(unique(patients$subject_id))

#' # Introduction to dplyr: data aggregation
Demographics <- group_by(admissions, subject_id) %>%
  mutate(los = difftime(dischtime, admittime, units = "days")) %>%
  summarise(admits = n(),
            ethnicity0 = length(unique(ethnicity)),
            ethnicity_combo = paste(sort(unique(ethnicity)),
                                    collapse = "+"),
            # language0 = length(unique(language)),
            # language_combo = paste(sort(unique(language)),
            #                        collapse = "+"),
            language = tail(language, 1),
            dod = max(deathtime, na.rm = TRUE),
            los = median(los),
            numED = length(na.omit(edregtime)))



ggplot(data = Demographics, aes(x = admits)) +
  geom_histogram() # shows distribution of admits

# subset dataframes in dplyr, by condition
subset(Demographics, ethnicity0 > 1)
#subset(Demographics, language0 > 1)

table(admissions$language)

#' # join admissions and patients df
intersect(names(Demographics), names(patients))
# identify what 2 tables have in common

# right join, left join, inner join, outer join

#' ## compare ids in 2 tables
#' ###
Demographics$subject_id
patients$subject_id
setdiff(Demographics$subject_id, patients$subject_id)
setdiff(patients$subject_id, Demographics$subject_id )
setdiff(Demographics$dod, patients$dod)

Demographics1 <- left_join(Demographics, select(patients, -dod), by = c("subject_id"))


#'
# Mapping the variables...



# build list of keywords
kw_abx <- c("vanco", "zosyn", "piperacillin", "tazobactam", "cefepime", "meropenam", "ertapenem", "carbapenem", "levofloxacin")
kw_lab <- c("creatinine")
kw_aki <- c("acute renal failure", "acute kidney injury", "acute kidney failure", "acute kidney", "acute renal insufficiency")
kw_aki_pp <- c("postpartum", "labor and delivery")



# search for those keywords in the tables to find the full label names
# remove post partum from aki in last line here
# may need to remove some of the lab labels as well (pending)
label_abx <- grep(paste0(kw_abx, collapse = '|'), d_items$label, ignore.case = T, value = T, invert = F)
label_lab <- grep(paste0(kw_lab, collapse = '|'), d_labitems$label, ignore.case = T, value = T, invert = F)
label_aki <- grep(paste0(kw_aki, collapse = '|'), d_icd_diagnoses$long_title, ignore.case = T, value = T, invert = F)
label_aki <- grep(paste0(kw_aki_pp, collapse = '|'), label_aki, ignore.case = T, value = T, invert = T)



# use dplyr filter to make tables with the item_id for the keywords above
item_ids_abx <- d_items %>% filter(label %in% label_abx)
item_ids_lab <- d_labitems %>% filter(label %in% label_lab)
item_ids_aki <- d_icd_diagnoses %>% filter(long_title %in% label_aki)

subset(item_ids_abx, category == 'Antibiotics') #Only selects rows with category of Antibiotics
subset(item_ids_abx, category == 'Antibiotics') %>%
  left_join(inputevents, by = 'itemid') #By using subset first in left_join, starting off
#by only selecting rows with antibiotics, and then pulling inputevents data for those
#patients that received the antibiotics with our specified IDs

Antibiotics <- subset(item_ids_abx, category == 'Antibiotics') %>%
  left_join(inputevents, by = 'itemid')

grep('N17', diagnoses_icd$icd_code, value = T) #ICD codes found within the dataset
grep('^548|^N17', diagnoses_icd$icd_code, value=T) #Either 548... or N17... values
#within the diagnosis_icd$icd_code data set
grepl('^548|^N17', diagnoses_icd$icd_code) #True/False for each row whether it contains value
subset(diagnoses_icd,grepl('^548|^N17',icd_code)) #Pulls only the rows that have ICD code of interest
Akidiagnoses_icd <- subset(diagnoses_icd,grepl('^548|^N17',icd_code))

Cr_labevents <- subset(item_ids_lab, fluid == "Blood") %>%
  left_join(labevents, by = 'itemid') #Filter only blood Cr and match to lab events

grepl(paste(kw_abx, collapse='|'),emar$medication)
subset(emar,grepl(paste(kw_abx, collapse='|'),medication,ignore.case = T))$event_txt%>%
  table()%>%sort() #Filter emar by antibiotic administration with individual event txt



#' # group Antibiotics into a smaller number of categories
#' ## aggregate df by a specific column

Antibiotics_Groupings <- ## group hmad_id by their antibiotics uses
  Antibiotics %>% group_by(hadm_id) %>%
  summarise(Vanc = "Vancomycin" %in% label,
            Zosyn = any(grepl("Piperacillin", label)),
            Other = length(grep("Piperacillin|Vancomycin", label, value = TRUE, invert = TRUE)) > 0,
            Exposure1 = case_when(!Vanc ~ "Other",
                                  Vanc&Zosyn ~ "Vanc&Zosyn",
                                  Other ~ "Vanc&Other",
                                  !Other ~ "Vanc",
                                  TRUE ~ "UNDEFINED"),
            #debug = {browser(); TRUE}, # look into each group_by() row
            N = n())

# 9-21-2022 STOPPED HERE: sapply(st, function(xx)){between()}

# Assignment: create an exposure2 variable: Vanc & !Zosyn & !Other ~ 'Vanc'

#' ## Find out existing Antibiotics combinations
Antibiotics_Groupings %>% group_by(Vanc, Zosyn, Other) %>%
  summarise(N = n())

#' ## 9-28-2022

# create Admissions_scaffold: days within the hospital admission
Admissions_scaffold <- admissions %>% select(hadm_id, admittime, dischtime) %>%
  transmute(hadm_id = hadm_id,
            ip_date = map2(as.Date(admittime), as.Date(dischtime), seq, by = "1 day")) %>%
  unnest(ip_date)

# create Antibiotics_dates: each row represents a day  with antibiotics injection
Antibiotics_dates <- Antibiotics %>%
  transmute(hadm_id = hadm_id,
            group = case_when(
              "Vancomycin" == label ~ "Vanc",
              grepl("Piperacillin", label) ~ "Zosyn",
              TRUE ~ "Other"),
            starttime = starttime,
            endtime = endtime) %>% unique() %>%
  subset(!is.na(starttime) & !is.na(endtime)) %>%
  transmute(hadm_id = hadm_id,
            ip_date = map2(as.Date(starttime), as.Date(endtime), seq, by = "1 day"),
            group = group) %>%
  unnest(ip_date) %>% unique()

# split Antibiotics_dates by antibiotics type
Antibiotics_dates <- split(Antibiotics_dates, Antibiotics_dates$group)

# update Antiniotics_dates: combined with Antibiotics_scaffold to indicate on what inpatient date, what antibiotics was adminstered
Antibiotics_dates <- sapply(names(Antibiotics_dates), function(xx)
  {
  names(Antibiotics_dates[[xx]])[3] <- xx
  Antibiotics_dates[[xx]]},
  simplify = FALSE) %>%
  Reduce(left_join, ., Admissions_scaffold)

# Two ways to replace N/As with empty string
# mutate(Antibiotics_dates, Other = paste(ifelse(is.na(Other), "", Other)),
#        Vanc = coalesce(Vanc, "")) %>% View()

mutate(Antibiotics_dates,
       across(all_of(c("Other", "Vanc", "Zosyn")), ~ coalesce(.x, "")),
       exposure = paste(Vanc, Zosyn, Other)) %>%
  select(hadm_id, exposure) %>%
  unique() %>%
  pull(exposure) %>% table()

#' #20221005
# identify the first date pt administered Vanc & Zosyn
# merge with Cr_labevents
# Compare charttime vs. first date with Vanc&Zosyn
Cr_labevents_2 <- Antibiotics_dates %>%
  group_by(hadm_id) %>%
  summarise(date_Vanc_Zosyn = min(ip_date[!is.na(Vanc) & !is.na(Zosyn)])) %>%
  subset(!is.infinite(date_Vanc_Zosyn)) %>%
  left_join(Cr_labevents, .) %>%
  subset(!is.na(hadm_id)) %>%
  arrange(hadm_id, charttime) %>%
  group_by(hadm_id) %>%
  mutate(Vanc_Zosyn = !all(is.na(date_Vanc_Zosyn)))

# combining demographics and creatinine tables
Analysis_data <- left_join(Cr_labevents_2, Demographics1)

ggplot(Analysis_data, aes(x = Vanc_Zosyn, y = valuenum)) +
  geom_violin()

pairred_analysis <- c("valuenum", "admits", "flag", "Vanc_Zosyn")

Analysis_data[, pairred_analysis] %>%
  ggpairs(aes(col = Vanc_Zosyn))

table1(data = Analysis_data, ~ valuenum + flag + anchor_age + gender | Vanc_Zosyn, render.continuous.default() = T)

xx <- stats.default(Analysis_data$anchor_age)
with(xx, MAX - MIN) # with(a, b): temporarily perform calculation b on object a
# sprintf(a, b, c):
sprintf("The decimal is %0.2f or %0.1f. The integer is %d. The string is %s. The percentage is %0.1f%%",
        4.222, 5.2222, 7, "string", 0.25444 * 100)

my.render.cont <- function(x) {
  with(stats.default(Analysis_data$anchor_age),
       sprintf("Range(%0.2f ~ %0.1f)", MIN, MAX))
}

table1(data = Analysis_data, ~ valuenum + flag + anchor_age + gender | Vanc_Zosyn, render.continuous = my.render.cont)


# with(a, b): temporarily perform calculation b on object a



