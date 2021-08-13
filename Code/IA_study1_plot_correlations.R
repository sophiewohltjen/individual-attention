#IA_study1_plot_correlations.R

#Sophie, 4/21
#here is where I read in the csv of correlations and plot them.
library(ggplot2)
library(reshape2)

base_directory <- '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
condition <- 'acc_oddball'

IA_comparecorrs <- read.csv(paste(base_directory,'/Analyses/study1/IA_',condition,'correlations.csv',sep=''))
IA_comparecorrs <- IA_comparecorrs[,2:3]
IA_comparecorrs_melt <- melt(IA_comparecorrs)

# boxplot
ggplot(IA_comparecorrs_melt,aes(x=variable,y=value,)) + geom_boxplot(alpha=0.2,fill='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=30)) +
  geom_segment(x = 1.3,y=0.97,xend=1.7,yend=0.97,size=0.5) +
  geom_text(x = 1.5, y= 0.98, label="***",size=8) + 
  scale_y_continuous(name=("Correlation Values")) +
  scale_x_discrete(name="",labels=c("Within Subjects","Between Subjects"))

mean(IA_comparecorrs$withinsub,na.rm=TRUE)
sd(IA_comparecorrs$withinsub,na.rm=TRUE)
mean(IA_comparecorrs$betweensub,na.rm=TRUE)
sd(IA_comparecorrs$betweensub,na.rm=TRUE)
