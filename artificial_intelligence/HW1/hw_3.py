import torch
import torchvision
import numpy as np
import pickle
import json
from utils import part3Plots, visualizeWeights

# Define the ANN architectures
class MLP1(torch.nn.Module):
    def __init__(self):
        super(MLP1, self).__init__()
        self.fc1 = torch.nn.Linear(784, 32)
        self.relu = torch.nn.ReLU()
        self.fc2 = torch.nn.Linear(32, 10)
        
    def forward(self, x):
        x = x.view(-1, 784)
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        return x

class MLP2(torch.nn.Module):
    def __init__(self):
        super(MLP2, self).__init__()
        self.fc1 = torch.nn.Linear(784, 32)
        self.relu = torch.nn.ReLU()
        self.fc2 = torch.nn.Linear(32, 64, bias=False) # No bias
        self.fc3 = torch.nn.Linear(64, 10)
        
    def forward(self, x):
        x = x.view(-1, 784)
        x = self.relu(self.fc1(x))
        x = self.relu(self.fc2(x))
        x = self.fc3(x)
        return x

class CNN3(torch.nn.Module):
    def __init__(self):
        super(CNN3, self).__init__()
        self.conv1 = torch.nn.Conv2d(1, 16, 3)
        self.conv2 = torch.nn.Conv2d(16, 8, 5)
        self.conv3 = torch.nn.Conv2d(8, 16, 7)
        self.relu = torch.nn.ReLU()
        self.pool = torch.nn.MaxPool2d(2)
        self.fc = torch.nn.Linear(16 * 2 * 2, 10)  # Adjusted input size for the linear layer
        
    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.pool(x)
        x = self.relu(self.conv3(x))
        x = self.pool(x)
        x = x.view(-1, 16 * 2 * 2)  # Adjusted reshaping size
        x = self.fc(x)
        return x

class CNN4(torch.nn.Module):
    def __init__(self):
        super(CNN4, self).__init__()
        self.conv1 = torch.nn.Conv2d(1, 16, 3, padding=1)
        self.conv2 = torch.nn.Conv2d(16, 8, 3, padding=1)
        self.conv3 = torch.nn.Conv2d(8, 16, 5, padding=2)
        self.conv4 = torch.nn.Conv2d(16, 16, 5, padding=2)
        self.relu = torch.nn.ReLU()
        self.pool = torch.nn.MaxPool2d(2)
        self.fc = torch.nn.Linear(16 * 1 * 1, 10)  # Adjusted input size for the linear layer
        
    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.pool(x)
        x = self.relu(self.conv2(x))
        x = self.pool(x)
        x = self.relu(self.conv3(x))
        x = self.pool(x)
        x = self.relu(self.conv4(x))
        x = self.pool(x)
        x = x.view(-1, 16 * 1 * 1)  # Adjusted reshaping size
        x = self.fc(x)
        return x

class CNN5(torch.nn.Module):
    def __init__(self):
        super(CNN5, self).__init__()
        self.conv1 = torch.nn.Conv2d(1, 8, 3)
        self.conv2 = torch.nn.Conv2d(8, 16, 3)
        self.conv3 = torch.nn.Conv2d(16, 8, 3)
        self.conv4 = torch.nn.Conv2d(8, 16, 3)
        self.conv5 = torch.nn.Conv2d(16, 16, 3)
        self.relu = torch.nn.ReLU()
        self.pool = torch.nn.MaxPool2d(2)
        self.fc = torch.nn.Linear(16 * 4 * 4, 10)  # Adjusted input size for the linear layer
        
    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.relu(self.conv3(x))
        x = self.relu(self.conv4(x))
        x = self.pool(self.relu(self.conv5(x)))
        x = self.pool(x)
        x = x.view(-1, 16 * 4 * 4)  # Adjusted reshaping size
        x = self.fc(x)
        return x

# Define the transformations
transform = torchvision.transforms.ToTensor()

# Training set
train_data = torchvision.datasets.FashionMNIST('./data', train=True, download=True, transform=transform)

# Test set
test_data = torchvision.datasets.FashionMNIST('./data', train=False, download=True, transform=transform)

# Define the data loaders
batch_size = 8
train_loader = torch.utils.data.DataLoader(train_data, batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(test_data, batch_size=batch_size)

# Define a function to train and evaluate the model
def train_and_evaluate(model, model_name, loss_fn, optimizer, train_loader, test_loader, epochs=15):
    loss_curve = []
    train_acc_curve = []
    val_acc_curve = []
    model.train()
    for epoch in range(epochs):
        running_loss = 0.0
        correct_train = 0
        total_train = 0
        for i, (images, labels) in enumerate(train_loader):
            optimizer.zero_grad()
            outputs = model(images)
            loss = loss_fn(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            _, predicted = torch.max(outputs.data, 1)
            total_train += labels.size(0)
            correct_train += (predicted == labels).sum().item()
            
            if (i+1) % 10 == 0:
                print(f'Epoch [{epoch+1}/{epochs}], Step [{i+1}/{len(train_loader)}], Loss: {running_loss/10:.4f}, Accuracy: {(100*correct_train/total_train):.2f}%')
                loss_curve.append(running_loss/10)
                running_loss = 0.0
        
        # Test accuracy
        model.eval()
        correct_test = 0
        total_test = 0
        with torch.no_grad():
            for images, labels in test_loader:
                outputs = model(images)
                _, predicted = torch.max(outputs.data, 1)
                total_test += labels.size(0)
                correct_test += (predicted == labels).sum().item()
        
        test_accuracy = 100 * correct_test / total_test
        print(f'Test Accuracy of {model_name} on the 10000 test images: {test_accuracy:.2f}%')
        model.train()
        train_acc_curve.append(100 * correct_train / total_train)
        val_acc_curve.append(test_accuracy)

    # Save the trained model weights
    torch.save(model.state_dict(), f'{model_name}_weights.pth')

    return {
        'name': model_name,
        'loss_curve': loss_curve,
        'train_acc_curve': train_acc_curve,
        'val_acc_curve': val_acc_curve,
        'test_acc': test_accuracy,
        'weights': f'{model_name}_weights.pth'
    }

# Train and evaluate each architecture
model_mlp1 = MLP1()
optimizer_mlp1 = torch.optim.SGD(model_mlp1.parameters(), lr=0.01)
result_mlp1 = train_and_evaluate(model_mlp1, "MLP1", torch.nn.CrossEntropyLoss(), optimizer_mlp1, train_loader, test_loader)

model_mlp2 = MLP2()
optimizer_mlp2 = torch.optim.SGD(model_mlp2.parameters(), lr=0.01)
result_mlp2 = train_and_evaluate(model_mlp2, "MLP2", torch.nn.CrossEntropyLoss(), optimizer_mlp2, train_loader, test_loader)

model_cnn3 = CNN3()
optimizer_cnn3 = torch.optim.SGD(model_cnn3.parameters(), lr=0.01)
result_cnn3 = train_and_evaluate(model_cnn3, "CNN3", torch.nn.CrossEntropyLoss(), optimizer_cnn3, train_loader, test_loader)

model_cnn4 = CNN4()
optimizer_cnn4 = torch.optim.SGD(model_cnn4.parameters(), lr=0.01)
result_cnn4 = train_and_evaluate(model_cnn4, "CNN4", torch.nn.CrossEntropyLoss(), optimizer_cnn4, train_loader, test_loader)

model_cnn5 = CNN5()
optimizer_cnn5 = torch.optim.SGD(model_cnn5.parameters(), lr=0.01)
result_cnn5 = train_and_evaluate(model_cnn5, "CNN5", torch.nn.CrossEntropyLoss(), optimizer_cnn5, train_loader, test_loader)

# Save the results
with open('part3_results.pkl', 'wb') as f:
    pickle.dump([result_mlp1, result_mlp2, result_cnn3, result_cnn4, result_cnn5], f)

# Create performance plots
results = [result_mlp1, result_mlp2, result_cnn3, result_cnn4, result_cnn5]
part3Plots(results)

# Visualize weights
# Load the trained model weights
model_weights_mlp1 = torch.load(result_mlp1['weights'])
model_weights_mlp2 = torch.load(result_mlp2['weights'])
model_weights_cnn3 = torch.load(result_cnn3['weights'])
model_weights_cnn4 = torch.load(result_cnn4['weights'])
model_weights_cnn5 = torch.load(result_cnn5['weights'])

# Extract the weights of the first layer for each model
weights_mlp1_fc1 = model_weights_mlp1['fc1.weight'].numpy()
weights_mlp2_fc1 = model_weights_mlp2['fc1.weight'].numpy()
weights_cnn3_conv1 = model_weights_cnn3['conv1.weight'].numpy()
weights_cnn4_conv1 = model_weights_cnn4['conv1.weight'].numpy()
weights_cnn5_conv1 = model_weights_cnn5['conv1.weight'].numpy()

# Visualize weights for each model
visualizeWeights(weights_mlp1_fc1, save_dir="C:/EE_449", filename="MLP1 Weights")
visualizeWeights(weights_mlp2_fc1, save_dir="C:/EE_449", filename="MLP2 Weights")
visualizeWeights(weights_cnn3_conv1, save_dir="C:/EE_449", filename="CNN3 Weights")
visualizeWeights(weights_cnn4_conv1, save_dir="C:/EE_449", filename="CNN4 Weights")
visualizeWeights(weights_cnn5_conv1, save_dir="C:/EE_449", filename="CNN5 Weights")
