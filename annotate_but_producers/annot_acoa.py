#!/usr/bin/python3

"""
A script to parse hmmsearch output files to annotate acoa pathway of butyrate production from gut genomes/bins
Keerthi Sannareddy, September 2023

"""

import os
import sys
import pandas as pd
import numpy as np
from functools import reduce
import math
from collections import Counter

#if len(sys.argv) != 6:
#    print("usage:python3 acoa_pwy.py ")
#    sys.exit

##read in hmmoutput files for all genes from acoa pathway, extract columns targetID and score
df1 = pd.read_csv('THL_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df1 = df1.iloc[:,[0,5]]

df2 = pd.read_csv('BHBD_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df2 = df2.iloc[:,[0,5]]

df3 = pd.read_csv('CRO_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df3 = df3.iloc[:,[0,5]]

df4 = pd.read_csv('BCD_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True,encoding='utf8', engine='python',index_col = False)
df4 = df4.iloc[:,[0,5]]

df5 = pd.read_csv('BUT_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df5 = df5.iloc[:,[0,5]]

df6 = pd.read_csv('BUK_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df6 = df6.iloc[:,[0,5]]

print(df6)

df7 = pd.read_csv('PTB_NormalT_hmmsearch.txt',comment='#',header=None,delim_whitespace=True)
df7 = df7.iloc[:,[0,5]]

print(df7)
##assign header
headers_THL =  ["THLID", "THLScore"]
df1.columns = headers_THL

headers_BHBD =  ["BHBDID", "BHBDScore"]
df2.columns = headers_BHBD

headers_CRO =  ["CROID", "CROScore"]
df3.columns = headers_CRO

headers_BCD =  ["BCDID", "BCDScore"]
df4.columns = headers_BCD

headers_BUT =  ["BUTID", "BUTScore"]
df5.columns = headers_BUT

headers_BUK =  ["BUKID", "BUKScore"]
df6.columns = headers_BUK

headers_PTB =  ["PTBID", "PTBScore"]
df7.columns = headers_PTB

##extract genomeID from targetID or geneID
df1['genomeID'] = df1['THLID'].str.split('_').str[0]
df1 = df1[['genomeID', 'THLID','THLScore']]
print(df1)

df2['genomeID'] = df2['BHBDID'].str.split('_').str[0]
df2 = df2[['genomeID', 'BHBDID','BHBDScore']]
print(df2)

df3['genomeID'] = df3['CROID'].str.split('_').str[0]
df3 = df3[['genomeID', 'CROID','CROScore']]
print(df3)

df4['genomeID'] = df4['BCDID'].str.split('_').str[0]
df4 = df4[['genomeID', 'BCDID','BCDScore']]
print(df4)

df5['genomeID'] = df5['BUTID'].str.split('_').str[0]
df5 = df5[['genomeID', 'BUTID','BUTScore']]
print(df5)

df6['genomeID'] = df6['BUKID'].str.split('_').str[0]
df6 = df6[['genomeID', 'BUKID','BUKScore']]
print(df6)

df7['genomeID'] = df7['PTBID'].str.split('_').str[0]
df7 = df7[['genomeID', 'PTBID','PTBScore']]
print(df7)

##taxonomy
tax = pd.read_csv('rep_tax.txt',sep='\t',header=0)
tax = tax.iloc[:,[0,1,6,7,14]]
tax.columns = ["genomeID","genomeType","Completeness","Contamination","Lineage"]
print(tax)

#merge dataframes
df_list = [df1,df2,df3,df4]
df_merged = reduce(lambda  left,right: pd.merge(left,right,on=['genomeID'],how='outer'), df_list)
print(df_merged)

##make selections, add final genes and taxonomy
acoa_genes=['THLID','BHBDID','CROID','BCDID']

##generate counts

df_merged['counts'] = df_merged[acoa_genes].count(axis=1)

##add terminal genes
##check buk and ptb in synteny
df_buk_ptb = pd.merge(df6, df7, on='genomeID', how='outer')
print(df_buk_ptb)

##buk and ptb positions
df_buk_ptb['BUK_pos'] = df_buk_ptb['BUKID'].str.split('_').str[1]
print(df_buk_ptb)
df_buk_ptb['PTB_pos'] = df_buk_ptb['PTBID'].str.split('_').str[1]
print(df_buk_ptb)

df_buk_ptb['diff'] = np.abs(df_buk_ptb['BUK_pos'].astype(float)-df_buk_ptb['PTB_pos'].astype(float))
df_buk_ptb_syn = df_buk_ptb.loc[df_buk_ptb['diff'] <=5]
df_buk_ptb_syn.to_csv('bukptb_IDS_true.txt',sep='\t', index=False)

##but true ID's
df_but_true_IDs = pd.read_csv('BUT_IDs_true_noref.txt', header=None)
df_but_true_IDs.columns = ['BUTID']
print(df_but_true_IDs)
##subset but dataframe
df5_but_true = df5.merge(df_but_true_IDs['BUTID'])
print(df5_but_true)

##merge terminal genes to the df_merged dataframe by left join
df_merged = df_merged.merge(df_buk_ptb_syn, on = 'genomeID', how = 'left')
df_merged = df_merged.merge(df5_but_true, on = 'genomeID', how = 'left')
print(df_merged)

##synteny analysis
df_merged['THL_pos'] = df_merged['THLID'].str.split('_').str[1]
df_merged['BHBD_pos'] = df_merged['BHBDID'].str.split('_').str[1]
df_merged['CRO_pos'] = df_merged['CROID'].str.split('_').str[1]
df_merged['BCD_pos'] = df_merged['BCDID'].str.split('_').str[1]

def all_distances_less_than_10(numbers):
    n = len(numbers)
    for i in range(n):
        for j in range(i + 1, n):
            if abs(numbers[i] - numbers[j]) >= 10:
                return False
    return True

synteny_list = []
for i in range(df_merged.shape[0]):
    pos_lists = [float(df_merged['THL_pos'][i]), float(df_merged['BHBD_pos'][i]), float(df_merged['CRO_pos'][i]), float(df_merged['BCD_pos'][i])]
    if (np.sum(np.isnan(pos_lists))) > 1:
        synteny_list.append(False)
    elif (np.sum(np.isnan(pos_lists))) == 1:
        pos_lists = np.array(pos_lists)
        pos_lists = pos_lists[~np.isnan(pos_lists)]
        synteny_list.append(all_distances_less_than_10(pos_lists))
    else:
        pos_lists = [int(df_merged['THL_pos'][i]), int(df_merged['BHBD_pos'][i]), int(df_merged['CRO_pos'][i]), int(df_merged['BCD_pos'][i])]
        synteny_list.append(all_distances_less_than_10(pos_lists))

df_merged['synteny_status'] = synteny_list
print(Counter(synteny_list))

##check but, buk status
df_merged['BUT_status']= df_merged['BUTID'].notnull()
df_merged['BUK_status']= df_merged['BUKID'].notnull()
'''
if (df_merged['BUT_status']==True) & (df_merged['BUK_status']==False):
    df_merged['BUT_BUK_STATUS']=='BUT_ONLY'
elif (df_merged['BUT_status']==False) & (df_merged['BUK_status']==True):
    df_merged['BUT_BUK_STATUS']=='BUK_ONLY'
elif (df_merged['BUT_status']==True) & (df_merged['BUK_status']==True):
    df_merged['BUT_BUK_STATUS']=='BOTH'
elif (df_merged['BUT_status']==False) & (df_merged['BUK_status']==False):
    df_merged['BUT_BUK_STATUS']=='NONE'
else:
    df_merged['BUT_BUK_STATUS']=='ERROR'
'''

df_merged['BUT_BUK_STATUS'] = 'ERROR'  # Default value if none of the conditions are met
df_merged.loc[(df_merged['BUT_status'] == True) & (df_merged['BUK_status'] == False), 'BUT_BUK_STATUS'] = 'BUT_ONLY'
df_merged.loc[(df_merged['BUT_status'] == False) & (df_merged['BUK_status'] == True), 'BUT_BUK_STATUS'] = 'BUK_ONLY'
df_merged.loc[(df_merged['BUT_status'] == True) & (df_merged['BUK_status'] == True), 'BUT_BUK_STATUS'] = 'BOTH'
df_merged.loc[(df_merged['BUT_status'] == False) & (df_merged['BUK_status'] == False), 'BUT_BUK_STATUS'] = 'NONE'

##check finalgenes status(but, buk)
final_genes = ['BUTID','BUKID']

df_merged['finalgenes_status'] = df_merged[final_genes].apply(lambda x: any(x.notnull()), axis = 1)

##make selections. all 4 genes
##3 genes, except THL
##3 genes, but not missing THL

df_allfour=df_merged[df_merged['counts']==4]
df_threegenes_noTHL=df_merged[(df_merged['counts']==3) & (df_merged['THLID'].isnull())]
#df_test=df_merged[(df_merged['counts'] == 3) & ((df_merged['THLID'].isna()) | (df_merged['THLID'] == ''))]
df_threegenes_THL=df_merged[(df_merged['counts']==3) & (df_merged['THLID'].notnull()) & (df_merged['finalgenes_status'] == True)]

'''
##check finalgenes status(but, buk)
final_genes = ['BUTID','BUKID']

df_allfour['finalgenes_status'] = df_allfour[final_genes].apply(lambda x: any(x.notnull()), axis = 1)
#df_allfour['finalgenes_status'] = df_allfour['finalgenes_status'].map({True:'True',False: 'False'})

df_threegenes_noTHL['finalgenes_status'] = df_threegenes_noTHL[final_genes].apply(lambda x: any(x.notnull()), axis = 1)
#df_threegenes_noTHL['finalgenes_status'] = df_threegenes_noTHL['finalgenes_status'].map({True:'True',False: 'False'})

df_threegenes_THL['finalgenes_status'] = df_threegenes_THL[final_genes].apply(lambda x: any(x.notnull()), axis = 1)
#df_threegenes_THL['finalgenes_status'] = df_threegenes_THL['finalgenes_status'].map({True:'True',False: 'False'})
'''

##sum of scores for each row and pick max score for each group
cols = ['THLScore','BHBDScore','CROScore','BCDScore']

df_allfour['sum_scores'] = df_allfour[cols].sum(axis=1)

df_allfour_filtered=df_allfour.groupby('genomeID', as_index=False, sort=False).apply(
        lambda x: x.loc[x['sum_scores'].idxmax()])

#df_allfour_filtered = df_allfour.groupby('genomeID')['sum_scores'].max().reset_index()
df_allfour_filtered.to_csv('df_allfour_filtered.txt', sep='\t',index=False)

##three genes, missing other than THL
df_threegenes_noTHL['sum_scores'] = df_threegenes_noTHL[cols].sum(axis=1)

df_threegenes_noTHL_filtered=df_threegenes_noTHL.groupby('genomeID', as_index=False, sort=False).apply(
        lambda x: x.loc[x['sum_scores'].idxmax()])

#df_allfour_filtered = df_allfour.groupby('genomeID')['sum_scores'].max().reset_index()
df_threegenes_noTHL_filtered.to_csv('df_threegenes_noTHL_filtered.txt', sep='\t',index=False)


##three genes, missing other than THL
df_threegenes_THL['sum_scores'] = df_threegenes_THL[cols].sum(axis=1)

df_threegenes_THL_filtered=df_threegenes_THL.groupby('genomeID', as_index=False, sort=False).apply(
        lambda x: x.loc[x['sum_scores'].idxmax()])

#df_allfour_filtered = df_allfour.groupby('genomeID')['sum_scores'].max().reset_index()
df_threegenes_THL_filtered.to_csv('df_threegenes_THL_filtered.txt', sep='\t',index=False)


##add taxonomy information
df_allfour_filtered_tax=df_allfour_filtered.merge(tax, on='genomeID', how='left')
df_threegenes_noTHL_filtered_tax=df_threegenes_noTHL_filtered.merge(tax, on='genomeID', how='left')
df_threegenes_THL_filtered_tax=df_threegenes_THL_filtered.merge(tax, on='genomeID', how='left')
df_tax = df_merged.merge(tax, on='genomeID', how='left')

##get genus info from Lineage
df_allfour_filtered_tax['genus'] = df_allfour_filtered_tax['Lineage'].str.split(';').str[-2]
df_threegenes_noTHL_filtered_tax['genus'] = df_threegenes_noTHL_filtered_tax['Lineage'].str.split(';').str[-2]
df_threegenes_THL_filtered_tax['genus'] = df_threegenes_THL_filtered_tax['Lineage'].str.split(';').str[-2]

df_allfour_filtered_tax['species'] = df_allfour_filtered_tax['Lineage'].str.split(';').str[-1]
df_threegenes_noTHL_filtered_tax['species'] = df_threegenes_noTHL_filtered_tax['Lineage'].str.split(';').str[-1]
df_threegenes_THL_filtered_tax['species'] = df_threegenes_THL_filtered_tax['Lineage'].str.split(';').str[-1]

#print(df_allfour_tax)

##summarize
##groupby genus and count total number of genomes per group, genomes with final genes and without final genes, genomes with final genes and synteny is true
#df_count=df_allfour_filtered_tax.groupby('genus').size().reset_index(name='genome_counts_genus')
#df_count.to_csv('genome_counts_genus_1.txt',sep='\t', index=False)

##list of dataframes

dict_of_dfs = {
     'df_allfour_filtered_tax': df_allfour_filtered_tax,
     'df_threegenes_noTHL_filtered_tax': df_threegenes_noTHL_filtered_tax,
     'df_threegenes_THL_filtered_tax': df_threegenes_THL_filtered_tax
 }

#df_list = [df_allfour_filtered_tax,df_threegenes_noTHL_filtered_tax,df_threegenes_THL_filtered_tax]

'''
for df_name, df in dict_of_dfs.items():
    #print(df)
    #check snyteny status, true, then synt + final genes, synt + no final genes
    df_count_synteny_genes = df.groupby('genomeID')['synteny_status'].apply(lambda x: (x==True).sum()).reset_index(name='genome_counts_species_synteny')
    df_count_synteny_genes.to_csv(f'{df_name}_genome_counts_species_synteny.txt',sep='\t', index=False)

    df_count_no_synteny_genes = df.groupby('genomeID')['synteny_status'].apply(lambda x: (x==False).sum()).reset_index(name='genome_counts_species_no_synteny')
    df_count_no_synteny_genes.to_csv(f'{df_name}_genome_counts_species_no_synteny.txt',sep='\t', index=False)

    ##
    condition_1 = (df.synteny_status == True) & (df.finalgenes_status == True)
    df_count_synteny_final_genes = df[condition_1].groupby('genomeID').size().reset_index(name='genome_counts_species_synteny_final_genes')

    df_count_synteny_final_genes['genome_counts_species_synteny_final_genes']=df_count_synteny_final_genes['genome_counts_species_synteny_final_genes'].astype(int)
    df_count_synteny_final_genes.to_csv(f'{df_name}_genome_counts_species_synteny_final_genes.txt',sep='\t', index=False)


    condition_2 = (df.synteny_status == True) & (df.finalgenes_status == False)
    df_count_synteny_no_final_genes = df[condition_2].groupby('genomeID').size().reset_index(name='genome_counts_species_synteny_no_final_genes')

    df_count_synteny_no_final_genes['genome_counts_species_synteny_no_final_genes']=df_count_synteny_no_final_genes['genome_counts_species_synteny_no_final_genes'].astype(int)
    df_count_synteny_no_final_genes.to_csv(f'{df_name}_genome_counts_species_synteny_no_final_genes.txt',sep='\t', index=False)


    condition_3 = (df.synteny_status == False) & (df.finalgenes_status == True)
    df_count_no_synteny_final_genes = df[condition_3].groupby('genomeID').size().reset_index(name='genome_counts_species_no_synteny_final_genes')

    df_count_no_synteny_final_genes['genome_counts_species_no_synteny_final_genes']=df_count_no_synteny_final_genes['genome_counts_species_no_synteny_final_genes'].astype(int)
    df_count_no_synteny_final_genes.to_csv(f'{df_name}_genome_counts_species_no_synteny_final_genes.txt',sep='\t', index=False)


    condition_4 = (df.synteny_status == False) & (df.finalgenes_status == False)
    df_count_no_synteny_no_final_genes = df[condition_4].groupby('genomeID').size().reset_index(name='genome_counts_species_no_synteny_no_final_genes')


    df_count_no_synteny_no_final_genes['genome_counts_species_no_synteny_no_final_genes']=df_count_no_synteny_no_final_genes['genome_counts_species_no_synteny_no_final_genes'].astype(int)
    df_count_no_synteny_no_final_genes.to_csv(f'{df_name}_genome_counts_species_no_synteny_no_final_genes.txt',sep='\t', index=False)

'''
for df_name, df in dict_of_dfs.items():
    #print(df)
    #check snyteny status, true, then synt + final genes, synt + no final genes
    df_count_synteny_genes = df.groupby('genus')['synteny_status'].apply(lambda x: (x==True).sum()).reset_index(name='genome_counts_genus_synteny')
    df_count_synteny_genes.to_csv(f'{df_name}_genome_counts_genus_synteny.txt',sep='\t', index=False)

    df_count_no_synteny_genes = df.groupby('genus')['synteny_status'].apply(lambda x: (x==False).sum()).reset_index(name='genome_counts_genus_no_synteny')
    df_count_no_synteny_genes.to_csv(f'{df_name}_genome_counts_genus_no_synteny.txt',sep='\t', index=False)

    ##
    condition_1 = (df.synteny_status == True) & (df.finalgenes_status == True)
    df_count_synteny_final_genes = df[condition_1].groupby('genus').size().reset_index(name='genome_counts_genus_synteny_final_genes')

    df_count_synteny_final_genes['genome_counts_genus_synteny_final_genes']=df_count_synteny_final_genes['genome_counts_genus_synteny_final_genes'].astype(int)
    df_count_synteny_final_genes.to_csv(f'{df_name}_genome_counts_genus_synteny_final_genes.txt',sep='\t', index=False)


    condition_2 = (df.synteny_status == True) & (df.finalgenes_status == False)
    df_count_synteny_no_final_genes = df[condition_2].groupby('genus').size().reset_index(name='genome_counts_genus_synteny_no_final_genes')

    df_count_synteny_no_final_genes['genome_counts_genus_synteny_no_final_genes']=df_count_synteny_no_final_genes['genome_counts_genus_synteny_no_final_genes'].astype(int)
    df_count_synteny_no_final_genes.to_csv(f'{df_name}_genome_counts_genus_synteny_no_final_genes.txt',sep='\t', index=False)


    condition_3 = (df.synteny_status == False) & (df.finalgenes_status == True)
    df_count_no_synteny_final_genes = df[condition_3].groupby('genus').size().reset_index(name='genome_counts_genus_no_synteny_final_genes')

    df_count_no_synteny_final_genes['genome_counts_genus_no_synteny_final_genes']=df_count_no_synteny_final_genes['genome_counts_genus_no_synteny_final_genes'].astype(int)
    df_count_no_synteny_final_genes.to_csv(f'{df_name}_genome_counts_genus_no_synteny_final_genes.txt',sep='\t', index=False)


    condition_4 = (df.synteny_status == False) & (df.finalgenes_status == False)
    df_count_no_synteny_no_final_genes = df[condition_4].groupby('genus').size().reset_index(name='genome_counts_genus_no_synteny_no_final_genes')

    df_count_no_synteny_no_final_genes['genome_counts_genus_no_synteny_no_final_genes']=df_count_no_synteny_no_final_genes['genome_counts_genus_no_synteny_no_final_genes'].astype(int)
    df_count_no_synteny_no_final_genes.to_csv(f'{df_name}_genome_counts_genus_no_synteny_no_final_genes.txt',sep='\t', index=False)


###Based on final genes

#df_count_final_genes = df_allfour_filtered_tax.groupby('genus')['finalgenes_status'].apply(lambda x: (x=='True').sum()).reset_index(name='genome_counts_genus_final_genes')
#df_count_final_genes.to_csv('genome_counts_genus_2.txt',sep='\t', index=False)

#df_count_no_final_genes = df_allfour_filtered_tax.groupby('genus')['finalgenes_status'].apply(lambda x: (x=='False').sum()).reset_index(name='genome_counts_genus_no_final_genes')
#df_count_no_final_genes.to_csv('genome_counts_genus_3.txt',sep='\t', index=False)

##
#condition = (df_allfour_filtered_tax.finalgenes_status == 'True') & (df_allfour_filtered_tax.synteny_status == True)
#df_count_final_genes_synteny = df_allfour_filtered_tax[condition].groupby('genus').size().reset_index(name='genome_counts_genus_final_genes_synteny')

#df_count_final_genes_synteny['genome_counts_genus_final_genes_synteny']=df_count_final_genes_synteny['genome_counts_genus_final_genes_synteny'].astype(int)
#df_count_final_genes_synteny.to_csv('genome_counts_genus_4.txt',sep='\t', index=False)

#from functools import reduce
#dataframes = [df_count,df_count_final_genes,df_count_no_final_genes,df_count_final_genes_synteny]
#results_df = reduce(lambda left,right: pd.merge(left,right,on='genus',how='left'),dataframes)
#results_df['genome_counts_genus_final_genes_synteny'].fillna(0,inplace=True)
#results_df['genome_counts_genus_final_genes_synteny']=results_df['genome_counts_genus_final_genes_synteny'].astype(int)
#results_df.to_csv('allfour_summary.txt', sep='\t', index=False)

df_allfour_filtered_tax.to_csv('acoa_merged_1.txt', sep='\t', index=False)
df_threegenes_noTHL_filtered_tax.to_csv('acoa_merged_2.txt', sep='\t', index=False)
df_threegenes_THL_filtered_tax.to_csv('acoa_merged_3.txt', sep='\t', index=False)
df_tax.to_csv('acoa_merged.txt', sep='\t', index=False)

