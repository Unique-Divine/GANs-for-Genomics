import vcf
import os
import sys
import gzip
import time
import numpy as np
import pandas as pd

sys.path.append("..")
DATA_PATH = os.path.join("..", "data" )
VCF_FILES = {
    "C": r"allChr.allSamps.90DR2.maf01.hweE7.noIBD.CharlesRiverOnly.vcf.gz",
    "H": r"allChr.allSamps.90DR2.maf01.hweE7.noIBD.HarlanOnly.vcf.gz"}

def read_chars_gz(n, vcf_file_path):
    """ Read the first n characters of the .gz vcf file.
    Args:
        n (int)
    """
    with gzip.open(vcf_file_path, 'rt') as f:
        print(f.read(n))

def appendRecordData(record_df, record):
    """
    Args:
        record_df (pd.DataFrame): 
        record (vcf.model._Record):
    
    Returns:
        (pd.DataFrame): record_df with an additional row of record (SNP) data.
    """
    
    # Alternate allele bases
    if len(record.ALT) == 0:
        alt0, alt1 = np.nan, np.nan
    elif len(record.ALT) == 1:
        alt0, alt1 = record.ALT[0], np.nan

    varIdentifier = pd.Series(record.ID, name="varIdentifier")
    
    df = pd.DataFrame(
        data = {"refBase": record.REF, "altAllele0": alt0,
                "altAllele1": alt1},
        index = varIdentifier)
    
    record_df = record_df.append(df, ignore_index=False)
    
    return record_df

def appendCallData(call_df, record):
    """
    Args:
        call_df (pd.DataFrame):
        record (vcf.model._Record): 
        
    Returns:
        (pd.DataFrame): call_df with additional columns of (SNP) data
    """

    varIdentifier = pd.Series(record.ID, name="SNP"+"varIdentifier")
    sample_names = np.array([sample.sample for sample in record.samples])
    gt_types = np.array([sample.gt_type for sample in record.samples]).reshape(1,-1)
    
    df = pd.DataFrame(
        data = gt_types,
        columns = sample_names,
        index = varIdentifier)
    
    call_df = call_df.append(df, ignore_index=False)
    
    return call_df

def vcftoDataFrame(vcf_reader, verbose=False, test=False, save=False):
    """Loops through the vcf file and converts the raw text data into 
    pd.DataFrame objects. 
    """

    BATCH_SIZE= 1000
    batch_idx = 0
    
    # initialize DataFrames 
    recordAttributes = pd.DataFrame()
    call_df = pd.DataFrame()
    
    # time the operation
    start_time = time.time()
    
    for snp_idx, record in enumerate(vcf_reader, start=0):
        recordAttributes = appendRecordData(recordAttributes, record=record)
        call_df = appendCallData(call_df, record=record) 

        if (snp_idx != 0) and (snp_idx % BATCH_SIZE == 0):  
            if save == True:
                # Save current DataFrames to csv
                tag = "H"
                recordAttributes.to_csv(f"recordAttributes_{tag} ({batch_idx}).csv")
                call_df.to_csv(f"gtTypes_{tag} ({batch_idx}).csv")
            else:
                print(f"Test save {batch_idx}")

            batch_idx += 1

            # Re-initialize DataFrames
            recordAttributes = pd.DataFrame()
            call_df = pd.DataFrame()

        if verbose == True:
            if (snp_idx % 1000) == 0:
                current_time = time.time() - start_time
                minutes = int(current_time / 60)
                seconds = current_time % 60
                print(f"SNPs looped: {snp_idx}. Time: {minutes} min, {seconds:.1f} s.")
            if (snp_idx % 10000) == 0:
                print("---------------------------")
                
        if test == True:
            # Stop criterion
            if snp_idx == 5:
                print(recordAttributes.head(), '\n\n\n')
                print(call_df.head())
                break

def main():
    # Charles River Processing
    vcf_file_name = VCF_FILES["C"]
    vcf_file_path = os.path.join(DATA_PATH, "DawleyRats", vcf_file_name)
    vcf_reader = vcf.Reader(filename=vcf_file_path, compressed=True)
    vcftoDataFrame(vcf_reader, test=False, verbose=True, save=True) 

    # Harlan River Processing
    vcf_file_name = VCF_FILES["H"]
    vcf_file_path = os.path.join(DATA_PATH, "DawleyRats", vcf_file_name)
    vcf_reader = vcf.Reader(filename=vcf_file_path, compressed=True)
    vcftoDataFrame(vcf_reader, test=False, verbose=True, save=True) 

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("Halted.")