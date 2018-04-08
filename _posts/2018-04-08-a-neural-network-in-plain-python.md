---
layout: post
published: true
categories:
  - personal
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

```
def feed_forward(self):
    self.current_value = 0
    for parent in self.parents:
        self.current_value += parent.get_value() * self.weights[parent]
    self.current_value = self.sigmoid(self.current_value)
    return self.current_value
```

```
def calculate_error(self):
    self.error = 0
    for child in self.children:
        self.error += self.sigmoid_derivative(child.get_value()) * self.weights[child] * child.get_error()
```

```
def update_weight(self):
    for parent in self.parents:
        self.weights[parent] += self.learning_rate * self.get_error() * parent.get_value()
        parent.set_weight(self, self.weights[parent])
```

## Training

The XOR function which was used earlier is approximated by the net. The activation function is the sigmoid. While the training I got a OverFlow exception because the sigmoid and its derivative were producing number that would not fit into a float64. Therefore I had to limit them manually for the ranges out of [-500; +500].

## The code

```
import random
import math
import time


class Neuron(object):
    def __init__(self, learning_rate=1.0):
        # parents are on the left side of their children
        # (where right is the classification and left the input)
        self.parents = []
        self.children = []
        # The key is the neighbouring node
        self.weights = {}
        self.current_value = None
        self.error = None
        self.learning_rate = learning_rate

    def add_parent(self, parent):
        self.parents.append(parent)
        self.weights[parent] = random.random()
        parent.add_child(self, weight=self.weights[parent])

    def add_child(self, child, weight=0.5):
        self.children.append(child)
        self.weights[child] = weight

    def set_value(self, value):
        self.current_value = value

    def get_value(self):
        return self.current_value

    def feed_forward(self):
        self.current_value = 0
        for parent in self.parents:
            self.current_value += parent.get_value() \
                                  * self.weights[parent]
        self.current_value = self.sigmoid(self.current_value)
        return self.current_value

    def set_error(self, error):
        self.error = error

    def get_error(self):
        return self.error

    def set_weight(self, neighbour, weight):
        self.weights[neighbour] = weight

    def calculate_error(self):
        self.error = 0
        for child in self.children:
            self.error += self.sigmoid_derivative(child.get_value()) \
                          * self.weights[child] * child.get_error()

    def update_weight(self):
        for parent in self.parents:
            self.weights[parent] += self.learning_rate * \
                                    self.get_error() * parent.get_value()
            parent.set_weight(self, self.weights[parent])

    @classmethod
    def sigmoid(cls, x):
        # this function is limited because the exponential operation
        # can easily lead to an OverFlow exception
        if x > 500:
            return 0.999
        if x < -500:
            return 0.001
        return 1.0/(1.0 + math.exp(-x*1.0))

    @classmethod
    def sigmoid_derivative(cls, x):
        # this function is limited because the exponential operation
        # can easily lead to an OverFlow exception
        if x < -500:
            return 0.001
        return math.exp(x) / ((1 + math.exp(x)) ** 2)


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
        for input_neuron, data in zip(self.layers[0], input_data):
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

        # set the error to the output layer
        error = (y - prediction[0]) * \
                Neuron.sigmoid_derivative(prediction[0])
        for neuron in self.layers[-1]:
            neuron.set_error(error)

        # calculate error for every neuron in hidden and input layers
        for layer in reversed(self.layers[:-1]):
            for neuron in layer:
                neuron.calculate_error()

        # Update the weight of every neuron
        for layer in reversed(self.layers[1:]):
            for neuron in layer:
                neuron.update_weight()


def train():
    # Create the "topology"
    nn = NeuralNet(['x1', 'x2'])
    nn.add_layer(4)
    nn.add_layer(2)
    nn.add_layer(1)

    # counters for the training loop
    i = 1
    correct = 0
    ratio = 0.0

    # loop: train until the error is < 1% and at least 10.000 sets
    while ratio < 0.99 or i < 10000:
        # The training data is sponsored by random
        x1 = random.randint(0, 1)
        x2 = random.randint(0, 1)
        y = x1 ^ x2
        nn.train_row([x1, x2], y)

        prediction = nn.predict([x1, x2])
        correct += 1 if ((y == 1 and prediction[0] > 0.5) 
                         or (y == 0 and prediction[0] < 0.5)) else 0
        ratio = float(correct)/i

        if i % 100000 == 0:
            print('{}, {}'.format(time.strftime("%H:%M:%S"), str(ratio)))

        i += 1


if __name__ == '__main__':
    train()

```



