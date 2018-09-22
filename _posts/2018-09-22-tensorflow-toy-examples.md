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
 
Obviously we would like to read the result but one might be surprised to see that no value is returned. Instead we obtain a node from the computational graph...
 
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

Suppose we have a dynamical system like a simulation of a swing or of the populations in a forest. These systems have something called a **state**. In programming we represent and manipulate this with variables. This concept also exists for tensorflow.

The following example calculates n fibonacci numbers in a non-recursive way. So the same graph is called n times and the variables' contents change for every iteration.

It is important to say that the manipulation of variables (reading and writing) justifies the need for another new thing called **control dependencies**. One can use them to assure the execution of a sequence in its correct order.

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

The assignment `file_writer = tf.summary.FileWriter('tf_logs', sess.graph)` writes the computational graph to disk and we can visualize it with tensorboard:

![Screenshot from 2018-09-22 14-42-18.png]({{site.baseurl}}/images/Screenshot from 2018-09-22 14-42-18.png)

I am not sure but I think: The yellow line shows a connection where the data could have been manipulated, the solid grey line where data flows without manipulation and the dashed lines are control flow operations. 

The blue rectangles with round corners are variables. The white ellipsis with grey border is an operation and the ellipsis with red dashed border is the grouping.
 
My intuition on how to read this graph is:

 - Find operations which do not have incoming dashed grey lines (control flow) and no incoming lines from such nodes (this excludes "Assign_2"). They are free to be evaluated without prerequisites. -> "Assign"
 - After "Assign" is done it is the turn of "Add" and then "Assign_1" and "Assign_2" could potentially be executed in parallel
 

## Finding primes with a while loop

The following program uses a while loop to classify whether a number is prime. Tensorflow can help to parallelize while loops "automagically". Imagine you could write loops that can be placed on GPUs instantaneously...
 
Tensorflow's explains how the `tf.while_loop` works: [White paper tensorflow control flow](http://download.tensorflow.org/paper/white_paper_tf_control_flow_implementation_2017_11_1.pdf).

The following image shows the basic components which were added in order to achieve the control flow (screenshot taken from paper).

![Screenshot from 2018-09-22 22-34-23.png]({{site.baseurl}}/images/Screenshot from 2018-09-22 22-34-23.png)

From the paper:

**Enter(name):** An Enter operator forwards its input to the execution frame that is uniquely identified by the given name. This Enter op is used to pass a tensor in one execution frame to a child execution frame. There can be multiple Enter ops to the same child execution frame, each making a tensor available (asynchronously) in that child execution frame.  An Enter is enabled for execution when its input is available. A new execution frame is instantiated in the TensorFlow runtime when the first Enter op to that frame is executed.


**Exit:** An Exit operator forwards a value from an execution frame to its parent execution frame. This Exit op is used to return a tensor computed in a child execution frame back to its parent frame. There can be multiple Exit ops to the parent frame, each asynchronously passing a tensor back to the parent frame. An Exit is enabled when its input is available.


**NextIteration:** A NextIteration operator forwards its input to the next iteration in the current execution frame.  The TensorFlow runtime keeps track of iterations in an execution frame. Any op executed in an execution frame has a unique iteration id, which allows us to uniquely identify different invocations of the same op in an iterative computation. Note that there can be multiple NextIteration ops in an execution frame. The TensorFlow runtime starts iteration N+1 when the first NextIteration op is executed at iteration N.  As more tensors enter an iteration by executing NextIteration ops, more ops in that iteration will be ready for execution. 
A NextIteration is enabled when its input is available.


The prime search code:

```python
# Is this number a prime?
import tensorflow as tf

# The number at the bench
number = tf.placeholder(tf.float32, name="number")

# Possible divisors which are increased [1...number-1]
i = tf.get_variable("i", dtype=tf.float32, initializer=tf.constant(2.0))

# Store the result if the calculation gets through
is_prime = tf.get_variable("is_prime", dtype=tf.bool, initializer=tf.constant(True))


# The "stop criterion" for the while-loop
def condition(number, i, is_prime):
    return tf.logical_and(
        tf.less(i, number),
        tf.equal(is_prime, tf.constant(True)),
        name="and"
    )


# The code that gets executed for every iteration
def body(number, i, is_prime):
    # remainder = number % i
    remainder = tf.floormod(number, i, name="remainder")

    # not_divisable = remainder != 0
    not_divisable = tf.not_equal(remainder, tf.constant(0.0), name="not_divisable")

    # is_prime AND not_divisable
    result_is_prime = tf.logical_and(is_prime, not_divisable)

    # This line is necessary because the shape of result_is_prime is not fixed
    result_is_prime.set_shape(is_prime.shape)

    # A print statement in tensorflow has to be a proper node
    # or else it will not get executed
    result_is_prime2 = tf.Print(result_is_prime,
                     [number, i, remainder, not_divisable, result_is_prime],
                     name="remainder_before")

    # The body function has to return the same amount of tensors as it got
    # via parameters.
    return number, tf.add(i, tf.constant(1.0)), result_is_prime2


# The main operation is the while loop
search_op = tf.while_loop(
    condition,
    body,
    [number, i, is_prime]
)


with tf.Session() as sess:
    # Store the graph
    file_writer = tf.summary.FileWriter('tf_logs', sess.graph)

    # search the number 1 to 100
    for x in range(1, 100):

        # Init vars
        sess.run(tf.global_variables_initializer())

        # Run the session and get the last return values of the loop
        _, _, x_is_prime = sess.run([search_op], feed_dict={number: x})[0]

        if x_is_prime:
            print("{} is prime".format(x))
        else:
            print(x)
```

The collapsed computational graph looks far too simple:

![Screenshot from 2018-09-22 22-46-52.png]({{site.baseurl}}/images/Screenshot from 2018-09-22 22-46-52.png)


When unfolding the while block, we see a lot of operations which we did not explicitly mention in the python code.

Every variable that is passed in to the functions (condition and body) run through an "Enter" node.

![Screenshot from 2018-09-22 22-49-24.png]({{site.baseurl}}/images/Screenshot from 2018-09-22 22-49-24.png)

All of the python code which was written to manipulate the variables was translated into the graph. I find this really impressing because I did not feel really restricted when writing the condition and body for the loop.

![Screenshot from 2018-09-22 22-54-15.png]({{site.baseurl}}/images/Screenshot from 2018-09-22 22-54-15.png)

The big benefit of this (telling from what I read on the web) is that it supports auto differentiation. So one could write a loop to solve some problem and end-to-end learning could still be possible.

