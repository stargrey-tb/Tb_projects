import torch
import torchvision
import numpy as np
import pickle
from torch.utils.data import DataLoader, Dataset
from torchvision.datasets import FashionMNIST
from torch.nn import Linear, Conv2d, ReLU, Sigmoid, MaxPool2d, CrossEntropyLoss
from torch.optim import SGD
from utils import part4Plots, part1CreateDataset, part1PlotBoundary

# Define custom dataset class to enable shuffling for each epoch
class ShuffledDataset(Dataset):
    def __init__(self, dataset):
        self.dataset = dataset

    def __getitem__(self, index):
        return self.dataset[index]

    def __len__(self):
        return len(self.dataset)

    def shuffle(self):
        indices = torch.randperm(len(self.dataset))
        self.dataset.data = self.dataset.data[indices]
        self.dataset.targets = self.dataset.targets[indices]

# Define the architectures with ReLU and Sigmoid activations
class ReLU_MLP1(torch.nn.Module):
    def __init__(self):
        super(ReLU_MLP1, self).__init__()
        self.fc1 = torch.nn.Linear(784, 32)
        self.relu = torch.nn.ReLU()
        self.fc2 = torch.nn.Linear(32, 10)
        
    def forward(self, x):
        x = x.view(-1, 784)
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        return x

class Sigmoid_MLP1(torch.nn.Module):
    def __init__(self):
        super(Sigmoid_MLP1, self).__init__()
        self.fc1 = torch.nn.Linear(784, 32)
        self.sigmoid = torch.nn.Sigmoid()
        self.fc2 = torch.nn.Linear(32, 10)
        
    def forward(self, x):
        x = x.view(-1, 784)
        x = self.sigmoid(self.fc1(x))
        x = self.fc2(x)
        return x

# Define data transformation
transform = torchvision.transforms.ToTensor()

# Load FashionMNIST dataset
train_data = FashionMNIST('./data', train=True, download=True, transform=transform)
train_data_shuffled = ShuffledDataset(train_data)
train_loader = DataLoader(train_data_shuffled, batch_size=50, shuffle=False)

# Define training parameters
epochs = 15
learning_rate = 0.01

# Initialize models and optimizers
relu_model = ReLU_MLP1()
sigmoid_model = Sigmoid_MLP1()
relu_optimizer = SGD(relu_model.parameters(), lr=learning_rate, momentum=0.0)
sigmoid_optimizer = SGD(sigmoid_model.parameters(), lr=learning_rate, momentum=0.0)
loss_fn = CrossEntropyLoss()

# Lists to store loss and gradient magnitude curves
relu_loss_curve = []
sigmoid_loss_curve_value = []
relu_gradient_magnitude_curve = []
sigmoid_gradient_magnitude_curve = []

# Training loop
for epoch in range(epochs):
    # Shuffle the training set
    train_data_shuffled.shuffle()
    
    # Training with ReLU model
    relu_model.train()
    for i, (images, labels) in enumerate(train_loader):
        relu_optimizer.zero_grad()
        outputs = relu_model(images)
        loss = loss_fn(outputs, labels)
        loss.backward()
        relu_optimizer.step()
        
        # Record loss at every 10 steps
        if (i + 1) % 10 == 0:
            relu_loss_curve.append(loss.item())
            print(f"ReLU - Epoch {epoch+1}/{epochs}, Step {i+1}/{len(train_loader)}")
        
        # Record gradient magnitude at every 10 steps
        if (i + 1) % 10 == 0:
            gradient_magnitude = torch.norm(relu_model.fc1.weight.grad).item()
            relu_gradient_magnitude_curve.append(gradient_magnitude)
    
    # Training with Sigmoid model
    sigmoid_model.train()  # Indentation fixed here
    for i, (images, labels) in enumerate(train_loader):
        sigmoid_optimizer.zero_grad()
        outputs = sigmoid_model(images)
        loss = loss_fn(outputs, labels)
        loss.backward()
        sigmoid_optimizer.step()
        
        # Initialize lists to store loss and gradient magnitude curves
        if epoch == 0 and i == 0:
            sigmoid_loss_curve_value = []
            sigmoid_gradient_magnitude_curve = []
        
        # Record loss at every 10 steps
        if (i + 1) % 10 == 0:
            sigmoid_loss_curve_value.append(loss.item())
            print(f"Sigmoid - Epoch {epoch+1}/{epochs}, Step {i+1}/{len(train_loader)}")
        
        # Record gradient magnitude at every 10 steps
        if (i + 1) % 10 == 0:
            gradient_magnitude = torch.norm(sigmoid_model.fc1.weight.grad).item()
            sigmoid_gradient_magnitude_curve.append(gradient_magnitude)



# Save the recorded curves
curves_data = {
    'relu_loss_curve': relu_loss_curve,
    'sigmoid_loss_curve': sigmoid_loss_curve_value,
    'relu_gradient_magnitude_curve': relu_gradient_magnitude_curve,
    'sigmoid_gradient_magnitude_curve': sigmoid_gradient_magnitude_curve
}

with open('part4_curves.pkl', 'wb') as f:
    pickle.dump(curves_data, f)

# Define results dictionaries for part4Plots function
relu_results = {
    'name': 'ReLU',
    'relu_loss_curve': relu_loss_curve,
    'sigmoid_loss_curve': [],
    'relu_grad_curve': relu_gradient_magnitude_curve,
    'sigmoid_grad_curve': []
}

sigmoid_results = {
    'name': 'Sigmoid',
    'relu_loss_curve': [],
    'sigmoid_loss_curve': sigmoid_loss_curve_value,
    'relu_grad_curve': [],
    'sigmoid_grad_curve': sigmoid_gradient_magnitude_curve
}

# Call part4Plots function to create performance comparison plots
part4Plots([relu_results, sigmoid_results], save_dir="C:/EE_449", filename='performance_comparison', show_plot=True)
