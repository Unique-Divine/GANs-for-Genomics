import pytest
import numpy as np 
import pandas as pd
import os
import sys
import get_common_indices

sys.path.append("..")
DATA_PATH = os.path.join("..", "data" )

class TestX_common:
    # TODO: Verify that common_indices_C.csv and common_indices_H.csv 
    # have the same number of elements before being combined. 

    def get_common_indices(data_path, group):
        # Load common indices
        common_indices_path = os.path.join(
            data_path, group, f"common_indices_{group}.csv")
        if os.path.exists(common_indices_path) == False:
            get_common_indices.main()
        common_indices = np.array(pd.read_csv(common_indices_path)).flatten()
        return common_indices

