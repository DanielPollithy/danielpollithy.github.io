---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: Last timestep in masked sequence
categories:
  - keras
  - python
---
## Motivation

This is just a short piece of code which I have needed multiple times when training a LSTM with masked inputs.

**Setup**: Seq2seq training with additional loss 

**Problem**: How to get the last time step which is not masked

**Why**: Calculating loss only at this timestep

## Example data

The input batches are masked like with `0.0`:

```
input = [ # mini-batch
	[ # 1st time series
    	[0.1, 0.00],
        [0.2, 0.01],
        [0.3, 0.01], # <--- we want this timestep
        [0.0, 0.0 ],
        [0.0, 0.0 ]
    ], 
	[ # 2nd time series
    	[0.5, 0.32], # <--- we want this timestep
        [0.0, 0.0 ],
        [0.0, 0.0 ],
        [0.0, 0.0 ],
        [0.0, 0.0 ]
    ], 
    ...
]
```

The labels for the seq2seq training are the `input`s but shifted one time step.

## Solution

```python
masking_value = 0.
timesteps = inp.shape[1]
point_dim = inp.shape[-1]  # example: is 2 for (x,y) points 

# 1. Find entries which are equal to the masking_value 
equal_zero = inp == K.cast([masking_value], tf.float64)

# 2. Count the zeros in the row
zeros_per_row = K.sum(equal_zero, axis=-1)

# 3. Find the rows which only contain masking_values
correct_rows = K.cast(zeros_per_row == [point_dim], tf.float64)

# (The following code is argmin which is forced to return the first occurence)

# 4. Set the wrong rows to the maximum value (-> not selected by argmin)
#        (timesteps**2 is an upper bound for step 5)
wrong_rows = (-1 * correct_rows + 1) * (timesteps**2)

# 5. Build enumerations for every track
range_np = np.array(list(range(timesteps)))  # [0,1,2,3...]
range_np_batch = np.tile(range_np, (batch_size, 1)).reshape([batch_size, timesteps])
range_keras = K.variable(range_np_batch)
# [
#   [0,1,2,3...],
#   [0,1,2,3...],
#   ...
# ]

# 6. Enumerate the correct values ascending + add the infinities of step 4
search_space = correct_rows * range_keras + wrong_rows
last_timesteps = K.argmin(search_space, axis=1) - 1

# 7. Build a mask for selection
mask_last_step = tf.one_hot(last_timesteps, depth=timesteps, dtype=tf.bool, on_value=True, off_value=False)
mask_last_step = K.cast(mask_last_step, tf.float64)

# 8. Use the mask for loss calc
loss_per_track = tf.keras.losses.mean_squared_error(y_label, y_hat) * mask_last_step
loss = K.sum(loss_per_track)
```

## Why not only argmin?

The tensorflow documentation for `tf.math.argmin` [(doc)](https://www.tensorflow.org/api_docs/python/tf/math/argmin) states:

"Note that in case of ties the identity of the return value is not guaranteed."

## Notes

- `range_np`, `range_np_batch`, `range_keras` should only be created once.
- Insted of using the ultimate mask a solution with `tf.gather_scatter_nd` is possible
- The sum in step 2 could be replaced by `K.all(K.equal(inp, mask_value), axis=-1)`
