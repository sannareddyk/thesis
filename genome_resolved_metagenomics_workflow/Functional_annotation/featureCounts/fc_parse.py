#!/usr/bin/python3

"""
A script for parsing featureCounts output
Keerthi Sannareddy, April 2022

"""
import os
import sys

inFileName = sys.argv[1]
inFile = open(inFileName)

outFileName = sys.argv[2]
outFile = open(outFileName, "w")
outFile.write('geneID' + '\t' + 'rawCounts' + '\t' + "geneLength" + "\t" + 'normCounts' + '\n')

for line in inFile.readlines()[2:]:

    line = line.strip().split('\t')

    geneID = line[0]
    #print(geneID)

    geneLength = line[5]
    geneLengthKb = int(line[5])/1000
    #print(geneLengthKb)

    rawCounts = line[-1]
    #print(rawCounts)

    normCounts = round(int(rawCounts)/geneLengthKb,2)
    #print(normCounts)
    
    resultLine = geneID + "\t" + str(rawCounts) + "\t" + str(geneLength) + "\t" + str(normCounts)
    outFile.write(resultLine + "\n")

inFile.close()
outFile.close()
