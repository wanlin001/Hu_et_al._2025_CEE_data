#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 23 12:32:06 2024

@author: wanlin

Plot profiles comparisons
Assign: folders and frames
Plot features and color scheme
"""

import sys
import os
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.patches import Rectangle
from matplotlib.colors import Normalize, LogNorm
from matplotlib.patches import Rectangle, Polygon
import matplotlib.ticker as ticker
from matplotlib.ticker import MaxNLocator

# Set default font style to Arial
plt.rcParams['font.family'] = 'Arial'

# Custom modules
sys.path.append('/Users/wanlin/Documents/FLAC/script_geoflac/util')
import flac
import read_flac as rf
from material_properties import material_properties  # Import material properties

# Path and folder settings


path = '/Users/wanlin/Documents/FLAC/3HENGCHUN/UC_LC1_CM1'
folders = [ f'{path}/UC5_LC1_CM1']
frames = [  50]

# Plotting details
yrange = [-150, 15]
xrange = [200, 700]

# Input space for x and y limits for zoomed-in regions in the first column
xlim_zoom_1st = [300, 580]
ylim_zoom_1st = [-80, 14]

# Input space for x and y limits for the columns other than the first column
xlim_2 = xlim_zoom_1st
ylim_2 = ylim_zoom_1st 

# Extract the last part of each folder path
folder_names = [folder.split('/')[-1] for folder in folders]
# Create the figure title
#fig_title = f'Profiles, path={path}; folders={folder_names}; frames={frames}'

# Plot bars to represent sigma1 vectors as thin lines
step = 5  # Change this value to adjust the density of the vectors
# Define a scaling factor for the vectorsLC-
scale_factor = 10
'''
# for velocity vector
# vel_scale=20
vel_scale = 0.1
step_v = 10
'''
# Font size and text labels for the subplots
fontsz = 40
tick_fontsz = 24  # Font size for the tick labels
label_fontsz = 42  # Font size for the axis labels
text_labels = ['A', 'B', 'C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T']
profile_text_labels = [f'{label}' for label in text_labels]

# Create a custom colormap
cmap1 = 'tab20b'
cmap2= 'gist_stern_r'
cmap3 = 'turbo'
cmap4 = 'gist_ncar_r'
# Manually assign vmin and vmax for each colormap
vmin_cmap1, vmax_cmap1 = 0, 17
vmin_cmap2, vmax_cmap2 = 1e-3, 1e1
vmin_cmap3, vmax_cmap3 = -16, -12
vmin_cmap4, vmax_cmap4 = 0, 6

# Calculate the height of the figure based on the number of models
num_models = len(folders)
fig_height = 9 * num_models

# Depth range for strength profile
strength_profile_depth_min1 = 10
strength_profile_depth_max1 = -100
strength_profile_depth_min2 = strength_profile_depth_min1 
strength_profile_depth_max2 = strength_profile_depth_max1

# Create a figure with subplots arranged in a grid and an additional row for the color bar
fig = plt.figure(figsize=(60, fig_height))  # Adjust width to accommodate larger columns
gs = GridSpec(len(folders) + 1, 5, width_ratios=[1.1, 1.1, 3, 3, 3], height_ratios=[1] * len(folders) + [0.05], hspace=0.1, wspace=0.1)
ax1 = []  # List to store the created axes
caxes = []  # List to store the ColorAxis objects

# Profile extraction details
target_value1 = 250 # Example target value for profile extraction
target_value2 = 680  # Another example target value for profile extraction
tolerance = 2  # Tolerance for being "close" to target_value

# Function to calculate frictional strength
def get_fric_strength_density(coh, fric, depth, tho):
    strength = coh + tho * 9.8 * depth * np.tan(np.radians(fric))  # meter
    return strength

# Iterate over folders and frames to generate plots

for i, (folder, frame_assign) in enumerate(zip(folders, frames)):
    x, z, phase, pls, density, visc = rf.read_flac(folder, frame=frame_assign)
    _, _, s1, mag = rf.get_sigma_1(folder, frame=frame_assign)
    _, _, temp = rf.read_temp(folder, frame=frame_assign)
    _, _, srII = rf.read_srII(folder, frame=frame_assign)
    #strain 1
    #_, _, e1, e1mag = rf.get_strain_1(folder, frame=frame_assign)
    
    # Find accretionary top : max value between given ranges
    #mask = (x[:, 0] >0) & (x[:, 0] < 1100)
    max_index = np.argmax(z[:, 0])
    max_x = x[max_index, 0]

    # Find trench the index of the minimum value in the first column of z #trench
    #mask = (x[:, 0] >0 ) & (x[:, 0] < 1100)
    min_index = np.argmin(z[:max_index, 0])
    min_x = x[min_index, 0]

    
    # Define quiver plot variables
    sigma1_x = s1[:, :, 0]
    sigma1_z = s1[:, :, 1]
    
    # Strain rate orientation
    #e1_x = e1[:, :, 0]
    #e1_z = e1[:, :, 1]

    # Calculate the midpoints for quiver
    x_quiver = (x[:-1, :-1] + x[1:, :-1] + x[:-1, 1:] + x[1:, 1:]) / 4
    z_quiver = (z[:-1, :-1] + z[1:, :-1] + z[:-1, 1:] + z[1:, 1:]) / 4
    temp_quiver = (temp[:-1, :-1] + temp[1:, :-1] + temp[:-1, 1:] + temp[1:, 1:]) / 4

    original_array = x_quiver

    # Step 1: Create boolean arrays for the two target values
    boolean_array1 = np.abs(original_array - target_value1) < tolerance
    boolean_array2 = np.abs(original_array - target_value2) < tolerance

    # Step 2: Convert the boolean arrays to integer arrays
    index_array1 = boolean_array1.astype(int)
    index_array2 = boolean_array2.astype(int)

    # Step 3: Use the integer arrays to index another array
    extracted_srII1 = srII[index_array1 == 1]
    extracted_pls1 = pls[index_array1 == 1]
    extracted_visc1 = visc[index_array1 == 1]
    extracted_phase1 = phase[index_array1 == 1]
    extracted_z1 = z_quiver[index_array1 == 1]
    extracted_density1 = density[index_array1 == 1]
    extracted_temp1 = temp_quiver[index_array1 == 1]

    extracted_srII2 = srII[index_array2 == 1]
    extracted_pls2 = pls[index_array2 == 1]
    extracted_visc2 = visc[index_array2 == 1]
    extracted_phase2 = phase[index_array2 == 1]
    extracted_z2 = z_quiver[index_array2 == 1]
    extracted_density2 = density[index_array2 == 1]
    extracted_temp2 = temp_quiver[index_array2 == 1]

    # Sort the extracted values by z for better visualization
    sorted_indices1 = np.argsort(extracted_z1)
    extracted_z1 = extracted_z1[sorted_indices1]
    extracted_srII1 = extracted_srII1[sorted_indices1]
    extracted_pls1 = extracted_pls1[sorted_indices1]
    extracted_visc1 = extracted_visc1[sorted_indices1]
    extracted_phase1 = extracted_phase1[sorted_indices1]
    extracted_density1 = extracted_density1[sorted_indices1]
    extracted_temp1 = extracted_temp1[sorted_indices1]

    sorted_indices2 = np.argsort(extracted_z2)
    extracted_z2 = extracted_z2[sorted_indices2]
    extracted_srII2 = extracted_srII2[sorted_indices2]
    extracted_pls2 = extracted_pls2[sorted_indices2]
    extracted_visc2 = extracted_visc2[sorted_indices2]
    extracted_phase2 = extracted_phase2[sorted_indices2]
    extracted_density2 = extracted_density2[sorted_indices2]
    extracted_temp2 = extracted_temp2[sorted_indices2]

    # Calculate viscous strength
    viscous_strength1 = pow(10, extracted_visc1) * 2 * pow(10, extracted_srII1)
    viscous_strength2 = pow(10, extracted_visc2) * 2 * pow(10, extracted_srII2)

    # Calculate frictional strength based on conditions
    cohesion1 = np.zeros_like(extracted_z1)
    friction_angle1 = np.zeros_like(extracted_z1)
    density1 = np.zeros_like(extracted_z1)

    cohesion2 = np.zeros_like(extracted_z2)
    friction_angle2 = np.zeros_like(extracted_z2)
    density2 = np.zeros_like(extracted_z2)

    # plastic threshold fro weakend values of coh and frictional angle
    for j in range(len(extracted_z1)):
        key = (extracted_pls1[j] < 0.1, extracted_phase1[j])
        props = material_properties[key]
        cohesion1[j] = props['coh']
        friction_angle1[j] = props['fric_angle']
        density1[j] = props['density']

    for j in range(len(extracted_z2)):
        key = (extracted_pls2[j] < 0.1, extracted_phase2[j])
        props = material_properties[key]
        cohesion2[j] = props['coh']
        friction_angle2[j] = props['fric_angle']
        density2[j] = props['density']

    fric_strength1 = get_fric_strength_density(cohesion1, friction_angle1, -extracted_z1 * 1e3, density1)
    fric_strength2 = get_fric_strength_density(cohesion2, friction_angle2, -extracted_z2 * 1e3, density2)

    # Calculate the minimum strength profile
    min_strength1 = np.minimum(viscous_strength1, fric_strength1)
    min_strength2 = np.minimum(viscous_strength2, fric_strength2)

    # Plot the first strength profile in the leftmost column
    ax_strength1 = fig.add_subplot(gs[i, 0])
    ax_strength1.set_xlim([0, 1000])

    ax_strength1.plot(viscous_strength1 / 1e6, extracted_z1, label='Viscous Strength', color='r', alpha=0.5)
    ax_strength1.plot(fric_strength1 / 1e6, extracted_z1, label='Frictional Strength', color='g', alpha=0.5)
    ax_strength1.plot(min_strength1 / 1e6, extracted_z1, label='Strength', color='k', linestyle='-')
    ax_strength1.set_xticklabels([])
    # Overlay the temperature profile
    ax_temp1 = ax_strength1.twiny()
    ax_temp1.plot(extracted_temp1, extracted_z1, label='Temperature', color='purple', linestyle='--')
    ax_temp1.set_xlabel('Temperature (°C)', fontsize=fontsz, labelpad=18)
    ax_temp1.tick_params(axis='both', which='major', labelsize=tick_fontsz)  
    ax_temp1.set_xticklabels([])

    ax_strength1.set_ylabel('Depth (km)', fontsize=label_fontsz)

    ax_strength1.set_ylim([strength_profile_depth_min1, strength_profile_depth_max1])
    #ax_strength1.legend(loc="lower right")
    #ax_strength1.grid(True)


    # Invert y-axis to have depth increasing downwards
    ax_strength1.invert_yaxis()
    ax_strength1.tick_params(axis='both', which='major', labelsize=tick_fontsz)
    ax_strength1.set_aspect(aspect=13.5)  # Set the aspect ratio to 3:2
    ax_strength1.set_xticklabels([])
    # Add label to the strength profile
    #label = f"{profile_text_labels[i]}a"
    label = "A"
    '''
    ax_strength1.text(-0.07, 1.02, label, transform=ax_strength1.transAxes,
                     fontsize=fontsz, fontweight='bold', va='center',
                     bbox=dict(facecolor='white', edgecolor='black', linewidth=0.5, alpha=0.8, boxstyle='round,pad=0.3'))
    '''    
    # Plot the second strength profile in the second column
    ax_strength2 = fig.add_subplot(gs[i, 1])
    ax_strength2.set_xlim([0, 1000])
    ax_strength2.plot(viscous_strength2 / 1e6, extracted_z2, label='Viscous Strength', color='r', alpha=0.5)
    ax_strength2.plot(fric_strength2 / 1e6, extracted_z2, label='Frictional Strength', color='g', alpha=0.5)
    ax_strength2.plot(min_strength2 / 1e6, extracted_z2, label='Strength', color='k', linestyle='-')
    ax_strength2.set_xticklabels([])
    # Overlay the temperature profile
    ax_temp2 = ax_strength2.twiny()
    ax_temp2.plot(extracted_temp2, extracted_z2, label='Temperature', color='purple', linestyle='--')
    ax_temp2.set_xlabel('Temperature (°C)', fontsize=fontsz, labelpad=18)
    ax_temp2.tick_params(axis='both', which='major', labelsize=tick_fontsz)  
    ax_temp2.set_xticklabels([])
    
   

    
    ax_temp1.set_xlim(0, 1300)
    ax_temp2.set_xlim(0, 1300)
    

    #ax_strength2.set_ylabel('Depth (km)', fontsize=label_fontsz)
  
    ax_strength2.set_ylim([strength_profile_depth_min2, strength_profile_depth_max2])
    #ax_strength2.legend(loc="lower right")
    #ax_strength2.grid(True)

    # Invert y-axis to have depth increasing downwards
    ax_strength2.invert_yaxis()
    ax_strength2.tick_params(axis='both', which='major', labelsize=tick_fontsz)
    ax_strength2.set_aspect(aspect=13.5)  # Set the aspect ratio to 3:2
    

    # Add label to the strength profile
    #label = f"{profile_text_labels[i]}"
    label = "B"
    '''
    #ax_strength2.text(-0.07, 1.02, label, transform=ax_strength2.transAxes,
    #                 fontsize=fontsz, fontweight='bold', va='center',
    #                 bbox=dict(facecolor='white', edgecolor='black', linewidth=0.5, alpha=0.8, boxstyle='round,pad=0.3'))
    '''
    if i==0:
        ax_temp2.set_xlabel('Temperature (°C)', fontsize=label_fontsz, color='purple')
        ax_temp1.set_xlabel('Temperature (°C)', fontsize=label_fontsz, color='purple')
        desired_ticks = [400,800,1200]
        ax_temp2.set_xticks(desired_ticks)
        ax_temp2.set_xticklabels([str(tick) for tick in desired_ticks])
        ax_temp1.set_xticks(desired_ticks)
        ax_temp1.set_xticklabels([str(tick) for tick in desired_ticks])
        ax_temp1.tick_params(axis='x', colors='purple')
        ax_temp2.tick_params(axis='x', colors='purple')
        
    if i == len(folders) - 1:
        ax_strength1.set_xlabel('Strength (MPa)', fontsize=label_fontsz)
        ax_strength2.set_xlabel('Strength (MPa)', fontsize=label_fontsz)
        desired_ticks = [200,400,600,800,1000]
        ax_strength1.set_xticks(desired_ticks)
        ax_strength1.set_xticklabels([str(tick) for tick in desired_ticks])
        
        ax_strength2.set_xticks(desired_ticks)
        ax_strength2.set_xticklabels([str(tick) for tick in desired_ticks])
        
        ax_strength1.tick_params(axis='x', colors='k')
        ax_strength2.tick_params(axis='x', colors='k')
    # Set the same grid interval for all plots
    ax_strength1.xaxis.set_major_locator(ticker.MultipleLocator(200))
    ax_strength1.yaxis.set_major_locator(ticker.MultipleLocator(20))
    ax_strength1.grid(True)
    ax_strength2.xaxis.set_major_locator(ticker.MultipleLocator(200))
    ax_strength2.yaxis.set_major_locator(ticker.MultipleLocator(20))
    ax_strength2.grid(True)


############
#
#plot profiles
#
############
    #for j, (item, cmap, vmin, vmax) in enumerate(zip([phase, pls, srII, mag], [cmap1, cmap2, cmap3, cmap4], [vmin_cmap1, vmin_cmap2, vmin_cmap3, vmin_cmap4], [vmax_cmap1, vmax_cmap2, vmax_cmap3, vmax_cmap4])):
    #    ax = fig.add_subplot(gs[i, j+2])
    #    ax1.append(ax)
    #for j, (item, cmap, vmin, vmax) in enumerate(zip([phase], [cmap1], [vmin_cmap1], [vmax_cmap1])):
    #for j, (item, cmap, vmin, vmax) in enumerate(zip([srII, mag], [cmap3, cmap4], [ vmin_cmap3, vmin_cmap4], [vmax_cmap3, vmax_cmap4])):
    for j, (item, cmap, vmin, vmax) in enumerate(zip([phase,  srII, mag], [cmap1, cmap3, cmap4], [vmin_cmap1,  vmin_cmap3, vmin_cmap4], [vmax_cmap1,  vmax_cmap3, vmax_cmap4])):
        ax = fig.add_subplot(gs[i, j+2])
        ax1.append(ax)
    
        # Draw contours
        mid_x = (x[:-1, :-1] + x[1:, 1:]) / 2
        mid_z = (z[:-1, :-1] + z[1:, 1:]) / 2
        ax.contour(mid_x, mid_z, phase, colors='black', linewidths=0.8)
        
        if j==0:
            contour = ax.contour(x, z, temp, colors='white', alpha=1, linewidths=2)
            # Add labels to contours
            ax.clabel(contour, inline=True, fontsize=28, fmt='%d', inline_spacing=2)
        else:
            print('skip countour')
            #contour = ax.contour(x, z, temp, colors='grey', alpha=1, linewidths=2)
            #ax.clabel(contour, inline=True, fontsize=20, fmt='%d', inline_spacing=1, colors='k')
      
        # Overlay the plastic strain contours on the srII plot
        #if j == 1:  # Assuming j==1 corresponds to srII plot
        #    pls_contour = ax.contour(mid_x, mid_z, pls, levels=13, colors='red', linewidths=3)  # Adjust levels and color as needed
        #    ax.clabel(pls_contour, inline=True, fontsize=12, fmt='%1.2f')
        if j == 1:  # Assuming j == 1 corresponds to srII plot
            # Create logarithmically spaced contour levels
            log_levels = np.logspace(-4, -1, num=3)  # levels: 10^-3, 10^-2, 10^-1
            pls_contour = ax.contour(mid_x, mid_z, pls, levels=log_levels, colors='red', linewidths=3)
            
            # Add labels to the contours with appropriate formatting for logarithmic values
            ax.clabel(pls_contour, inline=True, fontsize=28, fmt=lambda x: f'$10^{{{int(np.log10(x))}}}$')
    
    
    
        norm = Normalize(vmin=vmin, vmax=vmax)
            
        
        # Plotting
        cax = ax.pcolormesh(x, z, item, cmap=cmap, norm=norm)
        # Increase tick label font size
        ax.tick_params(axis='both', which='major', labelsize=tick_fontsz)  # Increase to your desired size, e.g., 20
    
        # Plot the selected item
    
        caxes.append(cax)
        # Draw a triangle at the x location of the minimum z value
        # triangle = Polygon(((min_x, 0), (min_x - 5, 10), (min_x + 5, 10)), color='blue')
        triangle = Polygon(((max_x-130, 0), (max_x - 5 -130, 10), (max_x -130 + 5, 10)), color='blue') 
        ax.add_patch(triangle)
        # Draw a triangle at the x location of the minimum z value
        triangle = Polygon(((max_x, 0), (max_x - 5, 10), (max_x + 5, 10)), color='red')
        ax.add_patch(triangle)
        
        # Add text labels outside each subplot
        #label = f"{text_labels[i]}{j + 2}" 
        # Update label assignment to match the desired format (A1, B1, C1, D1, ... etc.)
        label = f"{text_labels[j+2]}"  # 'j' controls the letter and 'i' controls the number
        ax.text(0.01, 1.3, label, transform=ax.transAxes,
        fontsize=fontsz, fontweight='bold', va='center',
        bbox=dict(facecolor='white', edgecolor='black', linewidth=0.5, alpha=0.8, boxstyle='round,pad=0.3'))
        
        #showing the model name
        #ax.text(0.1, 1.3, os.path.basename(folder), transform=ax.transAxes, fontsize=fontsz-3, fontweight='light', va='center')
        
        # Set axis limits for the first profile: overview
        if j == 0:
            ax.set_xlim(xrange)
            ax.set_ylim(yrange)
            # Add yellow box for the first profile
            ax.add_patch(Rectangle((target_value1 - tolerance, strength_profile_depth_min1), 2 * tolerance, strength_profile_depth_max1 - strength_profile_depth_min1,
                                   edgecolor='yellow', facecolor='none', linewidth=2))
            # Add light blue box for the second profile
            ax.add_patch(Rectangle((target_value2 - tolerance, strength_profile_depth_min2), 2 * tolerance, strength_profile_depth_max2 - strength_profile_depth_min2,
                                   edgecolor='lightblue', facecolor='none', linewidth=2))
    
            # Add red boxes to show zoomed-in regions in the first column
            ax.add_patch(Rectangle((xlim_zoom_1st[0], ylim_zoom_1st[0]), xlim_zoom_1st[1] - xlim_zoom_1st[0], ylim_zoom_1st[1] - ylim_zoom_1st[0],
                                       edgecolor='red', facecolor='none', linewidth=2))
    
        else :
            ax.set_xlim(xlim_2)
            ax.set_ylim(ylim_2)
            # Set denser ticks
            #ax.xaxis.set_major_locator(MaxNLocator(nbins=5))
            ax.yaxis.set_major_locator(MaxNLocator(nbins=5))
        
        ax.set_aspect('equal')
        
    
        # Increase the size of the axis tick labels
        ax.tick_params(axis='both', which='minor', labelsize=tick_fontsz)
    
        # Set axis labels with increased font size
        if i == len(folders) - 1:  # Only set xlabel for bottom row subplots
            ax.set_xlabel('Distance along the profile (km)', fontsize=label_fontsz)
        #if j == 0:  # Only set ylabel for the first column subplots
            #ax.set_ylabel('Depth (km)', fontsize=label_fontsz)
        #    continue
        # Plot sigma-1 vectors (orientation) as bars in the 4 column
        if j == 2:
            for m in range(0, x_quiver.shape[0], step):
                for n in range(0, x_quiver.shape[1], step):
                    ax.plot([x_quiver[m, n] - scale_factor * sigma1_x[m, n] / 2, x_quiver[m, n] + scale_factor * sigma1_x[m, n] / 2],
                            [z_quiver[m, n] - scale_factor * sigma1_z[m, n] / 2, z_quiver[m, n] + scale_factor * sigma1_z[m, n] / 2], 
                            'k-', linewidth=1)
    # Plot strain axis
    #if j == 2:
    #    for m in range(0, x_quiver.shape[0], step):
    #        for n in range(0, x_quiver.shape[1], step):
    #            ax.plot([x_quiver[m, n] - scale_factor * e1_x[m, n] / 2, x_quiver[m, n] + scale_factor * e1_x[m, n] / 2],
    #                    [z_quiver[m, n] - scale_factor * e1_z[m, n] / 2, z_quiver[m, n] + scale_factor * e1_z[m, n] / 2], 
    #                    'k-', linewidth=1)

        

# Add color bars at the bottom of all subplots
cbar_ax1 = fig.add_subplot(gs[-1, 2])
cbar1 = fig.colorbar(caxes[0], cax=cbar_ax1, orientation='horizontal', fraction=0.1, pad=0.1)
cbar1.set_label('Phase', fontsize=label_fontsz)  # Adjust the label based on the item being plotted
cbar1.ax.tick_params(labelsize=tick_fontsz)


cbar_ax3 = fig.add_subplot(gs[-1, 3])
cbar3 = fig.colorbar(caxes[1], cax=cbar_ax3, orientation='horizontal', fraction=0.1, pad=0.1)
cbar3.set_label(r'$\log \dot{\epsilon}_{II} $ (s$^{-1}$)', fontsize=label_fontsz)  # Adjust the label based on the item being plotted
cbar3.ax.tick_params(labelsize=tick_fontsz)

cbar_ax4 = fig.add_subplot(gs[-1, 4])
cbar4 = fig.colorbar(caxes[2], cax=cbar_ax4, orientation='horizontal', fraction=0.1, pad=0.1)
cbar4.set_label(r'$\sigma_1$ (100 MPa)', fontsize=label_fontsz)  # Adjust the label based on the item being plotted
cbar4.ax.tick_params(labelsize=tick_fontsz)

plt.tight_layout()
plt.show()
