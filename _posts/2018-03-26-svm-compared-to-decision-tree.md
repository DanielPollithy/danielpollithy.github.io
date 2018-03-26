---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: SVM compared to Decision Tree
description: ''
headline: ''
modified: ''
tags: ''
imagefeature: ''
---
## Support Vector Machine compared to Decision Tree

I have got a small data set (my working hours as a working student) on which I want to train a binary classifier. My regular days in the office changed depending on the lectures I attended.

## Cleaning the data set

![Screenshot from 2018-03-09 22-16-32.png]({{site.baseurl}}/images/Screenshot from 2018-03-09 22-16-32.png)

The data set contains one row for every work day. The row contains every necessary information in German: 
"Donnerstag, 8. Juni (9:00 - 18:00) -> 8h (1h Mittag): Shop system"

So I wrote a function which generates every weekday, day and year for a given time frame `get_dates_table(start_date, end_date)` and two functions that can generate the training data and the test data. The test data generates two years and the training data one year. The design matrix of each of them looks like this:

<center>
  
| weekday       | day           | month | label |
| ------------- | ------------- | ----- | -----:|
| 5             | 1             | 3     | 0     |
| 6             | 2             | 3     | 1     |
| 7             | 3             | 3     | 1     |
| 1             | 4             | 3     | 1     |

</center>









## Decision tree

![ID3_algorithm_decision_tree.png]({{site.baseurl}}/images/ID3_algorithm_decision_tree.png)

By Acoggins38 (Own work) [CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0)], via Wikimedia Commons

A decision tree is the output of algorithms that find the most discriminating features and value borders for them. The tree can then be used like a search tree with the difference that the leaf names to which class the data belongs to.


