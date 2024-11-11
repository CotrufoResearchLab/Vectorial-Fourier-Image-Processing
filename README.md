# Vectorial Fourier Image Processing (vfip)
A Matlab script to calculate the filtering/processing performed on an optical image by an optical element (such as a thin metasurface) characterized by angle-dependent vectorial transfer functions.

The script implements the mathematical steps outlined in [this](https://www.sciencedirect.com/science/article/pii/S0079663824000027) paper 
(Note: there are a couple of typos in the equations in the published paper. 
The typos have been annotated in [this](https://github.com/CotrufoResearchLab/Vectorial-Fourier-Image-Processing/blob/main/Paper/2024%20-%20Progress%20in%20Optics%20-%20Cotrufo%2C%20Alu%20-%20Metamaterials%20for%20analog%20all-optical%20computation.pdf) pdf file. 
Make sure to open the file with Acrobat Reader to see the comments).

See files in the ```Examples``` folder to learn how to use the script. See docstring in the file [vfip.m](https://github.com/CotrufoResearchLab/Vectorial-Fourier-Image-Processing/blob/main/vfip/vfip.m) for a description of the input and output parameters.

If you wish to implement any change to the ```vfip.m``` file, make sure to run the tests inside the ```Test``` folder before submitting a Pull request.

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
%       Normalized vector describing the polarization(s) of the input image(s). if Npol=1, only one input image (with a
%       certain polarization) is assumed. If Npol>1 the scripts will repeata the calculations N times, each time assuming
%       an image with a shape given by inputimage and with polarization vector equal to inputpol(:,j). Accordingly,
%       multiple output images will be returned
%       If the polarization vector is not normalized, the script normalizes it
%
%   TFs = 1x4 cell array. 
%       The four complex transfer functions, TFs = {tss,tpp,tsp,tps}. Each transfer function is a rectangular matrix.
%       The four matrices must have the same size. The size of these matrices does not need to match the size of
%       inputimage
%
%   Kgrids = 1x2 cell array
%       The meshgrids KX and KY associated to the transfer functions, Kgrids = {KX,KY}. KX and KY are meshgrids with the
%       same size as the transfer functions
%
%   DefaultValueTFs = 1x4 double (optional). Default value = [0,0,0,0]
%       If the k-space range over which the transfer functions are defined is smaller than the k-space range of the
%       Fourier transform of the image, the script will assume that, in the region where the transfer functions are not defined,
%       the transfer functions have a value equal to the one specified in the array DefaultValueTFs, following the 
%       order DefaultValueTFs = [tss,tpp,tsp,tps]
%       
%
%   MakeIntermediatePlots = boolean (optional). Default value = False
%
%   FigHandles = 1x6 double (optional)
%       If MakeIntermediatePlots == True, then FigHandles will contain the handles of the figure objects that will be
%       used for the intermediate plots

%   OUTPUT ARGUMENTS
%
%   OutputImages = Npolx2 cell array, each cell containing an NxM double matrix
%       OutputImages{i,1} (with 1<=i<=Npol) is the Ex component of the output image when the input image has
%       polarization given by inputpol(2,i)
%       OutputImages{i,2} (with 1<=i<=Npol) is the Ey component of the output image when the input image has
%       polarization given by inputpol(2,i)
%
%   X1D = 1xM double
%       x coordinates of the pixels in the input/output images
%
%   Y1D = 1xM double
%       y coordinates of the pixels in the input/output images
%
%   InputImage = NxM double
%       Input image
%
%   TFs_Fitted = 1x4 cell array
%       The four complex transfer functions, TFs_Fitted = {tss,tpp,tsp,tps}, but fitted on the SAME range of k vectors defined by
%       the fourier transform of the input image 
% 
%   Kgrids_Fitted = 1x2 cell array
%       The meshgrids KX and KY associated to the transfer functions, Kgrids_Fitted = {KX,KY}, but fitted on the SAME range of k vectors defined by
%       the fourier transform of the input image 
%
```

