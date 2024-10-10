#!/usr/bin/python3

import sys
import pandas as pd

data1 = pd.read_csv(sys.argv[1], sep='\t', header=None)
print(data1)

data1.columns = ["geneID","PFamID","evalue","GO"]
print(data1)

#data2=data1.groupby("geneID")["evalue"].min()

data2=data1.loc[data1.groupby("geneID")["evalue"].idxmin()].reset_index(drop=True)
print(data2.head(10))

data2.to_csv(sys.argv[2], sep='\t', index=False)

