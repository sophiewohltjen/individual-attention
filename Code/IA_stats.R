##IA_stats.R

# These are all of the statistics run in study 2 of the individual attention paper

# Sophie Wohltjen, 9/21

# read in data

base_dir <- '/Users/sophie/Dropbox/IRF_modeling/individual-attention'

IA_acc <- read.csv(paste(base_dir,'/Analyses/study2/IA_allData.csv',sep=''))
IA_acc$subject <- as.factor(IA_acc$subject)
IA_acc$condition <- as.factor(IA_acc$condition)

IA_acc$rt[IA_acc$subject == 2] <- NA

dprimes <- matrix(,nrow=nrow(IA_acc)/4,ncol = 1)
library(psycho)
for (i in 1:nrow(IA_acc)/4){
  performances <- dprime(IA_acc$n_hit[i],IA_acc$n_fa[i],n_miss = IA_acc$n_miss[i],
                         n_cr = IA_acc$n_cr[i],n_targets = IA_acc$n_targets[i],
                         n_distractors = IA_acc$n_distractors[i])
  dprimes[i] <- performances$dprime
}

IA_acc$dprime <- rep(dprimes,4)

#which condition are you interested in?
cond <- 'standard'

# run the dprime models first
accmodel <- lm(scale(dprime) ~ scale(tmax) + scale(amplitude),data=IA_acc[IA_acc$condition == cond,])
summary(accmodel)

entrainmodel <- lm(scale(dprime) ~ scale(isi_power) + scale(oddball_power), data=IA_acc[IA_acc$condition == cond,])
summary(entrainmodel)

# now reaction time models 
rtmodel <- lm(scale(rt) ~ scale(tmax) + scale(amplitude),data=IA_acc[IA_acc$condition == cond,])
summary(rtmodel)

entrainrtmodel <- lm(scale(rt) ~ scale(isi_power) + scale(oddball_power), data=IA_acc[IA_acc$condition == cond,])
summary(entrainrtmodel)


# recreate Figure 5 plot
library(ggplot2)
p1 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=tmax,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 3700, y= 0.5, label= expression(paste(beta,"= -0.29*")),size=5,fontface="plain") + 
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Time to Peak Pupil Size \n (ms)"))
library(ggExtra)
p1<- ggMarginal(p1,type='histogram')

p2 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=amplitude,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 1.74, y= 0.5, label= expression(paste(beta,"= 0.34**")),size=5,fontface="plain") + 
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Dilation Amplitude \n (Z-Scored Change from Baseline)"))
p2 <- ggMarginal(p2,type='histogram')

p3 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=isi_power,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 5.3, y= 0.5, label= expression(paste(beta,"= 0.22*")),size=5,fontface="plain") +
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Inter-Stimulus Interval Entrainment \n (Power at 0.83Hz)"))
p3<- ggMarginal(p3,type='histogram')

p4 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=oddball_power,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 5.3, y= 0.5, label= expression(paste(beta,"= 0.25*")),size=5,fontface="plain") +
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Deviant-Stimulus Interval Entrainment \n (Power at 0.21Hz)"))
p4<- ggMarginal(p4,type='histogram')

library(cowplot)
gridmodels <- plot_grid(p1,p2,p3,p4,nrow=2,ncol=2)

ggdraw(gridmodels) + 
  draw_label(
    "Task performance (d')",
    #x=0.014,y=0.31,
    x=0.014,y=0.21,
    hjust = 0,
    angle=90,
    size = 26
  )
