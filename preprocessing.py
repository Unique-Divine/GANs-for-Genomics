#!/usr/bin/python
__author__ = "Unique Divine"

# standard DS stack
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns; sns.set()
import pandas as pd
# embed static images in the ipynb
# %matplotlib inline 

# PyTorch
import torch
import torch.nn as nn 
import torch.nn.functional as F

from sklearn.linear_model import SGDClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.feature_selection import SelectKBest, chi2
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.model_selection import KFold
from sklearn.model_selection import cross_val_score
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
import warnings
warnings.filterwarnings('ignore')

# !pip install statsmodels
import statsmodels.api as sm
import os
import time
import csv
from IPython.display import clear_output

class Preprocessing:
    def __init__(self):
        self.X = None
        self.Y = None
        self.target_names = None
        self.data = None

    def get_Y(self, group=None):
        """ Retrives the target matrix from "targets.csv". 
        
        The mice were scored on a test and grouped into 3 categories, [GT, IR, ST]. 
        GT was the worst and ST was the best, so the groups are integer encoded
        in the following manner: [GT, IR, ST] -> [0, 1, 2].

        Args:
            group (str): 

        Returns:
            Y (np.ndarray): Phenotype values to be predicted by ML model. 
            names (np.ndarray): The names of the rats.
        """
        
        df = pd.read_csv("data/targets.csv")

        # Retrieve `sample_names` that were parsed from the vcf files.
        sample_names = {}
        batch_size = 10
        for batch_idx, batch in enumerate(pd.read_csv(
            "data/C/gt_C.csv", chunksize=batch_size)):
            sample_names['C'] = np.array(batch.columns[1:]).astype(int)
            break
        for batch_idx, batch in enumerate(pd.read_csv(
            "data/H/gts/gt_H (0).csv", chunksize=batch_size)):
            sample_names['H'] = np.array(batch.columns[1:]).astype(int)
            break

        def get_Y(target_file_ids, vcf_ids):
            assert len((a:=set(target_file_ids[:, 0]))
                        .intersection((b:=set(vcf_ids)))
                    ) == len(vcf_ids)
            # Remove uncommon elements
            for number in a.difference(b):
                target_file_ids[:, 0] = np.where(
                    (target_file_ids[:, 0] == number), 
                    None, 
                    target_file_ids[:, 0])    
            target_file_ids = pd.DataFrame(target_file_ids, columns=["RatID", "Phenotype"]).dropna()
            assert target_file_ids.shape[0] == len(vcf_ids)

            # Sort IDs
            target_file_ids = target_file_ids.set_index("RatID").sort_index()
            vcf_ids.sort()
            assert np.all(target_file_ids.index.values == vcf_ids.astype(int))
            target_file_ids = target_file_ids.astype(str)

            # Encode categories as integers
            for i, pt in enumerate(target_file_ids.Phenotype.values):
                if 'GT' in pt:
                    target_file_ids.Phenotype.iloc[i] = '0'
                if 'IR' in pt:
                    target_file_ids.Phenotype.iloc[i] = '1'
                if 'ST' in pt:
                    target_file_ids.Phenotype.iloc[i] = '2'

            assert len(target_file_ids.Phenotype.value_counts()) == 3
            # Return Y
            Y = target_file_ids.Phenotype.values.astype(int).reshape(-1, 1)
            names = np.array(list(target_file_ids.index))
            return Y, names

        # Check if targets.csv contains the IDs in the feature matrix
        target_file_ids = df.loc[(df["Vendor"] == "Charles River")][["RatID", "Phenotype"]].values
        vcf_ids = sample_names["C"]
        Y_C, names_C = get_Y(target_file_ids, vcf_ids) 
        if group == "C":
            return Y_C, names_C

        target_file_ids = df.loc[(df["Vendor"] == "Harlan")][["RatID", "Phenotype"]].values
        vcf_ids = sample_names["H"]
        Y_H, names_H = get_Y(target_file_ids, vcf_ids)
        if group == "H":
            return Y_H, names_H
        
        Y = np.concatenate([Y_C, Y_H])
        names = np.concatenate([names_C, names_H])
                
        return Y, names

    def get_x(self, group = "C"):
        """Generator for grabbing feature columns from X.

        Args:
            group (str, optional): Specifies dataset. Defaults to "C".
        Raises:
            ValueError: Group must be in ['C', 'H'].
        Yields:
            x (np.ndarray, 1D): A feature column.
        """

        if group in ["C", "H"]:
            pass
        else:
            raise ValueError(f"{group} is not a valid argument."
                            + "`group` must be in ['C', 'H']")

        Y = self.get_Y(group)[0]
        file_name = f"data/{group}/X_common_{group}.T.csv"
        with open(file_name) as f:
            reader = csv.reader(f)
            for line_idx, line in enumerate(reader):
                if line_idx >= 1:
                    x = np.array(line)[1:]
                    assert x.size == Y.size
                    
                    yield x    

    def calculate_fs_criterion(self, group="C", get_coefs=True) -> np.ndarray:
        """ Get the feature selection criterion, SVM classifier coefficients. 
        The absolue value of the these coefficients roughly correspond to
        feature importances because they are the weights given to each feature. 
        
        Args:
            group (str): Dataset selction. "C" or "H". Defaults to "C".
            get_coefs (bool, optional):  Defaults to True.

        Returns:
            coefs (np.ndarray, 1D): If `get_coefs == True`, the feature 
                selection coefficients are returned. Otherwise, they are just
                saved. 
        """

        if group in ["C", "H"]:
            if group == "C":
                Y = self.get_Y("C")[0].reshape(-1, 1)
            else:
                Y = self.get_Y("H")[0].reshape(-1, 1)
        else:
            raise ValueError(f"{group} is not a valid argument."
                            + "`group` must be in ['C', 'H']")
        
        save_path = os.path.join("data", group, f"coefs_{group}.csv")
        if os.path.exists(save_path):
            print(f"{save_path} already exists.")
            if get_coefs:
                return (coefs := pd.read_csv(save_path).values)

        coefs, ps = [], []
        scaler = StandardScaler()
        start_time = time.time()
        # For each feature column, fit a univariate model
        print("Calculating feature selection coefficients...")
        for i, feature_col in enumerate(self.get_x(group)):
            feature_col = feature_col.reshape(-1, 1)
            feature_col = scaler.fit_transform(feature_col, Y)
            if get_coefs:
                # Calculate classification coefficients and store in a list.
                model = SGDClassifier(loss='hinge') # SVM classifier
                model.fit(feature_col, Y)
                coefs.append(model.coef_[0,0])
            current_time = time.time() - start_time
            if i % 1000 == 0:
                print(f"Time (s): {current_time:.1f}\tIterations: {i}\t"
                    + f"Iterations/T: {i / current_time:.1f}")

            # else:
            #     # Calculate p-values from logit model
            #     sm_model = sm.Logit(Y, sm.add_constant(feature_col)).fit(disp=0)
            #     ps.append(sm_model.pvalues[1])
            # ps = np.array(ps)

        # Take the absolute value of the calculated coefs
        coefs = np.abs(np.array(coefs))
        # Save
        print("Saving coefficients...")
        pd.Series(coefs).to_csv(save_path, index=False)
        if get_coefs:
            return coefs            

    def varAnalysis(self, X, verbose=False):
        """ Retrieves summary statistics about the variance of the columns of X.

        Args:
            X (np.ndarray, 2D): Feature matrix.
            verbose (bool, optional): Toggles print statements on or off. 
                Defaults to False (off).
                
        Returns:
            V_avg (np.ndarray): Average variance of each column of X.
        """
        V = np.var(X, axis=0)
        V_avg, V_std = np.mean(V), np.std(V)
        V_max, V_min = np.max(V), np.min(V)
        
        if verbose:
            print(f"V_avg: {np.mean(V):.3f}")    
            print(f"V_std: {np.std(V):.3f}")
            print(f"V_max: {np.max(V):.3f}")
            print(f"V_min: {np.min(V):.3f}")
        
        return V_avg, V_std, V_max, V_min

    def plotV_info(self, V_info):
        """[summary]

        Args:
            V_info (dict[np.ndarray]): [description]
        """
        global fig, ax
        figscale, defaultSize = 2, np.array([8, 6])
        fig, ax = plt.subplots(nrows=2, ncols=2 ,figsize=figscale*defaultSize)
        plt.tight_layout()
        plt.subplots_adjust(wspace=0.1, hspace=0.4, left = 0.1, right = 0.7, bottom = 0.1, top = 0.9) 
        
        ax[0,0].hist(V_info["avg"])
        ax[0,0].set(xlabel="V_avg", ylabel="batches", title="Avg(Var)")
        
        ax[1,0].hist(V_info["std"])
        ax[1,0].set(xlabel="V_std", ylabel="batches", title="Std(Var)")

        ax[0,1].hist(V_info["max"])
        ax[0,1].set(xlabel="V_max", ylabel="batches", title="Max(Var)")

        ax[1,1].hist(V_info["min"])
        ax[1,1].set(xlabel="V_min", ylabel="batches", title="Min(Var)")
        plt.show()

    def main(self, plot_vars=False):
        """[summary]

        Args:
            plot_vars (bool, optional): [description]. Defaults to False.
        """
        # There are about 220,000 features, so we can loop <= 110 times.
        batch_size = 2000
        maxIteration = 112
        
        V_info = {}
        V_info["avg"] = np.empty(maxIteration + 1) 
        V_info["std"] = np.empty(maxIteration + 1) 
        V_info["max"] = np.empty(maxIteration + 1) 
        V_info["min"] = np.empty(maxIteration + 1) 
        
        global coefs_list
        coefs_list = []
        start_time = time.time()
        
        for batch_idx, batch in enumerate(
                pd.read_csv("gt_C.csv", chunksize=batch_size)):
            current_time = time.time() - start_time
            minutes = int(current_time / 60)
            seconds = current_time % 60
            print(f"Batch: {batch_idx}.\tTime: {minutes} min, {seconds:.2f} s."
                + f"\tSamples per second: {(batch_size * batch_idx) / current_time:.2f}")
            
            self.data = batch
            self.X = self.data.values[:, 1:].astype(float).T

            if batch_idx == 0:
                Y, rat_names = self.getTargets()
                self.Y = Y
                self.target_names = rat_names

            # Dynamically plot variance distributions
            if plot_vars:
                varAnalysisInfo = self.varAnalysis(X=X)
                V_info["avg"][batch_idx], V_info["std"][batch_idx] = varAnalysisInfo[:2]
                V_info["max"][batch_idx], V_info["min"][batch_idx] = varAnalysisInfo[2:]
                
                V_info_sofar = {} 
                for key in V_info:
                    V_info_sofar[key] = V_info[key][:batch_idx + 1]
                clear_output(wait=True)
                print(f"----------\nbatch: {batch_idx}")
                self.plotV_info(V_info_sofar)
            
            # Store feature selection coefficients
            coefs_list.append(self.getCriterion(self.X, self.Y))
            
            if batch_idx == maxIteration:
                break

    #------------------------------------------------------
    # post-main()


    def getX_r(self, k, coefs, X, indices=False):
        """ Retrieve the reduced feature matrix, X_r, which is X with a smaller 
        number of features. Features are selected based on the feature selection 
        coefficients. 

        Args:
            k (int or float): The number of SNPs (features).
            coefs (np.ndarray, 1D): Coefficients to determine feature selection.
            indices (bool, optional): Defaults to False.

        Returns:
            X_r (array-like): The reduced feature matrix.  
        """

        if isinstance(k, int):
            pass
        elif isinstance(k, float) and (np.abs(k) < 1):
            num_features = X.shape[1]
            k = int(k * num_features + 1)
             
        topk_coefs, topk_indices = [np.array(t) for t in torch.topk(torch.Tensor(coefs), k=k)]
        
        if X is not None:
            if isinstance(X, np.ndarray):
                X_r = X[:, topk_indices]
            elif isinstance(X, pd.DataFrame):
                X_r = X.iloc[:, topk_indices]
        else:
            raise NotImplementedError("TODO | Handle case when X is None.")
        
        if indices:
            return X_r, topk_indices
        else:
            return X_r

    def splitX(self, splits, time_it=True, return_type="array"):
        """
        Args:
            splits (int): The number of partitions the data will be split into. 
                Decides the batch size. 
        Returns:
            Xs (return_type)
            SNP_names_list (return_type)
            return_type (str): "np.ndarray" or "list".
        """
        assert return_type == ("array" or "list"), \
            "return_type must be an 'array' or 'list'."
        
        group = "C"
        coefs = pp.calculate_fs_criterion(group = group, get_coefs = True)
        Xs, SNP_names_list = [], []
        batch_size = int((coefs.size / splits) + 1)
        
        start_time = time.time()
        csv_path = os.path.join("data", group, f"X_common_{group}.T.csv")
        for batch_idx, batch in enumerate(
                pd.read_csv(csv_path, chunksize=batch_size)):
            data = batch
            coef_batch_idx_bounds = np.array([batch_idx, batch_idx + 1]) * batch_size  
            coef_batch = coefs[coef_batch_idx_bounds[0]: coef_batch_idx_bounds[1]]
            X = data.values[:, 1:].astype(float).T
            SNP_names = data.values[:, 0].astype(str)
            assert coef_batch.size == X.shape[1]

            return X, SNP_names
            X_r, indices_r = self.getX_r(k = 0.1, coefs = coef_batch, 
                                         X = X, indices = True)
            assert X_r.shape[1] == indices_r.size, \
                "The column count of X_r doesn't match the number of SNP_names."
            Xs.append(X_r)

            SNP_names = SNP_names[indices_r]
            SNP_names_list.append(SNP_names)
            
            if time_it and (batch_idx % 5 == 0):
                current_time = time.time() - start_time
                minutes = int(current_time / 60)
                seconds = current_time % 60
                print(f"Batch: {batch_idx}.\tTime: {minutes} min, {seconds:.2f} s."
                    + f"\tSNPs/second: {(batch_size * batch_idx) / current_time:.2f}")
        if return_type == "array":
            Xs = np.hstack(Xs)
            SNP_names = np.concatenate(SNP_names_list)
        elif return_type == "list": 
            SNP_names = SNP_names_list
        return Xs, SNP_names

if __name__ == "__main__":
    try:
        # main()
        pp = Preprocessing() 
        coefs_C = pp.calculate_fs_criterion(group = "C", get_coefs = True)
        o1, o2 = pp.splitX(20, True)
        # Xs, SNP_names = pp.splitX(splits=100)
        # print(len(coefs))
        
    except KeyboardInterrupt:
        print("stopped")
# saveCoefs(coefs_list)

