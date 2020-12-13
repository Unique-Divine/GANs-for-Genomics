import numpy as np
from numpy import testing
import pandas as pd
import warnings
warnings.filterwarnings('ignore')
import time
import os
import get_common_indices

def get_common_Xs(group: str, data_path="data", timeit=True) -> None:
    if group in ["C", "H"]:
        pass
    else:
        raise ValueError(f"{group} is not a valid argument."
                        + "`group` must be in ['C', 'H']")
    
    save_idx = 0

    if group == "C":
        X_batch_size = 2000
        maxIteration = 130

        # Load common indices
        X_path = os.path.join(data_path, group, f"gt_{group}.csv")
        common_indices_path = os.path.join(
            data_path, group, f"common_indices_{group}.csv")
        if os.path.exists(common_indices_path) == False:
            get_common_indices.main()
        common_indices = np.array(pd.read_csv(common_indices_path)).flatten()
        
        start_time = time.time()
        for X_batch_idx, X_batch in enumerate(
            pd.read_csv(X_path, chunksize=X_batch_size)):
            X_batch = X_batch.values
            current_time = time.time() - start_time

            # Print execution speed            
            if (X_batch_idx % 1 == 0) and (timeit):
                print(f"Batch: {X_batch_idx}\t"
                    + f"Time: {current_time:.2f} s\t"
                    + "SNPs per second: {:.2f}".format(
                        (X_batch_size * X_batch_idx) / current_time))

            # Get common_X_batch := the common elements in X
            batch_indices = np.arange(
                start = X_batch_idx * X_batch_size,  
                stop = (X_batch_idx + 1) * X_batch_size )
            assert np.abs(batch_indices[4] - batch_indices[5]) == 1
            keepers = np.array([batch_idx for batch_idx in batch_indices \
                if (batch_idx in common_indices)])
            keepers = (keepers % 2000).astype(int)
            common_X_batch = X_batch[keepers]
            
            # Save common_X_batch
            if common_X_batch.size > 0: 
                dir_path = "data/C/common_Xs"
                if os.path.exists(dir_path) == False:
                    os.mkdir(dir_path)
                save_path = os.path.join(dir_path, f"{save_idx}.csv")
                pd.DataFrame(common_X_batch).to_csv(
                    save_path,
                    index = False)
                save_idx += 1

            if X_batch_idx >= maxIteration:
                break
    else: # group == "H"
        # Load common indices
        common_indices_path = os.path.join(
            data_path, group, f"common_indices_{group}.csv")
        if os.path.exists(common_indices_path) == False:
            get_common_indices.main()
        common_indices = np.array(pd.read_csv(common_indices_path)).flatten()
        
        start_time = time.time()
        for X_batch_idx in range(114):
            X_path = os.path.join(data_path, group,
                                  f"gtTypes_{group} ({X_batch_idx}).csv")
            X_batch = pd.read_csv(X_path, index_col=False).values
            
            # Print execution speed
            current_time = time.time() - start_time
            if (X_batch_idx % 5 == 0) and (timeit):
                print(f"Batch: {X_batch_idx}\t"
                    + f"Time: {current_time:.2f} s\t"
                    + "SNPs per second: {:.2f}".format(
                        (X_batch.shape[0] * X_batch_idx) / current_time))
            
            # Get common_X_batch := the common elements in X
            final_batch_idx = 1
            if X_batch_idx == 0:
                starting_batch_idx = 0
                final_batch_idx = X_batch.shape[0]
            else:
                starting_batch_idx = final_batch_idx
                final_batch_idx += X_batch.shape[0]
            batch_indices = np.arange(starting_batch_idx, final_batch_idx)                        
            assert np.abs(batch_indices[4] - batch_indices[5]) == 1
            keepers = np.array([batch_idx for batch_idx in batch_indices \
                if (batch_idx in common_indices)])
            keepers = (keepers % X_batch.shape[0]).astype(int)
            common_X_batch = X_batch[keepers]
            
            # Save common_X_batch
            if common_X_batch.size > 0:
                dir_path = "data/H/common_Xs"
                if os.path.exists(dir_path) == False:
                    os.mkdir(dir_path) 
                save_path = os.path.join(dir_path, f"{save_idx}.csv")
                pd.DataFrame(common_X_batch).to_csv(
                    save_path,
                    index = False)
                save_idx += 1

def combine_common_Xs(group, data_path="data"):
    """[summary]

    Args:
        group (str): Specifies dataset. "C" or "H". Defaults to "C".
        data_path (str, optional): Path to the data directory. 
            Defaults to "data".
    Raises:
        ValueError: Group must be in ['C', 'H'].
    """
    if group in ["C", "H"]:
        pass
    else:
        raise ValueError(f"{group} is not a valid argument."
                        + "`group` must be in ['C', 'H']")

    common_Xs = []
    if group == "C":
        for i in range(107):
            X_path = os.path.join(data_path, group, 'common_Xs', f"{i}.csv")
            common_X = pd.read_csv(X_path, index_col=False).values
            common_Xs.append(common_X)

            # Delete unnecessary csv files
            if os.path.exists(X_path):
                os.remove(X_path)

        file_path = "data/C/X_common_C.T.csv"
        print(f"Saving {file_path}...")
        X_common = np.vstack(common_Xs)
        pd.DataFrame(X_common).to_csv(
            file_path,
            index = False)

    else: # group == "H"
        for i in range(114):
            X_path = os.path.join(data_path, group, 'common_Xs', f"{i}.csv")
            common_X = pd.read_csv(X_path, index_col=False).values
            common_Xs.append(common_X)

            # Delete unnecessary csv files
            if os.path.exists(X_path):
                os.remove(X_path)

        file_path = "data/H/X_common_H.T.csv"
        print(f"Saving {file_path}...")
        X_common = np.vstack(common_Xs)
        pd.DataFrame(X_common).to_csv(
            file_path,
            index = False)

def main():
    get_common_Xs("C")
    get_common_Xs("H")
    combine_common_Xs("C")
    combine_common_Xs("H")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("operation halted.")
