---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: Popoviciu's inequality
categories:
  - general
description: An upper bound to the variance of samples from an unknown distribution on a known interval.
---

Suppose you have a neural network with a function as its last layer that squashes
its outputs to a fixed interval [a,b]. Popoviciu's inequality can give us an upper bound
to the sample variance.

If we knew the distribution where the samples stem from, then it would be easy
to answer this question. Consider the most simple case of a [uniform distribution](https://en.wikipedia.org/wiki/Continuous_uniform_distribution):
$$ p(x) \sim U(a,b), Var[p(x)]=\frac{1}{12}(b-a)^2 $$

The upper bound derived from Popoviciu's inequality is $$ \frac{1}{4}(b-a)^2 $$.
Interestingly, Mihaly Bencze and Florin Popovici write in their [proof](https://www.researchgate.net/publication/267072994_A_simple_proof_of_Popoviciu%27s_inequality) that
"Popoviciu’s inequality is a refinement of Jensen’s inequality".

In the following, I am going to adapt the proof by [Zen](https://stats.stackexchange.com/questions/45588/variance-of-a-bounded-random-variable) with minor notational changes:



Let $$ g(x) = E[(X - t)^2] $$ where X is our random variable and $$t$$ to be determined such that we find the minimum of g.

Therefore we derive g with respect to t: $$ \frac{d}{dt} g(x) = \frac{d}{dt} E[X^2 - 2Xt + t^2] $$

$$ = \frac{d}{dt} E[X^2] - E[2Xt] + E[t^2] = 0 - \frac{d}{dt} E[2Xt] + \frac{d}{dt} E[t^2] $$

$$= -2 E[X] + 2t $$

... and set it to zero:

$$-2 E[X] + 2t \stackrel{!}{=} 0 $$

$$t = E[X] $$

The second derivative is $2$ which is larger than zero. $E[X]$ is therefore the global minimum. $$g(\cdot)$$ was constructed such that $$g(E[X]) = Var[X]$$

Now we choose $$t = \frac{a+b}{2}$$ seemingly arbitrary in the middle of our interval but of course it is chosen on purpose.

Since $$g(\cdot)$$ has its global minimum at $E[X]$, we know that our chosen $$t$$ cannot make the function smaller:

$$ g(E[X]) \le g(\frac{a+b}{2})$$

By having a closer look at $$g(\frac{a+b}{2})$$ we can derive an upper bound for it:

$$ g(\frac{a+b}{2}) = E[(X - \frac{a+b}{2})^2]$$

$$ = E[(\frac{1}{2}(2X - (a + b))^2] = E[\frac{1}{4}(2X - (a - b))^2]$$

$$ = \frac{1}{4} E[(X+X - a - b)^2] = \frac{1}{4} E[(X - a + X - b)^2] $$

$$ = \frac{1}{4} E[(\underbrace{(X - a)}_{\ge 0} + \underbrace{(X - b)}_{\le 0})^2] $$

Since every sample from X has to be greater than $$a$$ and smaller than $$b$$, these observations are true. While the left part increases the value, the right part decreases it. Our upper bound can thus be constructed by simply flipping the sign such that the right part is not subtracted but added:


$$ \frac{1}{4} E[((X - a) + (X - b))^2] \le \frac{1}{4} E[((X - a) - (X - b))^2] $$

Modifying the right hand side:

$$ \frac{1}{4} E[((X - a) + (X - b))^2] \le \frac{1}{4} E[(X - a - X + b))^2] $$

The X is eradicated:

$$ \frac{1}{4} E[((X - a) + (X - b))^2] \le \frac{1}{4} E[(b-a)^2] $$

$$ \underbrace{\frac{1}{4} E[((X - a) + (X - b))^2]}_{g(\frac{a+b}{2})} \le \frac{1}{4} (b-a)^2 $$

Recalling that $$Var[X] = g(E[X]) \le g(\frac{a+b}{2})$$ we see that:

$$ Var[X] \le \frac{1}{4} (b-a)^2 $$
