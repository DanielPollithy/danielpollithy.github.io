---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: A Decision Tree
categories:
  - python
  - numpy
  - scikit
  - machine-learning
---
## Decision Tree

I have got a small data set (my working hours as a working student) on which I want to train a binary classifier to tell working days from non-working days apart. My regular days in the office changed depending on the lectures I attended.

## Cleaning the data set

![Screenshot from 2018-03-09 22-16-32.png]({{site.baseurl}}/images/Screenshot from 2018-03-09 22-16-32.png)

The data set contains one row for every work day. The row contains every necessary information in German: 
"Donnerstag, 8. Juni (9:00 - 18:00) -> 8h (1h Mittag): Shop system"

So I wrote a function which extracts every weekday, day and year for a given time frame `get_dates_table(start_date, end_date)` and two functions that can generate the training data and the test data. The test data generates two years and the training data one year. The design matrix of each of them looks like this (where label is a boolean stating whether I went to work on that day):

<table align="center">
  <tr>
    <th>weekday</th>
    <th>day</th>
    <th>month</th>
    <th>label</th>
  </tr>
  <tr>
    <td>5</td>
    <td>1</td>
    <td>3</td>
    <td>0</td>
  </tr>
  <tr>
    <td>6</td>
    <td>2</td>
    <td>3</td>
    <td>1</td>
  </tr>
  <tr>
    <td>7</td>
    <td>3</td>
    <td>3</td>
    <td>1</td>
  </tr>
  <tr>
    <td>1</td>
    <td>4</td>
    <td>3</td>
    <td>1</td>
  </tr>
</table>



**Objective:** I don't expect the classifier to tell workday from normal weekday apart because the pattern changes over time but what I want is that we can differentiate between weekday and day of the weekend which should not be too hard.

## Let's take a look at the data set

### Histogram of the days I went to work

![Screenshot from 2018-03-26 13-44-46.png]({{site.baseurl}}/images/Screenshot from 2018-03-26 13-44-46.png)

This plot shows the amount of days I went to work by week day in the test data (one year). The enumeration starts with 1=Monday and ends with 7=Sunday.

## Decision tree

![ID3_algorithm_decision_tree.png]({{site.baseurl}}/images/ID3_algorithm_decision_tree.png)

By Acoggins38 (Own work) [CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0)], via Wikimedia Commons

A decision tree is the output of algorithms that find the most discriminating features and value borders in the data. The tree can then be used like a search tree with the difference that the leaf maps to which class the data belongs to.
(A good tutorial to write a CART like algorithm: [https://www.youtube.com/...](https://www.youtube.com/watch?v=LDRbO9a6XPU))

### Training

We use the DecisionTreeClassifier from sklearn and output a graph as a visualization.

```
from sklearn import tree

features, labels = get_training_data()
clf = tree.DecisionTreeClassifier()
clf = clf.fit(features, labels)

tree.export_graphviz(clf, feature_names=['weekday', 'day', 'month'])
```

The generated tree.dot file can be viewed in graphiz or [http://webgraphviz.com/](http://webgraphviz.com/).

The generated tree is so huge that I cannot view it as a image on one monitor:

![Screenshot from 2018-03-26 14-08-28.png]({{site.baseurl}}/images/Screenshot from 2018-03-26 14-08-28.png)

The tree makes me sceptic although the first node looks promising because it says that the most important feature is the weekday and whether it is less than friday or not.

### Testing

```
test_features, test_labels = get_test_data()
predictions = clf.predict(test_features)

ok = 0
max_ = len(test_labels)
for supervision, predition, test_feature in zip(test_labels, predictions, test_features):
    ok += 1 if supervision == predition else 0

print("OK={} WRONG={} => ERROR={}%".format(ok, max_ - ok, int((max_ - ok) * 100 / max_)))  
```

This code snippet prints **OK=110 WRONG=52 => ERROR=32%** to the console.

32% errors seems to be a lot. Let's figure out whether this is only drawing from random.

The following plot shows the inverse of the weekday plot, so it says on which days I did not go to work.

![Screenshot from 2018-03-26 14-25-20.png]({{site.baseurl}}/images/Screenshot from 2018-03-26 14-25-20.png)

Let's sum up the work days vs the non-work days:

<table align="center"><tr><th>workdays</th><th>non workdays</th><th>total</th></tr><tr><td>125</td><td>240</td><td>365</td></tr><tr><td>34%</td><td>66%</td><td>100%</td></tr></table>

**Result:** If our estimator made the assumption that every day is a "non workday" then it would be equally good as the DecisionTree.

### Training again

This time I am only going to use the weekday feature.

```
from sklearn import tree

features, labels = get_training_data()
# only use the first column
feature_weekday = np.asarray(features)[:, 0]

clf = tree.DecisionTreeClassifier()
clf = clf.fit(features, labels)

tree.export_graphviz(clf, feature_names=['weekday', 'day', 'month'])
```

![Screenshot from 2018-03-26 14-50-43.png]({{site.baseurl}}/images/Screenshot from 2018-03-26 14-50-43.png)

The tree shrinks with only one feature but the first node stays more or less the same.

### Testing again

This way the error can be reduced to 29% (**OK=115 WRONG=47 => ERROR=29%**)

If I only feed the weekends to the DecisionTree the error is reduced to **4%** because it predicts every day as a non-workday (error comes from two saturdays).

If I only feed the weekdays to the DecisionTree the result is **OK=71 WRONG=45 => ERROR=38%**.
The probability to draw a workday from the days monday to friday by random is 46%. I conclude therefore that the decision tree helps a little bit in this scenario although it's less than 10%.

But one can say that the weekends are identified good enough.

(Having spent some time with the data now I think modelling the data with a gamma distribution or using k-nearest-neighbours would result in better results.)









