# Tensorflow Note

## Question

1. activation function selection: sigmoid, softmax, relu
2. L1 regularization, L2 regularization

## Process

1. Generalization
2. build a model
3. Train, evaluate and predict

## Keras

[Trains a simple deep NN on the MNIST dataset](https://github.com/keras-team/keras/blob/master/examples/mnist_mlp.py)

1. 数据集获取 `mnist.load_data()`
2. 定义模型 `model = Sequential()`
3. 模型评估 `model.compile(loss='categorical_crossentropy', optimizer=RMSprop(), metrics=['accuracy']) # 评估指标`
4. 训练模型 `history = model.fit(x_train, y_train, batch_size=100, epochs=20, verbose=1, validation_data=(x_test, y_test))`
    `score = model.evaluate(x_test, y_test, verbose=0)`

## Install

### [Install by conda]

`conda create --name tf1.14 python=3.6 tensorflow==1.14.0 keras==2.2.4`
`conda create --name tf2.0 python=3.6 tensorflow==2.0.0 keras==2.2.4`

### [Install](https://www.tensorflow.org/install/pip#1-install-the-python-development-environment-on-your-system)

Create a new virtual environment by choosing a Python interpreter and making a ./venv directory to hold it:
`virtualenv --system-site-packages -p python3 ~/venv`
`source ~/venv/bin/activate  # sh, bash, ksh, or zsh` Activate the virtual environment

Install packages within a virtual environment without affecting the host system setup. Start by upgrading pip:
`pip install --upgrade pip`
`pip list  # show packages installed within the virtual environment`

And to exit virtualenv later:
`deactivate  # don't exit until you're done using TensorFlow`

Virtualenv install: `pip install --upgrade tensorflow` or `pip install tensorflow==2.0.0-beta1`
Verify the install: `python3 -c "import tensorflow as tf; tf.enable_eager_execution(); print(tf.reduce_sum(tf.random_normal([1000, 1000])))"`

`pip install tensorflow==1.14.0`
`pip install keras==2.2.4-tf`

## Machine Learning Crash Course

### Terminology

#### Labels

A label is the thing we're predicting—the y variable in simple linear regression. The label could be the future price of wheat, the kind of animal shown in a picture, the meaning of an audio clip, or just about anything.

#### Features

A feature is an input variable—the x variable in simple linear regression. A simple machine learning project might use a single feature, while a more sophisticated machine learning project could use millions of features

#### Regression

A regression model predicts continuous values. For example, regression models make predictions that answer questions like the following:

    What is the value of a house in California?

    What is the probability that a user will click on this ad?

#### classification

A classification model predicts discrete values. For example, classification models make predictions that answer questions like the following:

    Is a given email message spam or not spam?

    Is this an image of a dog, a cat, or a hamster?

### Descending into ML: Linear Regression

`y = b + wx`

where:

`y` is the predicted label (a desired output).
`b` is the bias (the y-intercept)
`w` is the weight of feature 1. Weight is the same concept as the "slope" in the traditional equation of a line.
`x` is a feature (a known input).

### First Steps with TensorFlow: Toolkit

    ```python
    import tensorflow as tf

    # Set up a linear classifier.
    classifier = tf.estimator.LinearClassifier(feature_columns)

    # Train the model on some example data.
    classifier.train(input_fn=train_input_fn, steps=2000)

    # Use it to predict.
    predictions = classifier.predict(input_fn=predict_input_fn)
    ```

### Generalization: Peril of Overfitting

#### The ML fine print

The following three basic assumptions guide generalization:

    We draw examples independently and identically (i.i.d) at random from the distribution. In other words, examples don't influence each other. (An alternate explanation: i.i.d. is a way of referring to the randomness of variables.)
    The distribution is stationary; that is the distribution doesn't change within the data set.
    We draw examples from partitions from the same distribution.

In practice, we sometimes violate these assumptions. For example:

    Consider a model that chooses ads to display. The i.i.d. assumption would be violated if the model bases its choice of ads, in part, on what ads the user has previously seen.
    Consider a data set that contains retail sales information for a year. User's purchases change seasonally, which would violate stationarity.

When we know that any of the preceding three basic assumptions are violated, we must pay careful attention to metrics.

### Representation: Cleaning Data

#### Scaling feature values

Scaling means converting floating-point feature values from their natural range (for example, 100 to 900) into a standard range (for example, 0 to 1 or -1 to +1)

#### Handling extreme outliers

[bin boundaries](https://developers.google.cn/machine-learning/crash-course/representation/cleaning-data)
[bucketing](https://developers.google.cn/machine-learning/glossary/#bucketing)
 Converting a (usually continuous) feature into multiple binary features called buckets or bins, typically based on value range
