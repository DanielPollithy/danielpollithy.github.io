---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: LogSumExp
categories:
  - general
description: A short note on the difference between softargmax and softmax
---
This is a short note to show the difference between softmax and softargmax.

It is common to use a "Softmax" layer as an activation function for a neural network used for classification. But this is actually a wrong name. The layer should be called softargmax.

## Softmax

Given a vector x = [20, 5, 0.1, 300]. The softmax (also called LogSumExp) is a approximation to the maximum of the vector. Let's apply the three steps in the name:

1. exp: exp([20, 5, 0.1, 300]) -> [4.8e+008, 1.4e+002, 1.1e+000, 1.9e+130]
2. sum: ~1.9e+130
3. log: 299.97

Note: If there were two "300" in the input vector, then the sum in the second step was 2 * 1.9e+130. Third step: log(2 * 1.9e+130) = log(2) + log(1.9e+130) = 300.67

## Softargmax

The softargmax divides each entry of the input vector x by the softmax. Therefore it can be seen as a probability measure. The probability of each entry to be the maximum of the vector.

1. Calculate softmax s=299.97
2. x' = x/s = [20, 5, 0.1, 300] / 299.97 ~= [0.066, 0.016, 0.0003, 1.0001]

In the classification framework we would choose the fourth class as a prediction.


## Addendum

1. Maximum rewritten:$$ max(x) = log(exp(max(x))) $$
2. Softargmax definition: $$ logsumexp(x) = log(exp(x_1) + ... + exp(x_n)) $$
3. Upper bound for Softargmax: $$ log(exp(x_1) + ... + exp(x_n)) \le log(exp(max(x)) + ... + exp(max(x)))  $$
4. Factor out n: $$ log(exp(max(x)) + ... + exp(max(x))) = log(n \cdot exp(max(x))) $$
5. Log rule: $$ log(n \cdot exp(max(x))) = log(n) +  log(exp(max(x))) $$
6. Insert defintion of max: $$log(n) +  log(exp(max(x))) = log(n) + max(x) $$
7. Result: $$ logsumexp(x) \le max(x) + log(n) $$




