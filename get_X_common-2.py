#!/usr/bin/python
__author__ = "Unique Divine"
#%%
import time 
import numpy as np
import pandas as pd

#%%
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
    print("Saving X_common_C.T.csv...")
    X_common_C_T = np.hstack(X_common_C).T
    pd.DataFrame(X_common_C_T).to_csv(
        "data/X_common_C.T.csv", index = False)

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
    print("Saving X_common_H.T.csv...")
    X_common_H_T = np.hstack(X_common_H).T
    pd.DataFrame(X_common_H_T).to_csv(
        "data/X_common_H.T.csv", index = False)

# X_common_C()
# X_common_H()

#%%
import csv
import numpy as np
import pandas as pd
import get_target_matrix

Y_C, names_C = get_target_matrix.get_Y("C")
#%%
def get_x(group = "C"):
    """Generator for grabbing feature columns from X.

    Args:
        group (str, optional): Specifies dataset. Defaults to "C".
    Raises:
        ValueError: Group must be in ['C', 'H'].
    Yields:
        x (np.ndarray, 1D): A feature column.
    """
    if group in ["C", "H"]:
        pass
    else:
        raise ValueError(f"{group} is not a valid argument."
                        + "`group` must be in ['C', 'H']")

    Y = get_target_matrix.get_Y(group)[0]
    file_name = f"data/{group}/X_common_{group}.T.csv"
    with open(file_name) as f:
        reader = csv.reader(f)
        for line_idx, line in enumerate(reader):
            if line_idx >= 1:
                x = np.array(line)[1:]
                assert x.size == Y.size
                
                yield x    


# %%
