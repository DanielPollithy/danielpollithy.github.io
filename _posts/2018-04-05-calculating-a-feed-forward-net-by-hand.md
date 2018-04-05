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

Multiple perceptrons form layers and the layers form a neural network. Neural networks are general function approximation machines. That means that for every continuous function within a limited range a neural network can serve an approximation with an error less than some chosen epsilon.

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

There are a lot activation functions like sigmoid, tanh or linear. The default recommendation as of the deeplearningbook is ReLU (rectified linear unit). You can play around with neural networks and different activation functions at: [playground.tensorflow.org](playground.tensorflow.org).

![ReLU.png]({{site.baseurl}}/images/ReLU.png)

**Back to the question:** How can a combination of linear functions (ReLU is still linear from -inf to ]0 and ]0 to +inf) approximate a cubic functions?

Well it is definetely not the most precise way to do it but the network could learn a step function like such because the ReLU can "activate" and "deactivate" whether the output of a perceptron shall be used.

![cubic_steps.png]({{site.baseurl}}/images/cubic_steps.png)

## Learning XOR

Learning the XOR function was a prominent example of what could not be approximated by a linear model. 
The following link ([playground with linear activation](https://playground.tensorflow.org/#activation=relu&regularization=L2&batchSize=10&dataset=spiral&regDataset=reg-gauss&learningRate=0.03&regularizationRate=0.01&noise=0&networkShape=8,6,8,8,6,2&seed=0.45009&showTestData=false&discretize=false&percTrainData=50&x=true&y=true&xTimesY=true&xSquared=true&ySquared=true&cosX=false&sinX=true&cosY=false&sinY=true&collectStats=false&problem=classification&initZero=false&hideText=false)) brings you to the playground of tensorflow. It contains the XOR classification problem and I preset the linear activation function.

![Screenshot from 2018-04-05 15-11-59.png]({{site.baseurl}}/images/Screenshot from 2018-04-05 15-11-59.png)


It doesn't matter how many epochs you are going to wait our how many hidden layers you add the loss will always stay at around 0.5.

But if you swith the activation function to ReLU or anything else and add one hidden layer with four perceptrons you obtain a perfect example.

![Screenshot from 2018-04-05 15-18-08.png]({{site.baseurl}}/images/Screenshot from 2018-04-05 15-18-08.png)

### Calculation

The network is called feed forward because there is no backward loop as in recurrent neural networks. The perceptrons a. k. a. neurons are illustrated as single units but we are going to deal with them layerwise as vectors.

![xor_ffn.png]({{site.baseurl}}/images/xor_ffn.png)

The calculation of every layer i consists of:
- Our input x_i is a vector consisting of two binary values. For example: $$ x_0 = (0,0)^T $$
- The weight matrix W_i
- The vector of biases for every neuron b_i
- Estimated values ŷ which are calculated by ŷ_i = W_i x_i + b_i




























