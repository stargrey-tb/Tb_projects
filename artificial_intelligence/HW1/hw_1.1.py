import numpy as np
import matplotlib.pyplot as plt

# Define the range of x values
x = np.linspace(-5, 5, 200)

# Tanh function and its derivative
y1 = (np.exp(2*x) - 1) / (np.exp(2*x) + 1)
dy1_dx = 4 * np.exp(2*x) / (np.exp(2*x) + 1)**2

# Sigmoid function and its derivative
y2 = 1 / (1 + np.exp(-x))
dy2_dx = np.exp(-x) / (1 + np.exp(-x))**2

# ReLU function and its derivative
y3 = np.maximum(0, x)
dy3_dx = np.where(x >= 0, 1, 0)

# Plotting
plt.figure(figsize=(15, 5))

# Tanh function and its derivative
plt.subplot(1, 3, 1)
plt.plot(x, y1, label='Tanh Function')
plt.plot(x, dy1_dx, label='Derivative')
plt.title('Tanh Function and Derivative')
plt.xlabel('x')
plt.ylabel('y')
plt.legend()

# Sigmoid function and its derivative
plt.subplot(1, 3, 2)
plt.plot(x, y2, label='Sigmoid Function')
plt.plot(x, dy2_dx, label='Derivative')
plt.title('Sigmoid Function and Derivative')
plt.xlabel('x')
plt.ylabel('y')
plt.legend()

# ReLU function and its derivative
plt.subplot(1, 3, 3)
plt.plot(x, y3, label='ReLU Function')
plt.plot(x, dy3_dx, label='Derivative')
plt.title('ReLU Function and Derivative')
plt.xlabel('x')
plt.ylabel('y')
plt.legend()

plt.tight_layout()
plt.show()