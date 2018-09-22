---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: Tensorflow Toy Examples
categories:
  - tensorflow
---
I have been using tensorflow for some examples in this blog. Building a sequential model and evaluating some metrics was easy. But when I wanted to do a little bit more (for example image data set augmentation) I got really stuck.

This blog post is a collection of toy examples I made from scratch with tensorflow in order to get a better understanding.

The following video is a good introduction to tensorflow (although it is pretty old):

<p>
  <figure>
    <div class="videoWrapper">
      <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/L8Y2_Cq2X5s?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>
  </figure>
</p>

[Slides](https://cs224d.stanford.edu/lectures/CS224d-Lecture7.pdf)

## The computational graph: Session and constant

A programmer can construct a computational graph with tensorflow. It does not contain data or is evaluated directly. For this reason we need **sessions** where we can **feed** data in and **fetch** results out.
 
`import tensorflow as tf`
 
For jupyter notebook there is an interactive session:
 
`sess = tf.InteractiveSession()`
 
In real programs we use:

`with tf.Session() as sess:`

```python
# Let us build a simple mathematical expression
# (13 * 13) - (12 * 12) - (11 * 11) 
a = tf.constant(11)
b = tf.constant(12)
c = tf.constant(13)

result = a*a - b*b - c*c
```
 
Obviously we would like the read the result but one might be surprised to see that no value is returned but instead we obtain a node from the computational graph...
 
`result.eval()` in an interactive session or `sess.run([result])` delivers what we expect!

## Placeholders

But this is kind of cheap. A calculation formed of constant values. 
What about something like $$f(x) = x^2 + 4x + 8$$?

For this we use **placeholders**. We define their size and datatype and feed them into the eval or run command.

```python
# The placeholder for the parameter
x = tf.placeholder(tf.float32)

# the function
f = x*x + 4*x + 8

# f(x=0) in interactive session
f.eval(feed_dict={x:0})
```

Okay interesting. We can build things with this. 
Let's imagine we have ball with mass m and we want to 
know the potential energy it has (m * g * h).

```python
# the mass m in kilogram
m = tf.placeholder(tf.float32)

# the height h in meters
h = tf.placeholder(tf.float32)

# gravitational constant of the earth
g = tf.constant(9.81)

# potential energy
e_pot = m * g * h

# Now let's say we want to lift the ball with a
# mass of 400g from the ground to a height of 
# 1.8 meters. How much is the energy difference?
difference = e_pot.eval(feed_dict={m:0.4, h:1.8}) - e_pot.eval(feed_dict={m:0.4, h:0})

print("{} Joule(?)".format(difference))
```

## Adding state to the graph

Suppose we have a dynamical system like a simulation of a swing or of the populations in a forest. These systems have something called a **state**. In programming we represent and manipulate this with variables. This concepts also exists for tensorflow.

The following example calculates n fibonacci numbers and stores the found numbers in its variables. So the same graph is called n times and the variables' contents change over this time.

It is important to say that the manipulation of variables (reading and writing) justifies the need for another new thing called **control dependencies**. One can use them to assure the execution of a sequence in its order.

```python
import tensorflow as tf

# Make the graph empty
tf.reset_default_graph()

# Create two variables for the fibonacci numbers and one for the swap
number_one = tf.get_variable("number_1", initializer=tf.constant([0], dtype=tf.int64))
number_two = tf.get_variable("number_2", initializer=tf.constant([1], dtype=tf.int64))
# Variable for the swapping
number_tmp = tf.get_variable("number_3", initializer=tf.constant([0], dtype=tf.int64))

# Operation to temporarily store one of the numbers
store_tmp = tf.assign(number_tmp, number_two)

# First store one of the numbers
with tf.control_dependencies([store_tmp]):

    sum_of_both = tf.add(number_one, number_two)

    # then calculate the sum
    with tf.control_dependencies([sum_of_both]):

        # and over finally overwrite the variables' values
        assign_new_number_one = tf.assign(number_one, number_tmp)
        assign_new_number_two = tf.assign(number_two, sum_of_both)

        # group the last assignments -> only call this later
        next_fib = tf.group([assign_new_number_one, assign_new_number_two])

# Here we store the fibonacci numbers
numbers = []

# How many numbers do we want?
n = 100

with tf.Session() as sess:
    # Store the graph
    file_writer = tf.summary.FileWriter('tf_logs', sess.graph)

    # Init vars
    sess.run(tf.global_variables_initializer())

    for _ in range(n):
        # Run the group which has to execute its control dependencies first
        sess.run([next_fib])

        # store the variables
        x = [number_one.read_value().eval(),
             number_two.read_value().eval(),
             number_tmp.read_value().eval()
             ]
        numbers.append(x)

# Extract only the fibonacci numbers with numpy
import numpy as np

fibs = np.asarray(numbers)[:, 1].flatten()

print(fibs)
```


