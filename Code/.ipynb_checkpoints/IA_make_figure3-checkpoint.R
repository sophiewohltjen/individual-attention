#IA_study1_plot_correlations.R

#Sophie, 4/21
#here is where I read in the csv of correlations and plot them.
library(ggplot2)
library(reshape2)
library(cowplot)

base_directory <- '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
condition <- 'acc_oddball'

#do you want to look at entrainment similarity? 1 = yes, 0 = no
#This will plot both correlations and similarity scores next to one another
entrain <- 1

IA_comparecorrs <- read.csv(paste(base_directory,'/Analyses/study1/oddball_task/IA_',condition,'correlations.csv',sep=''))
IA_comparecorrs <- IA_comparecorrs[,2:3]
IA_comparecorrs_melt <- melt(IA_comparecorrs)

if (entrain){
  IA_comparecorrs_e <- read.csv(paste(base_directory,'/Analyses/study1/oddball_task/IA_',condition,'correlations_entrain.csv',sep=''))
  IA_comparecorrs_e <- IA_comparecorrs_e[,2:3]
  IA_comparecorrs_e_melt <- melt(IA_comparecorrs_e)
  
  p1 <- ggplot(IA_comparecorrs_melt,aes(x=variable,y=value,)) + geom_boxplot(alpha=0.2,fill='black') + 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
          plot.title = element_text(hjust = 0.5),text=element_text(size=30),
          axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) +
    geom_segment(x = 1.3,y=0.97,xend=1.7,yend=0.97,size=0.5) +
    geom_text(x = 1.5, y= 0.98, label="***",size=8) + 
    scale_y_continuous(name=("Correlation Values")) +
    scale_x_discrete(name="Pupil Responses to Target Tones",labels=c("Within Subjects","Between Subjects"))
  
  p2 <- ggplot(IA_comparecorrs_e_melt,aes(x=variable,y=value,)) + geom_boxplot(alpha=0.2,fill='black') + 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
          plot.title = element_text(hjust = 0.5),text=element_text(size=30),
          axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) +
    geom_segment(x = 1.3,y=11,xend=1.7,yend=11,size=0.5) +
    geom_text(x = 1.5, y= 11.2, label="***",size=8) + 
    scale_y_continuous(name=("Difference Scores")) +
    scale_x_discrete(name="Entrainment Synchrony",labels=c("Within Subjects","Between Subjects"))
  
  plot_grid(p1,p2)
  ggsave(file='Figure3.pdf',device='pdf',path='/Users/sophie/Dropbox/IRF_modeling/individual-attention/Figures/',width=15,height=8,units='in')
  ggsave(file='Figure3.png',device='png',path='/Users/sophie/Dropbox/IRF_modeling/individual-attention/Figures/',width=15,height=8,units='in')
  
} else {
  
  # boxplot
  ggplot(IA_comparecorrs_melt,aes(x=variable,y=value,)) + geom_boxplot(alpha=0.2,fill='black') + 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
          plot.title = element_text(hjust = 0.5),text=element_text(size=30)) +
    geom_segment(x = 1.3,y=0.97,xend=1.7,yend=0.97,size=0.5) +
    geom_text(x = 1.5, y= 0.98, label="***",size=8) + 
    scale_y_continuous(name=("Correlation Values")) +
    scale_x_discrete(name="",labels=c("Within Subjects","Between Subjects"))
}

print(paste("within subject mean = ",mean(IA_comparecorrs$withinsub,na.rm=TRUE)))
print(paste("within subject SD = ",sd(IA_comparecorrs$withinsub,na.rm=TRUE)))
print(paste("between subject mean = " ,mean(IA_comparecorrs$betweensub,na.rm=TRUE)))
print(paste("between subject SD = ",sd(IA_comparecorrs$betweensub,na.rm=TRUE)))

print(paste("within subject entrainment mean = ",mean(IA_comparecorrs_e$withinsub,na.rm=TRUE)))
print(paste("within subject entrainment SD = ",sd(IA_comparecorrs_e$withinsub,na.rm=TRUE)))
print(paste("between subject entrainment mean = ",mean(IA_comparecorrs_e$betweensub,na.rm=TRUE)))
print(paste("between subject entrainment SD = ",sd(IA_comparecorrs_e$betweensub,na.rm=TRUE)))