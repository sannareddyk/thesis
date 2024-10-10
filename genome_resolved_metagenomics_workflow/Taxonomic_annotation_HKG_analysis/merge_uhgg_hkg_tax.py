#!/usr/bin/python3

import sys
import pandas as pd

# reading csv files
data1 = pd.read_csv(sys.argv[1],sep='\t',names=['geneID','HKGtype'])
data2 = pd.read_csv(sys.argv[2],sep='\t',names=['genomeID','lineage'])

#data1.bin = data1.bin.str.encode('utf-8')
#data2.bin = data2.bin.str.encode('utf-8')

data1.geneID = data1.geneID.str.strip()
data2.genomeID = data2.genomeID.str.strip()
print(data1)
print(data2)

data1['genomeID']=data1.geneID.str.split('_').str[0]
print(data1)

output1 = pd.merge(data1,data2,how='left',on='genomeID')
print(output1)

output1.to_csv(sys.argv[3],index=None, sep='\t')

