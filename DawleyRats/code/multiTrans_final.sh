#!/bin/bash

#PBS -N mTrans_bodySort
#PBS -S /bin/bash
#PBS -l walltime=8:00:00
#PBS -l nodes=1:ppn=4
#PBS -j oe
#PBS -o /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/logs/${PBS_JOBID}_multiTrans_sort.out
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

chrom=`head -$PBS_ARRAYID /oasis/tscc/scratch/agileta/SD/GBS/chroms_rat.list | tail -1`

export PATH=/home/agileta/anaconda2/bin:$PATH
module load gnu
module load python
module load scipy

#################################
#### Make dosage/Xpath files ####
#################################

#### Trim off first 3 columns
#cut -d ' ' -f 4- /oasis/tscc/scratch/agileta/SD/GBS/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.dosages > /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.4multiTrans.dosages
#cut -d ' ' -f 4- /oasis/tscc/scratch/agileta/SD/GBS/variants/dosageFiles/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.dosages > /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.4multiTrans.dosages

#### Transpose matrix to have samples as rows and variants as columns ####
#cat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.4multiTrans.dosages | ~/rowsToCols stdin /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.4multiTrans.transpose.dosages
#cat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.4multiTrans.dosages | ~/rowsToCols stdin /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.4multiTrans.transpose.dosages

####3. Generate correlation matrix r in the rotate space
cd /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/

#mkdir genR_CR_bodyweight_${chrom}
#/home/agileta/R-3.3.2/bin/R CMD BATCH --args \
#-Xpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.4multiTrans.transpose.dosages" \
#-Kpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/LOCO/GRMs/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.cXX.txt" \
#-VCpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/varianceComponents_bodyweight_CharlesRiver.txt" \
#-outputPath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}" \
#/projects/ps-palmer/software/local/src/MultiTrans/generateR.R #/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/generateR_CR_bodyweight_${chrom}.log

#mkdir genR_Har_bodyweight_${chrom}
#/home/agileta/R-3.3.2/bin/R CMD BATCH --args \
#-Xpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.4multiTrans.transpose.dosages" \
#-Kpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/GEMMA_files/LOCO/GRMs/allExcept${chrom}.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.cXX.txt" \
#-VCpath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/varianceComponents_bodyweight_Harlan.txt" \
#-outputPath="/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}" \
#/projects/ps-palmer/software/local/src/MultiTrans/generateR.R #/oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/generateR_Har_bodyweight_${chrom}.log

####4. Generate correlation band matrix c
#/usr/lib/jvm/jre-1.8.0/bin/java -jar /projects/ps-palmer/software/local/src/MultiTrans/generateC/generateC.jar 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/r.txt /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/c.txt

#/usr/lib/jvm/jre-1.8.0/bin/java -jar /projects/ps-palmer/software/local/src/MultiTrans/generateC/generateC.jar 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/r.txt /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/c.txt

####5.1. slide_1prep
#/projects/ps-palmer/software/local/src/slide.1.0/slide_1prep -C /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/c.txt 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/prep

#/projects/ps-palmer/software/local/src/slide.1.0/slide_1prep -C /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/c.txt 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/prep

####5.1.SINGLE slide_1prep
#/projects/ps-palmer/software/local/src/slide.1.0/slide_1prep -C /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr15/c.txt 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr15/prep

#/projects/ps-palmer/software/local/src/slide.1.0/slide_1prep -C /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr18/c.txt 1000 /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr18/prep

####5.2. slide_2run
#/projects/ps-palmer/software/local/src/slide.1.0/slide_2run /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/prep /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_${chrom}/maxstat 1000000 1234

#/projects/ps-palmer/software/local/src/slide.1.0/slide_2run /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/prep /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_${chrom}/maxstat 1000000 1234

####5.2.SINGLE slide_2run
#/projects/ps-palmer/software/local/src/slide.1.0/slide_2run /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr15/prep /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr15/maxstat 1000000 1234

#/projects/ps-palmer/software/local/src/slide.1.0/slide_2run /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr18/prep /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr18/maxstat 1000000 1234

#####5.3. slide_3sort
#/projects/ps-palmer/software/local/src/slide.1.0/slide_3sort /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/sorted_CR_bodyweight /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr1/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr2/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr3/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr4/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr5/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr6/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr7/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr8/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr9/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr10/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr11/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr12/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr13/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr14/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr15/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr16/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr17/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr18/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr19/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_CR_bodyweight_chr20/maxstat  

#/projects/ps-palmer/software/local/src/slide.1.0/slide_3sort /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/sorted_Har_bodyweight /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr1/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr2/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr3/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr4/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr5/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr6/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr7/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr8/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr9/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr10/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr11/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr12/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr13/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr14/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr15/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr16/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr17/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr18/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr19/maxstat /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/genR_Har_bodyweight_chr20/maxstat                           

####5.4. slide_4correct
/projects/ps-palmer/software/local/src/slide.1.0/slide_4correct -t /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/sorted_CR_bodyweight /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/threshold.txt /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/MultiTrans_CR_bodyweight_05.output

/projects/ps-palmer/software/local/src/slide.1.0/slide_4correct -t /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/sorted_Har_bodyweight /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/threshold.txt /oasis/tscc/scratch/agileta/SD/GBS/variants/multiTrans/MultiTrans_Har_bodyweight_05.output


################################################################
echo -n 'Ended job at  : ' ; date
