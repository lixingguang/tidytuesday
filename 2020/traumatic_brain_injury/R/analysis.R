# load library
library(tidyverse)

# load library for scrapping from PDF
library(rvest)

# read data from CSV
tbi_age <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-24/tbi_age.csv')
tbi_year <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-24/tbi_year.csv')
tbi_military <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-24/tbi_military.csv')

### EDA tbi_age

# check class
class(tbi_age$age_group)
# convert age_group as character to factor
tbi_age$age_group <- as.factor(tbi_age$age_group)


# see all levels [1] "0-17"  "0-4"   "15-24" "25-34" "35-44" "45-54" "5-14"  "55-64" "65-74" "75+"   "Total"
tbi_age %>% sapply(levels)
# reorder factor levels for age_group
tbi_age$age_group = factor(tbi_age$age_group, levels(tbi_age$age_group)[c(2, 7, 3, 4, 5, 6, 8, 9, 10, 11, 1)])

## Plot
# disable scientific notation
options(scipen = 999)

# Unintentional Falls vs Everything else, across age groups
tbi_age %>% 
filter(age_group != 'Total' & age_group != '0-17') %>% 
ggplot(aes(x=age_group, y=number_est, fill = ifelse(grepl("Unintentional Falls", injury_mechanism), "red", "black"))) 
+ geom_bar(stat = "identity")
+ theme_classic()
+ labs(fill = "Injury Mechanism", y = "Numbers", x = "Age")

# Comparison of Injury Mechanism across Life Span, 
# have each injury mechanism represent on bar geom_bar, Position = Dodge
tbi_age %>% 
filter(age_group != 'Total' & age_group != '0-17' & injury_mechanism != 'Other or no mechanism specified') %>% 
ggplot(aes(x=age_group, y=number_est, fill = injury_mechanism)) 
+ geom_bar(stat = "identity", position = "dodge") 
+ theme_classic() 
+ labs(fill = "Injury Mechanism", y = "Numbers", x = "Age")

# convert injury_mechanism as character to factor
tbi_age$injury_mechanism <- as.factor(tbi_age$injury_mechanism)

# Comparing Injury Mechanisms across Life Span,
# Highlight diverging trend in brain trauma from Unintentional Falls
# manually change colors only for Factors
tbi_age %>% 
filter(age_group != 'Total' & age_group != '0-17' & injury_mechanism != 'Other or no mechanism specified') %>% 
ggplot(aes(x=age_group, y=number_est, fill = injury_mechanism)) 
+ geom_bar(stat = "identity", position = "dodge") 
+ theme_classic() 
+ labs(fill = "Injury Mechanism", y = "Numbers", x = "Age") 
+ scale_fill_manual(values = c("#276419", "#4d9221", "#7fbc41", "#b8e186", "#de77ae", "#e6f5d0"))

# Two levels of diversion (cool vs warm colors); all lighter shades
# highlight Unintentional Falls; only dark shade
injury_across_age_group <- tbi_age %>% 
filter(age_group != 'Total' & age_group != '0-17' & injury_mechanism != 'Other or no mechanism specified') %>% 
ggplot(aes(x=age_group, y=number_est, fill = injury_mechanism)) 
+ geom_bar(stat = "identity", position = "dodge") 
+ theme_classic() 
+ labs(title = "Injuries Across Life-Span", subtitle = "Data from 2006 - 2014", fill = "Injury Mechanism", y = "Numbers", x = "Age") 
+ scale_fill_manual(values = c("#a6cee3", "#b2df8a", "#cab2d6", "#fb9a99", "#e31a1c", "#fdbf6f"))

injury_across_age_group


########----- tbi_year ------########

# change injury_mechanism to factor
class(tbi_year$injury_mechanism)
tbi_year$injury_mechanism <- as.factor(tbi_year$injury_mechanism)

# view factor levels of injury_mechanism
tbi_year %>% sapply(levels)

# plot basic barchart
# display all years separately on x-axis
# note: employ scale_fill_manual to injury_mechanism which is a factor

injury_across_year <- tbi_year %>% 
filter(injury_mechanism != 'Other or no mechanism specified') %>% 
ggplot(aes(x=year, y=number_est, fill=injury_mechanism)) 
# position = fill provides % stacked bar 
+ geom_bar(stat = "identity", position = "fill") 
+ theme_classic() 
# only possible after convert injury_mechanism to factor
+ scale_fill_manual(values = c("#a6cee3", "#b2df8a", "#cab2d6", "#fb9a99", "#e31a1c", "#fdbf6f")) 
# display all years separately
+ scale_x_continuous(breaks = tbi_year$year) 
+ labs(title = "Injuries from 2006 - 2014", subtitle = "Across all age groups", fill = "Injury Mechanism", y = "Observed Numbers", x = "Year")

injury_across_year

## injuries across 'type' (death, ED, hospitalization)
## Note: Intentional self-harm leads to death, more than unintentional falls
## However, unintentional falls dominates ED visit and hospitalization

injury_across_type <- tbi_year %>% 
filter(injury_mechanism != 'Other or no mechanism specified') %>% 
ggplot(aes(x=type, y=number_est, fill=injury_mechanism)) 
+ geom_bar(stat = "identity", position = "fill") 
+ theme_classic() 
+ scale_fill_manual(values = c("#a6cee3", "#b2df8a", "#cab2d6", "#fb9a99", "#e31a1c", "#fdbf6f")) 
+ labs(title = "Injuries from 2006 - 2014", subtitle = "Across Injury Type", fill = "Injury Mechanism", y = "Observed Numbers", x = "Type")

injury_across_type


######------ tbi_military ------######
# NOTE: join by year (factor vs num)

# change year to factor


# change injury_mechanism to factor
class(tbi_year$injury_mechanism)
tbi_year$injury_mechanism <- as.factor(tbi_year$injury_mechanism)

# select only type, injury_mechanism and year
tbi_year %>%
+ select(year, injury_mechanism, type, number_est) -> temp

# join temp with tbi_military
temp <- tbi_military %>%
+ inner_join(temp, by = "year")



###-----EXPERIMENTING change tbi_military$year to factor
# note makes no difference

tbi_military2 <- tbi_military
tbi_military2$year <- as.factor(tbi_military2$year)

tbi_year2 <- tbi_year
tbi_year2$year <- as.factor(tbi_year2$year)

tbi_year2 %>%
+ select(year, injury_mechanism, type, number_est) -> temp

temp <- tbi_military2 %>%
+ inner_join(temp, by = "year")

# plot
ggplot(data = temp, mapping = aes(x=type, y=diagnosed, fill=service)) + geom_bar(stat = 'identity', position = 'fill')

# get age
tbi_age %>%
+ select(age_group, type) -> temp2

# join temp and temp2
temp <- temp2 %>%
+ inner_join(temp, by = "type")

# CANNOT search within 'Unintentional falls' to find severity (equal number of severity categories)
# conclusion: joined data frames not informative: temp, temp2

# read data from PDF
