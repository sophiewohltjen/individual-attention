##IA_stats.R

# These are all of the statistics run in study 2 of the individual attention paper

# Sophie Wohltjen, 9/21

# read in data

base_dir <- '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
IA_acc <- read.csv(paste(base_dir,'/Analyses/study1/IA_allData_localEpoch.csv',sep=''))
IA_acc <- read.csv(paste(base_dir,'/Analyses/study2/IA_allData_localEpoch.csv',sep=''))
#if this is study 1, make subject-level var
for (i in c('107','108','109','110','111','112','113','114')){
  IA_acc$sub_rep[grepl(i,IA_acc$subject) == TRUE] <- i
}
IA_acc$sub_rep <- as.factor(IA_acc$sub_rep)
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
cond <- 'acc_oddball'

# run the dprime models first
accmodel <- lm(scale(dprime) ~ scale(amplitude) * scale(tmax),
               data=IA_acc[IA_acc$condition == cond,])
summary(accmodel)

# if study 1
accmodel <- lmer(scale(dprime) ~ scale(amplitude) * scale(tmax) + (1|sub_rep),
                 data=IA_acc[IA_acc$condition == cond,])
summary(accmodel)

entrainmodel <- lmer(scale(dprime) ~ scale(powerSum) + (1|sub_rep), 
                     data=IA_acc[IA_acc$condition == cond,])
summary(entrainmodel)

entrainmodel <- lm(scale(dprime) ~ scale(powerSum), data=IA_acc[IA_acc$condition == cond,])
summary(entrainmodel)

#fdr correct the effects we care about for multiple comparisons
p.adjust(c(0.002,0.003,0.8,0.14,0.92,0.7,0.004,0.03,0.001),method='fdr')

# now reaction time models 
rtmodel <- lm(scale(rt) ~ scale(tmax) * scale(amplitude),data=IA_acc[IA_acc$condition == cond,])
summary(rtmodel)

entrainrtmodel <- lm(scale(rt) ~ scale(powerSum), data=IA_acc[IA_acc$condition == cond,])
summary(entrainrtmodel)

entraindprimemodel <- lm(scale(dprime) ~ scale(rt),data=IA_acc[IA_acc$condition == cond,])
summary(entraindprimemodel)

#fdr correct the effects we care about for multiple comparisons
p.adjust(c(0.001,0.99,0.3,0.4,0.2,0.08,0.24,0.92,0.09,0.005),method='fdr')

library(interactions)
interact_plot(rtmodel, pred = tmax, modx = amplitude, 
              plot.points = TRUE,
              data=IA_acc[IA_acc$condition == cond,],
              x.label = "tmax",y.label = "reaction time",
              legend.main = "amplitude") + 
  theme(plot.title = element_text(hjust = 0.5),text=element_text(size=15))

library(ggplot2)
ggplot(IA_acc[IA_acc$condition == cond,],aes(x=amplitude,y=dprime)) +
#ggplot(IA_acc,aes(x=loc_amp,y=loc_tmax,color=condition)) +
#ggplot(IA_acc[IA_acc$condition == cond,],aes(x=loc_amp,y=oddball_power)) +
  geom_point(size=3) + 
  geom_smooth(method='lm') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15))  

ggplot(IA_acc[IA_acc$condition == cond,],aes(x=avg_tmaxdiff,y=avg_ampdiff,color=dprime)) +
  geom_point(size=5,alpha=0.8) + 
  #geom_smooth(method='lm',color='black') + 
  scale_color_gradient2(name="dprime",midpoint=2.6,low='red',high='blue',breaks=c(0.5,1.6,2.7,3.8,4.9),
                        labels=c("0.5"," "," "," ","4.9"), 
                        guide = guide_colorbar(title.position="top",direction="horizontal",
                                               barwidth = 9.5)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) 
  
ggplot(IA_acc,aes(x=tmax,color=condition)) +
  geom_density(size=2) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) 
  
test<- lm(scale(amplitude) ~ scale(tmax),data=IA_acc[IA_acc$condition == cond,])
summary(test)
#without outlier?
IA_acc$tmax[IA_acc$tmax < 0] <- NA
IA_acc$isi_power[IA_acc$tmax < 0] <- NA
IA_acc$oddball_power[IA_acc$tmax < 0] <- NA

#features of irf models
iamodel <- lm(scale(dprime) ~ scale(avg_tmaxdiff) + scale(avg_ampdiff) + scale(powerDiff),data=IA_acc[IA_acc$condition == cond,])
summary(iamodel)


# recreate Figure 5 plot
library(ggplot2)
p1 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=tmax,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 2600, y= 0.5, label= expression(paste(beta,"= 0.18")),size=5,fontface="plain") + 
  scale_y_continuous(name=("Task Performance (d')")) +
  scale_x_continuous(name = ("Time to Peak Pupil Size \n (ms)"))
library(ggExtra)
p1<- ggMarginal(p1,type='histogram')

p2 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=amplitude,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 0.7, y= 0.5, label= expression(paste(beta,"= 0.02")),size=5,fontface="plain") + 
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Dilation Amplitude \n (Z-Scored Change from Baseline)"))
p2 <- ggMarginal(p2,type='histogram')

p3 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=powerSum,y=dprime)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 9.2, y= 0.5, label= expression(paste(beta,"= 0.36**")),size=5,fontface="plain") +
  scale_y_continuous(name=("Task Performance (d')")) +
  scale_x_continuous(name = ("Oddball Entrainment Synchrony\n (Sum of power at 0.21Hz and 0.83Hz)"))
p3<- ggMarginal(p3,type='histogram')

p4 <- ggplot(aggregate(.~subid,data=IRF_synchrony_long,FUN=mean),aes(x=tmax,y=synchrony)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 1900, y= -3.6, label= expression(paste(beta,"= -0.31**")),size=5,fontface="plain") + 
  scale_y_continuous(name=("Pupillary Synchrony (-DTW cost)")) +
  scale_x_continuous(name = ("Time to Peak Pupil Size \n (ms)"))
library(ggExtra)
p4 <- ggMarginal(p4,type='histogram')

p5 <- ggplot(aggregate(.~subid,data=IRF_synchrony_long,FUN=mean),aes(x=amplitude,y=synchrony)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 1.7, y= -3.6, label= expression(paste(beta,"= 0.37***")),size=5,fontface="plain") + 
  scale_y_continuous(name=("")) +
  scale_x_continuous(name = ("Dilation Amplitude \n (Z-Scored Change from Baseline)"))
p5 <- ggMarginal(p5,type='histogram')

p6 <- ggplot(aggregate(.~subid,data=IRF_synchrony_long,FUN=mean),aes(x=powerSum,y=synchrony)) +
  geom_point() + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=15)) +
  annotate("text",x = 9.2, y= -3.6, label= expression(paste(beta,"= 0.21**")),size=5,fontface="plain") +
  scale_y_continuous(name=("Pupillary Synchrony (-DTW cost)")) +
  scale_x_continuous(name = ("Oddball Entrainment Synchrony\n (Sum of power at 0.21Hz and 0.83Hz)"))
p6<- ggMarginal(p6,type='histogram')


library(cowplot)
plot_grid(p3,p6,nrow=1,ncol=2)
gridmodels <- plot_grid(p1,p2,p3,p4,p5,p6,nrow=2,ncol=3)

ggdraw(gridmodels) #+ 
  #draw_label(
    #"Task performance (d')",
    ##x=0.014,y=0.31,
    #x=0.012,y=0.15,
    #hjust = 0,
    #angle=90,
    #size = 26
  #)

## correlate all variables with each other
test <- reshape(IA_acc, timevar=c("condition"), idvar=c("subject"), dir="wide")
test_usedcos <- test[,c(4,11,12,13,14,2,3,16,17,30,31,44,45)]
simMat = cor(test_usedcos,use="complete.obs")
simMat_df <- melt(simMat)
library(viridis)
ggplot(data = simMat_df, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile() + 
  scale_fill_viridis(option='D') +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

## try getting subject level correlation
tmax_diffs=matrix(nrow=3,ncol=1)
amp_diffs=matrix(nrow=3,ncol=1)
for (sub in unique(IA_acc$subject)){
  tmax_sub <- IA_acc$loc_tmax[IA_acc$subject == sub]
  amp_sub <- IA_acc$loc_amp[IA_acc$subject == sub]
  power_diff <- abs(IA_acc$oddball_power[IA_acc$subject == sub] - IA_acc$isi_power[IA_acc$subject == sub])
  for (i in 2:4){
    tmax_diffs[i-1] <- tmax_sub[1] - tmax_sub[i]
    amp_diffs[i-1] <- amp_sub[1] - amp_sub[i]
  }
  IA_acc$avg_ampdiff[IA_acc$subject == sub] <- mean(amp_diffs)
  IA_acc$avg_tmaxdiff[IA_acc$subject == sub] <- mean(tmax_diffs)
  IA_acc$powerDiff[IA_acc$subject == sub] <- power_diff
}
