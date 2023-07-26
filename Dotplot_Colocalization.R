##
# Script: Dot plot of colocalization analysis 
#
# Copyright (c) 2023 Alyssa Bergmann Borges
#
#
# Permission Notice:
# I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this script as long as the original source is cited:
# Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
#
# Overview:
# The purpose of this script is to analyze the correlation coefficients (Pearson or Spearman) obtained from image analysis and assembled in an excel file providing:
# - Descriptive analysis
# - Prepare a dot plot or violin plot for data visualization
# 
#
# Note:
# Place this script in the same folder in which you have your data. So, it will be easily recognized as the working directory.
# For the colocalization analysis see ImageJ macro
#
#################################################


#Loading packages 
library(openxlsx)
library(ggplot2)
library(psych)
library(ggpubr)
library(RColorBrewer)


#Checking working directory
getwd()

#Loading datasets
dat1 <- read.xlsx("CorrelationResults_EP1-Rab11_AllReplicates.xlsx", sheet=1)

#Changing category of variables
Spearman_num <- as.numeric(dat1$Spearman)
CellCycleStage.f <- factor(dat1$CellCycleStage)


#Placing variables of interest into a new dataset
dat2.table <- data.frame(Spearman_num, CellCycleStage.f)
colnames(dat2.table) <- c("Spearman", "Cell_Cycle")
dat2.table # checking the new df


#Checking descriptives of Pearson_num
describeBy(Spearman_num, group=CellCycleStage.f)


#Dot plot

xLabels <- c("1K1N", "1Kd1N", "2K1N", "2K2N")


dotplot2 <- ggplot(dat2.table, aes(x=CellCycleStage.f, y=Spearman_num)) + 
  geom_dotplot(binaxis = 'y',stackdir = 'center', stackratio = 1.1, dotsize = 0.6, position=position_dodge(0.7)) +
  stat_summary(fun=median, geom="crossbar", size=0.4, color="brown1", width = 0.3) +
  labs(title=NULL, x= NULL, y = "Correlation Coefficient\n") +
  theme_classic() +  theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
                                             axis.title.y = element_text(size = 12, face = "bold"), 
                                             axis.text.x = element_text(size = 9, face = "bold"), 
                                            axis.ticks.x = element_blank(),
                                             aspect.ratio = 5/10) +
  scale_x_discrete(labels = xLabels)
  
dotplot2

ggsave("DotPlot_Correlation_EP1-Rab11.svg", width = 7, height = 5, units = "in", dpi = 300)


#Violin plot

vioplot1 <- ggplot(dat2.table, aes(x=CellCycleStage.f, y=Spearman_num)) + 
  geom_violin(trim = FALSE) +
  scale_fill_brewer(palette="PuRd") +
  stat_summary(fun=median, geom="point", size=2, color="darkgray", position = position_dodge(0.9)) +
  labs(title=NULL, x= NULL, y = "Correlation Coefficient\n") +
  theme_classic() +  
  theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
                                             axis.title.y = element_text(size = 12, face = "bold"), 
                                             axis.text.x = element_text(size = 9, face = "bold"), 
                                             axis.ticks.x = element_blank(),
                                             aspect.ratio = 5/10) +
  scale_x_discrete(labels = xLabels)
  

vioplot1
ggsave("Correlation_Violin.svg", width = 10, height = 5, units = "in", dpi = 300)

