#!/usr/bin/python

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn import model_selection
from sklearn import linear_model
import xgboost as xgb 

class ML:
    def __init__(self, X: np.ndarray, Y: np.ndarray, model_type=None) -> None:
        self.X = X
        self.Y = Y
        self.model_type = model_type
        self.model = None
        self.setTrainTestSplits()
        self.Y_pred = None

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
        return [self._X_train, self._Y_train, self._X_test, self._Y_test]

    def trainClassifier(self):
        shallow_models = {"xgb": xgb.XGBClassifier(), 
                          "svc": linear_model.SGDClassifier(),}

        # For sklearn-like ML models
        if self.model_type == "xgb" or "svc":
            self.model = shallow_models[self.model_type]
            self.model.fit(self._X_train, self._Y_train)
        elif self.model_type == "custom":
            self.model.fit(self._X_train, self._Y_train)

        elif self.model_type == "mlp":
            model_name = input("")
            # TODO PyTorch dataloader
            # TODO PyTorch training

            # save model architecture

            # save model weights
            raise NotImplementedError
        
        pass

    def makePrediction(self) -> np.ndarray:
        """[summary]

        Returns:
            Y_pred (np.ndarray): [description]
        """

        # Sklearn-like models
        if self.model_type == "xgb" or "svc":
            Y_pred = self.model.predict(self._X_test)

        # Neural Network models
        elif self.model_type == "mlp":

            # TODO return Y_pred
            Y_pred = None
        else:
            raise Exception("Invalid model_type attribute.")

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


