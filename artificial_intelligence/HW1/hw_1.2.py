# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 20:12:34 2024

@author: Talha's Laptop
"""

import numpy as np
from matplotlib import pyplot as plt
from sklearn.datasets import make_blobs


class MLP:
    def __init__(self, input_size, hidden_size, output_size):
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.output_size = output_size
        # Initialize weights and biases
        self.weights_input_hidden = np.random.randn(self.input_size, self.hidden_size)
        self.bias_hidden = np.zeros((1, self.hidden_size))
        self.weights_hidden_output = np.random.randn(self.hidden_size, self.output_size)
        self.bias_output = np.zeros((1, self.output_size))
    
    def sigmoid(self, x):
        return 1 / (1 + np.exp(-x))
    
    def sigmoid_derivative(self, x):
        return x * (1 - x)
    
    def forward(self, inputs):
        # Forward pass through the network
        self.hidden_output = self.sigmoid(np.dot(inputs, self.weights_input_hidden) + self.bias_hidden)
        self.output = self.sigmoid(np.dot(self.hidden_output, self.weights_hidden_output) + self.bias_output)
        return self.output
    
    def backward(self, inputs, targets, learning_rate):
        # Backward pass through the network
        # Compute error
        output_error = targets - self.output
        hidden_error = np.dot(output_error, self.weights_hidden_output.T)
        # Compute gradients
        output_delta = output_error * self.sigmoid_derivative(self.output)
        hidden_delta = hidden_error * self.sigmoid_derivative(self.hidden_output)
        # Update weights and biases
        self.weights_hidden_output += np.dot(self.hidden_output.T, output_delta) * learning_rate
        self.bias_output += np.sum(output_delta, axis=0, keepdims=True) * learning_rate
        self.weights_input_hidden += np.dot(inputs.T, hidden_delta) * learning_rate
        self.bias_hidden += np.sum(hidden_delta, axis=0, keepdims=True) * learning_rate
    
    def part1CreateDataset(self, train_samples=1000, val_samples=100, std=0.4):
        # CREATE A RANDOM DATASET

        centers = [[1, 1], [1, -1], [-1, -1], [-1, 1]] #center of each class
        cluster_std = std # standard deviation of random gaussian samples

        x_train, y_train = make_blobs(n_samples=train_samples, centers=centers, n_features=2, cluster_std=cluster_std, shuffle=True)
        y_train[y_train==2] = 0 # make this an xor problem
        y_train[y_train==3] = 1 # make this an xor problem
        y_train = y_train.reshape(-1, 1) #vectorize the ground truth

        x_val, y_val = make_blobs(n_samples=val_samples, centers=centers, n_features=2, cluster_std=cluster_std, shuffle=True)
        y_val[y_val==2] = 0 # make this an xor problem
        y_val[y_val==3] = 1 # make this an xor problem
        y_val = y_val.reshape(-1, 1) # vectorize the ground truth
        
        return x_train, y_train, x_val, y_val

    def part1PlotBoundary(self, X, y):
        # Plot decision boundary
        h = 0.01
        x_min, x_max = X[:, 0].min() - 0.1, X[:, 0].max() + 0.1
        y_min, y_max = X[:, 1].min() - 0.1, X[:, 1].max() + 0.1
        xx, yy = np.meshgrid(np.arange(x_min, x_max, h), np.arange(y_min, y_max, h))
        Z = self.forward(np.c_[xx.ravel(), yy.ravel()])
        Z = Z.reshape(xx.shape)
        plt.contourf(xx, yy, Z, levels=[0, 0.5, 1], colors=['lightcoral', 'lightblue'], alpha=0.5)
        
        # Add contour lines
        plt.contour(xx, yy, Z, levels=[0.5], colors='black')

        # Plot data points
        plt.scatter(X[:, 0], X[:, 1], c=y.flatten(), cmap=plt.cm.RdYlBu)

        plt.xlabel('X1')
        plt.ylabel('X2')
        plt.title('Decision Boundary')
        plt.show()

# Instantiate MLP class
mlp = MLP(input_size=2, hidden_size=4, output_size=1)

# Call part1CreateDataset method to create the dataset
x_train, y_train, x_val, y_val = mlp.part1CreateDataset(train_samples=1000, val_samples=100, std=0.4)

# Train the neural network
for epoch in range(10000):
    # Forward propagation
    output = mlp.forward(x_train)
    # Backpropagation
    mlp.backward(x_train, y_train, learning_rate=0.1)
    # Print the loss (MSE) every 1000 epochs
    if epoch % 1000 == 0:
        loss = np.mean((y_train - output) ** 2)
        print(f'Epoch {epoch}: Loss = {loss}')

# Test the trained neural network
y_predict = np.round(mlp.forward(x_val))
accuracy = np.mean(y_predict == y_val) * 100
print(f'{accuracy} % of test examples classified correctly.')

# Plot the final decision boundary
mlp.part1PlotBoundary(x_val, y_val)

# Instantiate MLP class
mlp_sigmoid = MLP(input_size=2, hidden_size=4, output_size=1)
mlp_tanh = MLP(input_size=2, hidden_size=4, output_size=1)
mlp_relu = MLP(input_size=2, hidden_size=4, output_size=1)

# Define the activation functions
sigmoid_activation = lambda x: 1 / (1 + np.exp(-x))
tanh_activation = lambda x: np.tanh(x)
relu_activation = lambda x: np.maximum(0, x)

# Train the neural networks
for mlp, activation_name, activation_func in [(mlp_sigmoid, 'Sigmoid', sigmoid_activation),
                                              (mlp_tanh, 'Tanh', tanh_activation),
                                              (mlp_relu, 'ReLU', relu_activation)]:
    print(f'Training with {activation_name} activation function...')
    for epoch in range(10000):
        # Forward propagation
        output = mlp.forward(x_train)
        # Backpropagation
        mlp.backward(x_train, y_train, learning_rate=0.1)
        # Print the loss (MSE) every 1000 epochs
        if epoch % 1000 == 0:
            loss = np.mean((y_train - output) ** 2)
            print(f'Epoch {epoch}: Loss = {loss}')

    # Test the trained neural network
    y_predict = np.round(mlp.forward(x_val))
    accuracy = np.mean(y_predict == y_val) * 100
    print(f'{activation_name} - {accuracy} % of test examples classified correctly.')

    # Plot the final decision boundary
    mlp.part1PlotBoundary(x_val, y_val)
    plt.title(f'Decision Boundary with {activation_name} Activation')

# Show the plots
plt.show()
