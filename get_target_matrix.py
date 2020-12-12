#!/usr/bin/python
__author__ = "Unique Divine"

import time 
import numpy as np
import pandas as pd

def get_target_matrix():
    """ Retrives the target matrix from "targets.csv". 
    
    The mice were scored on a test and grouped into 3 categories, [GT, IR, ST]. 
    GT was the worst and ST was the best, so the groups are integer encoded
    in the following manner: [GT, IR, ST] -> [0, 1, 2].

    Returns:
        Y (np.ndarray): Phenotype values to be predicted by ML model. 
        names (np.ndarray): The names of the rats.
    """
    
    df = pd.read_csv("data/targets.csv")

    # Retrieve `sample_names` that were parsed from the vcf files.
    sample_names = {}
    batch_size = 10
    for batch_idx, batch in enumerate(pd.read_csv(
        "data/C/gt_C.csv", chunksize=batch_size)):
        sample_names['C'] = np.array(batch.columns[1:]).astype(int)
        print(f"samples in C: {len(sample_names['C'])}")
        break
    for batch_idx, batch in enumerate(pd.read_csv(
        "data/H/gts/gt_H (0).csv", chunksize=batch_size)):
        sample_names['H'] = np.array(batch.columns[1:]).astype(int)
        print(f"samples in H: {len(sample_names['H'])}")
        break

    def get_Y(target_file_ids, vcf_ids):
        assert len((a:=set(target_file_ids[:, 0]))
                    .intersection((b:=set(vcf_ids)))
                   ) == len(vcf_ids)
        # Remove uncommon elements
        for number in a.difference(b):
            target_file_ids[:, 0] = np.where((target_file_ids[:, 0] == number), None, target_file_ids[:, 0])    
        target_file_ids = pd.DataFrame(target_file_ids, columns=["RatID", "Phenotype"]).dropna()
        assert target_file_ids.shape[0] == len(vcf_ids)

        # Sort IDs
        target_file_ids = target_file_ids.set_index("RatID").sort_index()
        vcf_ids.sort()
        assert np.all(target_file_ids.index.values == vcf_ids.astype(int))
        target_file_ids = target_file_ids.astype(str)

        # Encode categories as integers
        for i, pt in enumerate(target_file_ids.Phenotype.values):
            if 'GT' in pt:
                target_file_ids.Phenotype.iloc[i] = '0'
            if 'IR' in pt:
                target_file_ids.Phenotype.iloc[i] = '1'
            if 'ST' in pt:
                target_file_ids.Phenotype.iloc[i] = '2'

        assert len(target_file_ids.Phenotype.value_counts()) == 3
        # Return Y
        Y = target_file_ids.Phenotype.values.astype(int).reshape(-1, 1)
        names = np.array(list(target_file_ids.index))
        return Y, names

    # Check if targets.csv contains the IDs in the feature matrix
    target_file_ids = df.loc[(df["Vendor"] == "Charles River")][["RatID", "Phenotype"]].values
    vcf_ids = sample_names["C"]
    Y_C, names_C = get_Y(target_file_ids, vcf_ids) 

    target_file_ids = df.loc[(df["Vendor"] == "Harlan")][["RatID", "Phenotype"]].values
    vcf_ids = sample_names["H"]
    Y_H, names_H = get_Y(target_file_ids, vcf_ids)
    
    Y = np.concatenate([Y_C, Y_H])
    names = np.concatenate([names_C, names_H])

    return Y, names

Y, names = get_target_matrix()

print(Y.shape)
print(names.shape)