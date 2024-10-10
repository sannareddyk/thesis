#!/bin/bash

#Keerthi Sannareddy, Mar 2022

fileNamePattern_1="final_pure_reads_1.fastq"
fileNamePattern_2="final_pure_reads_2.fastq"

#please change input file path
for file in *mWoutput/final*.fastq; do
	if [[ $file =~ $fileNamePattern_1 ]]; then
		sampleName=`echo $file | cut -d"_" -f1`
		#echo $file
		#echo $sampleName
		mv $file ${sampleName}_trimmed_1.fastq
	elif [[ $file =~ $fileNamePattern_2 ]]; then
		sampleName=`echo $file | cut -d"_" -f1`
		mv $file ${sampleName}_trimmed_2.fastq
		#echo $file
		#echo $sampleName
	fi
done
