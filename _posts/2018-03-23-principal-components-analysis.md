---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: Principal components analysis
description: ''
headline: ''
modified: ''
tags: ''
imagefeature: ''
---
## Principal components analysis with numpy

The first section of the deeplearningbook aims to refresh basic knowledge about linear algebra.
Only the most imortant concepts to understand machine learning were covered. New for me (or I just did not remember from university were):

 - **Frobenius norm:** We use norms to measure the size of a vector (like L¹ or L²) and with the Frobenius norm one can measure the size of a matrix.
 - **Singular value decomposition:** This decomposition has the same goal as the **eigenvalue decomposition** but it works on every real matrix and does not have that many prerequisites.
 - **Moore-Penrose pseudoinverse:** To solve linear equations (Ax=y) one can calculate the inverse of A to solve for x. But if A is not a square matrix for example, then you can use the Moore-Penrose pseudoinverse to obtain a solution with minimal L² distance.

The section ends with five pages about the example of **principal components analysis (PCA)**. In order to check whether I am ready to continue with the next parts of the book I will try to write my own little principal components analysis on a toy data set.

## Intuition about PCA
![peerson_1901.png]({{site.baseurl}}/images/peerson_1901.png)

Pearson, 1901: http://stat.smmu.edu.cn/history/pearson1901.pdf

Imagine you have got a set of high dimensional vectors and you want to visualize them in a 3d plot that is helpful to discrimate your data points. With PCA you first find new "axes" for your data which show a lot of variation. They are not related to the metrics on your axes anymore because they form combinations. We call these new "axes" components.

As you can see in the figure from Pearson's first introduction of the idea in 1901, the points had an x- and y-axis. The first new component is a good line fit through the points which is reduced by the euclidean distance (L²).

The next component can be found by minimizing the L² distance of a line which is perpendicular to the first line and so on.

Order the received components by the variation they introduce, only take the first n of them and you get the principal components n. For the problem with the 3d plot we make n=3.

The last step would be to obtain a rotation that converts all data points from the original coordinate system to the new coordinate system spanned by the three principal components.

An interactive illustration can be found here: [http://setosa.io/ev/principal-component-analysis/](http://setosa.io/ev/principal-component-analysis/)

## 








