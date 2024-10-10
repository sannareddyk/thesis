#!/usr/bin/python3

import sys
import pandas as pd

# reading csv files
data1 = pd.read_csv(sys.argv[1],sep='\t',names=['geneID','geneLength','counts'])
data2 = pd.read_csv(sys.argv[2],sep='\t',header=0)

data1 = data1.sort_values("geneID")
data2 = data2.sort_values("geneID")
#print(data1)
#print(data2)

#data1.geneID = data1.geneID.str.encode('utf-8')
#data2.geneID = data2.geneID.str.encode('utf-8')

data1.geneID = data1.geneID.str.strip()
data2.geneID = data2.geneID.str.strip()
print(data1)
print(data2)

#data1.bin = data1.bin.astype(str)
#data2.bin = data2.bin.astype(str)

output1 = pd.merge(data1.assign(geneID=data1.geneID.astype(str)), data2.assign(geneID=data2.geneID.astype(str)),how='left',on='geneID')
print(output1)

output1.to_csv(sys.argv[3],index=None, sep='\t')
