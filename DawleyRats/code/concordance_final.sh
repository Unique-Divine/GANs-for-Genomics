#!/bin/bash

#PBS -N concordance_RAW
#PBS -S /bin/bash
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=2
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/logs/${PBS_JOBID}_concordance_RAW.out
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
module load bcftools
#chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`


###################################################################
# BGZIP and Tabix index primary VCF file		          #
###################################################################

#gunzip /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz

##### ALL SAMPLES #########################################################################################################################
## (1) ## Filter original set of SNPs for DR2 & MAF
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.snplist.txt --maf 0.01 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.80DR2.snplist.txt --maf 0.01 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.70DR2.snplist.txt --maf 0.01 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01

## (2) ## Filter for HWE in both populations at various DR2 thresholds
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.90DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.90DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.80DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.80DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.70DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/allChr.allSamps.70DR2.maf01.snplist --hwe 0.0000001 --write-snplist --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.HarlanOnly


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

########################################################################################################
# Make dosage ande snpinfo files for all chromosomes for just the good SNPs and duplicate samples      #
########################################################################################################
cd /oasis/tscc/scratch/agileta/SD/GBS/variants/concordance/

#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.90DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.90DR2.maf01.hweE7.originals4concordance.dosages
#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.90DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.90DR2.maf01.hweE7.originals4concordance.snpinfo
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.90DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance.dosages
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.90DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance.snpinfo

#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.80DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.80DR2.maf01.hweE7.originals4concordance.dosages
#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.80DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.80DR2.maf01.hweE7.originals4concordance.snpinfo
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.80DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance.dosages
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.80DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance.snpinfo

#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.70DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.70DR2.maf01.hweE7.originals4concordance.dosages
#bcftools view -Ou --samples-file originals_4Concordance.list --regions-file allChr.allSamps.70DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.70DR2.maf01.hweE7.originals4concordance.snpinfo
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.70DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance.dosages
#bcftools view -Ou --samples-file duplicates_4Concordance.list --regions-file allChr.allSamps.70DR2.maf01.hweE7.bcfRegions.snplist  /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance.snpinfo
#########################################################################################################

## (4) ## Extract filtered SNP sets into VCF, compress them, and index it.
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/originals_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/duplicates_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance

#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance.vcf 
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance.vcf.gz

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/originals_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/duplicates_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance

#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance.vcf 
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance.vcf.gz

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/originals_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/concordance/duplicates_4Concordance.list --extract ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance

#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance.vcf 
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance.vcf.gz

## (4b) ## Convert VCF to bed file for Yuyu concordance check
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance.vcf.gz --make-bed --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance

## (?4c?) ## Extract overlapping SNPs - DIDN'T USE 1/30/2018
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup1 --extract ${homedir}/variants/concordance/overlapping_snpnames.txt --make-bed --out ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup1_overlap
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup2 --extract ${homedir}/variants/concordance/overlapping_snpnames.txt --make-bed --out ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup2_overlap

## (?5?) ## Run PLINK merge to check for strand flip issues DIDN'T USE 1/30/2018
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup2_overlap --bmerge ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup1_overlap --make-bed --out ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.merged

## (6) ## Output RAW files for overlap filtered data for use with concordance script
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.originals4concordance
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.90DR2.maf01.hweE7.duplicates4concordance

/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.originals4concordance
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.80DR2.maf01.hweE7.duplicates4concordance

/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.originals4concordance
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance --recodeA --out ${homedir}/variants/concordance/allChr.allSamps.70DR2.maf01.hweE7.duplicates4concordance
##############################################################################################################################################################

## (7) ##
##/projects/ps-palmer/software/local/src/bcftools-1.3/bcftools gtcheck -g ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup1.vcf.gz --GTs-only 1 --all-sites ${homedir}/variants/concordance/chr20.allSamps.hweE7.maf01.dup2.vcf.gz

##############################################################################################################################################################

