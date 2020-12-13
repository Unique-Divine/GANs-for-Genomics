import numpy as np
from numpy import testing
import pandas as pd
import warnings
warnings.filterwarnings('ignore')
import time
import os


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
        X_path = os.path.join(data_path, group, f"gt_{group}.csv")
        common_indices_path = os.path.join(
            data_path, group, f"common_indices_{group}.csv")
        common_indices = np.array(pd.read_csv(common_indices_path)).flatten()
        
        start_time = time.time()
        for X_batch_idx, X_batch in enumerate(
            pd.read_csv(X_path, chunksize=X_batch_size)):
            X_batch = X_batch.values
            current_time = time.time() - start_time
            
            if (X_batch_idx % 1 == 0) and (timeit):
                print(f"Batch: {X_batch_idx}\t"
                    + f"Time: {current_time:.2f} s\t"
                    + "SNPs per second: {:.2f}".format(
                        (X_batch_size * X_batch_idx) / current_time))
            batch_indices = np.arange(
                start = X_batch_idx * X_batch_size,  
                stop = (X_batch_idx + 1) * X_batch_size )
            assert np.abs(batch_indices[4] - batch_indices[5]) == 1
            keepers = np.array([batch_idx for batch_idx in batch_indices \
                if (batch_idx in common_indices)])
            keepers = (keepers % 2000).astype(int)
            common_X_batch = X_batch[keepers]
            
            if common_X_batch.size > 0: 
                save_path = f"data/C/Xrs/{save_idx}.csv"
                pd.DataFrame(common_X_batch).to_csv(
                    save_path,
                    index = False, 
                    header = False)
                save_idx += 1

            if X_batch_idx >= maxIteration:
                break
    else: # group == "H"
        common_indices_path = os.path.join(
            data_path, group, f"common_indices_{group}.csv")
        common_indices = np.array(pd.read_csv(common_indices_path)).flatten()
        
        start_time = time.time()
        for X_batch_idx in range(114):
            
            X_path = os.path.join(
                data_path, group, f"gtTypes_{group} ({X_batch_idx}).csv")
            X_batch = pd.read_csv(X_path, index_col=False).values
            
            current_time = time.time() - start_time
            if (X_batch_idx % 5 == 0) and (timeit):
                print(f"Batch: {X_batch_idx}\t"
                    + f"Time: {current_time:.2f} s\t"
                    + "SNPs per second: {:.2f}".format(
                        (X_batch.shape[0] * X_batch_idx) / current_time))
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
            
            if common_X_batch.size > 0: 
                save_path = f"data/H/Xrs/{save_idx}.csv"
                pd.DataFrame(common_X_batch).to_csv(
                    save_path,
                    index = False, 
                    header = False)
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

        X_common = np.vstack(common_Xs)
        pd.DataFrame(X_common).to_csv(
            "data/C/X_common_C.T.csv",
            index = False, 
            header = False)

    else: # group == "H"
        for i in range(114):
            X_path = os.path.join(data_path, group, 'common_Xs', f"{i}.csv")
            common_X = pd.read_csv(X_path, index_col=False).values
            common_Xs.append(common_X)

            # Delete unnecessary csv files
            if os.path.exists(X_path):
                os.remove(X_path)

        X_common = np.vstack(common_Xs)
        pd.DataFrame(X_common).to_csv(
            "data/H/X_common_H.T.csv",
            index = False, 
            header = False)

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
