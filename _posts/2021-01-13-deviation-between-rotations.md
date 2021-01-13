---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: Deviation between rotations
categories:
  - general
description: In pose estimation the predicted pose has to be compared to the real pose.
   In contrast to their positions, the there are many ways to compare the orientations.
---

In visual localization, the accuracy of a system is determined by comparing
predicted poses to ground truth poses.

The position in R³ is a euclidean space. But the orientations can be given in
multiple ways, like axis and angle, rotations matrices or quaternions.

Du Q. Huynh describes in [Metrics for 3D Rotations: Comparison and Analysis](https://www.cs.cmu.edu/~cga/dynopt/readings/Rmetric.pdf)
five metrics on SO(3):

 - Euclidean Distance between Euler Angles: This is only a metric on SO(3) if further restrictions are made.
 - Norm of the Difference of Quaternions: Since every rotation is covered twice by unit-quaternions, one property of metrics does not hold. Which is the property that states, if the distance between two entities is zero then the two entities are the same. This is not true for the positive and the negative quaternion who have a rotational difference of zero. This makes it a pseudometric which can be alleviated by adding a further restriction.
 - Inner Product of Unit Quaternions: Also pseudometrics on the unit quaternion.
 - Deviation from the Identity Matrix: $$ \lVert I - R_1 R_2^T \rVert_F $$
 - Geodesic on the Unit Sphere: the magnitude of the angle of the rotation matrix necessary to transform
   $$R_1$$ into $$R_2$$
