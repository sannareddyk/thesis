#!/usr/bin/python3

import sys
import glob
import pandas as pd
from functools import reduce

filenames = sorted(glob.glob("*PF_summarize.txt"))
print(filenames)
cols = [i.split('.')[0] for i in filenames] 
fin_cols = ['PFamID'] + cols
#get sample names and rename columns after merge

dfs = [pd.read_table(filename) for filename in filenames]
print(dfs)

#dfs[0].join(dfs[1:])
df_final = reduce(lambda left,right: pd.merge(left,right,on=['PFamID'], how='outer').fillna(0),dfs)
#df_final.fillna(0)

df_final.set_axis(fin_cols, axis=1,inplace=True)
print(df_final.columns)

df_final.to_csv(sys.argv[1], index=None, sep='\t')
