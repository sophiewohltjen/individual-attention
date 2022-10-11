#!/usr/bin/env python

#IA_Preprocessing.py
#created by Sophie Wohltjen, 11/28/18

#Preprocessing_Functions is the python script I wrote myself. 
#Here I'm just importing all the functions I wrote for preprocessing my pupil data. 
#I find that defining the functions I want to use in another file and then importing them 
#makes this script cleaner and easier to understand
from Preprocessing_Functions import datacheck, window_stack, lin_interpolate, median_filt, butter_lowpass_filter, detrending
#os is the operating system module. you call os when you want to change directories or things like that.
import os
#glob is a module that allows you to use global variables, such as *
import glob
#here, I'm importing the module 'pandas' as 'pd', so that when I call it, I don't have to continually type pandas
#pandas is a module designed for dealing with large dataframes
import pandas as pd
#same idea with numpy, I call it a lot, so I import it using a shorter name. Numpy does linear algebra operations.
import numpy as np
#seaborn is a plotting function, makes very pretty figures
import seaborn as sns
#same with matplotlib, it's the main python plotting module
import matplotlib.pyplot as plt

#will need to be changed as base directory changes
base_directory = "/Users/Sophie/Dropbox/IRF_modeling/individual-attention"
#which study? can be "study1", "study2", or "study3"
study = "study2"

#get the raw data files using a global variable.
rawfiles = glob.glob("{0}/Data/{1}/raw_pupils/*.txt".format(base_directory,study))

#for saving the threshold vals
#open a writable version of a new file
threshval_file=open('{0}/Analyses/{1}/threshold_log.csv'.format(base_directory,study),'ab')
#header for the file
header1='subject'
header2='SD threshold'
header3='window size'
#using numpy to save the headings to the new file. I'll write data to this file later.
np.savetxt(threshval_file,np.c_[[header1],[header2],[header3]],fmt='%s',delimiter=',')

#loop through the raw data files that I want to preprocess
for file in sorted(rawfiles):
    #set up the variable that we'll use to break out of the while loop below
	clean = '0'
	# starting thresholds for data interpolation
	val = -1
	winsize = 450
	
	while clean == '0':
		print(file)
        #this is a variable I'll use to skip over subjects that have really messy data
		skip=1
		#read data file into a pandas dataframe
		alldata = pd.read_csv(file,sep='\t')
        #read into a numpy array the variable from the dataframe that we care about
		data_withevents = np.array(alldata['Pupil Diameter Left [mm]'])
        #find locations of stimulus onsets in the data
		events = np.array(np.where(data_withevents == '-'))
        #delete those from the array because we don't care about them right now
		data = np.array(np.delete(data_withevents,np.where(data_withevents == '-')),dtype=float)
        #trim the zeros from the end of the data where subs took off glasses
		data = np.trim_zeros(data,trim='b')
	
		#check data
        #if the data was never recorded (due to glasses malfunction), the array will be empty. This is checking for that case and skipping the subject if so.
		if data.size == 0:
			skip = '0'
			break
		
        #this is calling the function "datacheck" from my other script, which outputs a percentage of data that will need to be removed
		dataremoved = datacheck(data,threshold=0)
        
        #check whether the data exceeds my 25% threshold
		if dataremoved > 25:
            #print the amount of data that will need to be removed
			print(dataremoved)
            #prompt user for decision on whether to keep preprocessing or to skip the subject
			skip = input('This data is messy. should we keep preprocessing this subject? Type 1 for yes and 0 for no: ')
			if skip == '0':
				break

		#interpolate data in windows of varying size based on clean-ness of data
		data_noEB_slidewin = []
		#Break the data into chunks using a windowing function I wrote in the other script
		data = window_stack(data,stepsize=1,winsize=winsize)
		#interpolate the windowed data
		overflow = []
        #loop through all the data chunks
		for window in data:
			#see whether there's overflow from the last window (this will happen if there's a bunch of noisy data at the end of the previous window)
			if len(overflow) > 0:
				#if there is, add it on to the current window
				window = np.insert(window,0,overflow)
				overflow = []
			#interpolate each window using an interpolation function I wrote in the other script
			data_noEB = lin_interpolate(window,threshold='zscore',val=val,padding=5,n_samples=10)
			#see whether there was data cut off this window
			if len(data_noEB) < len(window):
				#add it to the overflow if so
				overflow = window[(len(data_noEB)-1):-1]
			data_noEB_slidewin.append(data_noEB)
		#concatenate it all together
		data_noEB_slidewin = np.concatenate(data_noEB_slidewin)
		#for manual window/zscore manipulation:
		#plot the current data so we can see how messy it is
		fig, ax = plt.subplots(figsize=(15,3))
		plt.plot(data_noEB_slidewin)
		plt.show()
		
		#does it look good?
		clean = input('Does this data look alright? Type 1 for yes and 0 for no: ')
		#change thresholding if it doesn't look good
		if clean == '0':
			val = int(input('please type the SD threshold you would like: '))
			winsize = int(input('please type the window size you would like: '))
	
	if skip == '0':
		continue		
	#median filter data using function I wrote in the other script
	data_noEB_filt = median_filt(data_noEB_slidewin,filtsize=5)
	
	#lowpass filter data using function I wrote in the other script
	data_noEB_filt_10 = butter_lowpass_filter(data_noEB_filt, cutoff=10, fs=60, order=5)
	
	#detrend data using function I wrote in the other script
#data_noEB_filt_10_dt = detrending(data_noEB_filt_10)
    
    #save the files
	pupildir="{0}/Analyses/{1}/preprocessed_pupils".format(base_directory,study)
	if study == "study1":
		sub = file[file.find('raw_pupils')+11:file.find('raw_pupils')+16]
	elif study == "study2":
		sub = file[file.find('raw_pupils')+11:file.find('oddball')-1]
		if len(sub) < 3:
			while(len(sub) < 3):
				sub = '0' + sub
	elif study == "study3":
		if file.find('listen') == -1:
			sub = file[file.find('raw_pupils')+11:file.find('speak')-1]
		else:
			sub = file[file.find('raw_pupils')+11:file.find('listen')-1]
		if len(sub) < 3:
			while(len(sub) < 3):
				sub = '0' + sub
	
	np.savetxt("{0}/{1}_noEB_filt_10_lefteye.txt".format(pupildir,sub),data_noEB_filt_10)
	
	#append the final thresholding vals to a csv
	np.savetxt(threshval_file,np.c_[[sub],[val],[winsize]],fmt='%s',delimiter=',')
	
	#if we want to save the event files (but this requires some manual cleaning afterward which has already been done)
	#eventdir="{0}/Analyses/{1}/events".format(base_directory,study)
	#np.savetxt("{0}/{1}_events.txt".format(eventdir,sub),events.astype(int))
    
threshval_file.close()

#thresh_vals.append([file[44:-8],val,winsize])
#and save all thresholding vals to a csv
#np.savetxt("thresholds.csv",thresh_vals)
