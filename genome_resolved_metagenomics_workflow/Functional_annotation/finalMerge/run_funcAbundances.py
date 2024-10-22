#!/usr/bin/python3

import os
import sys
import re

######################################################
##usage section

#if len(sys.argv) != 6:
#	print("usage: python3 run_funcAbundances.py S101_sub0.merge_out.txt KO_counts.txt PF_counts.txt GO_counts.txt Uniref_counts.txt CAZy_counts.txt")
#	sys.exit()

######################################################
###Inputs
inFileName = sys.argv[1]
outFileName1 = sys.argv[2]
outFileName2 = sys.argv[3]
outFileName3 = sys.argv[4]
outFileName4 = sys.argv[5]
outFileName5 = sys.argv[6]

###Open input file and start processing
inFile = open(inFileName)
outFile1 = open(outFileName1,'w')
outFile2 = open(outFileName2,'w')
outFile3 = open(outFileName3,'w')
outFile4 = open(outFileName4,'w')
outFile5 = open(outFileName5,'w')


outFile1.write('geneID' + '\t' + 'KOfamID' + '\t' + 'RPK' + '\n')
outFile2.write('geneID' + '\t' + 'PFamID' + '\t' + 'RPK' + '\n')
outFile3.write('geneID' + '\t' + 'GOID' + '\t' + 'RPK' + '\n')
outFile4.write('geneID' + '\t' + 'UniRefID' + '\t' + 'RPK' + '\n')
outFile5.write('geneID' + '\t' + 'CAZyID' + '\t' + 'RPK' + '\n')


for line in inFile:
    
    if line.startswith('G'):
        line = line.strip()
        line = line.split('\t')

        if re.search('^K', line[4]):
            outFile1.write(line[0] + '\t' + line[4] + '\t' + str(line[3]) + '\n')
        if re.search('^PF', line[5]) :
            outFile2.write(line[0] + '\t' + line[5] + '\t' + str(line[3]) + '\n')
        if re.search('^GO', line[6]) :
            outFile3.write(line[0] + '\t' + line[6] + '\t' + str(line[3]) + '\n')
        if re.search('^Uni', line[7]):
            outFile4.write(line[0] + '\t' + line[7] + '\t' + str(line[3]) + '\n')
        if line[8]!='0':
            outFile5.write(line[0] + '\t' + line[8] + '\t' + str(line[3]) + '\n')

    elif line.startswith('MG'):
        line = line.strip()
        line = line.split('\t')

        if re.search('^K', line[9]) :
            outFile1.write(line[0] + '\t' + line[9] + '\t' + str(line[3]) + '\n')
        if re.search('^PF', line[10]) :
            outFile2.write(line[0] + '\t' + line[10] + '\t' + str(line[3]) + '\n')
        if re.search('^GO', line[11]) :
            outFile3.write(line[0] + '\t' + line[11] + '\t' + str(line[3]) + '\n')
        if re.search('^Uni', line[12]) :
            outFile4.write(line[0] + '\t' + line[12] + '\t' + str(line[3]) + '\n')
        if line[13]!='0':
            outFile5.write(line[0] + '\t' + line[13] + '\t' + str(line[3]) + '\n')
        
inFile.close()
outFile1.close()
outFile2.close()
outFile3.close()
outFile4.close()
outFile5.close()
