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

for condition in conditions:
	wdir = '{0}/Analyses/study1'.format(base_directory)
	ARPRs = pd.read_csv('{0}/IA_{1}means.csv'.format(wdir,condition))
	
	withinsub=[]
	betweensub=[]
	
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
	
	IA_plot_dist.to_csv('{0}/Analyses/study1/IA_{1}correlations.csv'.format(base_directory,condition))
