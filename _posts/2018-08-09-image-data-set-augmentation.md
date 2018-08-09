---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: Image data set augmentation
categories:
  - personal
  - keras
  - cnn
---
## Transform images to increase the size of the GTSRB dataset

My GTSRB Keras CNN is overfitting its training data. I know that because the accuracy on the training data ist above 98% but the accuracy on the test data was 84% on its best run.

Before I balanced the classes of the data set the test accuracy was even lower at 80%. Adding L2 regularization to the last dense layer added 1%. 

The remaining gap is still more than 10% so I tried other regularization strategies. Increasing the batch_size did not help. Doubling the size of the images also had no great effect.

But I kept the best option for images for the end: Data set augmentation.
The idea is to transform the images randomly (shifting the pixels, rotating, zooming...). This is intuitively a really important building block in the training pipeline in order to avoid that the model find "too simple" methods like checking whether a pixel at an exact position is white. Although the convolutional layers and pooling layers already help a little bit here.

## Code

I am using the same Keras code as in my last blog entries for the exact same dataset.

Now I only have to add a ImageDataGenerator:

```python

from keras.preprocessing.image import ImageDataGenerator

datagen = ImageDataGenerator(
    #featurewise_center=True,
    #featurewise_std_normalization=True,
    
    #samplewise_center=True,
    #samplewise_std_normalization=True,
    
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    horizontal_flip=False,
    zoom_range=0.2,
    shear_range=15
)

# compute quantities required for featurewise normalization
# (std, mean, and principal components if ZCA whitening is applied)
datagen.fit(X_balanced)

```

And replace the training control:

```python

%matplotlib inline

from keras.callbacks import LearningRateScheduler, ModelCheckpoint

def lr_schedule(epoch):
    return lr * (0.1 ** int(epoch / epochs))

epochs = 10
batch_size = 32

# here's a more "manual" example
for e in range(epochs):
    print('Epoch', e)
    batches = 0
    for x_batch, y_batch in datagen.flow(X_balanced, Y_balanced, batch_size=batch_size):
        verbose = batches % 1000 == 0
        
        # show some images
        if verbose:
          for i in range (0, batch_size):
            image = x_batch[i]
            plt.imshow(image)
            plt.show()
        
        model.fit(x_batch, y_batch, verbose=verbose,
                      callbacks=[LearningRateScheduler(lr_schedule), 
                                 ModelCheckpoint('model.h5', save_best_only=True)])
        batches += 1
        if batches >= len(X_balanced) / epochs:
            # we need to break the loop by hand because the generator loops indefinitely
            break
```

![Screenshot from 2018-08-09 11-48-47.png]({{site.baseurl}}/images/Screenshot from 2018-08-09 11-48-47.png)

The transformed images are classifiable but it is getting harder... Let's whether this has an impact on the generalization error.

I can already tell that the training takes a lot longer, that could be because the ImageDataGenerator works on the CPU.

## Result 

The training took 40 minutes instead of 5. And the training accuracy went down over time...

![Training accuracy.png]({{site.baseurl}}/images/Training accuracy.png)

And the test accuracy was a little bit lower 84,4% instead of 84,8% (without augmentation).

I fixed the learning rate to 0.1 now. No exponential decay. The next step is to be able to get a high training accuracy to see whether we can get the network to overfit the data generating function again...

I manually early stopped the training with loss: 0.8872 - acc: 0.9688.

And the test accuracy got boosted a lot:

Test accuracy = 0.9583531274742676. That's a plus of 10%.

That is really impressing. I am going to upload this new model into my tensorflow.js application.

![Screenshot from 2018-08-09 14-43-06.png]({{site.baseurl}}/images/Screenshot from 2018-08-09 14-43-06.png)

(I can upload a badly cropped and skewed image and it gets recognized. Wow!)

Next steps could be:

- The colors of the images have to be normalized
- Some of the signs are partially hidden or have a post in front of them
- A better adaptive learning rate might be a good idea. I should evaluate different optimizers
