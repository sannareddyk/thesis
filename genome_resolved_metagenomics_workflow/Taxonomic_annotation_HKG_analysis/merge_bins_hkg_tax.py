#!/usr/bin/python3

import sys
import pandas as pd

# reading csv files
data1 = pd.read_csv(sys.argv[1],sep='\t',names=['geneID','HKGtype','bin'])
data2 = pd.read_csv(sys.argv[2],sep='\t',names=['bin','lineage'])

#data1.bin = data1.bin.str.encode('utf-8')
#data2.bin = data2.bin.str.encode('utf-8')

data1.bin = data1.bin.str.strip()
data2.bin = data2.bin.str.strip()
print(data1)
print(data2)

output1 = pd.merge(data1.assign(bin=data1.bin.astype(str)), data2.assign(bin=data2.bin.astype(str)),on='bin')
print(output1)

output1.to_csv(sys.argv[3],index=None, sep='\t')
