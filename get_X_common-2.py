#!/usr/bin/python
__author__ = "Unique Divine"

import time 
import numpy as np
import pandas as pd

def X_common_C():
    X_common_C = []
    start_time = time.time()
    for batch_idx in range(44):
        # Build matrix
        batch = pd.read_csv(f"data/X_common/C ({batch_idx}).csv", index_col=False).values.T
        X_common_C.append(batch)
        # Print execution speed
        current_time = time.time() - start_time
        print(f"Batch: {batch_idx}\tTime (s): {current_time:.1f}\t"
            + f"Rows/t: {batch_idx * batch.shape[0] / current_time:.1f}")
    # Save matrix
    print("Saving X_common_C.csv...")
    X_common_C = np.hstack(X_common_C)
    pd.DataFrame(X_common_C).to_csv(
        "data/X_common_C.csv", index = False)

def X_common_H():
    X_common_H = []
    start_time = time.time()
    for batch_idx in range(44):
        # Build matrix
        batch = pd.read_csv(f"data/X_common/H ({batch_idx}).csv", index_col=False).values.T
        X_common_H.append(batch)
        # Print execution speed
        current_time = time.time() - start_time
        print(f"Batch: {batch_idx}\tTime (s): {current_time:.1f}\t"
            + f"Rows/t: {batch_idx * batch.shape[0] / current_time:.1f}")
    # Save matrix
    print("Saving X_common_H.csv...")
    X_common_H = np.hstack(X_common_H)
    pd.DataFrame(X_common_H).to_csv(
        "data/X_common_H.csv", index = False)

X_common_C()
X_common_H()