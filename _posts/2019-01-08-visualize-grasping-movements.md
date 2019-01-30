---
layout: post
published: true
mathjax: false
featured: true
comments: false
title: Visualize Grasping Movements
categories:
  - python
---
## Visualizing joint angles of grasps

In this post I am going to explain how to use the master motor map (MMM) in order to visualize grasping movements with joint angle data I downloaded from handcorpus.org.

![animated_minimized.gif]({{site.baseurl}}/images/animated_minimized.gif)

The MMM has a Whole-body human reference model and comes for example with tools to play captured motions on the figure. That is what we are going to do:

1. Install MMM
2. Get joint angle data of a hand while grasping
3. Convert the joint angles to a MMM motion
4. Export and convert to gif

### Installation

I am following this page:
https://mmm.humanoids.kit.edu/installation.html

Tt says: "The MMM Libraries officially supports Ubuntu 14.04 and 16.04."
It makes sense to use all cores of my laptop by adding the "-j4" option to the "make" command.

The following packages will be installed:
 - MMMCore
 - Simox
 - MMMTools

### Get the data

I used the HUST data set from handcorpus.org. Utter is a repository for hand motion data and tools. http://www.handcorpus.org/?p=1596

The joint angles of multiple subjects were collected with a CyberGlove while they were grasping different objects with grasps according to the Feix taxonomy.

The following image taken from the Paper "Biomechanical Characteristics of Hand Coordination in Grasping Activities of Daily Living" by Liu et al. explains the hand skeleton and which parts are measured by the CyberGlove.

[View Image on Researchgate](/https://www.researchgate.net/publication/289495089/figure/fig4/AS:341327033192461@1458390114726/CyberGlove-sensor-placement-and-corresponding-kinematic-model-of-human-hand-A.png))

Opening one random grasp shows us that it is tabular data, but what are the columns? They are described in the downloaded folder of the HUST dataset:

```python
hust_columns = [
    "TIME",
    "T_CMC",
    "T_ABD",
    "T_MCP",
    "T_IP",
    "I_MCP",
    "I_PIP",
    "I_DIP",
    "M_MCP",
    "M_PIP",
    "M_DIP",
    "R_MCP",
    "R_PIP",
    "R_DIP",
    "L_MCP",
    "L_PIP",
    "L_DIP"
]
```

![Screenshot from 2019-01-08 16-10-49.png]({{site.baseurl}}/images/Screenshot from 2019-01-08 16-10-49.png)

### Convert data

The next step is to convert one file of joint angles from the data glove to a MMM motion file.
There is a command line tool which will do this for us. It is going to place the reference figure into the center of a room, load a hand model and then convert the hand configurations.

The command is called **MMMDataGloveConverter**. Read more about it [here](https://mmm.humanoids.kit.edu/commandlinetools.html#mmmdatagloveconverter).

It has the following prerequisites:

- A configuration file which maps joint angles to the MMM figure
- A CSV containing one hand configuration per row

Let's work on these two steps now.

#### Configuration file

There is a sample for a configuration file. 

`less ~/MMMTools/data/DataGloveConverterRightHandWithoutDIP2MMMConfig.xml`

```
<?xml version='1.0' encoding='UTF-8'?>
<DataGloveConverterConfig>
        <DataGloveFileConfig separator="," hasHeader="false"/>
        <Timestep type="ByIndex" value="1"/>
        <!-- <Timestep type="ByDelta" value="0.5"/> if no time is available in the file a delta can be specified -->
        <FingerMapping>
                <Mapping index="2" jointName="RightFingerJoint11z_joint" description="Thumb rotation" multiplyBy="-1.0"/>
                ...
                <Mapping index="21" jointName="RightFingerJoint51x_joint" description="Pinkie abd"/>
        </FingerMapping>
</DataGloveConverterConfig>
```

The fingers are enumerated from left to right: 1=thumb, 5=pinkie.
"index" enumerates the columns of our motion csv.
For the given dataset we have to adjust the config file. If you are using the HUST dataset you can use the following file:

```
<?xml version='1.0' encoding='UTF-8'?>
<DataGloveConverterConfig>
        <DataGloveFileConfig separator="," hasHeader="false"/>
        <Timestep type="ByIndex" value="1"/>
        <!-- <Timestep type="ByDelta" value="0.5"/> if no time is available in the file a delta can be specified -->
        <FingerMapping>
                <Mapping index="1" jointName="RightFingerJoint11z_joint" description="Thumb rotation" multiplyBy="1.0"/>
                <Mapping index="3" jointName="RightFingerJoint12y_joint" description="Thumb mp" multiplyBy="1.0"/>
                <Mapping index="4" jointName="RightFingerJoint13y_joint" description="Thumb ip" multiplyBy="1.0"/>
                <Mapping index="2" jointName="RightFingerJoint11y_joint" description="Thumb abd"/>
                <Mapping index="5" jointName="RightFingerJoint21y_joint" description="Index mp" multiplyBy="1.0"/>
                <Mapping index="6" jointName="RightFingerJoint22y_joint" description="Index pip" multiplyBy="1.0"/>
                <Mapping index="7" jointName="RightFingerJoint23y_joint" description="Index dip" multiplyBy="1.0"/>
                <Mapping index="7" jointName="RightFingerJoint21x_joint" description="Index abd (0)" multiplyBy="0.0"/>
                <Mapping index="8" jointName="RightFingerJoint31y_joint" description="Middle mp" multiplyBy="1.0"/>
                <Mapping index="9" jointName="RightFingerJoint32y_joint" description="Middle pip" multiplyBy="1.0"/>
                <Mapping index="10" jointName="RightFingerJoint33y_joint" description="Middle dip" multiplyBy="1.0"/>
                <Mapping index="10" jointName="RightFingerJoint31x_joint" description="Middle abd (0)" multiplyBy="0.0"/>
                <Mapping index="11" jointName="RightFingerJoint41y_joint" description="Ring mp" multiplyBy="1.0"/>
                <Mapping index="12" jointName="RightFingerJoint42y_joint" description="Ring pip" multiplyBy="1.0"/>
                <Mapping index="13" jointName="RightFingerJoint43y_joint" description="Ring dip" multiplyBy="1.0"/>
                <Mapping index="13" jointName="RightFingerJoint41x_joint" description="Ring abd (0)" multiplyBy="0.0"/>
                <Mapping index="14" jointName="RightFingerJoint51y_joint" description="Pinkie mp" multiplyBy="1.0"/>
                <Mapping index="15" jointName="RightFingerJoint52y_joint" description="Pinkie pip" multiplyBy="1.0"/>
                <Mapping index="16" jointName="RightFingerJoint53y_joint" description="Pinkie dip" multiplyBy="1.0"/>
                <Mapping index="16" jointName="RightFingerJoint51x_joint" description="Pinkie abd (0)" multiplyBy="0.0"/>
        </FingerMapping>
</DataGloveConverterConfig>
```

#### Preprocess CSV file


Replace "\t" seperation of HUST by commas and remove the last empty row.

I wrote the following small script for that although I guess that this could be done far more elegant with sed.

```python
# convert_hust_for_mmm.py

import sys

print("Replace tabs by commas and remove last column")
file_in = sys.argv[1]
file_out = sys.argv[2]

print("{} => {}".format(file_in, file_out))

with open(file_in, "r") as inp:
	output = ""
	for lc, line in enumerate(inp.read().split("\n")):
		if lc > 0:
			output += "\n"
		output += line.replace("\t", ",")[:-2] # replace tabs and remove the last character
	
	with open(file_out, "w") as out:
		out.write(output)
```

Then I can call: `python convert_hust_for_mmm.py grasp.txt grasp.csv`

![Screenshot from 2019-01-08 16-26-21.png]({{site.baseurl}}/images/Screenshot from 2019-01-08 16-26-21.png)


#### Run the converter

Now call the MMMDataGloveConverter:

`~/MMMTools/build/bin/MMMDataGloveConverter --config "DataGloveConfigConverterHUST.xml" --data "5.csv" --mode test`

Notes:

- Use the config file I have shown above
- You have to add the "--mode test" or else it won't work
 
 ![Screenshot from 2019-01-08 16-27-27.png]({{site.baseurl}}/images/Screenshot from 2019-01-08 16-27-27.png)


### Play and record

Now start the MMMViewer: `~/MMMTools/build/bin/MMMViewer`!
Within the program open the file generated by the MMMDataGloveConverter which is called "MMMDataGloveConverter_output.xml"
and press play.

![Screenshot from 2019-01-08 16-29-52.png]({{site.baseurl}}/images/Screenshot from 2019-01-08 16-29-52.png)


#### Record a gif

Unfortunately the program can only export an image sequence so we have to generate a gif from that on our own.
I wrote the following python script to do this for me (it also adds a pause between the loops) and compresses the file size.

```python

from subprocess import call
import sys
import os


# the folder which contains the image sequence
folder = sys.argv[1]
print("work in folder: {}".format(folder))

# Configs
delay_between_frames = 5
pause_between_loops = 300
export_name = os.path.join(folder, 'animated.gif')
export_name_with_pause = os.path.join(folder, 'animated_with_pause.gif')
export_name_minimized = os.path.join(folder, 'animated_minimized.gif')

# get all files from that folder
filelist = os.listdir(folder)
new_filelist = {}

# example filenames: ls | sort -n or sort -V (=> none of them work sufficiently)
# 
# MMMViewerWindow_0.png
# MMMViewerWindow_0.5.png
# MMMViewerWindow_0.26699999.png
# MMMViewerWindow_0.73299998.png
# ...
# MMMViewerWindow_0.967000008.png
# MMMViewerWindow_1.png

for file_ in filelist:
    # only process png
    if not file_.endswith('.png'):
        continue

    # try to parse a float from the name 
    try:
        float_string = file_.lstrip("MMMViewerWindow_").rstrip(".png")
	float_ = float(float_string)
    except:  
        continue

    # float -> filename
    new_filelist[float_] = file_

# sort the keys and then the filenames by keys
sorted_keys = sorted(new_filelist)
sorted_list = [new_filelist[key] for key in sorted_keys]

# build the imagemagick command which we use for .gif creation
command = ['convert', '-delay', str(delay_between_frames)] + map(lambda n: os.path.join(folder, n), sorted_list) + [export_name]

# build the gif -> animated.gif
print("Create GIF")
error_code = call(command)

if error_code != 0:
    print("error code {}".format(error_code))
    quit()


# build edit command for the gif
command_pause = "convert {} \( +clone -set delay {} \) +swap +delete  {}".format(export_name, pause_between_loops, export_name_with_pause)

# add pause
print("Add pause to GIF")
error_code = os.system(command_pause)

if error_code != 0:
    print("error code {}".format(error_code))
    quit()

# build edit command for the gif
command_pause = "convert {} -coalesce -resize 700x525 -fuzz 2% +dither -layers Optimize +map {}".format(export_name_with_pause, export_name_minimized)

# build the gif -> animated.gif
print("Minimize GIF")
error_code = os.system(command_pause)

if error_code != 0:
    print("error code {}".format(error_code))
    quit()

print("Success")

```

Now calling `python create_gif.py grasp1` results in three gifs in the specified folder grasp1.

- A full sized grasp gif
- A full sized grasp gif with pause between loops
- And a minimized version with pause

![anim_closeup.gif]({{site.baseurl}}/images/anim_closeup.gif)
