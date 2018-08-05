---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: tensorflow.js
---
## Using tensorflow.js to run a Keras model in browser


`!pip install tensorflowjs`


```python
import tensorflowjs as tfjs
import shutil

model_dir = 'tfjs'
model_zip = 'keras_model.zip'


if not os.path.exists(model_dir):
  os.mkdir(model_dir)
tfjs.converters.save_keras_model(model, model_dir)

def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))

os.remove(model_zip)
            
with zipfile.ZipFile(model_zip, 'w') as zipf:
    zipdir(model_dir, zipf)
    zipf.close()
    
from google.colab import files
files.download(model_zip) 
```



https://js.tensorflow.org/tutorials/import-keras.html


https://js.tensorflow.org/tutorials/webcam-transfer-learning.html
