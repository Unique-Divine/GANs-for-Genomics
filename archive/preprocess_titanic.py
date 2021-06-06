import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Load in Titanic dataset
titanic_data = sns.load_dataset('titanic')

# For a list of seaborn datasets, use
# sns.get_dataset_names()


def one_hot_encode(X, cat_features):
    """Converts an unstructued 2-D array consisting of categorical values
    into a 2-D array consisting of one-hot-encoded vectors.

    Args:
        X (pd.DataFrame): 
        cat_features (list): categorical feature names
    
    Returns:
        hot_X (pd.DataFrame): one-hot encoded matrix
    """ 
    
    X_cat = X[cat_features]
    for cat in cat_features[:]:
        X = X.drop(cat, axis=1)

    # Replace the nonnumerical columns with one-hot encoded ones.
    for name in cat_features[:]:
        hot_one = pd.get_dummies(X_cat[name], prefix=name)
        X = pd.concat([X, hot_one.set_index(X.index)], axis=1)
    return X

def preprocess_titanic(df=titanic_data):
    """Helper function to prepare the Titanic dataset for usability as
    a neural network data matrix. 

    Args:
        df (pd.DataFrame, optional): Titanic dataset. 

    Returns:
        X, Y (np.ndarray, np.ndarray): feature matrix, target matrix
    """
    df['sex'] = (df['sex'].values.astype(str) == 'male').astype(int)
    df['alone'] = df['alone'].values.astype(int)
    df.drop(['deck', 'alive'], axis=1,  inplace=True)
    df = one_hot_encode(df, 
        ['who', 'embark_town', 'embarked', 'adult_male', 'class'])
    df.dropna(inplace=True)
    df = df.astype(float)
    
    # Get column names
    col_names = list(df.columns)

    # Get feature and target matrix
    A = df.values
    X, Y = A[:, 1:], A[:, 0].reshape(-1,1) 
    
    return X, Y, col_names