#!/usr/bin/python
__author__ = "Unique Divine"

from ctgan.synthesizer import CTGANSynthesizer
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import torch
from sklearn import model_selection
from sklearn import linear_model
import xgboost as xgb 

import neural_networks
import ctgan 

class ML:
    def __init__(self, X: np.ndarray, Y: np.ndarray, model_type=None) -> None:
        self.X = X
        self.Y = Y
        self.model_type = model_type
        self.model = None
        self.getTrainTestSplits()
        self.Y_pred = None
        self.GANs = None

    @property
    def X_train(self) -> np.ndarray:
        return self._X_train
    @X_train.setter
    def X_train(self, x):
        self._X_train = x
    @X_train.deleter
    def X_train(self):
        del self._X_train

    @property
    def Y_train(self) -> np.ndarray:
        return self._Y_train
    @Y_train.setter
    def Y_train(self, y):
        self._Y_train = y
    @Y_train.deleter
    def Y_train(self):
        del self._Y_train

    @property
    def X_test(self) -> np.ndarray:
        return self._X_test
    @X_test.setter
    def X_test(self, x):
        self._X_test = x
    @X_test.deleter
    def X_test(self):
        del self._X_test

    @property
    def Y_test(self) -> np.ndarray:
        return self._Y_test
    @Y_test.setter
    def Y_test(self, y):
        self._Y_test = y
    @X_test.deleter
    def X_test(self):
        del self._Y_test

    def printAvailableModels(self):
        print("model_name [shorthand]\n")
        models = {"SVM Classifier": "svc",
                  "XGBoost classifier": "xgb",
                  "Multilayer perceptron": "mlp"}
        for model_name in models:
            shorthand = models[model_name]
            print(f"{model_name} [{shorthand}]")

    def getTrainTestSplits(self, test_size=0.25, random_state=7) -> list:
        self._X_train, self._X_test, self._Y_train, self._Y_test = \
            model_selection.train_test_split(self.X, self.Y, 
                                             test_size=test_size, 
                                             random_state=random_state)
        return [self._X_train, self._X_test, self._Y_train, self._Y_test]
    
    # -------------------------------------------------------------------
    # GANs 
    # -------------------------------------------------------------------

    def trainGANs(self):
        train_data = np.hstack([self.X, self.Y]) 
        ctgan = CTGANSynthesizer()
        ctgan.fit(train_data=train_data, epochs=300)
        self.GANs = ctgan

    def getFakeSamples(self, n) -> np.ndarray:
        """
        Args:
            n (int): Number of samples wanted

        Returns:
            X_fake (np.ndarray): Fake inputs
            Y_fake (np.ndarray): Fake targets
        """
        fake_samples = self.GANs.sample(n=1000, 
                                        condition_column=None, 
                                        condition_value=None)
        X_fake, Y_fake = fake_samples[:, :-1], fake_samples[:, -1]
        return X_fake, Y_fake

    # -------------------------------------------------------------------
    # Predictive Modeling
    # -------------------------------------------------------------------

    def trainClassifier(self):
        shallow_models = {"xgb": xgb.XGBClassifier(), 
                          "svc": linear_model.SGDClassifier(),}

        # For sklearn-like ML models
        if self.model_type == "xgb" or "svc":
            self.model = shallow_models[self.model_type]
            self.model.fit(self.X_train, self.Y_train)
        elif self.model_type == "custom":
            self.model.fit(self.X_train, self.Y_train)

        elif self.model_type == "mlp":
            model_name = input("Desired name for the NN architecture: ")
            constants = neural_networks.NNConstants(
                BATCH_SIZE=100, D_OUT=3, X=self.X)
            ffnn = neural_networks.FFNN(self.X, self.Y, constants)
            network = ffnn.network
            ffnn.train(n_epochs = 5, plot=True)
            self.model = network

            # save model architecture
            model_path = f"temp/{model_name}.pt"
            torch.save(network, model_path)
            # save model weights
            w_path = f"temp/{model_name}_w.pt"
            torch.save(network.state_dict(), w_path)
            
    def makePrediction(self) -> np.ndarray:
        """[summary]

        Returns:
            Y_pred (np.ndarray): [description]
        """
        if self.model_type in ["xgb", "svc", "mlp"]:
            pass
        else:
            raise ValueError("Invalid model_type attribute.")
        # Sklearn-like models
        if self.model_type == "xgb" or "svc":
            Y_pred = self.model.predict(self.X_test)

        # Neural Network models
        else: # self.model_type == "mlp"
            X_test = torch.Tensor(self.X_test)
            Y_pred = np.array(self.model(X_test))

        return Y_pred

    def crossValidate(self):
        # TODO cross validate sklearn models
        # TODO cross validate NNs
        raise NotImplementedError


def main():
    pass

if __name__ == "__main__":
    main()


#  Functions to learn
# ------------------------
# zip()
# partition()
# split() | https://python-reference.readthedocs.io/en/latest/docs/str/split.html

# ds interview questions from the quiz
# https://www.interviewquery.com/blog-calibrating-the-data-science-quiz-results/

# Improving Python speed
# ------------------------
# https://www.freecodecamp.org/news/if-you-have-slow-loops-in-python-you-can-fix-it-until-you-cant-3a39e03b6f35/


