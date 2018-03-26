---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: Support Vector Machine
---
## Using a support vector machine to classify workdays

I use the same data set as in my last [post](http://blog.pollithy.com/python/numpy/scikit/svm-compared-to-decision-tree) which is a list of days (weekday, day of the month, month) from the last years labeled with 1 or 0 depending on whether I went to work on that particular day or not.

## Support Vector Machine

![Svm_max_sep_hyperplane_with_margin.png]({{site.baseurl}}/images/Svm_max_sep_hyperplane_with_margin.png)

If you want to classify the data points in this image you can draw a line which defines a border. All the points on one side belong to one class and vice versa. In above image only the "important" points have a thick border. They are called the **support vectors**.

The intuition behind the support vector machine is to fit the line (decision boundary) with the greatest distance to all support vectors.

## The data

![Screenshot from 2018-03-26 16-23-03.png]({{site.baseurl}}/images/Screenshot from 2018-03-26 16-23-03.png)

This plot show the weekdays on the x-axis in relation to the work days (red) and non-work days (blue). It is already visible that the two classes cannot be differentiated well on weekdays.

## Training

We use svm from scikit-learn.

```
from sklearn import svm



