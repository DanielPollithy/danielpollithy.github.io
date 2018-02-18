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

Now loop over the colors, find the areas and add them to the mask:
```
for key, (lower, upper) in hsb_colors.items():
		# create NumPy arrays from the boundaries
		lower = np.array(lower, dtype = "uint8")
		upper = np.array(upper, dtype = "uint8")
	 
		# find the colors within the specified boundaries and apply the mask
		mask = cv2.inRange(image_hsv, lower, upper)
		tmp_mask = cv2.bitwise_and(all_white, all_white, mask = mask)
		blank_mask = cv2.add(blank_mask, tmp_mask)
```

#### Remove small areas

Bring the lines and areas together:
```
combined = cv2.add(dilated_image, blank_mask)
```

Now dilate and erode to strengthen the cubes mask and remove lines and other noise.

```
# bring the lines and areas closer together (merge them)
kernel = np.ones((11,11), np.uint8)
combined_dilated = cv2.dilate(combined, kernel, iterations=1)

# remove everything smaller than 71x71
kernel = np.ones((71,71), np.uint8)
combined_eroded = cv2.erode(combined_dilated, kernel, iterations=1)

# increase everything in size that is left
kernel = np.ones((91,91), np.uint8)
combined_area = cv2.dilate(combined_eroded, kernel, iterations=1)

final_img = np.zeros((width,height,3), np.uint8)
final_img = cv2.bitwise_and(img, img, mask = combined_area)
```

Show the result:
```
cv2.namedWindow("final cube image", cv2.WINDOW_NORMAL)
cv2.imshow("final cube image", final_img)
```

![Screenshot from 2018-02-11 15-03-44.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 15-03-44.png)

### Does the approach work?

Looking at the last screenshot one could assume that this approach works. 
Well... Looking at the cube from the correct angle with the perfect amount of light. This works.
But if the light or the angle changes the color ranges are not large enough.
When I tried to adjust them too many colors were in the range and a lot of areas in the image were big enough to overcome the fourth described stage. The color problem is visible in the next image.

![Screenshot from 2018-02-11 15-37-47.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 15-37-47.png)

So I started all over again with a new idea.

## Second try

My second approach is to use the a priori knowledge about cubes to find them by their edges not the size of masks or the color of faces.

1. Find the most important edges
2. Find all perpendicular lines that are equally long and close to each others
3. Connect the upper ends of lines and lower ends of lines
4. Cluster the ends of lines with DBSCAN to find the edges of the cube

### Find the most important edges

```
img_gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

noise_removal = cv2.bilateralFilter(img_gray, 9,75,75)

thresh_image = cv2.adaptiveThreshold(img_gray, 255,
	cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
	cv2.THRESH_BINARY, 11, 2)

kernel = np.ones((10,1), np.uint8)
dilated_thresh_image = cv2.dilate(thresh_image, kernel, iterations=1)

kernel = np.ones((10,1), np.uint8)
dilated_thresh_image = cv2.erode(dilated_thresh_image, kernel, iterations=1)

kernel = np.ones((5,5), np.uint8)
dilated_thresh_image = cv2.erode(dilated_thresh_image, kernel, iterations=1)

kernel = np.ones((20,1), np.uint8)
dilated_thresh_image = cv2.dilate(thresh_image, kernel, iterations=1)

kernel = np.ones((25,1), np.uint8)
dilated_thresh_image = cv2.erode(dilated_thresh_image, kernel, iterations=1)

kernel = np.ones((5,5), np.uint8)
dilated_thresh_image = cv2.erode(dilated_thresh_image, kernel, iterations=1)

inverted_dilated_thresh_image = cv2.bitwise_not(dilated_thresh_image)

img2 = img.copy()
```

### Find perpendicular lines

```
minLineLength = 100
	maxLineGap = 80
	lines = cv2.HoughLinesP(inverted_dilated_thresh_image, 
			rho = 1,
			theta = 1 * np.pi/180,
			lines=np.array([]),
			threshold = 100,
			minLineLength = 100,
			maxLineGap = 50)

	correct_lines = np.array([])

	count = 0

	if lines is not None and lines.any():
		for x1,y1,x2,y2 in lines[0]:
			# calculate angle in radian,  if you need it in degrees just do angle * 180 / PI
			angle = np.arctan2(y1 - y2, x1 - x2)
			degree = abs(angle * (180 / np.pi))
			
			if 85 < degree < 95:
				
				count += 1
				cv2.line(img2,(x1,y1),(x2,y2),(0,255,0),2)

				if y1 < y2:
					temp = y2
					y2 = y1
					y1 = temp
					
					temp = x2
					x2 = x1
					x1 = temp

				correct_lines = np.concatenate((correct_lines, np.array([x1,y1,x2,y2], \
                				dtype = "uint32")))				
				
				cv2.circle(img2, (x1,y1), 2, (0,0,255), thickness=2, lineType=8, shift=0)
				cv2.circle(img2, (x2,y2), 2, (255,0,0), thickness=2, lineType=8, shift=0)

	correct_lines = correct_lines.reshape(-1, 4)
```

### Connect the upper ends of lines and lower ends of lines

```
squares = np.array([])
	lower_points = np.array([])
	upper_points = np.array([])

	top_lines = np.array([])
	bottom_lines = np.array([])

	areas = np.array([])


	for a_x1, a_y1, a_x2, a_y2 in correct_lines:
		count2 += 1
		line_length = np.linalg.norm(np.array([a_x1, a_y1])-np.array([a_x2, a_y2]))
		cv2.circle(img2, (int(a_x1),int(a_y1)), 2, (0,255,255), thickness=2, lineType=8, shift=0)
		#cv2.circle(img2, (int(a_x2),int(a_y2)), 2, (0,255,255), thickness=2, lineType=8, shift=0)


		for b_x1, b_y1, b_x2, b_y2 in correct_lines:
			#cv2.circle(img2, (int(b_x1),int(b_y1)), 2, (255,0,255), thickness=2, lineType=8, shift=0)
			cv2.circle(img2, (int(b_x2),int(b_y2)), 2, (255,0,255), thickness=2, lineType=8, shift=0)
			line_length_b = np.linalg.norm(np.array([b_x1, b_y1])-np.array([ b_x2, b_y2]))

			if 0.9 > max(line_length, line_length_b)/min(line_length, line_length_b) > 1.1:
				continue

			dist = np.linalg.norm(np.array([ a_x1, a_y1 ]) - np.array([b_x1, b_y1]))
			if 20 < dist < line_length:
				

				dist = np.linalg.norm(np.array([ a_x2, a_y2 ]) - np.array([b_x2, b_y2]))
				if 20 < dist < line_length:
					top_lines = np.concatenate((top_lines, np.array([a_x1,a_y1,b_x1,b_y1], \
                    		dtype = "uint32")))
					angle_top_line = np.arctan2(int(a_y1) - int(b_y1), int(a_x1) - int(b_x1))
					degree_top_line = abs(angle_top_line * (180 / np.pi))
	
					bottom_lines = np.concatenate((bottom_lines, np.array([a_x1,a_y1,b_x1,b_y1], \
                    		dtype = "uint32")))
					angle_bottom_line = np.arctan2(int(a_y1) - int(b_y1), int(a_x1) - int(b_x1))
					degree_bottom_line = abs(angle_bottom_line * (180 / np.pi))
					
					# hack around 0 degree
					if degree_top_line == 0 or degree_bottom_line == 0:
						degree_top_line += 1
						degree_bottom_line += 1

					if 0.8 > max(degree_top_line, degree_bottom_line)/min(degree_top_line, 
                    			degree_bottom_line) > 1.2:
						print("too much difference in line degrees")
						continue

					cv2.line(img2, (int(a_x2), int(a_y2)), (int(b_x2), int(b_y2)), (0,0,255), 1)
					upper_points = np.concatenate((upper_points, np.array([a_x2, a_y2], \
                    			dtype = "uint32")))
					upper_points = np.concatenate((upper_points, np.array([b_x2, b_y2], \
                    			dtype = "uint32")))
					
					cv2.line(img2, (int(a_x1), int(a_y1)), (int(b_x1), int(b_y1)), (255,0,0), 1)
					lower_points = np.concatenate((lower_points, np.array([a_x1, a_y1], \
                    			dtype = "uint32")))
					lower_points = np.concatenate((lower_points, np.array([b_x1, b_y1], \
                    			dtype = "uint32")))

					area = np.array([	
						int(a_x1), int(a_y1),
						int(b_x1), int(b_y1),
						int(a_x2), int(a_y2), 
						int(b_x2), int(b_y2)
					], dtype = "int32")

					areas = np.concatenate((areas, area))
```

### Cluster the ends of lines with DBSCAN

```

	def centeroidnp(arr):
		length = arr.shape[0]
		sum_x = np.sum(arr[:, 0])
		sum_y = np.sum(arr[:, 1])
		return sum_x/length, sum_y/length

	corners = np.array([])
	lower_corners = np.array([])
	upper_corners = np.array([])

	vectors = np.int32(lower_points.reshape(-1, 2))

	if vectors.any():

		# http://scikit-learn.org/stable/modules/generated/sklearn.cluster.DBSCAN.html
		db = DBSCAN(eps=30, min_samples=10).fit(vectors)
		core_samples_mask = np.zeros_like(db.labels_, dtype=bool)
		core_samples_mask[db.core_sample_indices_] = True
		labels = db.labels_


		# Number of clusters in labels, ignoring noise if present.
		n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)

		vectors_result = {i: np.where(db.labels_ == i)[0] for i in range(n_clusters_)}


		for i in set(db.labels_):
			if i == -1:
				continue
			color = (random.randint(0, 255),random.randint(0, 255),random.randint(0, 255))
			index = db.labels_ == i
			for (point_x, point_y) in zip(vectors[index,0], vectors[index,1]):
				cv2.circle(img2,  (point_x, point_y), 5, color, thickness=1, lineType=8, shift=0)

			cluster_center = centeroidnp(np.array(zip(np.array(vectors[index,0]), np.array(vectors[index,1]))))
			cv2.circle(img2,  cluster_center, 5, color, thickness=10, lineType=8, shift=0)
			
			corners = np.concatenate((corners, np.array([cluster_center[0], cluster_center[1]], dtype = "uint32")))
			lower_corners = np.concatenate((lower_corners, np.array([cluster_center[0], cluster_center[1]], dtype = "uint32")))
	# play the same game for the top line
	vectors = np.int32(upper_points.reshape(-1, 2))

	if vectors.any():

		# http://scikit-learn.org/stable/modules/generated/sklearn.cluster.DBSCAN.html
		db = DBSCAN(eps=75, min_samples=10).fit(vectors)
		core_samples_mask = np.zeros_like(db.labels_, dtype=bool)
		core_samples_mask[db.core_sample_indices_] = True
		labels = db.labels_


		# Number of clusters in labels, ignoring noise if present.
		n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)

		vectors_result = {i: np.where(db.labels_ == i)[0] for i in range(n_clusters_)}


		for i in set(db.labels_):
			if i == -1:
				continue
			color = (random.randint(0, 255),random.randint(0, 255),random.randint(0, 255))
			index = db.labels_ == i
			for (point_x, point_y) in zip(vectors[index,0], vectors[index,1]):
				cv2.circle(img2,  (point_x, point_y), 5, color, thickness=1, lineType=8, shift=0)

			cluster_center = centeroidnp(np.array(zip(np.array(vectors[index,0]), np.array(vectors[index,1]))))
			cv2.circle(img2,  cluster_center, 5, color, thickness=10, lineType=8, shift=0)
			corners = np.concatenate((corners, np.array([cluster_center[0], cluster_center[1]], dtype = "uint32")))
			upper_corners = np.concatenate((upper_corners, np.array([cluster_center[0], cluster_center[1]], dtype = "uint32")))
```

![lines]({{site.baseurl}}/images/Screenshot from 2018-02-11 18-55-24.png)

![Screenshot from 2018-02-11 21-17-00.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 21-17-00.png)

![Screenshot from 2018-02-11 22-05-34.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 22-05-34.png)

![Screenshot from 2018-02-11 22-36-24.png]({{site.baseurl}}/images/Screenshot from 2018-02-11 22-36-24.png)



To be continued...
















