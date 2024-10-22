#!/usr/bin/python3

import sys
import pandas as pd

data1 = pd.read_csv(sys.argv[1], sep='\t')
print(data1)

data1.columns=data1.columns.str.strip()
data1['RPK']=pd.to_numeric(data1['RPK'])

data_per_CAZy=(data1.groupby('CAZyID')['RPK'].sum().reset_index().round(2))

print(data_per_CAZy.head(10))

data_per_CAZy.to_csv(sys.argv[2], sep='\t',index=False)
