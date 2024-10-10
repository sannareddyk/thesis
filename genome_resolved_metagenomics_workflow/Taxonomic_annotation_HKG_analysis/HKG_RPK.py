#!/usr/bin/python3

"""
A script for parsing HKG abundances and generate RPK
Keerthi Sannareddy, Jan 2023

"""
import os
import sys

inFileName = sys.argv[1]
inFile = open(inFileName)

outFileName = sys.argv[2]
outFile = open(outFileName, "w")
outFile.write('geneID' + '\t' + 'geneLength' + '\t' + 'rawCounts' + '\t' + 'RPK' + '\t' + 'HKGtype' + '\t' + 'genomeID' + '\t' + 'lineage' + '\n')

for line in inFile.readlines()[1:]:

    line = line.strip().split('\t')

    geneID = line[0]
    #print(geneID)

    geneLength = line[1]
    geneLengthKb = int(line[1])/1000
    #print(geneLengthKb)

    rawCounts = line[2]
    #print(rawCounts)
   
    HKGtype = line[3]
    genomeID = line[4]
    lineage = line[5]

    try:
        normCounts = round(int(rawCounts)/geneLengthKb,2)
    #print(normCounts)
    except ZeroDivisionError:
        normCounts = 0
    
    resultLine = geneID + "\t" + str(geneLength) + "\t" + str(rawCounts) + "\t" + str(normCounts) + "\t" + str(HKGtype) + "\t" + str(genomeID) + "\t" + str(lineage)
    outFile.write(resultLine + "\n")

inFile.close()
outFile.close()
