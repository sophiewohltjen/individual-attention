#!/usr/bin/env python

#IA_study1_mannWhitneyU.py
#created by Sophie Wohltjen, 8/21

import os

import numpy as np
import pandas as pd

from scipy.stats import mannwhitneyu,pearsonr
from math import sqrt

conditions = ['acc_oddball','standard','novel','omission']
base_directory = '/Users/sophie/Dropbox/IRF_modeling/individual-attention'
pre = 1
post = 3

for condition in conditions:
    wdir = '{0}/Analyses/study1/oddball_task'.format(base_directory)
    ARPRs = pd.read_csv('{0}/IA_{1}means_{2}spre_{3}spost.csv'.format(wdir,condition,pre,post))
    entrainVals = pd.read_csv('{0}/IA_allData_{1}spre_{2}spost.csv'.format(wdir,pre,post))
    entrainVals_cond = entrainVals.loc[entrainVals['condition'] == condition]
    
    withinsub=[]
    betweensub=[]
    #run for pupil responses
    for num,column in enumerate(ARPRs.columns):
        for num2,column2 in enumerate(ARPRs.columns):
            if num == num2:
                continue 
            elif num > num2:
                continue
            elif column[3:6] == column2[3:6]:
                r,p = pearsonr(ARPRs[column],ARPRs[column2])
                withinsub.append(r)
            else:
                r,p = pearsonr(ARPRs[column],ARPRs[column2])
                betweensub.append(r)
    
    u,p = mannwhitneyu(withinsub,betweensub)
    cohens_d = (np.mean(withinsub) - np.mean(betweensub)) / (sqrt((np.std(withinsub) ** 2 + np.std(betweensub) ** 2) / 2))
    
    print('condition: {0}\nU = {1}\np = {2}\nd = {3}'.format(condition,u,p,cohens_d)); 
    
    withinsub_pad = np.pad(np.array(withinsub),(0,(len(betweensub)-len(withinsub))),'constant',constant_values=np.nan)
    both_samples = np.array([withinsub_pad,betweensub])
    IA_plot_dist = pd.DataFrame(both_samples.transpose())
    IA_plot_dist.columns = ["withinsub","betweensub"]
    
    IA_plot_dist.to_csv('{0}/Analyses/study1/oddball_task/IA_{1}correlations.csv'.format(base_directory,condition))
    
    #now run for entrainment synchrony
    withinsub=[]
    betweensub=[]
    
    for row in entrainVals_cond.iterrows():
        for row2 in entrainVals_cond.iterrows():
            if row[0] == row2[0]:
                continue 
            elif row[0] > row2[0]:
                continue
            elif row[1][0][0:3] == row2[1][0][0:3]:
                diff = abs(row[1][13] - row2[1][13])
                withinsub.append(diff)
            else:
                diff = abs(row[1][13] - row2[1][13])
                betweensub.append(diff)
                
    u,p = mannwhitneyu(withinsub,betweensub)
    cohens_d = (np.mean(withinsub) - np.mean(betweensub)) / (sqrt((np.std(withinsub) ** 2 + np.std(betweensub) ** 2) / 2))
    
    print('entrainment (may be repeated!): {0}\nU = {1}\np = {2}\nd = {3}'.format(condition,u,p,cohens_d)); 
    
    withinsub_pad = np.pad(np.array(withinsub),(0,(len(betweensub)-len(withinsub))),'constant',constant_values=np.nan)
    both_samples = np.array([withinsub_pad,betweensub])
    IA_plot_dist = pd.DataFrame(both_samples.transpose())
    IA_plot_dist.columns = ["withinsub","betweensub"]
    
    IA_plot_dist.to_csv('{0}/Analyses/study1/oddball_task/IA_{1}correlations_entrain.csv'.format(base_directory,condition))
