import torch
import torchvision
import numpy as np
import pickle
import os
import matplotlib.pyplot as plt
from torch.utils.data import DataLoader, Dataset
from torchvision.datasets import FashionMNIST
from torch.nn import Linear, ReLU, CrossEntropyLoss
from torch.optim import SGD
from sklearn.model_selection import train_test_split
from utils import part5Plots

# Define custom dataset class to enable shuffling for each epoch
class ShuffledDataset(Dataset):
    def __init__(self, dataset):
        self.dataset = dataset
        self.indices = list(range(len(dataset)))

    def __getitem__(self, index):
        return self.dataset[self.indices[index]]

    def __len__(self):
        return len(self.dataset)

    def shuffle(self):
        np.random.shuffle(self.indices)

# Define the architecture 'mlp 2'
class MLP2(torch.nn.Module):
    def __init__(self):
        super(MLP2, self).__init__()
        self.fc1 = torch.nn.Linear(784, 32)
        self.relu = torch.nn.ReLU()
        self.fc2 = torch.nn.Linear(32, 64, bias=False)
        self.prediction_layer = torch.nn.Linear(64, 10)
 
        
    def forward(self, x):
        x = x.view(-1, 784)
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        x = self.prediction_layer(x)
        return x

# Define data transformation
transform = torchvision.transforms.ToTensor()

# Load FashionMNIST dataset
train_data = FashionMNIST('./data', train=True, download=True, transform=transform)

# Split data into training, validation, and testing sets
train_data, val_data = train_test_split(train_data, test_size=0.1, stratify=train_data.targets)

# Define data loaders
train_loader = DataLoader(ShuffledDataset(train_data), batch_size=50, shuffle=False)  # Shuffle will be handled by ShuffledDataset
val_loader = DataLoader(val_data, batch_size=50, shuffle=False)

# Define training parameters
epochs = 20
learning_rates = [0.1, 0.01, 0.001]
start=0
# Define the architectures with different initial learning rates
models = []
for lr in learning_rates:
    model = MLP2()
    model_dict = {'name': f'mlp2_lr_{lr}', 
                  'loss_curve_1': [], 'loss_curve_01': [], 'loss_curve_001': [],
                  'val_acc_curve_1': [], 'val_acc_curve_01': [], 'val_acc_curve_001': []}
    models.append(model_dict)

# Training loop for each model
for model_dict in models:
    model_name = model_dict['name']
    lr = float(model_name.split('_')[-1])
    model = MLP2()
    
    # Initialize optimizer
    optimizer = SGD(model.parameters(), lr=lr, momentum=0.0)
    
    # Variables to track the epoch step where validation accuracy stops increasing
    max_val_acc_epoch = 0
    prev_val_acc = 0.0
    
    for epoch in range(epochs):
        # Shuffle the training set
        train_loader.dataset.shuffle()
        
        # Training
        model.train()
        for i, (images, labels) in enumerate(train_loader):
            optimizer.zero_grad()
            outputs = model(images)
            loss = CrossEntropyLoss()(outputs, labels)
            loss.backward()
            optimizer.step()
            
            # Record training loss
            model_dict['loss_curve_1'].append(loss.item())
                
            # Record validation accuracy every 10 steps
            if (i + 1) % 10 == 0:
                model.eval()
                correct = 0
                total = 0
                with torch.no_grad():
                    for images, labels in val_loader:
                        outputs = model(images)
                        _, predicted = torch.max(outputs.data, 1)
                        total += labels.size(0)
                        correct += (predicted == labels).sum().item()
                val_acc = correct / total
                
                # Record validation accuracy
                model_dict['val_acc_curve_1'].append(val_acc)
                
                # Check if validation accuracy stops increasing
                if val_acc <= prev_val_acc:
                    max_val_acc_epoch = epoch
                    break  # Stop training if validation accuracy stops increasing
                else:
                    prev_val_acc = val_acc
            
                # Print epoch and step every 10 steps
                print(f"Epoch {epoch + 1}/{epochs}, Step {i + 1}/{len(train_loader)}")

        # Stop training if validation accuracy stops increasing
        if max_val_acc_epoch > 0:
            
            break
        part5Plots(model_dict, save_dir="C:/EE_449", filename='performance_comparison_q5_1', show_plot=True)
   
    # Change learning rate to 0.01 and continue training until 30 epochs
    if lr == 0.1:
        # Initialize new optimizer with learning rate 0.01
        
        optimizer = SGD(model.parameters(), lr=0.01, momentum=0.0)
        
        # Continue training until 30 epochs
        for epoch in range(max_val_acc_epoch, max_val_acc_epoch + 29):
            # Shuffle the training set
            train_loader.dataset.shuffle()
            
            # Training
            model.train()
            for i, (images, labels) in enumerate(train_loader):
                optimizer.zero_grad()
                outputs = model(images)
                loss = CrossEntropyLoss()(outputs, labels)
                loss.backward()
                optimizer.step()
                
                model_dict['loss_curve_01'].append(loss.item()) 
                # Record validation accuracy every 10 steps
                if (i + 1) % 10 == 0:
                    model.eval()
                    correct = 0
                    total = 0
                    with torch.no_grad():
                        for images, labels in val_loader:
                            outputs = model(images)
                            _, predicted = torch.max(outputs.data, 1)
                            total += labels.size(0)
                            correct += (predicted == labels).sum().item()
                    val_acc = correct / total
                    
                    # Record validation accuracy
                    model_dict['val_acc_curve_01'].append(val_acc) 
                    
                    # Print epoch and step every 10 steps
                    print(f"Epoch {epoch + 1}/{max_val_acc_epoch + 1}, Step {i + 1}/{len(train_loader)}")
    
        part5Plots(model_dict, save_dir="C:/EE_449", filename='performance_comparison_q5_01', show_plot=True)
    
    # Change learning rate to 0.001 and continue training until 30 epochs
    if lr == 0.01:
        # Initialize new optimizer with learning rate 0.001
        
          
        optimizer = SGD(model.parameters(), lr=0.001, momentum=0.0)

        # Continue training until 30 epochs
        for epoch in range(max_val_acc_epoch, max_val_acc_epoch + 29):
            # Shuffle the training set
            train_loader.dataset.shuffle()
            
            # Training
            model.train()
            for i, (images, labels) in enumerate(train_loader):
                optimizer.zero_grad()
                outputs = model(images)
                loss = CrossEntropyLoss()(outputs, labels)
                loss.backward()
                optimizer.step()
                
                model_dict['loss_curve_001'].append(loss.item()) 
                # Record validation accuracy every 10 steps
                if (i + 1) % 10 == 0:
                    model.eval()
                    correct = 0
                    total = 0
                    with torch.no_grad():
                        for images, labels in val_loader:
                            outputs = model(images)
                            _, predicted = torch.max(outputs.data, 1)
                            total += labels.size(0)
                            correct += (predicted == labels).sum().item()
                    val_acc = correct / total
                    
                    # Record validation accuracy
                    model_dict['val_acc_curve_001'].append(val_acc)
                    
                    # Print epoch and step every 10 steps
                    print(f"Epoch {epoch + 1}/{max_val_acc_epoch + 1}, Step {i + 1}/{len(train_loader)}")
        part5Plots(model_dict, save_dir="C:/EE_449", filename='performance_comparison_q5_001', show_plot=True)                          
    # Record the test accuracy of the trained model
    model.eval()
    correct = 0
    total = 0
    with torch.no_grad():
        for images, labels in val_loader:
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    test_acc = correct / total
      
    print(f"Test accuracy for model {model_name}: {test_acc}")
    
    
    
# Save the recorded curves
with open('part5_curves.pkl', 'wb') as f:
    pickle.dump(models, f)
    
part5Plots(model_dict, save_dir="C:/EE_449", filename='performance_comparison_q5_all', show_plot=True)