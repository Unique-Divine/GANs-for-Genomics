import numpy as np
import torch.nn as nn
import torch.nn.functional as F
from torch import Tensor
from numpy import ndarray
try:
    import genomics_gans
except:
    exec(open('__init__.py').read()) 
    import genomics_gans

class FFNN(nn.Module):
    def __init__(self, X: ndarray, in_dropout=0.1, hidden_dropout=0.1):
        super().__init__()
        self.n_features = X.shape[1]
        self.N_CLASSES = 3

        # ----------------------       Architecture       ----------------------
        self.D_IN = self.n_features
        hidden_dim = int(np.sqrt(self.D_IN * self.N_CLASSES))
        D_h_in = hidden_dim
        D_h_out = hidden_dim

        self.fc_layers = nn.Sequential(
            nn.Linear(self.D_IN, D_h_in),
                nn.LeakyReLU(),
                nn.Dropout(p = in_dropout),
            nn.Linear(D_h_in, D_h_out),
                nn.LeakyReLU(),
                nn.Dropout(p = hidden_dropout),
            nn.Linear(D_h_out, self.N_CLASSES))

    def forward(self, x: Tensor): 
        x = self.fc_layers(x)
        logits = F.log_softmax(input = x, dim = 1)
        return logits