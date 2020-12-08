#!/usr/bin/python
import numpy as np
from numpy.lib.ufunclike import _deprecate_out_named_y
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
import ml_models

X = np.empty([5, 2])
Y = np.empty([5, 2])

class NNConstants:
    def __init__(self, BATCH_SIZE, D_OUT, N_LAYERS, X=X):
        self.D_IN = X.shape[1]
        self._BATCH_SIZE = BATCH_SIZE
        self.D_OUT = D_OUT # number of output nodes (target categories).
        self.N_LAYERS = N_LAYERS
    
    @property
    def BATCH_SIZE(self) -> int:
        return self.BATCH_SIZE
    @BATCH_SIZE.setter
    def BATCH_SIZE(self, i: int):
        self.BATCH_SIZE = i
    @BATCH_SIZE.deleter
    def BATCH_SIZE(self):
        self.BATCH_SIZE = 100

class FeedForwardNN:

    def __init__(self, X: np.ndarray, Y: np.ndarray):
        ml = ml_models.ML(X, Y, model_type = "mlp")
        ttsplits = ml.getTrainTestSplits()
        self.X_train, self.Y_train, self.X_test, self.Y_test = ttsplits
        self.X, self.Y = ml.X, ml.Y
        self.n_features = self.X.shape[1]

    def getBATCH_SIZE(self):
        return self.BATCH_SIZE
    def getD_OUT(self):
        return self.D_OUT
    def getN_LAYERS(self):
        return self.N_LAYERS

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

    def setDataLoaders(self):
        self.train_set = self.TabularDataset(train=True)
        self.test_set = self.TabularDataset(train=False)
        self.train_dl = torch.utils.data.DataLoader(
            dataset=self.train_set, batch_size=self.BATCH_SIZE, shuffle=True)
        self.test_dl = torch.utils.data.DataLoader(
            dataset=self.test_set, batch_size=self.BATCH_SIZE, shuffle=True)

    class MLP(nn.Module): # inherits from nn.Module
        def __init__(self, c: NNConstants):
            super(FeedForwardNN.MLP, self).__init__()
            self.D_in = c.D_IN
            self.N_LAYERS = c.N_LAYERS
            self.D_out = c.D_OUT
            print(c.D_IN, c.N_LAYERS, c.D_OUT)
            D_h_in = int((self.N_LAYERS - 1) * (c.D_IN / self.N_LAYERS))
            D_h_out = int((self.N_LAYERS - 2) * (c.D_IN / self.N_LAYERS))
            
            # input layer
            self.fc_in = nn.Linear(self.D_in, D_h_in)
            # hidden layers
            self.h_layers = []
            for h_layer in range(self.N_LAYERS - 2):
                print(h_layer, D_h_in, D_h_out)
                D_h_in = int((self.N_LAYERS - h_layer - 1) * (c.D_IN / self.N_LAYERS))
                D_h_out = int((self.N_LAYERS - h_layer - 2) * (c.D_IN / self.N_LAYERS))
                self.h_layers.append(nn.Linear(D_h_in, D_h_out))
            # output layer
            self.fc_out = nn.Linear(D_h_out, self.D_out)
        
        def forward(self, x): # forward propagation
            x = F.relu(self.fc_in(x))
            for h_layer in range(self.N_LAYERS - 2):
                x = F.relu(self.h_layers[h_layer](x))
            x = F.leaky_relu(self.fc_out(x))
            return x

    # TODO: Training method

def main():
    z = torch.Tensor(np.random.randint(0, 25, size=[500, 10]).astype(float))
    print(z.shape)
    print(f"z: {z}")
    constants = NNConstants(BATCH_SIZE=100, D_OUT=3, N_LAYERS=3, X=z)
    network = FeedForwardNN.MLP(c = constants)
    print(f"network(z): {network(z)}")

if __name__ == "__main__":
    main()
