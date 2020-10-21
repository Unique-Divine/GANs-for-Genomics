#!/bin/bash

#PBS -N vcfFilter_concordance
#PBS -S /bin/bash
#PBS -l walltime=8:00:00
#PBS -l nodes=1:ppn=4
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/STITCH/logs/${PBS_JOBID}_overlapForConcordance.out
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

#chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`


#######################################################################
#This section is to take a VCF file, add the SNPs name as chr#.postion, 
#filter the sites for HWE in separate vendor population for HWE, 
#makes list of the SNPs that pass filtering, unite those lists into 1,
#and use that list on the original set of SNPs to filter MAF in the 
#full population.
#######################################################################

## (1) ## Filter original set of SNPs for DR2 and samples to keep
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract ${homedir}/variants/allChr.allSamps.90DR2.snplist.txt --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_FINAL.txt --maf 0.01 --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.vcf.gz --extract ${homedir}/variants/allChr.allSamps.90DR2.snplist.txt --keep ${homedir}/variants/Harlan_Samples_noIBD_FINAL.txt --maf 0.01 --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly

## (2) ## Filter for HWE in both populations
####### HWE THRESHOLD 1x10E-7
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Portage.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_Portage
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Frederick.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Frederick
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_Raleigh.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_Raleigh
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Haslett.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Haslett
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.CharlesRiverOnly.vcf --keep ${homedir}/variants/CharlesRiver_Samples_noIBD_SaintConstant.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.CharlesRiver_SaintConstant
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.HarlanOnly.vcf --keep ${homedir}/variants/Harlan_Samples_noIBD_Indianapolis.txt --hwe 0.00001 --hardy --out ${outputdir}/HWE/allChr.allSamps.90DR2.maf01.hweE7.Harlan_Indianapolis

#### Then take the HWE files and read into R code hwe_plots.R to create union SNP list for Charles River and Harlan

## (3) ## Extract SNPs passing HWE filters
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.noIBD.CharlesRiverOnly.vcf --extract ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.noIBD.HarlanOnly.vcf --extract ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.snplist --keep-allele-order --recode vcf-iid --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly

## (4) ## BGZIP VCF files and tabix index
#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.vcf.gz
#/home/aschitre/local/src/tabix-0.2.6/bgzip ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.vcf
#/home/aschitre/local/src/tabix-0.2.6/tabix -p vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.vcf.gz

## (4) ## Convert VCF files to BED format for use in plink
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.vcf.gz --make-bed --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.vcf.gz --make-bed --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly

#################################################################################################################
####    Get allele frequencies - .frq files
#################################################################################################################

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly --freq --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly --freq --out ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly

#################################################################################################################
####    Make files for PCA plots
#################################################################################################################

#### Extract overlapping Harlan/CharlesRiver SNPs, LD Prune
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep ${homedir}/variants/allSamples_noIBD_FINAL_plink.txt --extract ${homedir}/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.overlap.snplist --indep-pairwise 50 5 0.5 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.maf01.hweE7.noIBD.LDpruned50

#### Extract LD pruned SNP list
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep ${homedir}/variants/allSamples_noIBD_FINAL_plink.txt --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.maf01.hweE7.noIBD.LDpruned50.prune.in --maf 0.05 --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.maf05.hweE7.noIBD.LDpruned50

#### Make RAW file for PCA
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile ${homedir}/variants/PLINK_files/allChr.allSamps.90DR2.maf05.hweE7.noIBD.LDpruned50 --recode A --out ${homedir}/variants/PLINK_files/allChr.allSamps.90DR2.maf05.hweE7.noIBD.LDpruned50


## (6B) ## Non-LD filtered SNPs for association study
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz  --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned

## (6B1) ## Non-LD filtered SNPs for association study - HARLAN ONLY
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/Harlan_allSamps.list --maf 0.01 --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned.HarlanOnly

## (6B2) ## Non-LD filtered SNPs for association study - CHARLES RIVER ONLY
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/CharlesRiver_allSamps.list --maf 0.01 --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf01.unpruned.CharlesRiverOnly

## (6C) ## Non-LD filtered SNPs for weight association study
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr_SD3500.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/samples_with_weight.list --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr_SD3500.hwe7.maf01.weights

## (6D1) ## Non-LD filtered SNPs for linkage decay plot - HARLAN ONLY
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/Harlan_allSamps.list --maf 0.2 --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf20.4LD.HarlanOnly

## (6D2) ## Non-LD filtered SNPs for linkage decay plot - CHARLES RIVER ONLY
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/CharlesRiver_allSamps.list --maf 0.2 --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf20.4LD.CharlesRiverOnly

#### (7 - Charles River) ## Filter SNPs for PCA
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/CharlesRiver_allSamps.list --maf 0.05 --keep-allele-order --recode vcf-iid --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.CharlesRiverOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.CharlesRiverOnly.vcf --indep-pairwise 50 5 0.5 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.CharlesRiverOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.CharlesRiverOnly.vcf --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.CharlesRiverOnly.prune.in --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.CharlesRiverOnly

#### (7 - Harlan) ## Filter SNPs for PCA
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --keep /oasis/tscc/scratch/agileta/SD/GBS/Harlan_allSamps.list --maf 0.05 --keep-allele-order --recode vcf-iid --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.HarlanOnly.vcf --indep-pairwise 50 5 0.5 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.HarlanOnly.vcf --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.HarlanOnly.prune.in --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDprune50.4PCA.HarlanOnly

#################################################################################################################

#### Write list of reference SNPs from 42 genomes to extract from current set
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /projects/ps-palmer/data_public/rat/knownVariants/42genomes_homozygous_SNVs_GATK_rn6_sorted.vcf.gz --write-snplist --allow-extra-chr --vcf-idspace-to _ --out /oasis/tscc/scratch/agileta/SD/GBS/variants/42genomes_rn6

##################################################################################################################

#################################################
#### STITC    			     ####
#################################################

#chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`
cd /oasis/tscc/scratch/agileta/SD/GBS/STITCH/

#### MERGE ANNOTATED VCF FILES FOR ALL CHROMOSOMES 
#/home/aschitre/local/src/vcftools_0.1.13/perl/vcf-concat stitch.chr1.annotated.vcf.gz stitch.chr2.annotated.vcf.gz stitch.chr3.annotated.vcf.gz stitch.chr4.annotated.vcf.gz stitch.chr5.annotated.vcf.gz stitch.chr6.annotated.vcf.gz stitch.chr7.annotated.vcf.gz stitch.chr8.annotated.vcf.gz stitch.chr9.annotated.vcf.gz stitch.chr10.annotated.vcf.gz stitch.chr11.annotated.vcf.gz stitch.chr12.annotated.vcf.gz stitch.chr13.annotated.vcf.gz stitch.chr14.annotated.vcf.gz stitch.chr15.annotated.vcf.gz stitch.chr16.annotated.vcf.gz stitch.chr17.annotated.vcf.gz stitch.chr18.annotated.vcf.gz stitch.chr19.annotated.vcf.gz stitch.chr20.annotated.vcf.gz  | gzip -c > stitch.allChr.allSamps.annotated.vcf.gz

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.allSamps.annotated.vcf.gz --extract stitch.allChr.allSamps.INFO90.snplist --maf 0.01 --hwe 0.0000001 --keep /oasis/tscc/scratch/agileta/SD/GBS/variants/Harlan_Samples_noIBD_FINAL_plink.txt --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.allSamps.annotated.vcf.gz --extract stitch.allChr.allSamps.INFO90.snplist --maf 0.01 --hwe 0.0000001 --keep /oasis/tscc/scratch/agileta/SD/GBS/variants/CharlesRiver_Samples_noIBD_FINAL_plink.txt --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7

#### Get list of overlapping SNPs from ANGSD and STITCH results
#awk 'FNR==NR{a[$2];next}($2 in a){print $2}' /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.bim /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7.bim > stitch.angsd.Harlan.overlap.snplist

#awk 'FNR==NR{a[$2];next}($2 in a){print $2}' /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.bim /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7.bim > stitch.angsd.CharlesRiver.overlap.snplist

#### Prune ANGSD and STITCH SNP sets for LD (r2) 0.95 or higher
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly --indep-pairwise 50 5 0.95 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.LDpruned95.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly --indep-pairwise 50 5 0.95 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.LDpruned95.CharlesRiverOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7 --indep-pairwise 50 5 0.95 --out /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7.LDpruned95

#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7 --indep-pairwise 50 5 0.95 --out /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7.LDpruned95

#### Extract overlapping ANGSD/STITCH SNPs for concordance check using RAW file format
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly --extract stitch.angsd.Harlan.overlap.snplist --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.overlapWithSTITCH
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly --extract stitch.angsd.CharlesRiver.overlap.snplist --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.overlapWithSTITCH
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7 --extract stitch.angsd.Harlan.overlap.snplist --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7.overlapWithANGSD
#/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7 --extract stitch.angsd.CharlesRiver.overlap.snplist --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7.overlapWithANGSD

/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly --extract stitch.angsd.Harlan.overlap.snplist --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.overlapWithSTITCH
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly --extract stitch.angsd.CharlesRiver.overlap.snplist --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.overlapWithSTITCH
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7 --extract stitch.angsd.Harlan.overlap.snplist --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/stitch.allChr.Harlan.noIBD.INFO90.maf01.hweE7.overlapWithANGSD
/projects/ps-palmer/software/local/src/plink-1.90/plink --bfile /oasis/tscc/scratch/agileta/SD/GBS/STITCH/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7 --extract stitch.angsd.CharlesRiver.overlap.snplist --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/stitch.allChr.CharlesRiver.noIBD.INFO90.maf01.hweE7.overlapWithANGSD


#################################################################################################################
####    Case/Control SNP Filtering for Harlan
#################################################################################################################
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.annotated.90DR2.vcf --keep /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/CharlesRiver_CaseCon_0_plink.list --maf 0.01 --hwe 0.0000001 --write-snplist --out /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/allChr.allSamps.90DR2.hwe7.maf01.CharlesRiver.CaseCon0

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.annotated.90DR2.vcf --keep /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/CharlesRiver_CaseCon_025_plink.list --maf 0.01 --hwe 0.0000001 --write-snplist --out /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/allChr.allSamps.90DR2.hwe7.maf01.CharlesRiver.CaseCon025

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.annotated.90DR2.vcf --keep /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/CharlesRiver_CaseCon_05_plink.list --maf 0.01 --hwe 0.0000001 --write-snplist --out /oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/allChr.allSamps.90DR2.hwe7.maf01.CharlesRiver.CaseCon05

#################################################################################################################
####    PCA Plot - FINAL FOR PUBLICATION DATA
#################################################################################################################
#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --maf 0.05 --recode vcf-iid --keep-allele-order --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.vcf --indep-pairwise 50 5 0.5 --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDpruned50

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/allChr.allSamps.90DR2.hwe7.maf01.vcf.gz --extract /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDpruned50.prune.in --recode A --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.90DR2.hwe7.maf05.LDpruned50

#################################################################################################################
####    Convert overlap SNP sets to BED/BIM/FAM for LDAK
#################################################################################################################

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.HarlanOnly.vcf --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.HarlanOnly

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.CharlesRiverOnly.vcf --make-bed --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.CharlesRiverOnly

#################################################################################################################
####    Make a dosage file to see format for PRSice
#################################################################################################################

#/projects/ps-palmer/software/local/src/plink-1.90/plink --vcf /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.HarlanOnly.vcf --write-dosage --out /oasis/tscc/scratch/agileta/SD/GBS/variants/PLINK_files/allChr.allSamps.overlap.90DR2.hweE7.maf01.HarlanOnly.PLINKdos

################################################################
echo -n 'Ended job at  : ' ; date