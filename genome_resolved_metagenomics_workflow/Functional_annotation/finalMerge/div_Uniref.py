#!/usr/bin/python3

import sys
import pandas as pd

data1=pd.read_csv(sys.argv[1], sep='\t',header=0)
data1.set_index('UniRefID', inplace=True)

print(data1)

data2=pd.read_csv(sys.argv[2], sep='\t',header=None,index_col=0)

print(data2)

data2_transposed=data2.transpose()
print(data2_transposed)

data_normalized=data1.div(data2_transposed.iloc[0])

data_normalized.to_csv(sys.argv[3],sep='\t')
