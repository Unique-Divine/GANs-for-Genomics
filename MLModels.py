from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier 

class ML:
    def __init__(self, X, Y, model_type) -> None:
        self.X = X
        self.Y = Y
        self.model = None
        self.model_type = model_type
        self.X_train, self.Y_train = None, None
        self.X_test, self.Y_test = None, None

    def printAvailableModels(self) -> None:
        print("model_name [shorthand]\n")
        models = {"Logistic regression": "logreg"
                  "XGBoost classifier": "xgb"
                  "Multilayer perceptron": "mlp"}

        for idx, model_name in enumerate(models):
            shorthand = models[model_name]
            print(f"{model_name} [{shorthand}]")
    
    def trainModel(self):
        if self.model_type == "xgb" or "logreg":
            self.model = models[model_type]
            self.model.fit(X_train, Y_train)

        elif self.model_type == "mlp":

        pass

    def makePrediction(self):
        
        models = {}
        # For sklearn-like ML models
        models["xgb"] = XGBClassifier()
        models["logreg"] = LogisticRegression()

        # Sklearn-like models
        if self.model_type == "xgb" or "logreg":
            self.model = models[self.model_type]
            self.model.fit(self.X_train, self.Y_train)
            Y_pred = self.model.predict(self.X_test)  

        # Neural Network models
        elif self.model_type == "mlp":
            # TODO PyTorch dataloader
            # TODO PyTorch training
            # TODO return Y_pred
            continue

        pass


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