##
# Script: Analyzing Tendency of Area Measurements
#
# Copyright (c) 2023 Alyssa Bergmann Borges
#
#
# Permission Notice:
# I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this script as long as the original source is cited:
# Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
#
# Overview:
# The purpose of this script is to generate a scatter plot to summarize all area measurements and the tendency of the data
# 
#
# Note:
# Place this script in the same folder in which you have your data. So, it will be easily recognized as the working directory.
#
#################################################

#loading packages
library(ggplot2)
library(dplyr)
library(openxlsx)

#Checking working directory
getwd()


#Loading datasets
dat1 <- read.xlsx("Results_AllData.xlsx", sheet=1)


#Transforming variables
Stage.f <- factor(dat1$Stage) #groups to be displayed on X-axis
Stage.f

Area.n <- as.numeric(dat1$Area) #numerical data of Y-axis
Area.n

Group.f <- factor(dat1$Group, levels = c("Cell_Surface", "Endosome", "Clathrin", "Lysosome")) #ordering the different measurements taken (in this case, different cellular aspects)
Group.f


#Creating table for the chart
dat1.table <- data.frame(Stage.f, Area.n, Group.f)
dat1.table # checking the new df


#Plotting (data are randomly distributed within each group in the X-axis)

ggplot(dat1.table, aes(x = jitter(as.numeric(Stage.f)), y = Area.n, color = Stage.f)) +
  geom_jitter(width = 0.35, height = 0, size = 1.5) +
  geom_smooth(aes(group = 1), se=TRUE, level=0.95, fullrange=TRUE) +
  scale_y_continuous() +
  facet_wrap(~ Group.f, scales = "free_y", ncol = 1, strip.position = "left") +
  theme(strip.text = element_text(size = 12, margin = margin(b = 10)),
        strip.background = element_rect(fill = "white", color = NULL, size = 1),
        panel.spacing = unit(1, "lines"),
        axis.text.y = element_text(hjust = 1, margin = margin(r = 5)),
        axis.title.y = element_blank()) +
  theme_bw()
 
ggsave("ScatterPlot_.svg", width = 15, height = 20, units = "in", dpi = 300)
