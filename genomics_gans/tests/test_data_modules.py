
import os, sys
import numpy as np
import pandas as pd
import warnings; warnings.filterwarnings("ignore")
try: 
    import genomics_gans
except:
    exec(open('__init__.py').read())
    import genomics_gans
from genomics_gans.prepare_data import data_modules
# type imports
from torch.utils.data import Dataset, DataLoader

class TestDataModules:
    def test_X_subset_present(self):
        X: np.ndarray = pd.read_csv("X_subset.csv").values

    def test_Y_subset_present(self):
        Y: np.ndarray = pd.read_csv("Y_subset.csv").values
    
    def test_TabularDatset(self):
        X: np.ndarray = pd.read_csv("X_subset.csv").values
        Y: np.ndarray = pd.read_csv("Y_subset.csv").values
        dataset: Dataset = data_modules.TabularDataset(X=X, Y=Y)
        