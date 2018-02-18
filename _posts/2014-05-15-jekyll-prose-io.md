---
layout: post
published: true
title: Detect orientation of a cube with openCV
mathjax: false
featured: true
comments: false
headline: Making blogging easier for masses
categories:
  - personal
  - webdevelopment
tags: jekyll
description: ''
modified: ''
imagefeature: ''
---
Setup: There are 8 cameras positioned around a cube at which they are looking (ref: Initial setup).
Every face of the cube is colored differently.

Scope: Spot the location of every camera by analyzing its rgb stream.

Example: Camera No. 1 sees the blue, red and green face and therefore has to be south-bottom.

![Initial setup]({{site.baseurl}}/images/cube_wired.png)

**The idea:** If I could remove everything else except for the cube in the rgb stream, then I could easily match colored faces and from there derive the orientation of the cube.

## First try

I made the asumption that the colors of the cube's faces are unique in the image.
After crafting a 6cm cube from cardboard and painting it (see image cube) I got to work with openCV 2.6.

![Referential cube]({{site.baseurl}}/images/cube.png)

```
import cv2
import numpy as np
img = cv2.imread("<img path>")
```

The background of the image should be noisy because I wanted to build a robust solution.
So I found a real life object similar to a cube: a printer.

![Noisy background]({{site.baseurl}}/images/2018-02-11-140640.jpg)

### Isolating the cube

1. Create an all black mask 
2. Add all important edges to the mask
3. Add all areas filled with the colors of the cube to the mask
4. Remove areas of the combined mask which are too small to be a cube (for example a line)

#### Create the mask

```
# get the dimensions of the input image
width = img.shape[1::-1][1]
height = img.shape[1::-1][0]
# create a black image with the same dimensions
blank_mask = np.zeros((width,height,3), np.uint8)
# create a white image with the same dimensions
all_white = np.ones((width,height,3), np.uint8)
all_white[:] = (255, 255, 255)
# change the colorspace to rgb
blank_mask = cv2.cvtColor(blank_mask, cv2.COLOR_RGB2GRAY)
```

#### Add the lines


```
# blur the image
img_blurred = cv2.medianBlur(img, 17)
# remove noise with bilateral filter
img_noise_removed = cv2.bilateralFilter(img_blurred, 9,75,75)

# convert to grayscale
img_gray = cv2.cvtColor(noise_removal,cv2.COLOR_RGB2GRAY)
# use adaptive gaussian treshold to convert the image to black and white
thresh_image = cv2.adaptiveThreshold(img_gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, \
				cv2.THRESH_BINARY, 11, 2)
                
# canny edge detection
canny_image = cv2.Canny(thresh_image,250,255)
# dilate to strengthen the edges
kernel = np.ones((9,9), np.uint8)
dilated_image = cv2.dilate(canny_image,kernel,iterations=1)

combined = cv2.add(dilated_image, blank_mask)
```

#### Add the colored areas

First define the hsb colors:

```
hsb_colors = {
	'blue':   ([ 37, 85, 75], [150, 230, 255]),
	'orange': ([  1, 155, 127], [ 38, 255, 255]),
	'green': ([ 30,  60, 70], [ 90,  180, 255]),
	'red': 	  ([  0, 151, 100], [ 30, 255, 255])
}
```


![Screenshot from 2018-02-11 15-03-44.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 15-03-44.png)







