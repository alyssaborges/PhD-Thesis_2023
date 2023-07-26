##
# Script: Analyzing the Cell Cycle
#
# Copyright (c) 2023 Alyssa Bergmann Borges
#
#
# Permission Notice:
# I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this script as long as the original source is cited:
# Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
#
# Overview:
# The purpose of this script is to analyze the cell cycle analysis assembled in an excel file providing:
# - Descriptive analysis and finding the average percentage
# - Prepare a bar plot for data visualization
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
library(dplyr)


#Checking working directory
getwd()

#Loading datasets
dat1 <- read.xlsx("CellCycle_FinalSheet.xlsx", sheet=1)

#Changing category of variables
Group.f <- factor(dat1$Group)


#Checking descriptive
describeBy(dat1$Cell_number, group=Group.f)


#Preparing data frame for bar plot (based on numbers)
df <- dat1 %>% group_by(Group) %>% summarise(me = (mean(Cell_number)))
colnames(df) <- c("Cell_cycle_stage", "Cell_number_average")
df

c <- dat1 %>% group_by(Group) %>% summarise(std_dev = (sd(Cell_number)))

df.table <- data.frame(round(df$Cell_number_average,2), round(c$std_dev, 2), df$Cell_cycle_stage)
colnames(df.table) <- c("Average_number", "SD", "Cell_cycle")
df.table # checking the new df
  

# Transform in %
a <- sum(df$Cell_number_average)
b <- df$Cell_number_average/a*100



#Bar plot 
ggplot(data = df.table, aes(x=Cell_cycle, y=Average_number)) + 
  geom_bar(width = 0.5, stat="identity", color="black", fill="#0d4c6d") +
  geom_errorbar(aes(ymin = Average_number, ymax = Average_number + SD), 
                width = 0.2, color = "black", size = 0.6) +
  labs(title= NULL, x= NULL, y = "Cell number") + 
  theme_minimal() + ylim(0,240)




ggsave("CellCycle.svg", width = 10, height = 5, units = "in", dpi = 300)

