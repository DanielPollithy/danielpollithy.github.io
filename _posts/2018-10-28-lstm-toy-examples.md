---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: Lstm Toy Examples
---
Some impression of LSTM architectures for simple math functions.

## Sequence to sequence

### X-Y

I generated a line and hill like mapping from points f:X->Y.
A one layered LSTM (SGD with fixed learning rate) was able to approx. the line:
![line.png]({{site.baseurl}}/images/line.png)
 
In order to get the hill-shaped function I added a second lstm layer (I guess this has the same reason as the XOR "problem"):
![lstm_hill.gif]({{site.baseurl}}/images/lstm_hill.gif)
 
In general what this network learned should only be the identity function.
It received some coordinates x and y and tried its best to reproduce the same.
 
### Only Y

The following step was to remove the x value from the input so the lstm only received the y-values. It took a little bit longer but the function got approximated:
![hill.png]({{site.baseurl}}/images/hill.png)
 
### Sine
 
The next function I wanted to approximate was a sine:
![sine_target.png]({{site.baseurl}}/images/sine_target.png)
 
Which worked out:
![sine.png]({{site.baseurl}}/images/sine.png)

The "learning" of this network should be a little bit more. A temporal dependency between values which was the x-axis in the former example.
 
What happens when I feed lines as input to the network?
![not_identity.png]({{site.baseurl}}/images/not_identity.png)

Interestingly they perform something like a sine phase in the beginning and then they grow all by the same factor although their slopes differed from 0.1 to 1.2.
 
Let's plot this again without y-intercept.
![not_identity_2.png]({{site.baseurl}}/images/not_identity_2.png)

The linear functions are mapped to non-linear functions through the lstm.
 
What happens with other sine curves?
I start with the same sine with different amplitudes:

![sines.png]({{site.baseurl}}/images/sines.png)
The "learned" sine was in the area between blue and green.
 
After some graphs I realize that they are actually only interesting if you can see the original function.
![sines_with_comp.png]({{site.baseurl}}/images/sines_with_comp.png)
 
The valley in the middle stays nearly untouched. I guess that this will not be the case when I displace the phase.
![phase_displacement.png]({{site.baseurl}}/images/phase_displacement.png)

Wrong! The valley stays.
 
Last chance: Change the frequency...
![frequency.png]({{site.baseurl}}/images/frequency.png)
Except for the first part between 0.0 to 0.2 the frequency is copied correctly. It looks as though the only thing that is really wrong is the amplitude.

## Sequence to vector

### Amplitude of a wave

The next task is to extract the amplitude of a sine wave.
The lstm gets a sine and is supervised with the sine's amplitude.
The following sines are training examples.
![sines_with_different_amplitudes.png]({{site.baseurl}}/images/sines_with_different_amplitudes.png)

The validation set (from which the following curves are taken) have amplitudes greater than 0.5 (upper bound of ampl. from training set).

![predicted_amplitude.png]({{site.baseurl}}/images/predicted_amplitude.png)
This explains the divergence starting from 0.5 in this plot. Dotted curves are with amplitude from lstm, solid curves groundtruth.

### Slope and intercept

The next task is to learn the slope and intercept of a line.

![lines.png]({{site.baseurl}}/images/lines.png)

 
The hidden function is $f(x) = mx + t$ and the seq2vec lstm is trained to return the parameters (m, t).

![predicted_lines_1.png]({{site.baseurl}}/images/predicted_lines_1.png)

The thin line is the ground truth and the thick line is the "prediction". 
Neither negative slope nor a larger slope can be handle well. 


 





 





 


 


