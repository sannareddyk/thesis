#!/usr/bin/python3

import glob
import pandas as pd
from functools import reduce

#df1, geneID and FC
#df2, geneID and kofamID
#df3, geneID and PfamID
#df4, geneID and GOID
#df5, geneID and unirefID
#df6, geneID and CAZyID

samples=glob.glob('*featureCounts.norm.txt')
print(samples)
sampleNames=[x.rsplit('.featureCounts.norm.txt')[0] for x in samples]
print(sampleNames)

for sample in sampleNames:

    filenames=[sample+'.featureCounts.norm.txt',sample+'.kofam.final.txt',sample+'.pfam.final.txt',sample+'.GO.final.txt',sample+'.blastp.final.txt',sample+'.dbCAN4.final.txt','UHGG.kofam.final.txt','UHGG.pfam.final.txt','UHGG.GO.final.txt','UHGG.blastp.final.txt','UHGG.dbCAN4.final.txt']
    #filenames=[sample+'.featureCounts.norm.txt',sample+'.kofam.final.txt',sample+'.blastp.final.txt','UHGG.kofam.final.txt','UHGG.blastp.final.txt']
    #filenames=[sample+'.featureCounts.norm.txt',sample+'.kofam.final.txt',sample+'.blastp.final.txt',sample+'.dbCAN4.final.txt','UHGG.kofam.final.txt','UHGG.blastp.final.txt']
    print(filenames)

    dfs = [pd.read_table(filename) for filename in filenames]
    print(dfs)

    #dfs[0].join(dfs[1:])
    df_final = reduce(lambda left,right: pd.merge(left,right,on='geneID', how='left'),dfs).fillna(0)

    df_final.rename({'geneID':'geneID', 'rawCounts':'rawCounts', 'geneLength':'geneLength', 'normCounts':'normCounts', 'KOfamID_x':'KOfamID', 'PFamID_x':'PFamID','GOID_x':'GOID','UniRefID_x':'UniRefID','CAZyID_x':'CAZyID','KOfamID_y':'KOfamID_UHGG', 'PFamID_y':'PFamID_UHGG','GOID_y':'GOID_UHGG','UniRefID_y':'UniRefID_UHGG','CAZyID_y':'CAZyID_UHGG'}, axis=1, inplace=True)

    #float_col = df_final.select_dtypes(include=['float64'])
    #for col in float_col.columns.values:
    #df_final[col] = df_final[col].astype('Int64')

    df_final.to_csv(sample+'.merge_out.txt', sep='\t',index=False)
