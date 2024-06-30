# -*- coding: utf-8 -*-
"""
Created on Thu Mar 10 06:38:39 2022

@author: Jiageng Liu
"""

import numpy as np
import matplotlib.pyplot as plt
import os

def noise_sub(tractionTXT, energyTXT, prct=60):
    
    filtered_tractionTXT = tractionTXT[:-4] + '_new' + tractionTXT[-4:]
    data1 = np.loadtxt(tractionTXT, dtype=np.float32)
    thr_tractionTXT = np.percentile(data1[:, -1], 60) #you can adjust this
    sel_tractionTXT = set(np.where(data1[:, -1] > thr_tractionTXT)[0])

    with open(tractionTXT, 'r') as f:
        r = 0
        with open (filtered_tractionTXT, 'w') as f1:
            for line in f.readlines():
                tmp = line.split()
                if r in sel_tractionTXT:
                    # if you want to get rid of more noise, either make the threshold larger or subtract the threshold
                    tmp[-1] = str(float(tmp[-1]) - thr_tractionTXT) #if you want to subtract
                    f1.write(' '.join(tmp) + '\n')
                else:
                    f1.write(tmp[0] + ' ' + tmp[1] + ' 0 0 0\n')
                r += 1
    
    
    data = np.loadtxt(energyTXT, dtype=np.float32)
    threshold_energymag = np.percentile(data[:, -4], 60)
    threshold_forcemag = np.percentile(data[:, -3], 60)
    threshold_dismag = np.percentile(data[:, -2], 60)
    threshold_pascalmag = np.percentile(data[:, -1], 60)

    filtered_energyTXT = energyTXT[:-4] + '_new' + energyTXT[-4:]

    # process energy mag
    data[:, -4] -= threshold_energymag
    data[np.where(data[:, -4] < 0), -4] = 0
    
    # process force mag
    data[:, -3] -= threshold_forcemag
    data[np.where(data[:, -3] < 0), -3] = 0
    
    # process dis mag
    data[:, -2] -= threshold_dismag
    data[np.where(data[:, -2] < 0), -2] = 0
    
    # process pascal mag
    data[:, -1] -= threshold_pascalmag
    data[np.where(data[:, -1] < 0), -1] = 0
    np.savetxt(filtered_energyTXT, data)


diretory = "/Volumes/Well_5/"
wells = os.listdir(diretory)

for well in wells:
    if well.startswith("well_05"):
        the_well_PIV_dir = diretory + well + "/" + "PIV_Force/"
        series = os.listdir(the_well_PIV_dir)
        # for serie in series[:2]:
        for serie in series: # for serie in series
            the_serie_PIV_dir = the_well_PIV_dir + serie + "/"
            TractionTXT = the_serie_PIV_dir + "Traction_aligned_" + well + "_"\
                + serie + ".tif_PIV3_disp.txt"
            EnergyTXT = the_serie_PIV_dir + "Energy_forces.txt"
            noise_sub(TractionTXT, EnergyTXT)
            
                