#!/usr/bin/env python

#Preprocessing_Functions.py
#created by Sophie Wohltjen, 11/08/18
#These are all the functions I may ever need to preprocess pupil data, packaged into one 
#neat and tidy script so I can call them at will based on the pupillometry question I'm 
#asking. 

#Step 1 -- import everything I'll maybe need
from scipy.interpolate import CubicSpline, interp1d
from scipy.signal import medfilt, butter, lfilter, detrend, decimate
from scipy.stats import binned_statistic, zscore
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
import seaborn as sns

#should we throw out the subject?
#def is the command used to define a function
#define the function "datacheck", which accepts a dataset and a threshold value as arguments
def datacheck(data,threshold='zscore'):
	#basically right now this function only has the capability to run on zscore or zero thresholds, so it isn't very flexible
	if threshold == 'zscore':
		ind = np.array(np.where(zscore(data) <= -2)).flatten()#find samples recorded during blinks (2 SDs below mean)
		dataremoved = float(len(ind)) / len(data) * 100 #calculate percentage of data that is blink or noise
		if ind.size == 0:
			ind = np.array(np.where(data == 0)).flatten() #find samples recorded during blinks (data equals zero)
			dataremoved = float(len(ind)) / len(data) * 100
	else:
		ind = np.array(np.where(data == 0)).flatten() #find samples recorded during blinks (data equals zero)
		dataremoved = float(len(ind)) / len(data) * 100 #calculate percentage of data removed 
	return dataremoved
	
##winsize is the size of the windows you want, in samples
##stepsize is how much overlap you want 
##(so like a stepsize of 0.5 would 'step' halfway across the first window to make the next window)
def window_stack(a, stepsize=.5, winsize=600):
	#pad the remainder of dividing the data evenly into windows
	#to get an evenly divisible number for the data to be windowed
	padsize = winsize - np.mod(len(a),(winsize)) #get the amount of data that you'll need to pad
	a = np.pad(a, (0,padsize), 'median') #pad it
	width=int(len(a))
	n = a.shape[0]
	#this is the actual code breaking the data into stacked windows
	return np.vstack( a[i:i+(winsize):1] for i in range(0,width,int(winsize*stepsize)))
	
#linearly interpolate
#accepts a data matrix, "val" is the zscore threshold the function uses to find bad data
#n_samples is the number of samples on either side of the noise that the function will use to interpolate
#padding is the number of samples interpolated on either side of the noise to avoid interpolation spikes
def lin_interpolate(data,threshold='zscore',val=-2,padding=5,n_samples=10):
	if threshold == 'zscore':
		ind = np.array(np.where(zscore(data) <= val)).flatten()#find samples recorded during blinks (2 SDs below mean, unless val is different)
		blink_ind = np.split(ind, np.where(np.diff(ind) > 15)[0]+1)#split indexed samples into groups of blinks
		data_noEB = np.copy(data) #copy data to interpolate over
	else:
		ind = np.array(np.where(data == 0)).flatten()#find samples recorded during blinks (data equals zero)
		blink_ind = np.split(ind, np.where(np.diff(ind) > 15)[0]+1) #split indexed samples into groups of blinks
		data_noEB = np.copy(data) #copy data to interpolate over
    #loop through each group of blinks
	for blinks in blink_ind:
		if blinks.size == 0:
			continue
        #create a vector of data and sample numbers before and after the blink
		befores = np.arange((blinks[0] - (n_samples+padding)),(blinks[0]-padding))
		afters = np.arange(blinks[-1]+(1+padding),blinks[-1]+(1+n_samples+padding))
        #this if statement is a contingency for when the blinks occur at the end of the dataset. it deletes the blink rather than interpolating
		if any(afters > len(data)-1):
			data_noEB = data_noEB[0:blinks[0]-1]
		else:
            #this is the actual interpolation part. you create your model dataset to interpolate over
			x = np.append(befores,afters)
			y = np.append(data[befores],data[afters])
            #then interpolate it
			li = interp1d(x,y)
            #create indices for the interpolated data, so you can return it to the right segment of the data
			xs = range(blinks[0]-padding,blinks[-1]+(1+padding))
            #I'm actually not sure that you need these two variables anymore, but they're still in here for some reason.
			x_stitch = np.concatenate((x[0:n_samples],xs,x[n_samples:]))
			y_stitch = np.concatenate((y[0:n_samples],li(xs),y[n_samples:]))
            #put the interpolated vector into the data
			np.put(data_noEB,xs,li(xs))
	return data_noEB

#median filter 
#(kind of redundant, but I put it in so I don't have to import a bunch of disparate things in my actual preprocessing script)
def median_filt(data,filtsize=5):
    #this is a filtering function I got from the package "scipy"
	data_filt = medfilt(data, filtsize) 
	return data_filt

#lowpass butterworth filtering function
def butter_lowpass(cutoff, fs, order=5):
    #get nyquist frequency
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    #this is another filtering function from scipy
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def butter_lowpass_filter(data, cutoff=10, fs=60, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    #and another filtering function from scipy
    data_lp10 = lfilter(b, a, data)
    return data_lp10


#detrend
#(again kind of redundant but makes things simpler)
def detrending(data):
	data_dt = detrend(data)
	return data_dt


  
