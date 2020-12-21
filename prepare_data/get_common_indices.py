#!/usr/bin/python

import numpy as np
import pandas as pd
import warnings
warnings.filterwarnings('ignore')
import time

def getSNPNames(group="C", timeit=False):
    if group == "C":
        pass
    elif group == "H":
        pass
    else:
        raise ValueError(f"Group parameter must be 'C' or 'H', not '{group}'.")
    
    start_time = time.time()
    SNP_name_list = []
    if group == "C":
        # There are about 215,000 SNPs. 
        # You should set csvBatchSize * maxIteration > 215,000
        csvBatchSize = 2000 
        maxIteration = 130
        path = "data/C/recordAttributes_C.csv"

        for csvBatch_idx, csvBatch in enumerate(
            pd.read_csv(path, chunksize=csvBatchSize)):
            current_time = time.time() - start_time
            if (csvBatch_idx % 20 == 0) and (timeit):
                print(f"Batch: {csvBatch_idx}\t"
                    + f"Time: {current_time:.2f} s\t"
                    + "SNPs per second: {:.2f}".format(
                        (csvBatchSize * csvBatch_idx) / current_time))
            data = csvBatch
            SNP_name_batch = data["varIdentifier"].values.astype(str)
            SNP_name_list.append(SNP_name_batch)

            if csvBatch_idx == maxIteration:
                break
    else:
        for i in range(114):
            path = f"data/H/recordAttributes/recordAttributes_H ({i}).csv"
            data = pd.read_csv(path)
            SNP_name_batch = data["varIdentifier"].values.astype(str)
            SNP_name_list.append(SNP_name_batch)

    SNP_names = np.concatenate(SNP_name_list)
    return SNP_names

def getCommonSNPNames():
    SNP_names_C = getSNPNames("C")
    SNP_names_H = getSNPNames("H")
    common_SNP_names = set(SNP_names_C).intersection(set(SNP_names_H))
    return common_SNP_names

def printCommonSNPCounts():
    common_SNPs = getCommonSNPNames()
    print(f"Number of common SNPs: {len(common_SNPs)}")
    SNP_names_H = getSNPNames("H")
    print(f"Number of SNPs in H: {len(SNP_names_H)}")

def getCommonSNPIndices(group="C", save=False, verbose=True):
    common_SNP_names = getCommonSNPNames()
    if group == "C":
        SNP_names = getSNPNames("C")
    elif group == "H":
        SNP_names = getSNPNames("H")
    else:
        SNP_names = None
        raise ValueError(f"Group parameter must be 'C' or 'H', not '{group}'.")
    start_time = time.time()

    indices = []
    SNP_names = list(SNP_names)
    for iteration, name in enumerate(common_SNP_names):
        idx = SNP_names.index(name)
        indices.append(idx)
        if verbose and (iteration % 5000 == 0):
            current_time = time.time() - start_time
            print(f"Time: {current_time:.2f} s\t"
                + f"SNPs / s: {iteration / current_time:.2f}\t"
                + f"SNPs processed: {iteration}")
    if save: 
        if group == "C":
            pd.Series(indices).to_csv("data/C/common_indices_C.csv", index=False)
        elif group == "H":
            pd.Series(indices).to_csv("data/H/common_indices_H.csv", index=False)
    return np.array(indices)

def main (verbose=True):
    """The Charles River and Harlan River datasets don't contain the same SNPs.
    This script finds the SNPs for which the two datasets overlap and saves the
    indices corresponding this overlap in two .csv files. After running this
    script, run `get_common_Xs.py`.

    Args:
        verbose (bool, optional): Toggles print statements. Defaults to True.
    """
    if verbose: 
        print("\n---------------")
        printCommonSNPCounts()
        print("---------------")
    
        print("Charles River")
        print("---------------")    
        getCommonSNPIndices("C", save=True)
        print("---------------")
        
        print("Harlan River")
        getCommonSNPIndices("H", save=True)
        print("---------------")
    else:
        getCommonSNPIndices("C", save=True)
        getCommonSNPIndices("H", save=True)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("operation halted.")