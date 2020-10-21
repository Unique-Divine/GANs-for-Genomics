#!/bin/bash

#PBS -N eigen_union_smartpca
#PBS -S /bin/bash
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=4
#PBS -j oe
#PBS -o /projects/ps-palmer/Rats/SD/GBS/eigensoft/logs/${PBS_JOBID}_eigensoft_smartpcaSubpop_unionSNPs.out
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

cd /projects/ps-palmer/Rats/SD/GBS/eigensoft
export PERL5LIB=/home/aschitre/local/src/vcftools_0.1.13/perl
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/agileta/OpenBLAS
module load gnu
module load gsl
homedir="/oasis/tscc/scratch/agileta/SD/GBS"
outdir="/projects/ps-palmer/Rats/SD/GBS/eigensoft"

################################################
#### Create union and overlap SNP sets in R ####
################################################

#library(data.table)
#CR_snps = fread(input = "allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.bim")
#Har_snps = fread(input = "allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.bim")
#allSNPs = union(CR_snps$V2, Har_snps$V2)
#overlap = Har_snps$V2[Har_snps$V2 %in% CR_snps$V2]
#write.table(x = allSNPs, file = "allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.snplist", quote = F, row.names = F, col.names = F)
#write.table(x = overlap, file = "allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.snplist", quote = F, row.names = F, col.names = F)

#############################################################
#### Extract SNPs for union and overlap and LD prune     ####
#############################################################

#### Extract overlapping SNP set and make BED/BIM/FAM
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/allSamples_noIBD_FINAL_plink.txt --extract ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.snplist --make-bed --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap
#### Extract union SNP set and make BED/BIM/FAM
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --keep ${homedir}/variants/allSamples_noIBD_FINAL_plink.txt --extract ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.snplist --make-bed --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union

#### LD Prune overlapping SNP set at 0.2 threshold
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap --indep-pairwise 50 5 0.2 --out ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap
#### LD Prune union SNP set at 0.2 threshold
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union --indep-pairwise 50 5 0.2 --out ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union

#### Extract LD pruned SNPs overlap
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap --extract ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.prune.in --make-bed --out ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20
#### Extract LD pruned SNPs union 
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union --extract ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.prune.in --make-bed --out ${outdir}/allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20

#### ALTER FAM FILES FOR POPULATION CODING IN EXCEL in SD Rats All Phenotyoes D1-D5 

################################################
#### Check sample relatedness with smartrel ####
################################################

#/home/agileta/EIG/bin/smartrel.perl 

#################################################################################
#### Remove samples that showed up as highly related before running smartpca ####
# THIS SEEMS TO ALREADY BE DONE BY THE PROGRAM WHILE RUNNING
#################################################################################

################################################
#### Get principal components from smartpca ####
################################################

##### VENDOR ######
#/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Vendor.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Vendor.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Vendor.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Vendor.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Vendor.pca-smartpca.log

#/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Vendor.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Vendor.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Vendor.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Vendor.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Vendor.pca-smartpca.log


##### SUBPOP ######
#/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Subpop.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Subpop.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Subpop.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Subpop.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Subpop.pca-smartpca.log

/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Subpop.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Subpop.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Subpop.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Subpop.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Subpop.pca-smartpca.log


##### BARRIER ######
#/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Barrier.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Barrier.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Barrier.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Barrier.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.LDpruned20.Barrier.pca-smartpca.log

#/home/agileta/EIG/bin/smartpca.perl -i allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.bed -a allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.pedsnp -b allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Barrier.pedind -p allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Barrier.pca -e allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Barrier.eval -o allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Barrier.pca -q NO -l allChr.allSamps.90DR2.maf01.hweE7.noIBD.union.LDpruned20.Barrier.pca-smartpca.log


################################################################
echo -n 'Ended job at  : ' ; date


