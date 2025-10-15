#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 15 09:38:11 2024

@author: wanlin

read given item in given folder and assigned frames
"""


import sys
sys.path.append('/Users/wanlin/Documents/FLAC/script_geoflac/util')
import flac
import os
import numpy as np



def read_flac(folder, frame = 100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)     
    f1 = flac.Flac()
    x,z = f1.read_mesh(frame)
    phase=f1.read_phase(frame)
    pls=f1.read_aps(frame)
    visc=f1.read_visc(frame)
    density=f1.read_density(frame)
    os.chdir(original_folder)
    return x,z,phase,pls,density,visc


def read_srII(folder,frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)     
    f1 = flac.Flac()
    x,z = f1.read_mesh(frame)
    srII=f1.read_srII(frame)
    os.chdir(original_folder)
    return x,z,srII

def read_sxx(folder,frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)     
    f1 = flac.Flac()
    x,z = f1.read_mesh(frame)
    sxx=f1.read_sxx(frame)
    os.chdir(original_folder)
    return x,z,sxx

def read_vel(folder,frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)
    f1 = flac.Flac()
    vx,vz = f1.read_vel(frame)
    os.chdir(original_folder)
    return vx.transpose(), vz.transpose()


def read_temp(folder,frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)     
    f1 = flac.Flac()
    x,z = f1.read_mesh(frame)
    temp=f1.read_temperature(frame)
    os.chdir(original_folder)
    return x,z,temp
'''
    def read_sxx(self, frame):
        columns = 1
        f = open('sxx.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        sxx = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(sxx)
        return sxx


    def read_sxz(self, frame):
        columns = 1
        f = open('sxz.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        sxz = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(sxz)
        return sxz


    def read_szz(self, frame):
        columns = 1
        f = open('szz.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        szz = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(szz)
        return szz
'''



def compute_s1(sxx, szz, sxz):
    mag =  np.sqrt(0.25 * (sxx - szz)**2 + sxz**2) #+(sxx+szz)/2 
    theta = 0.5 * np.arctan2(2 * sxz, sxx - szz)
    nx, nz = sxx.shape
    tmp = np.zeros((nx, nz, 3), dtype=sxx.dtype)
    tmp[:, :, 0] = mag * np.sin(theta)
    tmp[:, :, 1] = mag * np.cos(theta)
    return tmp, mag
    
def get_sigma_1(folder, frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)
    f1 = flac.Flac()
    x, z = f1.read_mesh(frame)
    sxx = f1.read_sxx(frame)
    sxz = f1.read_sxz(frame)
    szz = f1.read_szz(frame)
    s1, mag = compute_s1(sxx, szz, sxz)
    os.chdir(original_folder)
    return x, z, s1, mag


def get_strain_1(folder, frame=100):
    original_folder = os.getcwd()  # Get the current working directory
    os.chdir(folder)
    f1 = flac.Flac()
    x, z = f1.read_mesh(frame)
    exx, ezz, exz = f1.read_strain(frame)
    s1, mag = compute_s1(exx, ezz, exz)
    os.chdir(original_folder)
    return x, z, s1, mag

'''
    def read_strain(self, frame):
        columns = 1
        f = open('exx.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        exx = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(exx)

        f = open('ezz.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        ezz = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(ezz)

        f = open('exz.0')
        offset = (frame-1) * columns * self.nelements * sizeoffloat
        f.seek(offset)
        exz = self._read_data(f, columns, count=self.nelements)
        self._reshape_elemental_fields(exz)
        return exx, ezz, exz

'''

#read_temperature
#read_strain exx, ezz, exz
#read_eII
