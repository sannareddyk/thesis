#!/usr/bin/python3

#Keerthi Sannareddy, June 2023

import sys
import glob
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
mpl.use('Agg')

samples=glob.glob('*_bins_UHGG_RPK.txt')
print(samples)
sampleNames=[x.rsplit('_bins_UHGG_RPK.txt')[0] for x in samples]
print(sampleNames)

for sample in sampleNames:

    data1 = pd.read_csv(sample+'_bins_UHGG_RPK.txt',sep='\t',header=0)

    data1_hkg_sum = data1.groupby('HKGtype')['RPK'].sum().reset_index()
    print(data1_hkg_sum)

    #data1_hkg_sum_sorted = data1_hkg_sum.sort_values(by = 'RPK')
    #data1_hkg_sum_sorted.to_csv('HKG_RPK.txt',index=None, sep='\t')
    #data1_hkg_sum_sorted.plot(y='RPK',kind='bar')
    #plt.plot(data1_hkg_sum_sorted.HKGtype,data1_hkg_sum_sorted.RPK,kind='bar')
    #plt.savefig('hkg_abundance.pdf')

    #filter sum>1000, calculate mean
    #filtering parameter, 500 or 1000?
    res_df=data1_hkg_sum.loc[data1_hkg_sum['RPK'] >= 500]
    print(res_df.shape)

    with open(sample+'_norm_fac.txt', "w") as f:
        print(sample + '\t' + str(round(res_df['RPK'].mean(),5)),file=f)
    
    #filtering parameter
    res_df.to_csv(sample+'_HKG_RPK_500.txt',index=None, sep='\t')

    #taxonomy
    data1_hkg_tax=data1.groupby('lineage')['RPK'].sum().reset_index()
    print(data1_hkg_tax)
    data1_hkg_tax_sorted=data1_hkg_tax.sort_values('RPK',ascending=False) 
    data1_hkg_tax_sorted.to_csv(sample+'_lineage_RPK.txt',sep='\t',index=False)

    #species
    data1_hkg_tax_sorted['species']=data1_hkg_tax_sorted.lineage.str.split('s__').str[1]
    print(data1_hkg_tax_sorted)

    data1_species_RPK=data1_hkg_tax_sorted[['species','RPK']]
    print(data1_species_RPK)

    data1_species_RPK_top8=data1_species_RPK.iloc[:8]
    s=data1_species_RPK_top8['species'].str.split(' ')
    data1_species_RPK_top8['species']=s.str[0].str[:1].str.cat(s.str[1],'.')
    print(data1_species_RPK_top8)

    data1_species_RPK_top8.plot(kind='bar',x='species',y='RPK')
    plt.xticks(fontsize=4, rotation='horizontal')
    #plt.plot(data1_species_RPK_top8.species,data1_species_RPK_top8.RPK)
    plt.savefig(sample+'_species_abundance.pdf')

    #######select species with min 20HKG with sum of HKGtype, RPK >0
    data1_hkgtype_tax_sum = data1.groupby(['lineage','HKGtype'])['RPK'].sum().reset_index()
    print(data1_hkgtype_tax_sum)
    data1_hkgtype_tax_sum.to_csv(sample+'_lineage_HKGtype.txt',sep='\t')

    df_20hkg=data1_hkgtype_tax_sum.groupby('lineage')['RPK'].apply(lambda x: (x>0.0).sum()).reset_index(name='count')
    print(df_20hkg)
    df_20hkg.to_csv(sample+'_lineage_hkg_count.txt',sep='\t')

    # Select categories with count greater than 20
    df_20hkg_final = df_20hkg[df_20hkg['count'] >= 20]
    #print(df_20hkg_final)

    df_20hkg_final_RPK = data1_hkg_tax.merge(df_20hkg_final, on='lineage')
    df_20hkg_final_RPK['rel_abundance'] = (df_20hkg_final_RPK['RPK']/df_20hkg_final_RPK['RPK'].sum())*100
    print(df_20hkg_final_RPK)

    df_20hkg_final.to_csv(sample+'_lineage_20hkg_final.txt',sep='\t',index=False)
    df_20hkg_final_RPK.to_csv(sample+'_lineage_20hkg_final_relabundance.txt',sep='\t',index=False)

