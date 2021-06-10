import numpy as np
import torch
from torch import Tensor
from numpy import ndarray
from typing import Tuple, List, Dict, Union

import pytorch_lightning as pl
try:
    import genomics_gans
except:
    exec(open('__init__.py').read()) 
    import genomics_gans

class TabularDataset(torch.utils.data.Dataset): # inherit from torch
    def __init__(self, 
                 X: Union[ndarray, Tensor], 
                 Y: Union[ndarray, Tensor],
                 kind: str = "c"):
        self.X, self.Y = X, Y
        self.kind = kind
        self.check_for_valid_inputs()
        self.X, self.Y = self.convert_data_to_tensors()
        self.n_samples = X.shape[0]

    def __getitem__(self, idx) -> Tuple[Tensor, Tensor]:
        return self.X[idx], self.Y[idx]
    
    def __len__(self) -> int:
        return self.n_samples

    def check_for_valid_inputs(self):
        X, Y = self.X, self.Y
        assert X.ndim in [0, 1, 2], (
            f"The array dimension of X is too high. X.ndim: {X.ndim}")
        assert Y.ndim in [0, 1, 2], (
            f"The array dimension of Y is too high. Y.ndim: {Y.ndim}")
        assert X.shape[0] == Y.shape[0], (
            f"X and Y have different numbers of samples. Dim 0 should match.")
        assert isinstance(X, (ndarray, Tensor))
        assert isinstance(Y, (ndarray, Tensor))

        assert self.kind in ["c", "classification", "r", "regression"], (
            f"Attribute 'kind' must be 'c' or 'r' for classification"
            +" or regression.")
        if self.kind in ["c", "classification"]:
            self.kind = "c"
        else:
            self.kind = "r"
    
    def convert_data_to_tensors(self) -> Tuple[Tensor, Tensor]:
        X, Y = self.X, self.Y
        
        if isinstance(X, ndarray):
            self.X = torch.from_numpy(X).float()
        elif isinstance(X, Tensor):
            self.X = X.float()
        else:
            raise Exception("Impossible!")

        if isinstance(Y, ndarray):
            Y = Y.reshape(-1)
            if self.kind == "r":
                self.Y = torch.from_numpy(Y).float()
            else:
                self.Y = torch.from_numpy(Y).long()
        elif isinstance(Y, Tensor):
            Y = Y.view(-1)
            if self.kind == "r":
                self.Y = Y.float()
            else:
                self.Y = Y.long()
        else:
            raise Exception("Impossible!")
        
        assert isinstance(X, (ndarray, Tensor))
        return X, Y


class SpragueDawleyDM(pl.LightningDataModule):
    """Data preparation hooks"""
    def __init__(self, train_set: TabularDataset, val_set: TabularDataset, 
                 test_set: TabularDataset, batch_size: int = 50):
        super().__init__()
        self.batch_size = batch_size
        # TODO? More to this module

    def prepare_data(self):
        # TODO: Remove zombie code
        """
        Args:
            X : feature matrix
            Y : target matrix
        X, Y = self.X, self.Y
        global X_train, Y_train
        global X_val, Y_val
        global X_test, Y_test
        splits = np.array([84, 15, 1]) / 100
        train_size, val_size, test_size = splits
        # train-test split
        train_test_splits = model_selection.train_test_split(
            X, Y, test_size = test_size, random_state = 42)
        X_train, X_test, Y_train, Y_test = train_test_splits
        # train-val split
        relative_val_size = val_size / (train_size + val_size)
        train_val_splits = model_selection.train_test_split(
            X_train, Y_train, test_size = relative_val_size,
            random_state = 42)
        X_train, X_val, Y_train, Y_val = train_val_splits
        assert X_train.shape[0] + X_val.shape[0] + X_test.shape[0] == X.shape[0] 
        """
        pass 

    def setup(self, stage=None):
        if stage in ["fit", None]:
            self.train_set = train_set
            self.val_set = val_set
        if stage in ["test", None]:
            self.test_set = test_set

    def get_dataloader(self, stage: str) -> torch.utils.data.DataLoader:
        if stage == "train":
            dataset = self.train_set
        elif stage == "val":
            dataset = self.val_set
        elif stage == "test":
            dataset = self.test_set
        else:
            raise ValueError("'stage' must be 'train', 'val', or 'test'.")
        dl = torch.utils.data.DataLoader(
            dataset = dataset, batch_size = self.batch_size) 
        return dl 
        
    def train_dataloader(self) -> torch.utils.data.DataLoader:
        return self.get_dataloader("train")

    def val_dataloader(self) -> torch.utils.data.DataLoader:
        return self.get_dataloader("val")
    
    def test_dataloader(self) -> torch.utils.data.DataLoader:
        return self.get_dataloader("test")
