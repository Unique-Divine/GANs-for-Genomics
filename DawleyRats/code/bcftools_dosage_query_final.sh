#! /bin/bash

#PBS -N bcftools_dosages
#PBS -l walltime=8:00:00
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/variants/dosageFiles/logs/${PBS_JOBID}_bcftools_dosages_byChrom.out
#PBS -l nodes=1:ppn=4
#PBS -q condo

######PBS -l nodes=tscc-3-25:ppn=4+nodes=tscc-3-27:ppn=4
######ulimit -n 5000

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

chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`
module load bcftools
homedir="/oasis/tscc/scratch/agileta/SD/GBS"

###################################################################
# BGZIP and Tabix index primary VCF file		          #
###################################################################

#gunzip /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.vcf.gz

###################################################################
# Extract a list of SNPs from filtered VCF for pulling dosages    #
###################################################################

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --write-snplist --out /oasis/tscc/scratch/agileta/SD/GBS/variants/dosageFiles/allChr.allSamps.90DR2.hweE7.maf01.snps4dosage

###################################################################
# Make dosage ande snpinfo files for all chromosomes together     #
###################################################################

#bcftools view -Ou --samples-file ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --regions-file ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.regions  ${homedir}/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages
#bcftools view -Ou --samples-file ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --regions-file ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.regions  ${homedir}/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snpinfo

#bcftools view -Ou --samples-file ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --regions-file ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.regions  ${homedir}/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %REF %ALT[ %DS]\n' -o ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages
#bcftools view -Ou --samples-file ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --regions-file ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.regions  ${homedir}/variants/allChr.allSamps.vcf.gz | bcftools query -f '%CHROM\.%POS %POS %CHROM\n' -o ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snpinfo

#########################################################################
# Extract filtered SNP list from concatenated dosage and snpinfo files  #
#########################################################################

cd /oasis/tscc/scratch/agileta/SD/GBS/variants/dosageFiles

###### THEN SPLIT THE DOSAGE FILE INTO MULTIPLE, EACH MISSING ONE CHROMOSOME ##########

grep -vw ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages > ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages
grep -vw ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snpinfo > ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snpinfo

grep -w ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages > ${homedir}/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages
grep -w ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snpinfo > ${homedir}/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snpinfo

grep -vw ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages > ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages
grep -vw ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snpinfo > ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snpinfo

grep -w ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages > ${homedir}/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages
grep -w ${chrom} ${homedir}/variants/dosageFiles/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snpinfo > ${homedir}/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snpinfo

#gzip ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.Harlan.90DR2.hweE7.maf01.dosages
#gzip ${homedir}/variants/dosageFiles/allChr.allSamps.Harlan.dosages

#gzip ${homedir}/variants/dosageFiles/allExcept${chrom}.allSamps.CharlesRiver.90DR2.hweE7.maf01.dosages
#gzip ${homedir}/variants/dosageFiles/allChr.allSamps.CharlesRiver.dosages


################################################################
echo -n 'Ended job at  : ' ; date