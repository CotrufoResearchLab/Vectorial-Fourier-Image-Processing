# Vectorial Fourier Image Processing (vfip)
A Matlab script to calculate the filtering/processing performed on an optical image by an optical element (such as a thin metasurface) characterized by angle-dependent vectorial transfer functions.

The script implements the mathematical steps outlined in Eqs. 1-7 of [this](https://www.sciencedirect.com/science/article/pii/S0079663824000027) paper from our group.

## Installation

Just download the whole code, and place it anywhere on your computer. Then, make sure that the file ```vfip/vfip.m``` can be accessed by your script. See files in the ```Examples``` folder to see a possible way of doing this.

## Usage

See files in the ```Examples``` folder, and read the description of the input parameters and output variables, to learn how to use the script. 

## Input Parameters and Output Variables

See docstring in the file [vfip.m](https://github.com/CotrufoResearchLab/Vectorial-Fourier-Image-Processing/blob/main/vfip/vfip.m) for a description of the input parameters and output variables.
```
%   INPUT ARGUMENTS
%
%   inputimage = NxM double
%       Input Image to be processed.
%
%   px_size = 1x2 double
%       Specifies the physical size of the pixels of the input image, px_size = [px_size_x,px_size_y], in units of
%       wavelength. 
%
%   inputpol = 2xNpol double
%       Normalized vector describing the polarization(s) of the input image(s). If Npol=1, only one input image, with 
%       polarization given by inputpol(:,1), is assumed. If Npol>1, the script will repeat the image procssing calculation Npol times, 
#       each time assuming an image with the same shape (given by inputimage) and with polarization vector equal to inputpol(:,j). Accordingly,
%       multiple output images will be returned. If the polarization vector is not normalized, the script normalizes it.
%
%   TFs = 1x4 cell array. 
%       The four complex transfer functions, TFs = {tss,tpp,tsp,tps}. Each transfer function is a rectangular matrix.
%       The four matrices must have the same size. The size of these matrices does not need to match the size of
%       inputimage.
%
%   Kgrids = 1x2 cell array
%       The meshgrids KX and KY associated to the transfer functions, Kgrids = {KX,KY}. KX and KY are meshgrids and must have the
%       same size as the transfer functions.
%
%   DefaultValueTFs = 1x4 double (optional). Default value = [0,0,0,0]
%       If the k-space range over which the transfer functions are defined is smaller than the k-space range of the
%       Fourier transform of the image, the script will assume that, in the region where the transfer functions are not defined,
%       the transfer functions have a value equal to the one specified in the array DefaultValueTFs, following the 
%       order DefaultValueTFs = [tss,tpp,tsp,tps]
%       
%   MakeIntermediatePlots = boolean (optional). Default value = False
%       When set to true, the script genereates intermediate plots.
%
%   FigHandles = 1x6 double (optional)
%       If MakeIntermediatePlots == True, then FigHandles will contain the numerical handles of the figure objects that will be
%       used for the intermediate plots. For example, you can set FigHandles = [1,2,3,4,5,6].

%   OUTPUT ARGUMENTS
%
%   OutputImages = Npolx2 cell array, each cell containing an NxM double matrix
%       OutputImages{j,1} (with 1<=j<=Npol) is the Ex component of the output image when the input image has
%       polarization given by inputpol(:,j)
%       OutputImages{j,2} (with 1<=j<=Npol) is the Ey component of the output image when the input image has
%       polarization given by inputpol(:,j)
%
%   X1D = 1xM double
%       x coordinates of the pixels in the input/output images.
%
%   Y1D = 1xM double
%       y coordinates of the pixels in the input/output images.
%
%   InputImage = NxM double
%       Input image.
%
%   TFs_Fitted = 1x4 cell array
%       The four complex transfer functions, TFs_Fitted = {tss,tpp,tsp,tps}, but fitted on the SAME range of k vectors defined by
%       the fourier transform of the input image. These are the transfer functions that are actually used by the script to calculate the Fourier filtering.
% 
%   Kgrids_Fitted = 1x2 cell array
%       The meshgrids KX and KY associated to the transfer functions, Kgrids_Fitted = {KX,KY}, but fitted on the SAME range of k vectors defined by
%       the fourier transform of the input image.
%
```

## New versions and Tests

If you wish to implement any change to the ```vfip.m``` file, make sure to run the tests inside the ```Test``` folder before submitting a Pull request. Make sure to also change the version of the file in the variable ```version``` defined inside the ```vfip.m``` file.



