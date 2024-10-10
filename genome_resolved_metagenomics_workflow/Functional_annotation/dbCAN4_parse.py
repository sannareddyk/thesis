#!/usr/bin/python3

"""
A script for parsing dbCAN4 output, generate geneID and CAZyID output
Keerthi Sannareddy, August 2023

"""
import os
import sys
import re

if len(sys.argv) != 3:
    print("usage: python3 dbCAN4_parse.py overview.txt CAZy.final.txt")
    sys.exit()

inFileName = sys.argv[1]
inFile = open(inFileName)
#next(inFile)

outFileName = sys.argv[2]
outFile = open(outFileName, "w")
outFile.write('geneID' + '\t' + 'CAZyID' + '\n')

for line in inFile.readlines()[1:]:

    words = line.strip().split('\t')
    print(words)

    if int(words[5])>=2:

        geneID = words[0]

        HMMER = words[2].split('+')
        HMMER_new = [re.sub("\(.*|_.*","", string) for string in HMMER]
        print(HMMER_new)

        dbCAN_sub = words[3].split('+')
        dbCAN_sub_new = [re.sub("_e.*","", string) for string in dbCAN_sub]
        print(dbCAN_sub_new)

        DIAMOND = words[4].split('+')
        DIAMOND_new = [re.sub("_.*","",string) for string in DIAMOND]
        print(DIAMOND_new)

        word_list = HMMER_new + dbCAN_sub_new + DIAMOND_new
        print(word_list)
        word_list = list(set(word_list))
        word_list = [i for i in word_list if i!='-']

        for i in word_list:
            outFile.write(geneID + '\t' + i + '\n')
