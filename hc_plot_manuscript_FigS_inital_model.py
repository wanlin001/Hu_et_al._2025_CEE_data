#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 17 17:44:21 2024

@author: wanlin
"""

import sys
import os
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.colors import ListedColormap
from matplotlib.patches import Rectangle

# Set default font style to Helvetica
plt.rcParams['font.family'] = 'Helvetica'

# Custom modules
sys.path.append('/Users/wanlin/Documents/FLAC/script_geoflac/util')
import flac
import read_flac as rf

# Path and folder settings
path = '/Users/wanlin/Documents/FLAC/Hengchun'
folders = [f'{path}/h1', f'{path}/h3']
frames = [3, 100]


path = '/Users/wanlin/Documents/FLAC/3HENGCHUN/CM'
folders = [  f'{path}/CM-1']
frames = [ 1]

# Extract the last part of each folder path
folder_names = [folder.split('/')[-1] for folder in folders]

# Font size and text labels for the subplots
fontsz = 10
tick_fontsz = 20  # Font size for the tick labels
label_fontsz = 20  # Font size for the axis labels

# Define target values and tolerance
target_values = [100, 350, 800]
tolerance = 10

# Function to calculate frictional strength
def get_fric_strength_density(coh, fric, depth, tho):   # frictional regime's strength
    strength = coh + tho * 9.8 * depth * np.tan(np.radians(fric)) #meter
    return strength

# Create a figure with GridSpec layout to accommodate color bars and phase plot
fig = plt.figure(figsize=(15, 12))  # Adjust size as needed
gs = GridSpec(2, 3, height_ratios=[1, 1], hspace=0.3, wspace=0.3)

# Read data from the first folder and frame
folder = folders[0]
frame_assign = frames[0]

x, z, phase, pls, dens, visc = rf.read_flac(folder, frame=frame_assign)
_, _, s1, mag = rf.get_sigma_1(folder, frame=frame_assign)
_, _, temp = rf.read_temp(folder, frame=frame_assign)
_, _, srII = rf.read_srII(folder, frame=frame_assign)

# Calculate the midpoints for quiver
x_quiver = (x[:-1, :-1] + x[1:, :-1] + x[:-1, 1:] + x[1:, 1:]) / 4
z_quiver = (z[:-1, :-1] + z[1:, :-1] + z[:-1, 1:] + z[1:, 1:]) / 4
temp_quiver = (temp[:-1, :-1] + temp[1:, :-1] + temp[:-1, 1:] + temp[1:, 1:]) / 4

original_array = x_quiver

# Define material properties
material_properties = {
    (True, 1): {'coh': 4e7, 'fric_angle': 30, 'density': 2880},
    (True, 2): {'coh': 4e7, 'fric_angle': 30, 'density': 2800},
    (True, 3): {'coh': 4e7, 'fric_angle': 30, 'density': 2880},
    (True, 4): {'coh': 4e7, 'fric_angle': 30, 'density': 3300},
    (True, 5): {'coh': 4e7, 'fric_angle': 30, 'density': 2900},
    (True, 6): {'coh': 4e7, 'fric_angle': 30, 'density': 2880},
    (True, 7): {'coh': 4e7, 'fric_angle': 30, 'density': 2880},
    (True, 8): {'coh': 4e7, 'fric_angle': 30, 'density': 3300},
    (True, 9): {'coh': 4e6, 'fric_angle': 9, 'density': 3200},
    (True, 10): {'coh': 4e6, 'fric_angle': 3, 'density': 2800},
    (True, 11): {'coh': 4e6, 'fric_angle': 3, 'density': 2800},
    (True, 12): {'coh': 4e6, 'fric_angle': 9, 'density': 2800},
    (True, 13): {'coh': 4e7, 'fric_angle': 30, 'density': 3480},
    (True, 14): {'coh': 4e7, 'fric_angle': 30, 'density': 2900},
    (True, 15): {'coh': 4e6, 'fric_angle': 9, 'density': 2800},

    (False, 1): {'coh': 4e6, 'fric_angle': 25, 'density': 2880},
    (False, 2): {'coh': 4e6, 'fric_angle': 15, 'density': 2800},
    (False, 3): {'coh': 4e6, 'fric_angle': 25, 'density': 2880},
    (False, 4): {'coh': 4e6, 'fric_angle': 15, 'density': 3300},
    (False, 5): {'coh': 4e6, 'fric_angle': 15, 'density': 2900},
    (False, 6): {'coh': 4e6, 'fric_angle': 15, 'density': 2880},
    (False, 7): {'coh': 4e6, 'fric_angle': 15, 'density': 2880},
    (False, 8): {'coh': 4e6, 'fric_angle': 15, 'density': 3300},
    (False, 9): {'coh': 4e6, 'fric_angle': 9, 'density': 3200},
    (False, 10): {'coh': 4e6, 'fric_angle': 3, 'density': 2800},
    (False, 11): {'coh': 4e6, 'fric_angle': 3, 'density': 2800},
    (False, 12): {'coh': 4e6, 'fric_angle': 9, 'density': 2800},
    (False, 13): {'coh': 4e6, 'fric_angle': 15, 'density': 3480},
    (False, 14): {'coh': 4e6, 'fric_angle': 25, 'density': 2900},
    (False, 15): {'coh': 4e6, 'fric_angle': 9, 'density': 2800}
}

for idx, target_value in enumerate(target_values):
    # Step 1: Create a boolean array
    boolean_array = np.abs(original_array - target_value) < tolerance

    # Step 2: Convert the boolean array to an integer array
    index_array = boolean_array.astype(int)

    # Step 3: Use the integer array to index another array
    extracted_srII = srII[index_array == 1]
    extracted_pls = pls[index_array == 1]
    extracted_visc = visc[index_array == 1]
    extracted_phase = phase[index_array == 1]
    extracted_z = z_quiver[index_array == 1]
    extracted_dens = dens[index_array == 1]
    extracted_temp = temp_quiver[index_array == 1]

    # Sort the extracted values by z for better visualization
    sorted_indices = np.argsort(extracted_z)
    extracted_z = extracted_z[sorted_indices]
    extracted_srII = extracted_srII[sorted_indices]
    extracted_pls = extracted_pls[sorted_indices]
    extracted_visc = extracted_visc[sorted_indices]
    extracted_phase = extracted_phase[sorted_indices]
    extracted_dens = extracted_dens[sorted_indices]
    extracted_temp = extracted_temp[sorted_indices]

    # Calculate viscous strength
    viscous_strength = pow(10, extracted_visc) * 2 * pow(10, extracted_srII)

    # Calculate frictional strength based on conditions
    cohesion = np.zeros_like(extracted_z)
    friction_angle = np.zeros_like(extracted_z)
    density = np.zeros_like(extracted_z)

    for i in range(len(extracted_z)):
        key = (extracted_pls[i] < 0.1, extracted_phase[i])
        props = material_properties[key]
        cohesion[i] = props['coh']
        friction_angle[i] = props['fric_angle']
        density[i] = props['density']

    fric_strength = get_fric_strength_density(cohesion, friction_angle, -extracted_z * 1e3, density)

    # Calculate the minimum strength profile
    min_strength = np.minimum(viscous_strength, fric_strength)

    # Create subplot for each target value
    ax1 = fig.add_subplot(gs[0, idx])
    ax2 = ax1.twiny()  # Create a twin Axes sharing the xaxis for strength

    # Plot temperature on the bottom X-axis
    ax1.plot(extracted_temp, extracted_z, label='Temperature', color='r', alpha=0.4)
    ax1.set_xlabel('Temperature (°C)')
    ax1.set_ylabel('Depth (km)')
    ax1.set_ylim([-100, 0])
    ax1.set_xlim(min(extracted_temp), max(extracted_temp))
    #ax1.invert_yaxis()
    if idx == 0:
        ax1.set_ylabel('Depth (z)')
    
    # Plot strength on the upper X-axis
    ax2.plot(viscous_strength / 1e6, extracted_z, label='Viscous Strength', color='purple', alpha=0.5)
    ax2.plot(fric_strength / 1e6, extracted_z, label='Frictional Strength', color='g', alpha=0.5)
    ax2.plot(min_strength / 1e6, extracted_z, label='Strength', color='k', linestyle='-')
    ax2.set_xlabel('Strength (MPa)')
    ax2.set_xlim(0, 1200)
    ax2.legend(loc='lower right')

    ax1.set_title(f'Strength profile\n(Profile at {target_value} km)')
    ax1.grid(True)
    if idx == len(target_values) - 1:  # Only add legend to the last subplot
        ax1.legend(loc='lower right')

    # Add subplot index
    ax1.text(-0.1, 1.1, chr(65+ idx), transform=ax1.transAxes, fontsize=20, fontweight='bold', va='top', ha='right')

# Add phase plot below the subplots
ax_phase = fig.add_subplot(gs[1, :])
c = ax_phase.pcolormesh(x, z, phase, cmap='tab20b', shading='auto', vmin=0, vmax=17)
ax_phase.contour(x_quiver, z_quiver, phase, colors='black', linewidths=0.2)
contour = ax_phase.contour(x, z, temp, colors='white', alpha=1, linewidths=0.3)
# Add labels to contours
ax_phase.clabel(contour, inline=True, fontsize=10, fmt='%d', inline_spacing=4)

ax_phase.set_xlabel('km')
ax_phase.set_ylabel('Depth (km)')
ax_phase.yaxis.set_label_position('right')  # Move label to the right
ax_phase.yaxis.tick_right()  # Move ticks to the right
ax_phase.set_title('Phase distribution', fontsize=20)
#ax_phase.set_title(f'Phase \nFrame: {frame_assign}, Folder: {folder}')

# Highlight the profile extraction ranges and add indices
for idx, target_value in enumerate(target_values):
    rect = Rectangle((target_value - tolerance, 10), 2 * tolerance, -100,
                     linewidth=1, edgecolor='r', facecolor='none')
    ax_phase.add_patch(rect)
    ax_phase.text(target_value, -90, chr(65 + idx), color='k', fontsize=20, fontweight='bold')

# Add color bar for the phase plot
cbar = fig.colorbar(c, ax=ax_phase, orientation='horizontal', fraction=0.03, pad=0.15)
cbar.set_label('Phase', fontsize=12)
cbar.ax.tick_params(labelsize=12)









plt.tight_layout()
plt.show()
