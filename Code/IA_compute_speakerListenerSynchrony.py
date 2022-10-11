#!/usr/bin/env python

#IA_compute_speakerListenerSynchrony.py
#created by Sophie Wohltjen, 9/22

# this script will loop through our participants and compute speaker listener synchrony via dtw
# DTW is computed by moving through each story in 3 second windows with 1.5s of overlap, 
# then averaging these values into 6s windows for the final dataset (per Kang & Wheatley, 2017). 


#first, import
import glob

import numpy as np
import pandas as pd

from scipy.signal import detrend
from fastdtw import fastdtw

#a function for windowing the data
def window_stack(a, stepsize=1, winsize=10):
    #subtract the remainder of dividing the data evenly into windows 
    #to get an evenly divisible number for the data to be windowed
    padsize = winsize - np.mod(len(a),winsize)
    a = np.pad(a, (0,padsize), 'median')
    width=int(len(a))
    n = a.shape[0]
    return np.vstack( a[i:i+(winsize):1] for i in range(0,width,int(winsize*stepsize)) if i+winsize < width)

#now preset some variables

stories = ['story3','story15','story16','story17']
storylens = [2453,3660,5746,6827]
storynums = [3,15,16,17]
base_directory = '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
wdir = '{0}/Analyses/study2/listening_task/preprocessed_pupils_indivStories'.format(base_directory)

#here are lists of our participants (we want participants who have BOTH oddball and listening data!)
listensubs = ['001','003','004','005','008','009','010','011','012','013','014','015','016','017','018','020',
          '021','022','027','028','029','030','031','032','036','037','038','039','054','055','056','057',
          '058','059','060','062','063','064','065','066','067','068','069','070','071','072','073','075',
          '076','077','078','079','080','081','082','083','086','087','088','089','090','091','092','093','094',
          '095','096','098','101','102','103','104','106']

oddballsubs = ['001','003','005','008','009','010','011','012','013','014','015','016','017','018','021','022',
           '023','027','028','029','030','031','032','034','036','037','038','039','053','054','055','056',
           '057','058','059','060','061','063','064','065','067','068','069','070','071','072','073','075',
           '077','078','079','080','082','083','086','087','088','089','090','092','093','094','095','096',
           '097','100','101','102','106']

allsubs = [listensub for listensub in listensubs if listensub in oddballsubs]


#now loop through and take all participants' data!
datamatrix_allstories = []
subs_allstories = []
for story,storylen,storynum in zip(stories,storylens,storynums):
    
    datafiles = glob.glob('{0}/*{1}*.txt'.format(wdir,story))

    datamatrix = np.zeros((len(datafiles),storylen))
    subs = []
    
    datafiles_trimmed=[file for file in sorted(datafiles) if file[file.find('Stories')+8:file.find('Stories')+11] in allsubs]
    
    datamatrix_trimmed = np.zeros((len(datafiles_trimmed),storylen))
    subs_trimmed = []
    for num,file in enumerate(sorted(datafiles_trimmed)):
        subs_trimmed.append(file[file.find('Stories')+8:file.find('Stories')+11])
        data = pd.read_csv('{0}'.format(file),sep=',')
        data_trim = data['preproc_pupil'].loc[0:storylen-1]
        datamatrix_trimmed[num,0:len(data_trim)] = data_trim
    
    subs_allstories.append(subs_trimmed)
    datamatrix_allstories.append(datamatrix_trimmed)
    
#we want the trimmed dataset that only includes participants with both oddball and listening data
data = datamatrix_trimmed

#detrend this data
storycuts = [2430,3645,5710,6810]

datamatrix_allstories_detrend = []
for data,storycut in zip(datamatrix_allstories,storycuts):
    datamatrix_detrend = detrend(data[:,0:storycut],axis=1)
    datamatrix_allstories_detrend.append(datamatrix_detrend)

#grab the pupil data from the speakers
speakerdir = '{0}/Analyses/study2/listening_task/preprocessed_pupils/speakers'.format(base_directory)
speakers = ['speaker03','speaker15','speaker16','speaker17']

##winsize is the size of the windows you want, in samples
##stepsize is how much overlap you want 
##(so like a stepsize of 0.5 would 'step' halfway across the first window to make the next window)
threesec = 90
winsize = threesec
stepsize = 0.5

sp_pupils = []
sp_data_stack_allstories = []
for storycut,speaker in zip(storycuts,speakers):

    sp_data = pd.read_csv('{0}/{1}_data_noEB_filt_ds4_10_dt.txt'.format(speakerdir,speaker),header=None)
    sp_pupil = np.array(sp_data[0].loc[1:storycut])
    sp_pupils.append(sp_pupil)
    sp_data_stack = window_stack(sp_pupil,winsize=winsize,stepsize=stepsize)
    sp_data_stack_allstories.append(sp_data_stack)

# loop through and compute dtw in 3s windows with 1.5s overlap
sp_dtw_matrix_allstories = []
sub_matrix_allstories =  []
psize_matrix_allstories = []

for storynum,(storymatrix,storysub,story) in enumerate(zip(datamatrix_allstories_detrend,
                                                           subs_allstories,sp_data_stack_allstories)):
    sp_dtw_matrix = np.zeros((len(storymatrix),len(story)))
    psize_matrix = np.zeros((len(storymatrix),len(story)))
    path_matrix = np.zeros((len(storymatrix),len(story)))
    sub_matrix = np.zeros((len(storymatrix),len(story)))
    print('running dtw for story number {0}'.format(storynum))
    for subnum,(pupils,sub) in enumerate(zip(storymatrix,storysub)):
        pupils_stack = window_stack(pupils,winsize=winsize,stepsize=stepsize)
        psize_matrix[subnum] = np.mean(pupils_stack,axis=1)
        for segnum,(pupil_seg,sp_seg) in enumerate(zip(pupils_stack,sp_data_stack)):
            distance,path = fastdtw(pupil_seg,sp_seg,radius = 15)
            sp_dtw_matrix[subnum,segnum] = distance
            sub_matrix[subnum,segnum] = sub
    psize_matrix_allstories.append(psize_matrix)
    sp_dtw_matrix_allstories.append(sp_dtw_matrix)
    sub_matrix_allstories.append(sub_matrix)
    
# now average into 6s windows and save into a dataframe

alldata = pd.DataFrame()
for num,speaker in enumerate(speakers):
    psize_6sec = np.array([window_stack(pupils,winsize=2,stepsize=1) for pupils in psize_matrix_allstories[num]])
    psize_long = np.reshape(np.mean(psize_6sec,axis=2),(psize_6sec.shape[0]*psize_6sec.shape[1]))
    
    sync_6sec = np.array([window_stack(sync,winsize=2,stepsize=1) for sync in sp_dtw_matrix_allstories[num]])
    sync_long = np.reshape(np.mean(sync_6sec,axis=2),(sync_6sec.shape[0]*sync_6sec.shape[1]))
    
    subs_6sec = np.array([subs[0:int(len(subs)/2)] for subs in sub_matrix_allstories[num]])
    subs_long = np.reshape(subs_6sec,(subs_6sec.shape[0]*(subs_6sec.shape[1])))
    
    story = np.repeat(speaker[7:9],len(subs_long))
    
    data = pd.DataFrame([subs_long,psize_long,sync_long,story]).T
    data.columns=['subid','psize','dtw','story']
    alldata = alldata.append(data,ignore_index=True)

alldata.to_csv('{0}/Analyses/study2/listening_task/pupilsize_sync_allstories_6sec.csv'.format(base_directory))