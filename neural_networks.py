#!/usr/bin/python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# neural network packages
import torch
import torch.nn as nn 
import torch.nn.functional as F
import torch.utils.data

import warnings
warnings.filterwarnings('ignore')
import time
import ml

BATCH_SIZE = 100

ml = ml.ML(X = np.empty([5, 2]), 
           Y = np.empty([5, 2]), 
           model_type = "mlp")
X, Y = ml.X, ml.Y
X_train, Y_train, X_test, Y_test = ml.setTrainTestSplits()

# TODO: data loading 

class TabularDataset(torch.utils.data.Dataset): # inherit from torch's Dataset class.
    def __init__(self, train: bool, X_train: np.ndarray, Y_train: np.ndarray, 
                 X_test: np.ndarray, Y_test: np.ndarray):
        # data loading
        if train == True:
            # training batch
            self.X = torch.from_numpy(X_train.astype(np.float32))
            self.Y = torch.from_numpy(Y_train.reshape(-1,1).astype(np.float32))
        else: 
            # testing batch
            self.X = torch.from_numpy(X_test.astype(np.float32))
            self.Y = torch.from_numpy(Y_test.reshape(-1,1).astype(np.float32))

        if self.X.shape[0] == self.Y.shape[0]:
            self.n_samples = self.X.shape[0]
        else:
            raise ValueError("Shape mismatch. X and Y should have the same" 
                             "number of rows")

    def __getitem__(self, idx):
        return self.X[idx], self.Y[idx]
    
    def __len__(self):
        return self.n_samples

# TODO: network architecture


# TODO: Training method

def main():

