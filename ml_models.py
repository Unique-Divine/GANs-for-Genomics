import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import SGDClassifier
from xgboost import XGBClassifier 

class ML:
    def __init__(self, X, Y, model_type) -> None:
        self.X = X
        self.Y = Y
        self.model = None
        self.model_type = model_type
        self.X_train, self.Y_train = None, None
        self.X_test, self.Y_test = None, None
        self.Y_pred = None

    def printAvailableModels(self):
        print("model_name [shorthand]\n")
        models = {"SVM Classifier": "svc",
                  "XGBoost classifier": "xgb",
                  "Multilayer perceptron": "mlp"}
    
        for model_name in models:
            shorthand = models[model_name]
            print(f"{model_name} [{shorthand}]")
    
    def setTrainTestSplits(self, test_size=0.3, random_state=7):
        self.X_train, self.X_test, self.Y_train, self.Y_test = train_test_split(
            self.X, self.Y, test_size=test_size, random_state=random_state)

    def trainClassifier(self):
        shallow_models = {"xgb": XGBClassifier(), 
                          "svc": SGDClassifier(),}

        # For sklearn-like ML models
        if self.model_type == "xgb" or "svc":
            self.model = shallow_models[self.model_type]
            self.model.fit(self.X_train, self.Y_train)
        elif self.model_type == "custom":
            self.model.fit(self.X_train, self.Y_train)

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
            Y_pred = self.model.predict(self.X_test)

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


