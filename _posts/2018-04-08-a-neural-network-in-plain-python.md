---
layout: post
published: true
categories:
  - machine-learning
  - python
  - programming
mathjax: false
featured: false
comments: false
title: A neural network in plain python
---
## Let's build a neural net from scratch without numpy and scikit

In my last blog entries I have been discovering neural networks:
- [Calculating a feed forward net by hand](http://blog.pollithy.com/personal/calculating-a-feed-forward-net-by-hand)
- [Backpropagation](http://blog.pollithy.com/personal/backpropagation)

Update 2021: Thanks to Tejasvi S. Tomar who spotted that the old code did not work properly.

As long as it is possible, I am a fan of implementing a simple version from scratch of what I have learned. That is why I built a small python neural network **without numpy or scikit**.

### Object oriented approach

I wrote two classes: **Neuron** and **NeuralNet**. Speaking about performance it does not make sense to do it like this. But it felt naturally to do so and maybe it helps remembering...

The NeuralNet knows all Neurons and contains the "api" for the user:

```
# instantiate a new neural network
net = NeuralNet(['x1', 'x2'])
# create the "topology"
net.add_layer(2)
net.add_layer(1)

# trigger a feed forward and get the output
prediction = net.predict([0, 1])

# train the network
net.train_row([1, 1], 0)
```

Whereas the neuron only knows its neighbours. It offers methods like: `.add_parent(parent)`, `.add_child(child)`, `.feed_forward()`, `calculate_error()` or `update_weight()`.

## The important methods

The most important methods which where built according to the previous blog posts where **feed_forward**, **calculate_error** and **update_weight**.

## Training

The XOR function which was used earlier is approximated by the net. The activation function is the sigmoid. While the training I got a OverFlow exception because the sigmoid and its derivative were producing number that would not fit into a float64. Therefore I had to limit them manually for the ranges out of [-500; +500].

## The code

```
import random
import math
import time


class Neuron(object):

    def __init__(self, learning_rate=0.1):

        # parents are on the left side of their children
        # (where right is the classification and left the input)

        self.parents = []
        self.children = []

        # The key is the neighbouring node

        self.weights = {}
        self.current_value = None
        self.error = None
        self.learning_rate = learning_rate
        self.bias = random.random()

    def add_parent(self, parent):
        self.parents.append(parent)
        self.weights[parent] = random.random()
        parent.add_child(self, weight=self.weights[parent])

    def add_child(self, child, weight=0.5):
        self.children.append(child)
        self.weights[child] = weight

    def set_value(self, value):
        self.current_value = value
        self.p = value

    def get_value(self):
        return self.current_value

    def feed_forward(self):
        self.current_value = self.bias
        for parent in self.parents:
            self.current_value += parent.get_value() \
                * self.weights[parent]
        self.y = self.current_value
        self.p = self.sigmoid(self.current_value)
        self.current_value = self.p
        return self.p

    def set_error(self, error):
        self.error = error

    def get_error(self):
        return self.error

    def set_weight(self, neighbour, weight):
        self.weights[neighbour] = weight

    def calculate_error(self):

        # self.error contains derivative of loss w.r.t. the neurons output p

        self.d_L__d_p = self.error

        # 1. backprop through sigmoid to weighted sum of inputs y
        # self.d_L__d_y = self.d_L__d_p * self.sigmoid(self.y)*(1.0 - sigmoid(self.y))

        self.d_L__d_y = self.d_L__d_p * self.p * (1.0 - self.p)

        # no need to derive y wrt to bias: d_y__d_b = 1

        self.d_L__d_b = self.d_L__d_y

        # derive error of weights

        self.d_L__d_w = {}

        for parent in self.parents:

            # dL/dw = dL/dy * corresponding_input_value

            self.d_L__d_w[parent] = self.d_L__d_y * parent.get_value()
            parent.set_error(self.d_L__d_y * self.weights[parent])

    def update_weight(self):
        self.bias -= self.learning_rate * self.d_L__d_b
        for parent in self.parents:
            self.weights[parent] -= self.learning_rate \
                * self.d_L__d_w[parent]
            parent.set_weight(self, self.weights[parent])

    @classmethod
    def sigmoid(cls, x):

        # this function is limited because the exponential operation
        # can easily lead to an OverFlow exception

        if x > 20:
            return 0.999
        if x < -20:
            return 0.001
        return 1.0 / (1.0 + math.exp(-x * 1.0))


class InputNeuron(Neuron):

    """This class can be extended to read data from generators"""

    def __init__(self, placeholder_name):
        super().__init__()
        self.placeholder_name = placeholder_name


class NeuralNet(object):

    def __init__(self, inputs):
        """

        :param inputs: an array of placeholder strings, 
        e.g. ['x1', 'x2,]
        """

        self.num_inputs = len(inputs)
        self.layers = []

        # the input layer is created with initialization

        self.layers.append([InputNeuron(name) for name in inputs])

    def add_layer(self, number_neurons, fully_connected=True):
        """
        Add a layer with n neurons to self.layers
        :param number_neurons:
        :param fully_connected: If set True all neurons of
                the new layer are connected to the next layer
        """

        self.layers.append([Neuron() for _ in range(number_neurons)])
        if fully_connected:
            for new_neuron in self.layers[-1]:
                for old_neuron in self.layers[-2]:
                    new_neuron.add_parent(old_neuron)

    def predict(self, input_data):

        # hand the data to the input layer

        for (input_neuron, data) in zip(self.layers[0], input_data):
            input_neuron.set_value(data)

        # calculate layer per layer

        for layer in self.layers[1:]:
            for neuron in layer:
                neuron.feed_forward()

        return [neuron.get_value() for neuron in self.layers[-1]]

    def train_row(self, X, y):
        """

        :param X: the feature vector as list
        :param y: the label
        :return:
        """

        prediction = self.predict(X)
        CE = (-math.log(prediction[0]) if y == 1 else -math.log(1.0
              - prediction[0]))

        # set the error to the output layer

        dCE_dp_hat = (-1.0 / prediction[0] if y == 1 else +1.0 / (1
                      - prediction[0]))

        # print([X, y, prediction, CE, dCE_dp_hat])

        self.layers[-1][0].set_error(dCE_dp_hat)

        # calculate error for every neuron in hidden and input layers

        for layer in reversed(self.layers):
            for neuron in layer:
                neuron.calculate_error()

        # Update the weight of every neuron

        for layer in reversed(self.layers):
            for neuron in layer:
                neuron.update_weight()


def train():

    # Create the "topology"

    nn = NeuralNet(['x1', 'x2'])
    nn.add_layer(2)
    nn.add_layer(2)
    nn.add_layer(1)

    # loop: train until the error is < 1% and at least 10.000 sets

    for epoch in range(20):
        correct = 0
        ratio = 0.0
        steps_per_epoch = 10000
        for i in range(steps_per_epoch):

            # The training data is sponsored by random

            x1 = random.randint(0, 1)
            x2 = random.randint(0, 1)
            y = x1 ^ x2
            nn.train_row([x1, x2], y)

            prediction = nn.predict([x1, x2])
            correct += (1 if y == 1 and prediction[0] > 0.5 or y == 0
                        and prediction[0] < 0.5 else 0)
            ratio = float(correct) / steps_per_epoch

        print('{}, {}'.format(time.strftime('%H:%M:%S'), str(ratio)))


if __name__ == '__main__':
    train()

```



