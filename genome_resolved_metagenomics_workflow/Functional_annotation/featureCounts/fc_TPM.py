#!/usr/bin/python3

#Keerthi Sannareddy
import sys
import pandas as pd

data1 = pd.read_csv(sys.argv[1], sep='\t')
#print(data1)

#scalingfactor
a = (data1['normCounts'].sum())/1000000
#print(a)

data1['TPM']= round(data1['normCounts']/a,2)

#print(data1)
data1.to_csv(sys.argv[2], sep='\t',index=False)


