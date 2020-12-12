#!/usr/bin/python
__author__ = "Unique Divine"

# import PyTorch
import torch

# standard DS stack
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns; sns.set()
import pandas as pd
# embed static images in the ipynb
# %matplotlib inline 

# neural network package
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
import time
from IPython.display import clear_output


class Preprocessing:
    def __init__(self):
        self.X = None
        self.Y = None
        self.target_names = None
        self.data = None


    def getTargets(self):
        """ Retrives the target matrix from "targets.csv". 
        
        The mice were scored on a test and grouped into 3 categories: GT, IR, and ST. 
        GT was the worst and ST was the best. These groups have been integer encoded.

        Returns:
            Y (np.ndarray): Phenotype values to be predicted by ML model. 
            names (np.ndarray): The names of the rats.
        """
        df = pd.read_csv("targets.csv")

        # Check if targets.csv contains the same IDs as the feature matrix
        targetRatIDs = df.loc[(df["Vendor"] == "Charles River")][["RatID", "Phenotype"]].values
        miceIDs = np.array(data.columns)[1:].astype(int)
        assert len((a:=set(targetRatIDs[:, 0])).intersection((b:=set(miceIDs)))) == 1780

        # Remove uncommon elements
        for number in a.difference(b):
            targetRatIDs[:, 0] = np.where((targetRatIDs[:, 0] == number), None, targetRatIDs[:, 0])    
        targetRatIDs = pd.DataFrame(targetRatIDs, columns=["RatID", "Phenotype"]).dropna()
        assert targetRatIDs.shape[0] == 1780

        targetRatIDs = targetRatIDs.set_index("RatID").sort_index()
        miceIDs.sort()
        assert np.all(targetRatIDs.index.values == miceIDs.astype(int))

        targetRatIDs = targetRatIDs.astype(str)
        targetRatIDs["Phenotype"].value_counts()

        for i, pt in enumerate(targetRatIDs.Phenotype.values):
            if 'GT' in pt:
                targetRatIDs.Phenotype.iloc[i] = '0'
            if 'IR' in pt:
                targetRatIDs.Phenotype.iloc[i] = '1'
            if 'ST' in pt:
                targetRatIDs.Phenotype.iloc[i] = '2'

        assert len(targetRatIDs.Phenotype.value_counts()) == 3
        
        Y = targetRatIDs.Phenotype.values.astype(int).reshape(-1, 1)
        names = np.array(list(targetRatIDs.index))

        assert X.shape[0] == Y.shape[0]

        return Y, names

    def getCriterion(self, X, Y, get_coefs=True, test_fn=False) -> np.ndarray:
        """ Get the feature selection criterion, SVM classifier coefficients. 
        
        Args:
            X (np.ndarray, 2D): feature matrix
            Y (np.ndarray, 2D): target matrix
            get_coefs (bool, optional):  Defaults to True.
            test_fn (bool, optional): Checks whether the function works correctly 
                using a randomly generated target matrix, Y_synth. 
                Defaults to False. 
        Returns:
            coefs (np.ndarray, 1D)
        """
        assert X.shape[0] == Y.shape[0], "X and Y have different numbers of samples"
        assert Y.shape[1] == 1, "Y needs to be a column vector"
        
        if test_fn:
            # simulated target matrix, Y
            rng = np.random.RandomState(7)
            Y_synth = rng.randint(0,3, X.shape[0]).reshape(-1,1)
            Y = Y_synth

        coefs, ps = [], []
        scaler = StandardScaler()
        
        # for each column of X
        for row in X.T:
            x = row.reshape(-1, 1)
            x = scaler.fit_transform(x, Y)
            if get_coefs:
                # Calculate classification coefficients
                model = SGDClassifier(loss='hinge') # SVM classifier
                model.fit(x, Y)
                # y_pred = model.predict(x)
                coefs.append(model.coef_[0,0])

            else:
                # Calculate p-values from logit model
                # sm_model = sm.Logit(Y, sm.add_constant(x)).fit(disp=0)
                sm_model = sm.MNLogit(Y, sm.add_constant(x)).fit(disp=0)
                ps.append(sm_model.pvalues[1])
        
        if get_coefs:
            return (coefs:= np.array(coefs))
        else:
            return (ps:= np.array(ps))

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
        csvBatchSize = 2000
        maxIteration = 112
        
        V_info = {}
        V_info["avg"] = np.empty(maxIteration + 1) 
        V_info["std"] = np.empty(maxIteration + 1) 
        V_info["max"] = np.empty(maxIteration + 1) 
        V_info["min"] = np.empty(maxIteration + 1) 
        
        global coefs_list
        coefs_list = []
        start_time = time.time()
        
        for csvBatch_idx, csvBatch in enumerate(pd.read_csv("gtTypes_C.csv", chunksize=csvBatchSize)):
            current_time = time.time() - start_time
            minutes = int(current_time / 60)
            seconds = current_time % 60
            print(f"Batch: {csvBatch_idx}.\tTime: {minutes} min, {seconds:.2f} s."
                + f"\tSamples per second: {(csvBatchSize * csvBatch_idx) / current_time:.2f}")
            
            self.data = csvBatch
            self.X = self.data.values[:, 1:].astype(float).T

            if csvBatch_idx == 0:
                Y, rat_names = self.getTargets()
                self.Y = Y
                self.target_names = rat_names

            # Dynamically plot variance distributions
            if plot_vars:
                varAnalysisInfo = self.varAnalysis(X=X)
                V_info["avg"][csvBatch_idx], V_info["std"][csvBatch_idx] = varAnalysisInfo[:2]
                V_info["max"][csvBatch_idx], V_info["min"][csvBatch_idx] = varAnalysisInfo[2:]
                
                V_info_sofar = {} 
                for key in V_info:
                    V_info_sofar[key] = V_info[key][:csvBatch_idx + 1]
                clear_output(wait=True)
                print(f"----------\ncsvBatch: {csvBatch_idx}")
                self.plotV_info(V_info_sofar)
            
            # Store feature selection coefficients
            coefs_list.append(self.getCriterion(self.X, self.Y))
            
            if csvBatch_idx == maxIteration:
                break

    #------------------------------------------------------
    # post-main()

    def saveCoefs(self, coefs_list):
        """ Saves the absolue value of the classification coefficients from 
        a linear SVM (feature importances). These are the weights given to each 
        feature. 
        
        Args:
            coefs (list[np.ndarray]): A list of the coefficients calculated
                during batch processing. The array elements batch-length
                1D arrays of coefficients. 
        Returns:
            coefficients (np.ndarray): The saved coefficients. 
        """
        try:
            coefs_exist = pd.read_csv("coefficients_C.csv")
        except:
            coefs_exist = None

        if coefs_exist is None:
            coefficients = np.abs(np.concatenate(coefs_list))
            pd.Series(coefficients).to_csv("coefficients_C.csv", index=False)
        else:
            print("Coefficients have already been saved.")
            
    def getCoefs(self, group="C", coefs_list=None, verbose=False) -> np.ndarray:
        """[summary]

        Args:
            group (str, optional): "C" for Charles River data, "H" for Harlan,
                "both" for both. Defaults to "C".
            coefs_list (list[np.ndarray], optional): A list of coefficients 
                outside of the default groups. Defaults to None.
            verbose (bool, optional): Toggles print statements. Defaults to False.

        Raises:
            Exception: [description]

        Returns:
            coefs (np.ndarray): 1D array of the feature selection coefficients.
        """
        if group == "C":
            file_name = "coefficients_C.csv"
        elif group == "H":
            file_name = "coefficients_H.csv"
        elif group == "both":
            file_name = "coefficients.csv"
        else:
            raise Exception("Invalid `group` parameter. `group` should be"
                            + "'C', 'H', or 'both'.")
            
        try:
            coefs = pd.read_csv(file_name, index_col=0)
            if verbose:
                print(coefs.shape)
                print("Coefficients loaded from file.")
            coefs = np.array(coefs).flatten()
        except:
            if isinstance(coefs_list, list):
                coefs = np.abs(np.concatenate(coefs_list))
            elif isinstance(coefs_list, np.ndarray):
                coefs = np.abs(coefs_list)
            if verbose:
                print("Coefficients loaded from global scope.")
            
        return coefs

    def getX_r(self, k, coefs, X, indices=False):
        """ Retrieve the reduced feature matrix, X_r, which is X with a smaller 
        number of features. Features are selected based on the feature selection 
        coefficients from `getCoefs()`. 

        Args:
            k (int): The number of SNPs (features).
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
        
        Xs, SNP_names_list = [], []
        csvBatchSize = int((self.getCoefs().size / splits) + 1)
        
        start_time = time.time()
        for csvBatch_idx, csvBatch in enumerate(
                pd.read_csv("gtTypes_C.csv", chunksize=csvBatchSize)):
            data = csvBatch
            coef_arr_idx_bounds = np.array([csvBatch_idx, csvBatch_idx + 1]) * csvBatchSize  
            coef_arr = self.getCoefs()[coef_arr_idx_bounds[0]: coef_arr_idx_bounds[1]]
            X = data.values[:, 1:].astype(float).T
            SNP_names = data.values[:, 0].astype(str)
            assert coef_arr.size == X.shape[1]
            X_r, indices_r = self.getX_r(k = 0.1, coefs = coef_arr, 
                                         X = X, indices = True)
            assert X_r.shape[1] == indices_r.size, \
                "The column count of X_r doesn't match the number of SNP_names."
            Xs.append(X_r)

            SNP_names = SNP_names[indices_r]
            SNP_names_list.append(SNP_names)
            
            if time_it and (csvBatch_idx % 5 == 0):
                current_time = time.time() - start_time
                minutes = int(current_time / 60)
                seconds = current_time % 60
                print(f"Batch: {csvBatch_idx}.\tTime: {minutes} min, {seconds:.2f} s."
                    + f"\tSNPs/second: {(csvBatchSize * csvBatch_idx) / current_time:.2f}")
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
        coefs = pp.getCoefs(group="C", coefs_list=None, verbose=True)
        Xs, SNP_names = pp.splitX(splits=100)
        print(len(coefs))
        
    except KeyboardInterrupt:
        print("stopped")
# saveCoefs(coefs_list)

