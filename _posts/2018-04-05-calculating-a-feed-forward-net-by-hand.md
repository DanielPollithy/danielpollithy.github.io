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

Multiple perceptrons forms layers and the layers form a neural network. Neural networks are general function approximation machines. That means that for every continuous function within a limited range a neural network can serve an approximation with an error less than some chosen epsilon.

Let's look at an example with only one perceptron to understand why we want to use them in layers.

Imagine you wanted to approximate 
$$
f(x) = 2x + 1
$$

It is easy to see that the following perceptron acts like a linear equation and can be extended to represent the general form of a linear equation system $$ Ax + b = y $$ by adding more inputs and weights.

![Perceptron2.png]({{site.baseurl}}/images/Perceptron2.png)

### But what about non-linear functions

Like $$ f(x) = x^2 $$?

One could propose a network like this:
![ANN2.png]({{site.baseurl}}/images/ANN2.png)
Or even more complex ones but chaining multiple perceptrons together will just mimic another linear equation system as long as the activation function is not involved ($$y = x$$).

The first choice for the activation function would be the cubic function itself. But I think approximating a function by using itself is not a valid solution.

### Activation functions

There are a lot activation functions 
















