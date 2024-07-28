

import numpy as np
import os
import matplotlib.pyplot as plt
from torchvision.utils import make_grid
import torch


def my_conv2d(input_data, kernel):
    batch_size, input_channels, input_height, input_width = input_data.shape
    output_channels, _, filter_height, filter_width = kernel.shape
    
    # Calculate the output dimensions
    output_height = input_height - filter_height + 1
    output_width = input_width - filter_width + 1
    
    # Initialize the output array
    output = np.zeros((batch_size, output_channels, output_height, output_width))
    
    # Iterate over each sample in the batch
    for i in range(batch_size):
        # Iterate over each channel in the input
        for j in range(input_channels):
            # Iterate over each filter
            for k in range(output_channels):
                # Apply convolution operation
                for m in range(output_height):
                    for n in range(output_width):
                        output[i, k, m, n] += np.sum(input_data[i, j, m:m+filter_height, n:n+filter_width] * kernel[k, j])
    
    return output

# Load input and kernel data
input_data = np.load('C:/449_hw1/samples_5.npy')
kernel = np.load('C:/449_hw1/kernel.npy')

# Apply convolution
out = my_conv2d(input_data, kernel)




def part2Plots(out, nmax=64, save_dir='', filename=''):
    out = torch.tensor(out).reshape(-1, 1, 25, 25)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.set_xticks([]); ax.set_yticks([])
    ax.imshow(make_grid((out.detach()[:nmax]), nrow=8).permute(1, 2, 0))
    fig.savefig(os.path.join(save_dir, filename + '.png'))

# Create the output image
part2Plots(out)

