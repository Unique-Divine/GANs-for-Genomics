#!/bin/bash

#PBS -N HWE_10e5
#PBS -S /bin/bash
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=2
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/variants/LDAK/MultiBLUP/logs/${PBS_JOBID}_HWE_10e5.out
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

export PERL5LIB=/home/aschitre/local/src/vcftools_0.1.13/perl
homedir="/oasis/tscc/scratch/agileta/SD/GBS"
outputdir="/projects/ps-palmer/Rats/SD/GBS/"

#chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`


### (1) ### Filter original set of SNPs for DR2 and samples to keep
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract ${homedir}/variants/allChr.allSamps.90DR2.snplist.txt --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --maf 0.01 --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract ${homedir}/variants/allChr.allSamps.90DR2.snplist.txt --keep ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --maf 0.01 --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly

### (2) ### Filter for HWE in all subpopulations at multiple thresholds
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly

####### NO THRESHOLD
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.Harlan_Frederick

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.Harlan_Haslett

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hardy --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.Harlan_Indianapolis

####### HWE THRESHOLD 1x10E-5
/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.CharlesRiver_Portage
/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.Harlan_Frederick

/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.CharlesRiver_Raleigh
/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.Harlan_Haslett

/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.CharlesRiver_SaintConstant
/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE5.Harlan_Indianapolis

####### HWE THRESHOLD 1x10E-7
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Frederick

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Haslett

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Indianapolis

####### HWE THRESHOLD 1x10E-9
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.Harlan_Frederick

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.Harlan_Haslett

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE9.Harlan_Indianapolis

####### HWE THRESHOLD 1x10E-12
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.Harlan_Frederick

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.Harlan_Haslett

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE12.Harlan_Indianapolis

####### HWE THRESHOLD 1x10E-15
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.Harlan_Frederick

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.Harlan_Haslett

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE15.Harlan_Indianapolis

#########################################
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --hardy --hwe 0.00001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE5.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --hardy --hwe 0.00001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE5.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --hardy --hwe 0.0000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --hardy --hwe 0.0000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --hardy --hwe 0.000000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE9.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --hardy --hwe 0.000000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE9.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --hardy --hwe 0.000000000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE12.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --hardy --hwe 0.000000000001 --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE12.HarlanOnly

## (3) ## Merge SNP lists and only save shared sites
#sort ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.HarlanOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.HarlanOnly.sorted.snplist
#sort ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.CharlesRiverOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist
#comm -12 ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.HarlanOnly.sorted.snplist ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist > ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.snplist

#sort ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.HarlanOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.HarlanOnly.sorted.snplist
#sort ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.CharlesRiverOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist
#comm -12 ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.HarlanOnly.sorted.snplist ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist > ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.snplist

#sort ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.HarlanOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.HarlanOnly.sorted.snplist
#sort ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiverOnly.snplist > ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist
#comm -12 ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.HarlanOnly.sorted.snplist ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiverOnly.sorted.snplist > ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.snplist
