---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: Sum-Product Network 2 - Learn Parameters
description: Given a valid SPN how can we train the parameters?
---
In the last post I wrote about inference, marginalization and such for SPNs. Now let us take a look at parameter learning for SPNs.

## Toy example

In order to motivate ourselves let's try to solve a motivating example:
We try to estimate the MNIST digits: classifying whether the pixels show a zero or not.

We preprocess the digits as follows to make the SPN small enough for visualization:

![SPN2.jpg]({{site.baseurl}}/images/SPN2.jpg)

And because we want to do parameter learning we assume that there is already the following Bayes Network given:

![SPN2-Page-3.jpg]({{site.baseurl}}/images/SPN2-Page-3.jpg)

Which can be converted into the following SPN:

![SPN2-Page-2.jpg]({{site.baseurl}}/images/SPN2-Page-2.jpg)

Where we assume the that the weights under the sum nodes are initialized with 0.5.

(The attentive reader might notice that the topology of the SPN makes the usage of SPNs a little bit obsolete. But for the sake of explanation I chose to do it like this.)

## Parameter Learning

There are generally two ways to learn the SPN parameters:

- generative learning: modelling P(x) for every y
- discriminative learning: P(y|x)

And there are two methods:

- Expectation Maximization (if we have variables which can't be observed)
- Gradient Descent

(Note: For deep SPNs there exists a solution to avoid the vanishing gradient called "hard gradient" which maximizes the likelihood of P'(x) instead of P(x). P'(x) is the approximation of the sum of P(x) by its largest term.)

### Gradient for discriminative learning

We want to maximize this term:
$$ \max  \nabla log P(y|x) $$

We apply the product rule:
$$ \max  \nabla log {P(y, x) \over P(x)}$$

Which is the same as:
$$\ max  \nabla log {P(y, x)} - \nabla log { P(x)}$$

P(y, x) is the probability that our network produces the correct output given the input.
And P(x) is the total output our network produces.

P(y, x) is just inference and P(x) can be calculated by marginalizing over y.

<!--$$\ max  \nabla log {\sum_h P(y, h, x)} - \nabla log { \sum_{y', h} P(y', h, x)}$$ where h are hidden variables.

In the context of SPNs hidden variables are the sum nodes. 
The first part we want to maximize is just the sum over all sum nodes which -->

### Illustration

Let's illustrate all necessary steps to do gradient descent on a SPN.

#### P(X,Y)

First we calculate P(x,y) by a single forward pass for the training example from the section about preprocessing:

![SPN2-Page-4.jpg]({{site.baseurl}}/images/SPN2-Page-4.jpg)

![SPN2-Page-4-2.jpg]({{site.baseurl}}/images/SPN2-Page-4-2.jpg)

![SPN2-Page-4-3.jpg]({{site.baseurl}}/images/SPN2-Page-4-3.jpg)

(Note that P(X,Y) = S(x_ind) / Z. Z=1 so we just skipped this.)

Okay, so the probability of our image and the label is 0,4%.

#### P(X)

Next step is to marginalize over Y to get P(X):

![SPN2-Page-6.jpg]({{site.baseurl}}/images/SPN2-Page-6.jpg)

#### Backprop

Because we want to maximize the difference between P(Y,X) and P(X) we can say that our error signal is P(Y,X) - P(X) = 0.002. To make this bigger we have to decrease P(X) and increase P(Y,X).
But what made P(X) so big? This is what backprop can tell us.

Therefore we are going to backprop the output of P(X) to all its variables:

![SPN2-backprop.jpg]({{site.baseurl}}/images/SPN2-backprop.jpg)

![SPN2-bp-2.jpg]({{site.baseurl}}/images/SPN2-bp-2.jpg)


Now we can calculate the 













