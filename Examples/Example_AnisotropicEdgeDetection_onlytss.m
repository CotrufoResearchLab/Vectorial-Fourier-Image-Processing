%% ANISOTROPIC EDGE DETECTION (only tss is different than zero, see also https://doi.org/10.1364/OPTICA.500121)

clear all; close all;
addpath('../vflip/')

%% General Settings

NA_image = 0.5;
NA_TF = 0.4;

MakeIntermediatePlots = false;
DefaultValueTFs = [1,1,0,0];

input_polarizations = [ [1;0], [0;1] ];
%% Create Input Image

gaussian_noise_average = 0; %Used to add random noise to input signal. Set to zero to deactivate
gaussian_noise_variance = 0; %Used to add random noise to input signal. Set to zero to deactivate
Ny = 400; Nx = 400;
input_image = CreateTestImage_Octagon(Nx,Ny);
input_image = imgaussfilt(input_image,1); %This step is used to make edges a bit smoother, and avoid numerical infinities

%input_image  = input_image+ sqrt(gaussian_noise_variance)*randn(Ny,Nx)+gaussian_noise_average;

%% Set Image Size

dx_m = 0.5/NA_image; % Size of each real space x pixel in units of lambda. 
dy_m = 0.5/NA_image; % Size of each real space y pixel in units of lambda 

%% Transfer Functions

kx = linspace(-NA_TF,NA_TF,100);
ky = linspace(-NA_TF,NA_TF,100);
[KX_TF,KY_TF] = meshgrid(kx,ky);

tss = (KX_TF.^2 + KY_TF.^2)/NA_TF^2;
tpp = 0*tss;
tsp = 0*tss;
tps = 0*tss;

%% Calculations

[OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = ...
    vfip(   input_image, ...
            [dx_m,dx_m], ...
            input_polarizations, ...
            {tss,tpp,tsp,tps}, ...
            {KX_TF,KY_TF}, ...
            DefaultValueTFs, ...
            MakeIntermediatePlots);
%% PLOTS
figure(100);
subplot(2,2,1)
imagesc(X1D,Y1D,abs(OutputImages{1}{1}).^2);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('After filter, |Ex|^2, InputPol = x')
colorbar
subplot(2,2,2)
imagesc(X1D,Y1D,abs(OutputImages{1}{2}).^2);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('After filter, |Ey|^2, InputPol = x')
colorbar
subplot(2,2,3)
imagesc(X1D,Y1D,abs(OutputImages{2}{1}).^2);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('After filter, |Ex|^2, InputPol = y')
colorbar
subplot(2,2,4)
imagesc(X1D,Y1D,abs(OutputImages{2}{2}).^2);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('After filter, |Ey|^2, InputPol = y')
colorbar

OutputImage_UnpolarizedExcitation = (abs(OutputImages{1}{1}).^2+ ...
                                     abs(OutputImages{1}{2}).^2+ ...
                                     abs(OutputImages{2}{1}).^2+ ...
                                     abs(OutputImages{2}{2}).^2)/2;

figure(200);
subplot(1,2,1)
imagesc(X1D,Y1D,abs(input_image).^2);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('Input Image')
colorbar

subplot(1,2,2)
imagesc(X1D,Y1D,OutputImage_UnpolarizedExcitation);
colormap(gray);
xlabel('x [\lambda]')
ylabel('y [\lambda]')
title('After filter, Unpol. Excitation')
colorbar