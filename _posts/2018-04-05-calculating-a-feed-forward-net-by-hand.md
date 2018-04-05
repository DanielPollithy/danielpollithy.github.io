---
layout: post
published: true
categories:
  - personal
mathjax: true
featured: false
comments: false
title: Calculating a feed forward net by hand
---
## Calculating a feed forward network by hand

In computer science the building blocks of everything are ones and zeros. This simplicity is not an obstacle for building complex systems.

For **Artifical Neural Networks** the simple building blocks are the **perceptrons**.

![Perceptron.png]({{site.baseurl}}/images/Perceptron.png)

They work by weighting their inputs (`w_0, w_1`), summing them up (Σ) and applying an activation function to the output.

Multiple perceptrons forms layers and the layers form a neural network. Neural networks are general function approximation machines.

Let's look at an example with only one perceptron to understand why we want to use them in layers.

Imagine you wanted to approximate `f(x) = 2x`







