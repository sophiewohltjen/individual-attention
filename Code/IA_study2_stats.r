##IA_stats.R

# These are all of the statistics run in study 2 of the manuscript "people who synchronize to a beat also synchronize with other minds"

# Sophie Wohltjen, 9/22

# set some basic vars
base_dir <- '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
#which condition are you interested in?
cond <- 'acc_oddball'

# read in data

# this is the oddball data
IA_acc <- read.csv(paste(base_dir,'/Analyses/study2/oddball_task/IA_allData_1spre_3spost.csv',sep=''))
IA_acc$subject <- as.factor(IA_acc$subject)
IA_acc$condition <- as.factor(IA_acc$condition)
#because we don't have reaction time data for participant 2
IA_acc$rt[IA_acc$subject == 2] <- NA

#calculate dprime
dprimes <- matrix(,nrow=nrow(IA_acc)/4,ncol = 1)
library(psycho)
for (i in 1:nrow(IA_acc)/4){
  performances <- dprime(IA_acc$n_hit[i],IA_acc$n_fa[i],n_miss = IA_acc$n_miss[i],
                         n_cr = IA_acc$n_cr[i],n_targets = IA_acc$n_targets[i],
                         n_distractors = IA_acc$n_distractors[i])
  dprimes[i] <- performances$dprime
}

IA_acc$dprime <- rep(dprimes,4)

# run the dprime models first
library(lme4)
library(lmerTest)

entrainmodel <- lm(scale(dprime) ~ scale(powerSum), data=IA_acc[IA_acc$condition == cond,])
summary(entrainmodel)
#this analysis is included in the supplement
accmodel <- lm(scale(dprime) ~ scale(amplitude) * scale(tmax),
               data=IA_acc[IA_acc$condition == cond,])
summary(accmodel)

#fdr correct the effects we care about for multiple comparisons
p.adjust(c(0.002,0.003,0.8,0.14,0.92,0.7,0.004,0.03,0.001),method='fdr')

# now reaction time models (also in supplement)
rtmodel <- lm(scale(rt) ~ scale(tmax) * scale(amplitude),data=IA_acc[IA_acc$condition == cond,])
summary(rtmodel)

entrainrtmodel <- lm(scale(rt) ~ scale(powerSum), data=IA_acc[IA_acc$condition == cond,])
summary(entrainrtmodel)

#fdr correct the effects we care about for multiple comparisons
p.adjust(c(0.001,0.99,0.3,0.4,0.2,0.08,0.24,0.92,0.09,0.005),method='fdr')

# now read in synchrony data
IRF_synchrony_long <- read.csv(paste(base_dir,'/Analyses/study2/listening_task/pupilsize_sync_allstories_6sec.csv',sep=''))
IRF_synchrony_long <- IRF_synchrony_long[order(IRF_synchrony_long$subid),]
rownames(IRF_synchrony_long) <- 1:nrow(IRF_synchrony_long)
IRF_synchrony_long$story <- as.factor(IRF_synchrony_long$story)
IRF_synchrony_long$subid <- as.factor(IRF_synchrony_long$subid)
subids <- unique(IRF_synchrony_long$subid)
for (sub in subids){
  IRF_synchrony_long$isi_power[IRF_synchrony_long$subid==sub] = IA_acc$isi_power[IA_acc$subject==sub][1]
  IRF_synchrony_long$oddball_power[IRF_synchrony_long$subid==sub] = IA_acc$oddball_power[IA_acc$subject==sub][1]
  IRF_synchrony_long$tmax[IRF_synchrony_long$subid==sub] = IA_acc$tmax[IA_acc$condition == 'acc_oddball' & IA_acc$subject==sub][1]
  IRF_synchrony_long$amplitude[IRF_synchrony_long$subid==sub] = IA_acc$amplitude[IA_acc$condition == 'acc_oddball' & IA_acc$subject==sub][1]
}
IRF_synchrony_long$powerSum <- rowSums(IRF_synchrony_long[,c(6,7)])
IRF_synchrony_long$synchrony <- -log(IRF_synchrony_long$dtw)

#run statistic
model <- lmer(scale(synchrony)  ~ scale(powerSum) + (1|subid) + (1|story),
             data=aggregate(.~subid+story,data=IRF_synchrony_long,FUN=mean))
summary(model)

### now save figures! ###
library(cowplot)
library(gridExtra)
library(grid)
library(ggplot2)
library(ggExtra)

p1 <- ggplot(IA_acc[IA_acc$condition == cond,],aes(x=powerSum,y=dprime)) +
  geom_point(size=4) + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=30),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) +
  annotate("text",x = 9.5, y= 0.5, label= expression(paste(beta,"= 0.36**")),size=8,fontface="plain") +
  scale_y_continuous(name=("Task Performance (d')")) +
  scale_x_continuous(name = ("Oddball Entrainment Synchrony"))
p1<- ggMarginal(p1,type='histogram')

p1 <- grid.arrange(p1, 
                   bottom = textGrob("(Sum of power at 0.21Hz and 0.83Hz)", 
                                     x = 0.5, y = 1, gp = gpar(fontsize = 20)))

p2 <- ggplot(aggregate(.~subid,data=IRF_synchrony_long,FUN=mean),aes(x=powerSum,y=synchrony)) +
  geom_point(size=4) + 
  geom_smooth(method = 'lm',color='black') + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black",size=1),
        plot.title = element_text(hjust = 0.5),text=element_text(size=30),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0))) +
  annotate("text",x = 9.5, y= -3.6, label= expression(paste(beta,"= 0.21**")),size=8,fontface="plain") +
  scale_y_continuous(name=("Pupillary Synchrony (-DTW cost)")) +
  scale_x_continuous(name = ("Oddball Entrainment Synchrony"))
p2 <- ggMarginal(p2,type='histogram')
p2 <- grid.arrange(p2, 
                   bottom = textGrob("(Sum of power at 0.21Hz and 0.83Hz)", 
                                     x = 0.5, y = 1, gp = gpar(fontsize = 20)))

library(cowplot)
plot_grid(p1,p2,nrow=1,ncol=2)

ggsave(file='Figure5.pdf',device='pdf',path='/Users/sophie/Dropbox/IRF_modeling/individual-attention/Figures/',width=15,height=8,units='in')
ggsave(file='Figure5.png',device='png',path='/Users/sophie/Dropbox/IRF_modeling/individual-attention/Figures/',width=15,height=8,units='in')

