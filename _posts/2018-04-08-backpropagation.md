---
layout: post
published: true
categories:
  - personal
mathjax: true
featured: true
comments: false
title: Backpropagation
---
## Calculating backpropagation by hand

My last post was about a [feed forward net](http://blog.pollithy.com/personal/calculating-a-feed-forward-net-by-hand). I did not explain where the weights in the network came from.

This entry explains back propagation and contains a calculation for the example from the last post which was about approximating the XOR function.

![xor_ffn.png]({{site.baseurl}}/images/xor_ffn.png)

### Initial values

Let's initialize the values of both weight matrices and biases with random numbers from `[-4, 4]\{0}`:

$$ W_{1} \begin{pmatrix}-4 & -4\\\ -1 & 1 \end{pmatrix} $$

$$ W_{2}  \begin{pmatrix}-3 & -2 \end{pmatrix} $$

$$ b_{1} \begin{pmatrix} -1 \\\ 2 \end{pmatrix} $$

$$ b_{2} \begin{pmatrix} 3 \end{pmatrix} $$

And let the learning rate be $$ \alpha = 1 $$ .

### Forward propagation

Backpropagation is an online algorithm which means "one example at a time". The first step is to calculate the prediction for given x-values and calculate the error using the attached label.

<table align="center"><tr><th>x XOR y<br></th><th>0</th><th>1</th></tr><tr><td>0<br></td><td>0</td><td>1<br></td></tr><tr><td>1</td><td>1<br></td><td>0</td></tr></table>

For $$ x = (0, 0)^T $$ the calculation of y is as follows:

$$ \sigma (\begin{pmatrix} -3 & -2 \end{pmatrix} * \sigma \bigg( \begin{pmatrix} -4 & -4 \\\ -1 & 1 \end{pmatrix} * \begin{pmatrix}0\\\ 0\end{pmatrix} + \begin{pmatrix}-1\\\ 2\end{pmatrix} \bigg) + \begin{pmatrix}3 \end{pmatrix}) =  $$

$$ \sigma (\begin{pmatrix} -3 & -2 \end{pmatrix} *  \begin{pmatrix}0.27 \\\ 0.88 \end{pmatrix}  + \begin{pmatrix}3 \end{pmatrix}) =  $$

$$ \sigma ( 0.43 ) = 0.6 $$

### Backward propagation

**0 XOR 0 should be 0.** We can now calculate the error of the output neuron(s): 
$$ y - ŷ = 0 - 0.6 = -0.6 $$

But how do we calculate the error of the hidden units? We don't have a supervision to directly compare them to something.

![XOR_bp.png]({{site.baseurl}}/images/XOR_bp.png)

The image above shows all of the steps and variables necessary for our XOR neural net. The weights to the biases where ignored so far as they were ones. If we want to change the weight of one bias, we just add the difference to the biase itself.

With the error to the output neuron we can calculate the error of every single neuron that is connected to the output neuron:

Error of hidden neuron h_i:

$$ E_{h_{i}} = \frac{\partial E}{\partial h_{i}} = \sum_{j} \sigma ' (y_{i}) * W2_{i,j} \frac{\partial E}{\partial y_{j}} $$

- We want to know the error of the neuron to change its value accordingly: 
$$\frac{\partial E}{\partial h_{i}}$$
- The error of the hidden neuron depends on the neurons that come after it. In this case it is only the output neuron: 
$$\frac{\partial E}{\partial y_{i}}$$
- The changerate of the output neuron depends on how the hidden neuron is changes: 
$$\sigma ' (y_{i}) * W2_{i,j}$$
- $$ \sum $$ and then all of these partial errors to single neurons that come after are summed up to determine how much the single hidden neuron affects the next layer
- The derivative of sigma is $$ \sigma ' (x) = e^x \div (1 + e^x)^2 $$

### Calculate the errors of the hidden layer

The following image contains all the numbers from the feed forward step:

![xor_bp2.png]({{site.baseurl}}/images/xor_bp2.png)

$$ E_{h_{2}} = \sigma ' (0.6) * (-2) * (-0.6) = 0.28 $$

![ffn_bg3.png]({{site.baseurl}}/images/ffn_bg3.png)

### Calculate the errors on weights

Now that we know how to calculate the error on hidden neurons we can calculate the error on weights.

Error on weight w connecting two neurons. h1 from hidden layer h and y1 from output layer y:

$$ \frac{\partial E}{\partial w} = \frac{\partial E}{\partial y_1} \sigma ' (y_1) * h_1 $$

![weight_errors.png]({{site.baseurl}}/images/weight_errors.png)


This error (which is the derivative of the error to one neuron) is used to update the weight w:

$$ w \leftarrow w - \alpha * \frac{\partial E}{\partial w} $$

![weights_updated.png]({{site.baseurl}}/images/weights_updated.png)




























**Good explanations:**

[https://www.youtube.com/watch?v=aVId8KMsdUU](https://www.youtube.com/watch?v=aVId8KMsdUU)

[https://www.youtube.com/watch?v=zpykfC4VnpM](https://www.youtube.com/watch?v=zpykfC4VnpM)

[https://www.youtube.com/watch?time_continue=230&v=An5z8lR8asY](https://www.youtube.com/watch?time_continue=230&v=An5z8lR8asY)






