##
# Script: Analyzing Area Measurements
#
# Copyright (c) 2023 Alyssa Bergmann Borges
#
#
# Permission Notice:
# I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this script as long as the original source is cited:
# Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
#
# Overview:
# The purpose of this script is to analyze area measurements assembled in an excel file providing:
# - Descriptive analysis
# - Prepare a dot plot for data visualization
# - Normality check (via QQ plot)
# - Variance analysis (one-way ANOVA) with Tukey range test as post hoc
#
#
#
# Note:
# Place this script in the same folder in which you have your data. So, it will be easily recognized as the working directory.
#
#################################################


#Loading packages 
library(openxlsx)
library(ggplot2)
library(psych)
library(tidyr)
library(rstatix)
library(ggpubr)


#Checking working directory
getwd()

#Loading datasets
dat1 <- read.xlsx("Results.xlsx", sheet=1)

#Changing category of variables
Area_num <- as.numeric(dat1$Area)
Stage.f <- factor(dat1$Stage) # this is the group


#Placing variables of interest into a new dataset
dat2.table <- data.frame(Area_num, Stage.f)
dat2.table # checking the new df


#Descriptive statistics of numerical variable
describeBy(Area_num, group=Stage.f)


#Dot plot

xLabels <- c("1K1N", "1Kd1N", "2K1N", "2K2N") #name according to your groups

dplot1 <- ggplot(dat2.table, aes(x=Stage.f, y=Area_num)) + 
  geom_dotplot(binaxis = 'y',stackdir = 'center', stackratio = 1.1, dotsize = 0.6, color="grey16", fill="grey16") +
  stat_summary(fun=median, geom="crossbar", size=0.4, color="brown1", width = 0.3) +
  labs(title=NULL, x= NULL, y = "Cell area") +
  theme_classic() +  theme_classic() + theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
                                             axis.title.y = element_text(size = 12, face = "bold"), 
                                             axis.text.x = element_text(size = 9, face = "bold"), 
                                             axis.ticks.x = element_blank(),
                                             aspect.ratio = 5/10) +
  scale_x_discrete(labels = xLabels)

dplot1

#ggsave("Area_CLC_ManualThreshold.png", width = 5, height = 5, units = "in", dpi = 300) #use this if you don't want to modify the file in 
ggsave("DotPlot_Cell-area.svg", width = 5, height = 5, units = "in", dpi = 300) # use this to modify colors and other aspects in a graphic design software


#### Checking variance of the mean

##Normality

#QQ plot (You can also inspect with a normality test, such as Shapiro-Wilk but it depends on your N. With N > 50 use visual inspection)
dat2.table %>%
  ggplot(aes(sample = Area_num)) +
  geom_qq() + geom_qq_line() +
  facet_wrap(~Stage.f, scales = "free_y")


#ANOVA (only this analysis if your data is normally distributed)
res.aov <- aov(Area_num ~ Stage.f, data = dat2.table)
summary(res.aov)


#Post-hoc
TukeyHSD(res.aov)
