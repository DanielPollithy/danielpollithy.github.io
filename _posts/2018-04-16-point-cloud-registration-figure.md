---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: Point Cloud Registration Figure
---
## Thoughts on how to design a registration figure

As mentioned in my last [post](http://blog.pollithy.com/personal/point-cloud-from-mesh-object) I was facing the challenge of registrating point clouds captured by multiple depth cameras.

The general idea behind registration in this context is to rotate and translate the point clouds of every camera a little bit to form a composite point cloud.

To do so there is an object placed into the middle of the cameras. Every camera can then use ICP to fit the own point cloud to the object with its part of the view.

### But how should the object look like?

We were experimenting with different figures and finally came to the conclusion that the figure should have:

- bounded planes visible for every camera and 
- edges aligned to every axis.

The bounded planes are necessary so the translation into every direction can be found.
The edges are necessary to control the rotation around every axis.

### Scenario with six cameras

In a scenario with six cameras this means that we have to have at least one vertical edge pointing to every camera and two surfaces fully  visible for each camera.
