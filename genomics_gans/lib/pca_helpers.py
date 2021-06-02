import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn import decomposition
from numpy import linalg
from typing import Union, Iterable

def PCA_decomposition(X: np.ndarray, n: int = None):
    """Perform PCA decomposition on X.
    Args:
        X (np.ndarray): A tabular (2-D) data matrix consisting entirely 
            of numerical features.
        n (int, optional): Number of principal components to keep for the 
            decomposition. If None, the decomposition is done using the maximum
            possible number of components.
    Returns:
        (sklearn.decomposition.PCA): A PCA decomposition that has been fitted
            to data matrix X.
    """
    # Find the maximum valid number of principal components
    n_components: int = linalg.matrix_rank(X) 

    # Perform PCA decomposition on X
    if n is not None:
        if not isinstance(n, int):
            raise ValueError("n must be an integer.")
        elif n >= n_components:
            raise ValueError(f"'n' value of {n} is too high." 
                             + f"'n' can be at most {n_components}.")
    pca = decomposition.PCA(components = n_components)
    pca.fit(X)
    return pca

def PCA_req_components(pca_X: decomposition.PCA, 
                       threshold: Union[float, Iterable[float]] = 0.99,
                       plot=True, verbose=False) -> pd.DataFrame:
    """Compute the number of required components for different variance
    explained values. 
    
    Args:
        pca_X (decomposion.PCA): An instance of sklearn.decomposition.PCA 
            that has been fitted to data matrix X. 
        threshold (Union[float, Iterable[float]]): 
        plot (bool, optional): Toggles whether to display a visualization of 
            how the number of principal components varies with variance 
            explained.
    Returns:
        req_components (pd.DataFrame): A table containing the required number
            of components for the following threshold values 
            [0.9, 0.95, 0.97, 0.99, 0.999].
    """
    n_components: int
    n_features: int
    n_components, n_features = pca_X.components_
    explained_variance = np.cumsum(pca_X.explained_variance_ratio_)
    threshold_line = np.ones(n_components) * threshold
    p_component_idxs = np.arange(n_components) + 1

    if plot:
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.plot(p_component_idxs, explained_variance, 
                label='cumulative variance explained')
        ax.plot(p_component_idxs, threshold_line, '--', label='threshold')
        # ax.plot(p_components, pca.explained_variance_ratio_, 'o', 
        #         label='individual variance explained')
        ax.set(title = f"Variance Explained, n_features = {n_features}",
               xlabel = "Principal components", 
               ylabel = "Percentage of Variance Explained")
        ax.legend()
        plt.show()

    reduced_components: int = list(explained_variance >= threshold).index(True)

    # Thresholds, required components table
    thresholds = [0.9, 0.95, 0.97, 0.99, 0.999]
    idx = []
    for t in thresholds:
        idx.append(list(explained_variance >= t).index(True))
    thresholds, idx = [np.array(l) for l in [thresholds, idx]]
    req_components = pd.DataFrame(np.vstack([thresholds, idx]),
                                  index = ["threshold", "principal components"])
    return req_components

def PCA_reduction(X: np.ndarray, pca_X: decomposition.PCA) -> np.ndarray:
    """ Transforms a feature matrix with PCA feature reduction.
    Args:
        X (np.ndarray): Feature matrix
        pca_X (decomposition.PCA): An sklearn.decomposition.PCA instance that 
            has been fitted to X.
    Returns:
        X_new (np.ndarray): X with PCA feature reduction.
    """
    X_new = pca_X.fit_transform(X)
    return X_new