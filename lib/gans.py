#!/usr/bin/python
__author__ = "Unique Divine"

from ctgan.synthesizer import CTGANSynthesizer
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import torch
import xgboost as xgb 
from typing import List, Tuple
import sdv # synthetic data vault

class TabularGANs:
    def __init__(self, X: np.ndarray, Y: np.ndarray, epochs: int = 200,
                 embedding_dim: int = 128, gen_dim: Tuple[int] = (256, 256),
                 dis_dim: Tuple[int] = (256, 256), l2scale: float = 1e-6,
                 batch_size: int = 500):
        self.X = X
        self.Y = Y
        self.train_data = np.hstack([X, Y])
        self.GANs = CTGANSynthesizer(
            embedding_dim = embedding_dim, gen_dim= gen_dim, dis_dim = dis_dim,
            l2scale = l2scale, batch_size = batch_size)
        self.epochs = epochs
        self.params = {'epochs': epochs, 'embedding_dim': embedding_dim, 
            'gen_dim': gen_dim, 'dis_dim': dis_dim, 'l2scale': l2scale, 
            'batch_size': batch_size 
            }
        
    # -------------------------------------------------------------------
    # GANs 
    # -------------------------------------------------------------------

    def train_GANs(self):
        self.GANs.fit(train_data = self.train_data, epochs = self.epochs)

    def create_synth_samples(self, n) -> np.ndarray:
        """
        Args:
            n (int): Number of samples wanted

        Returns:
            X_synth (np.ndarray): synth inputs
            Y_synth (np.ndarray): synth targets
        """
        synth_samples = self.GANs.sample(n=n, 
                                        condition_column=None, 
                                        condition_value=None)
        X_synth, Y_synth = synth_samples[:, :-1], synth_samples[:, -1]
        return X_synth, Y_synth

    # TODO: Implement demo method for comparison. 
    # def evaluate_demo_data(self):
    #     ctgan = CTGANSynthesizer(embedding_dim = 100)
    #     # demo_data = load_tabular_demo
    #     raise NotImplementedError("TODO")

    def evaluate_synth_data(self, synth_data, real_data, aggregate = True):
        evaluate = sdv.evaluation.evaluate
        eval = evaluate(
            synthetic_data = synth_data, real_data = real_data, 
            metrics = ['kstest', 'logistic_detection', 'svc_detection'],
            aggregate = aggregate)
        return eval
        
# def main():
#     pass

# if __name__ == "__main__":
#     main()


#  Functions to learn
# ------------------------
# zip()
# partition()
# split() | https://python-reference.readthedocs.io/en/latest/docs/str/split.html

# ds interview questions from the quiz
# https://www.interviewquery.com/blog-calibrating-the-data-science-quiz-results/

# Improving Python speed
# https://www.freecodecamp.org/news/if-you-have-slow-loops-in-python-you-can-fix-it-until-you-cant-3a39e03b6f35/


