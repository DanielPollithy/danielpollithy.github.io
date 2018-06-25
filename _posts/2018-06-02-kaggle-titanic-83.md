---
layout: post
published: true
categories:
  - python
  - numpy
  - scikit
  - machine-learning
mathjax: false
featured: false
comments: false
title: Kaggle Titanic 83%
---
## How I achieved 83% accuracy in the Kaggle Titanic challenge

After trying different things (a custom linear model, different cvs, different random forests, randomized searches, pca) I found the GradientBoostingClassifier with {'max_depth': 4, 'n_estimators': 200} to perform the best with 0.8282 with StratifiedCV on the training data.
This model resulted in a public score of 0.78947 on Kaggle.

Another interesting result was 0.84 accuracy with a RandomForest with CV=10, {'max_features': 5, 'min_samples_leaf': 7, 'min_samples_split': 3, 'n_estimators': 41}). It led to the same public score of 0.78947.

I have been searching for better parameters for hours using GridSearch but it did not return anything better than what the initial randomized search returned.

The most work intensive part of this challenge was the preprocessing.
In the end I had the following pipeline running:

```
num_attribs = [u'Pclass', u'Age', u'SibSp', u'Parch', u'Fare', u'Name']
cat_attribs = [u'Sex', u'Embarked', u'Name']

class NumAttributesAdder(BaseEstimator, TransformerMixin):
    def __init__(self):  # no *args or **kargs
        pass

    def fit(self, X, y=None):
        return self  # nothing else to do

    def transform(self, X, y=None):
        X['FamilySize'] = X['SibSp'] + X['Parch'] + 1
        X['IsAlone'] = 1  # initialize to yes/1 is alone
        X['IsAlone'].loc[X['FamilySize'] > 1] = 0

        return X
        
        
class CatAttributesAdder(BaseEstimator, TransformerMixin):
    def __init__(self, stat_min=10):  # no *args or **kargs
        self.stat_min = stat_min

    def fit(self, X, y=None):
        return self  # nothing else to do

    def transform(self, X, y=None):
        # create new features
        X['Title'] = X['Name'].str.split(", ", expand=True)[1].str.split(".", expand=True)[0]
        title_names = (X['Title'].value_counts() < self.stat_min)
        X['Title'] = X['Title'].apply(lambda x: 'Misc' if title_names.loc[x] == True else x)

        X = X.drop(['Name'], axis=1)

        return X

num_pipeline = Pipeline([
    ('selector1', DataFrameSelector(num_attribs)),
    ('name_length', NameLengthAdder()),
    ('pandas_median_fill', PandasMedianFill()),
    ('num_attribs_adder', NumAttributesAdder()),
    ('std_scaler', StandardScaler()),
])

cat_pipeline = Pipeline([
    ('selector2', DataFrameSelector(cat_attribs)),
    ('pandas_mode_fill', PandasModeFill()),
    ('cat_attribs_adder', CatAttributesAdder()),
    ('cat_encoder', CategoricalEncoder(encoding="onehot-dense")),
])

full_pipeline = FeatureUnion(transformer_list=[
    ("num_pipeline", num_pipeline),
    ("cat_pipeline", cat_pipeline),
])
```


Loading the data and transforming it by tunneling it through the pipeline is easy:
```
# load the train and test data
data_train = pd.read_csv('../input/train.csv')
train = data_train.copy()
train_labels = data_train['Survived'].copy()
train = full_pipeline.fit_transform(data_train)
```


Searching for a RandomForestClassifier looked like this
```
from sklearn.model_selection import GridSearchCV

param_grid = [
    {'n_estimators': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30], 
     'max_features': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]},
    {'bootstrap': [False], 'n_estimators': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 
     'max_features': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]},
  ]

forest_reg = RandomForestClassifier(random_state=42)

grid_search = GridSearchCV(forest_reg, param_grid, cv=10,
                           scoring='accuracy', return_train_score=True)
grid_search.fit(train, train_labels)

cvres = grid_search.cv_results_
for mean_score, params in zip(cvres["mean_test_score"], cvres["params"]):
    print(mean_score, params)
    
winner = sorted(zip(cvres["mean_test_score"], cvres["params"], ), key=lambda x: x[0], reverse=True)[0]
```

Predict the test data with a model and write to a kaggle submission compatible csv

```
# use the forest on the test data
best_forest = rnd_search.best_estimator_

data_test = pd.read_csv('../input/test.csv')
test = full_pipeline.fit_transform(data_test.copy())

test_predictions = best_forest.predict(test)

data_test['Survived'] = test_predictions
data_test.to_csv('solution.csv', columns = ['PassengerId', 'Survived'], index=False)
```


