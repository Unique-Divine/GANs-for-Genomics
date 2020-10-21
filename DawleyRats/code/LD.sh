#!/bin/bash

#PBS -N LD_plinkFreq
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=12
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/logs/${PBS_JOBID}_LD_plinkFreq_HS.out
#PBS -q home

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

module load gnu

#### Perform 
chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf20.4LD.CharlesRiverOnly --r2 yes-really square --chr ${chrom} --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/${chrom}.allSamps.90DR2.hwe7.maf20.4LD.CharlesRiverOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf20.4LD.HarlanOnly --r2 yes-really square --chr ${chrom} --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/${chrom}.allSamps.90DR2.hwe7.maf20.4LD.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/Axiom.hwe7.maf20.4LD --r2 yes-really square --chr ${chrom} --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/${chrom}.96Samps.hwe7.maf20.4LD

#### TO GET MINOR ALLELE FREQUENCIES FOR LD DECAY ####
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned.CharlesRiverOnly --freq --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/allChr.allSamps.90DR2.hwe7.maf01.unpruned.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned.HarlanOnly --freq --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/allChr.allSamps.90DR2.hwe7.maf01.unpruned.HarlanOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned --freq --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/allChr.allSamps.90DR2.hwe7.maf01.unpruned

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/Axiom.hwe7.maf20.4LD --freq --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/allChr.96axiom.90DR2.hwe7.maf20.4LD

#### COMMAND TO RUN THE LD DECAY SCRIPT ####
#/home/agileta/R-3.3.2/bin/R CMD BATCH /oasis/tscc/scratch/agileta/SD/GBS/code/LD_decay_axiom.R



###########################################################
# Working with HS data for filtering for LD Plot
###########################################################

###### FILTER FOR DR2 #############
cd /oasis/tscc/scratch/agileta/SD/GBS/variants/LD

#/home/aschitre/local/src/tabix-0.2.6/bgzip /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_Real.chrAll.rehead.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_Real.chrAll.rehead.vcf.gz

#zcat P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.vcf.gz | grep '^chr' | cut -f 1-9 > HS1604.allChr.snpinfo.txt
#sed 's/;/\t/g' HS1604.allChr.snpinfo.txt | sed 's/AR2=//g' | sed 's/DR2=//g' | sed 's/AF=//g' | cut -f 1-3,8-10 > HS1604.allChr.snpinfo_trimmed.txt
#threshold=0.9
#awk -v threshold="$threshold" '$4 >= threshold' HS1604.allChr.snpinfo_trimmed.txt | cut -f 3  > HS1604_SNPs_90DR2.list

#### Filter out SNPs with low DR2, MAF<0.2, and HWE violation after impuation ####
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.vcf.gz --remove /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/remove_axiom_from_HS.list --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/HS1604_SNPs_90DR2.list --maf 0.2 --hwe 0.0000001 --keep-allele-order --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.90DR2.MAF20.HWEe7

#### Get r2 for all HS SNPs on each chromosome ####
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.90DR2.MAF20.HWEe7 --r2 yes-really square --chr ${chrom} --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/${chrom}.P50_HS_5xBatches1550out1604.90DR2.MAF20.HWEe7

#### Get frequencies for LD calculations for HS ####
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.90DR2.MAF20.HWEe7 --freq --out /oasis/tscc/scratch/agileta/SD/GBS/variants/LD/P50_HS_5xBatches1550out1604.90DR2.MAF20.HWEe7

#### COMMAND TO RUN THE LD DECAY SCRIPT ####
/home/agileta/R-3.3.2/bin/R CMD BATCH /oasis/tscc/scratch/agileta/SD/GBS/code/LD_decay_HS.R

#P50_HS_5xBatches1550out1604_annotated.chrAll.rehead.90DR2.MAF20.HWEe7.vcf


################################################################
echo -n 'Ended job at  : ' ; date