#!/usr/bin/python3

import glob
import sys
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
mpl.use('Agg')

#
SMALL_SIZE = 3
mpl.rc('font', size=SMALL_SIZE)
mpl.rc('axes', titlesize=SMALL_SIZE)


samples=glob.glob('*_bins_UHGG_RPK.txt')
print(samples)
sampleNames=[x.rsplit('_bins_UHGG_RPK.txt')[0] for x in samples]
print(sampleNames)

for sample in sampleNames:

    data1 = pd.read_csv(sample+'_bins_UHGG_RPK.txt',sep='\t',header=0)
    print(data1)

    #filter rows from bins and groupby bin, sum
    data2 = data1[data1['genomeID'].str.startswith('bin')]
    print(data2)

    data2_hkg_bin_sum = data2.groupby('genomeID')['RPK'].sum().reset_index()
    print(data2_hkg_bin_sum)
    print(data2_hkg_bin_sum.shape)
    data2_hkg_bin_sum.to_csv(sample+'_hkg_bin_sum.txt', sep='\t',index=False)

    data2_hkg_bin_sum.plot(x='genomeID',y='RPK',kind='bar')
    plt.savefig(sample+'_bins_RPK.pdf')

    data2_hkg_bin_stats = data2.groupby('genomeID')['RPK'].agg(['count','sum','mean','median'])
    print(data2_hkg_bin_stats)
    data2_hkg_bin_stats.to_csv(sample+'_hkg_bin_stats.txt', sep='\t')

    #data2_hkg_bin_sum_desc = data2.groupby('genomeID')['RPK'].describe()
    #print(data2_hkg_bin_sum_desc)

    #rows from bins and groupby HKGtype
    data3 = data2.groupby('HKGtype')['RPK'].sum().reset_index()
    print(data3)
    data3_hkg_bin_stats = data2.groupby('HKGtype')['RPK'].agg(['count','sum','mean','median'])
    print(data3_hkg_bin_stats)
    data3_hkg_bin_stats.to_csv(sample+'_hkgtype_bin_stats.txt', sep='\t')

    data3_sum_sorted = data3.sort_values(by = 'RPK')
    data3_sum_sorted.to_csv(sample+'_hkgtype_bins_RPK.txt', sep='\t')
    data3_sum_sorted.plot(x='HKGtype',y='RPK',kind='bar')
    plt.savefig(sample+'_HKGtype_bins_RPK.pdf')


    ##groupby HKGtype from bins and UHGG
    data4 = data1.groupby('HKGtype')['RPK'].sum().reset_index()
    data4_sum_sorted = data4.sort_values(by = 'RPK')
    data4_sum_sorted.plot(x='HKGtype',y='RPK',kind='bar')
    plt.savefig(sample+'_HKGtype_all_RPK.pdf')
    
    #####UHGG#####
    #filter rows from uhgg and groupby genome, sum
    data5 = data1[data1['genomeID'].str.startswith('MG')]
    print(data5)
    data5_hkg_uhgg_sum = data5.groupby('genomeID')['RPK'].sum().reset_index()
    data5_hkg_uhgg_sum_sorted = data5_hkg_uhgg_sum.sort_values(by = 'RPK')
    data5_hkg_uhgg_sum_sorted.to_csv(sample+'_hkg_uhgg_sum.txt', sep='\t',index=False)

    #rows from uhgg and groupby HKGtype
    data6 = data5.groupby('HKGtype')['RPK'].sum().reset_index()
    data6_sum_sorted = data6.sort_values(by = 'RPK')
    data6_sum_sorted.to_csv(sample+'_hkgtype_uhgg_RPK.txt', sep='\t', index=False)

    data6_nonzero = data6_sum_sorted[data6_sum_sorted['RPK'] != 0]
    data6_nonzero.plot(x='HKGtype',y='RPK',kind='bar')
    plt.savefig(sample+'_HKGtype_uhgg_RPK.pdf')
