#!/bin/bash

#PBS -N snpInfo70
#PBS -S /bin/bash
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#PBS -o variants/logs/${PBS_JOBID}_SNPinfo70_allChr_allSamps.out
#PBS -q condo

#################################################################################
#			REPORTING DATA FOR OUTPUT SUMMARY			#
#################################################################################
echo -n 'Started job at : ' ; date
echo " "
echo "-------------------"
echo "This is a $PBS_ENVIRONMENT job"
echo "This job was submitted to the queue: $PBS_QUEUE"
echo "The job's id is: $PBS_JOBID"
echo "-------------------"
echo "The master node of this job is: $PBS_O_HOST"

# --- the nodes allocated to this job are listed in the
#     file PBS_NODEFILE

# --- count the number of processors allocated to this run 
# --- $NPROCS is required by mpirun.
NPROCS=`wc -l < $PBS_NODEFILE`
NNODES=`uniq $PBS_NODEFILE | wc -l`
echo "This job is using $NPROCS CPU(s) on the following $NNODES node(s):"
echo "-----------------------"
uniq $PBS_NODEFILE | sort
echo "-----------------------"
################################################################################

#################################################################
# 			Job Execution 				#
#################################################################

cd /oasis/tscc/scratch/agileta/SD/GBS/variants

#### Remove genotype information from SNPs
#zcat allChr.allSamps.vcf.gz | grep '^chr' | cut -f 1-9 > allChr.allSamps.snpinfo.txt

#### Remove semicolon separators and INFO tags
#sed 's/;/\t/g' allChr.allSamps.snpinfo.txt | sed 's/DR2=//g' | sed 's/AR2=//g' | sed 's/AF=//g' | cut -f 1-3,8-10 > allChr.allSamps.snpInfo_trimmed.txt

#### Set threshold and extract SNP names with >0.9 DR2
threshold=0.7
awk -v threshold="$threshold" '$4 >= threshold' allChr.allSamps.snpInfo_trimmed.txt | cut -f 3  > allChr.allSamps.70DR2.snplist.txt

#### To change the SNP name into a tab separated chromosome amd position should you need to extract regions rather than SNP names
#sed -i 's/\./\t/g' in order to change SNP names to tab separated chromosome and position
################################################################
echo -n 'Ended job at  : ' ; date
