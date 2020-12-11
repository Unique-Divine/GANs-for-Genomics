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
import torch.optim

import warnings
warnings.filterwarnings('ignore')
import time
import ml_models

class NNConstants:
    def __init__(self, BATCH_SIZE, D_OUT, X):
        self.D_IN = X.shape[1]
        self._BATCH_SIZE = BATCH_SIZE
        self._D_OUT = D_OUT # number of output nodes (target categories).

    @property
    def BATCH_SIZE(self) -> int:
        return self._BATCH_SIZE
    @BATCH_SIZE.setter
    def BATCH_SIZE(self, i: int):
        self._BATCH_SIZE = i
    @BATCH_SIZE.deleter
    def BATCH_SIZE(self):
        self._BATCH_SIZE = 100

    @property
    def D_OUT(self) -> int:
        return self._D_OUT
    @D_OUT.setter
    def D_OUT(self, i: int):
        self._D_OUT = i
    @D_OUT.deleter
    def D_OUT(self):
        self._D_OUT = 1

class FeedForwardNN:

    def __init__(self, X: np.ndarray, Y: np.ndarray, constants: NNConstants):
        """
        Args:
            X (np.ndarray): Feature matrix 
            Y (np.ndarray): Target matrix
            constants (NNConstants): Constants that speficy the NN architecture.
        """
        ml = ml_models.ML(X, Y, model_type = "mlp")
        ttsplits = ml.getTrainTestSplits()
        self.X_train, self.X_test, self.Y_train, self.Y_test = ttsplits
        self.X, self.Y = ml.X, ml.Y
        self.n_features = self.X.shape[1]
        self.constants = constants
        self.network = self.set_network()
        self.device = self.set_device()
        self.optimizer = self.set_optimizer()
        self.loss_fn = self.set_loss_fn()
        self.set_data_loaders()

    def getBATCH_SIZE(self):
        return self.BATCH_SIZE
    def getD_OUT(self):
        return self.D_OUT
    def getN_LAYERS(self):
        return self.N_LAYERS

    def get_tt_splits(self):
        return self.X_train, self.X_test, self.Y_train, self.Y_test

    def set_device(self):
        # If GPU is available
        if torch.cuda.is_available(): 
            device = torch.device("cuda") # device = GPU
        else:
            device = torch.device("cpu") # device = CPU
        return device
    
    def set_network(self):
        network = FeedForwardNN.MLP(self.constants)
        return network

    def set_optimizer(self):
        optimizer = torch.optim.Adam(self.network.parameters(), lr=0.01)
        return optimizer

    def set_loss_fn(self):
        loss_fn = nn.MSELoss()
        return loss_fn

    class TabularDataset(torch.utils.data.Dataset): # inherit from torch
        def __init__(self, train: bool, ffnn):
            X_train, X_test, Y_train, Y_test = ffnn.get_tt_splits() 

            # data loading
            if train == True:
                # training batch
                self.X = torch.from_numpy(X_train.astype(np.float32))
                self.Y = torch.from_numpy(
                    Y_train.reshape(-1,1).astype(np.float32))
            else: 
                # testing batch
                self.X = torch.from_numpy(X_test.astype(np.float32))
                self.Y = torch.from_numpy(
                    Y_test.reshape(-1,1).astype(np.float32))

            if self.X.shape[0] == self.Y.shape[0]:
                self.n_samples = self.X.shape[0]
            else:
                raise ValueError("Shape mismatch. X and Y should have the same" 
                                "number of rows")

        def __getitem__(self, idx):
            return self.X[idx], self.Y[idx]
        
        def __len__(self):
            return self.n_samples

    def set_data_loaders(self):
        self.train_set = self.TabularDataset(train=True, ffnn=self)
        self.test_set = self.TabularDataset(train=False, ffnn=self)
        self.train_dl = torch.utils.data.DataLoader(
            dataset=self.train_set, 
            batch_size=self.constants.BATCH_SIZE, 
            shuffle=True)
        self.test_dl = torch.utils.data.DataLoader(
            dataset=self.test_set, 
            batch_size=self.constants.BATCH_SIZE, 
            shuffle=True)

    class MLP(nn.Module): # inherits from nn.Module
        def __init__(self, c: NNConstants):
            super(FeedForwardNN.MLP, self).__init__()
            self.D_in = c.D_IN
            self.D_out = c.D_OUT

            D_h_in = int((2 / 3) * c.D_IN)
            D_h_out = int((1 / 3) * c.D_IN)

            # input layer
            self.fc_in = nn.Linear(self.D_in, D_h_in)
            # hidden layers
            self.fc_h0 = nn.Linear(D_h_in, D_h_out)
            # output layer
            self.fc_out = nn.Linear(D_h_out, self.D_out)
        
        def forward(self, x): # forward propagation
            x = F.leaky_relu(self.fc_in(x))
            x = F.leaky_relu(self.fc_h0(x))
            x = F.leaky_relu(self.fc_out(x))
            return x

    def train(self, n_epochs):
        train_loader = self.train_dl
        val_loader = self.test_dl
        device=self.device
        train_losses, val_losses = [], []

        for epoch in range(n_epochs):
            train_loss, val_loss = 0.0, 0.0
    
            # Training
            self.network.train()
            for idx, batch in enumerate(train_loader):
                self.optimizer.zero_grad() # clears paramter gradient buffers
                inputs, targets = batch
                # transfer batch data to computation device
                inputs, targets = [tensor.to(device) \
                    for tensor in [inputs, targets]]
                output = self.network(inputs)
                loss = self.loss_fn(output, targets)
                # back propagation
                loss.backward()
                self.optimizer.step() # update model weights
                train_loss += loss.data.item()
            train_losses.append(train_loss)
            if idx % 10 == 0:
                print(f"epoch {epoch+1}/{n_epochs}, batch {idx}.")
            
            # Validation 
            self.network.eval()        
            for batch in val_loader:
                inputs, targets = batch
                [inputs, targets] = [tensor.to(device) for tensor in batch]
                output = self.network(inputs)
                loss = self.loss_fn(output, targets)
                val_loss += loss.data.item()
            val_losses.append(val_loss)
        
            print(f"Epoch: {epoch}, Training Loss: {train_loss:.3f}, "
                 +f"Validation loss: {val_loss:.3f}")

        fig, ax = plt.subplots()
        fig.tight_layout()
        ax.plot(np.arange(n_epochs), train_losses, '-', label="training set")
        ax.plot(np.arange(n_epochs), val_losses, '-', label="test set")
        ax.set(xlabel="Epoch", ylabel="Loss")
        ax.legend()
        plt.show()

def main():
    # X = 
    # Y = 
    constants = NNConstants(BATCH_SIZE=100, D_OUT=3, X=X)
    ffnn = FeedForwardNN(X, Y, constants)
    ffnn.set_data_loaders()
    network = ffnn.network
    print(network)
    ffnn.train(n_epochs = 20)    
    print(f"network(z): {network(z)}")

if __name__ == "__main__":
    main()
