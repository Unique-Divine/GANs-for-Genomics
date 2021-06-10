import pytorch_lightning as pl
import torch
import torch.nn as nn
import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict, Any, Union, Iterable
try:
    import genomics_gans
except:
    exec(open('__init__.py').read()) 
    import genomics_gans
from genomics_gans.prepare_data.data_modules import TabularDataset

class LitFFNN(pl.LightningModule):
    # ----------------------------------
    # Initialize constants and NN architecture
    # ----------------------------------
    def __init__(self, network: nn.Module, train_set: TabularDataset, 
                 val_set: TabularDataset, test_set: TabularDataset):
        """ Feed-Forward Neural Network System
        Args:
            X (np.ndarray): Feature matrix 
        """
        super().__init__()
        # TODO: train-val-test splits
        self.network = network

        # Hard-coded constants
        self.loss_fn = nn.NLLLoss()
        self.lr = 1e-2
        self.N_CLASSES = 3
        
        self.epoch = 0
        self.epoch_train_losses = []
        self.epoch_val_losses = []
        self.best_val_epoch = 0

    def forward(self, x): 
        logits = self.network(x)
        return logits

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(
            params = self.parameters(), lr = self.lr)
        return optimizer

    # ----------------------------------
    # Training, validation, and test steps
    # ----------------------------------

    def training_step(self, batch, batch_idx):
        x, y = batch
        y = y.flatten().long()
        logits = self(x) 
        loss = self.loss_fn(logits, y)
        self.log('train_loss', loss, on_step=True, on_epoch=True, 
                 prog_bar=True)
        return loss

    def validation_step(self, batch, batch_idx, val=True):
        x, y = batch
        y = y.flatten().long()
        # compute loss
        logits = self(x)
        loss = self.loss_fn(logits, y)
        self.log('val_loss', loss, on_step=True, on_epoch=True, 
                 prog_bar=True) # self.log interacts with TensorBoard
        return loss

    def test_step(self, batch, batch_idx):
        x, y = batch
        y = y.flatten().long()
        # compute loss
        logits = self(x)
        loss = self.loss_fn(logits, y)
        self.log('test_loss', loss, on_step=True, on_epoch=True, 
                 prog_bar=False)
        return loss

    def training_epoch_end(self, outputs: List[Any]):
        outputs: List[torch.Tensor] = [list(d.values())[0] for d in outputs]
        sum = torch.zeros(1, dtype=float).to(self.device)
        for batch_idx, batch_loss in enumerate(outputs):
            sum += batch_loss.to(self.device)
        avg_batch_loss = (sum / batch_idx)
        self.epoch_train_losses.append({avg_batch_loss[0].item()})

    def validation_epoch_end(self, outputs: List[Any]):
        sum = torch.zeros(1, dtype=float).to(self.device)
        for batch_idx, batch_loss in enumerate(outputs):
            sum += batch_loss.to(self.device)
        avg_batch_loss = (sum / batch_idx) 
        self.epoch_val_losses.append({avg_batch_loss[0].item()})        

    # ---------------------------------------------------------------
    # Custom training for evolutionary algorithm
    # --------------------------------------------------------------

    def custom_training_step(self, verbose=False):
        self.network.train()
        train_loader = self.train_dl
        train_loss: float = 0
        for idx, batch in enumerate(train_loader):
            self.optimizer.zero_grad() # clears paramter gradient buffers
            inputs, targets = batch
            # transfer batch data to computation device
            inputs, targets = [
                tensor.to(self.device) for tensor in [inputs, targets]]
            targets = targets.long() # converts dtype to Long
            output = self.network(inputs)
            loss = self.loss_fn(output, targets.flatten())
            loss.backward() # back propagation
            self.optimizer.step() # update model weights
            train_loss += loss.data.item()
            if (idx % 10 == 0) and verbose:
                print(f"epoch {self.epoch+1}/{self.n_epochs}, "
                    + f"batch {idx}.")
        train_loss = train_loss / len(train_loader)
        return train_loss
    
    def custom_validation_step(self):
        val_loader = self.test_dl
        val_loss = 0.0
        self.network.eval()        
        for batch in val_loader:
            inputs, targets = batch
            inputs, targets = [tensor.to(self.device) for tensor in batch]
            targets = targets.long() # converts dtype to Long
            output = self.network(inputs)
            loss = self.loss_fn(output, targets.flatten())
            val_loss += loss.data.item()
        val_loss = val_loss / len(val_loader)
        return val_loss  
    
    def custom_train(self, n_epochs, plot=True, verbose=False, plot_train=False):
        train_loader = self.train_dl
        val_loader = self.test_dl
        device=self.device
        self.network.to(self.device)

        train_losses, val_losses = [], []
        best_val_loss = np.infty
        best_val_epoch = 0
        early_stopping_buffer = 10
        epoch = 0
        best_params = None

        for epoch in range(n_epochs):
            # Training
            train_loss = self.custom_training_step()
            train_losses.append(train_loss)
  
            # Validation 
            val_loss = self.custom_validation_step()
            val_losses.append(val_loss)

            if val_loss < best_val_loss:
                best_params = self.network.parameters()
                best_val_loss = val_loss
                best_val_epoch = epoch
            
            # If validation loss fails to decrease for some number of epochs
            # end training
            if np.abs(epoch - best_val_epoch) > early_stopping_buffer:
                break
        
            print(f"Epoch: {epoch}, Training Loss: {train_loss:.3f}, "
                 +f"Validation loss: {val_loss:.3f}")
        
        #self.network.parameters = best_params
        self.best_val_loss = best_val_loss
        self.best_val_epoch = best_val_epoch
        if plot:
            skip_frames = 3
            fig, ax = plt.subplots()
            fig.tight_layout()
            if plot_train:
                ax.plot(np.arange(epoch + 1)[skip_frames:], 
                    train_losses[skip_frames:], '-', label="training set")
            ax.plot(np.arange(epoch + 1)[skip_frames:], 
                    val_losses[skip_frames:], '-', label="test set")
            ax.set(xlabel="Epoch", ylabel="Loss")
            ax.legend()
            plt.show() 
    
    # ----------------------------------
    # Helper functions - Use post-training
    # ----------------------------------
    
    def predict(self, x: torch.Tensor) -> torch.Tensor:
        self.eval()
        x.to(self.device)
        logits = self.network(x)
        preds = torch.argmax(input = logits, dim=1)
        return preds

    def accuracy(self, pred: torch.Tensor, target: torch.Tensor):
        self.eval()
        if isinstance(pred, torch.Tensor) and isinstance(target, torch.Tensor):
            pred, target = [t.to(self.device) for t in [pred, target]]
        elif isinstance(pred, np.ndarray) and isinstance(target, np.ndarray):
            tensors = [torch.Tensor(t).to(self.device) for t in [pred, target]]
            pred, target = tensors
        else:
            raise ValueError("The types of `pred` and `target` must match. "
                + "These can be np.ndarrays or torch.Tensors.")

        accuracy = pl.metrics.functional.accuracy(pred, target)
        return accuracy

    def f1(self, pred: torch.Tensor, target: torch.Tensor):
        self.eval()
        pred, target = [t.flatten() for t in [pred, target]]
        if isinstance(pred, torch.Tensor) and isinstance(target, torch.Tensor):
            pred, target = [t.to(self.device) for t in [pred, target]]
        elif isinstance(pred, np.ndarray) and isinstance(target, np.ndarray):
            tensors = [torch.Tensor(t).to(self.device) for t in [pred, target]]
            pred, target = tensors
        else:
            raise ValueError("The types of `pred` and `target` must match. "
                + "These can be np.ndarrays or torch.Tensors.")
        f1 = pl.metrics.functional.f1(
            preds = pred, target = target, num_classes = 3, multilabel = True)
        return f1
        
    def multiclass_aucroc(self, pred: torch.Tensor, target: torch.Tensor):
        self.eval()
        if isinstance(pred, torch.Tensor) and isinstance(target, torch.Tensor):
            pred, target = [t.to(self.device) for t in [pred, target]]
        elif isinstance(pred, np.ndarray) and isinstance(target, np.ndarray):
            tensors = [torch.Tensor(t).to(self.device) for t in [pred, target]]
            pred, target = tensors
        else:
            raise ValueError("The types of `pred` and `target` must match. "
                + "These can be np.ndarrays or torch.Tensors.")
        auc_roc = pl.metrics.functional.classification.multiclass_auroc(
            pred = pred, target = target)
        return auc_roc

    def plot_losses(self, plot_train=True):
        skip_frames = 1
        fig, ax = plt.subplots()
        fig.tight_layout()

        n_epochs = len(self.epoch_val_losses)
        self.epoch_train_losses = [s.pop() for s in self.epoch_train_losses]
        self.epoch_val_losses = [s.pop() for s in self.epoch_val_losses]
        if plot_train:
            n_epochs = len(self.epoch_train_losses)
            ax.plot(np.arange(n_epochs)[skip_frames:], 
                    self.epoch_train_losses[skip_frames:], label="train")
        ax.plot(np.arange(n_epochs)[skip_frames:], 
                self.epoch_val_losses[1:][skip_frames:], label="val")
        ax.set(xlabel="Epoch", ylabel="Loss")
        ax.legend()
        plt.show()
