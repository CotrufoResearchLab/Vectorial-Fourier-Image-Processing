function [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(inputimage,px_size,inputpol,TFs,Kgrids,DefaultValueTFs,MakeIntermediatePlots, FigHandles)
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
%       each time assuming an image with the same shape (given by inputimage) and with polarization vector equal to inputpol(:,j). Accordingly,
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

arguments
    inputimage (:,:) double
    px_size (1,2) double
    inputpol (2,:) double
    TFs 
    Kgrids
    DefaultValueTFs (1,4) double = [0,0,0,0]
    MakeIntermediatePlots logical = false
    FigHandles (1,6) double = [1,2,3,4,5,6];
end

version = '0.2_20241117';
disp(['vfip version = ',version])

[~,Npol] = size(inputpol);

% Validate input: TFs
    if or( not(iscell(TFs)), not(isequal(size(TFs),[1,4])) )
        error('The input argument ''TFs'' must be a 1x4 cell array');
        return
    end
    
    tss = TFs{1,1};
    tpp = TFs{1,2};
    tsp = TFs{1,3};
    tps = TFs{1,4};
    
    if ~all([ismatrix(tss),ismatrix(tpp),ismatrix(tsp),ismatrix(tps)])
        error('The elements of input argument ''TFs'' must be a matrices');
        return
    end
    
    if ~all([isequal(size(tss),size(tpp)), isequal(size(tss),size(tsp)), isequal(size(tss),size(tps)),])
        error('The elements of input argument ''TFs'' must be matrices with the same size');
        return
    end

% Validate input: Kgrids
    if or( not(iscell(Kgrids)), not(isequal(size(Kgrids),[1,2])) )
        error('The input argument ''Kgrids'' must be a 1x2 cell array');
        return
    end
    
    KX_TF = Kgrids{1,1};
    KY_TF = Kgrids{1,2};
    
    if ~all([ismatrix(KX_TF),ismatrix(KY_TF)])
        error('The elements of input argument ''Kgrids'' must be a matrices');
        return
    end
    
    if ~isequal(size(KX_TF),size(KY_TF))
        error('The elements of input argument ''Kgrids'' must be matrices with the same size');
        return
    end
    
    if ~isequal(size(tss),size(KX_TF))
        error('The meshgrids contained in the input argument ''Kgrids'' must have the same size as the transfer functions defined in the input argument ''TFs''');
        return
    end

% INPUT IMAGE
    dx_m = px_size(1);
    dy_m = px_size(2);
    [Ny,Nx] = size(inputimage);
    X1D = dx_m.*[-Nx/2:Nx/2];
    Y1D = dy_m.*[-Ny/2:Ny/2];
    
    % PLOT IMAGE IN REAL SPACE
    if MakeIntermediatePlots
        figure(FigHandles(1));clf(FigHandles(1));
        imagesc(X1D,Y1D,abs(inputimage));
        colormap(gray);
        xlabel('x [\lambda]')
        ylabel('y [\lambda]')
        title('Input Image (absolute value)')
    end

% TRANSFER FUNCTIONS, PLOT

if MakeIntermediatePlots

    figure(FigHandles(2));clf(FigHandles(2));
    sgtitle('Transfer Functions passed to the script')

        subplot(2,4,1)
        pcolor(KX_TF,KY_TF,abs(tss))
        shading flat        
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{ss}|')
        subplot(2,4,5)
        pcolor(KX_TF,KY_TF,angle(tss))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{ss})')

        subplot(2,4,2)
        pcolor(KX_TF,KY_TF,abs(tpp))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{pp}|')
        subplot(2,4,6)
        pcolor(KX_TF,KY_TF,angle(tpp))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{pp})')

        subplot(2,4,3)
        pcolor(KX_TF,KY_TF,abs(tsp))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{sp}|')
        subplot(2,4,7)
        pcolor(KX_TF,KY_TF,angle(tsp))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{sp})')

        subplot(2,4,4)
        pcolor(KX_TF,KY_TF,abs(tps))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{ps}|')
        subplot(2,4,8)
        pcolor(KX_TF,KY_TF,angle(tps))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{ps})')
end

%CALCULATE FOURIER TRANSFORM of input image
%NOTE: the maximum value of the k vector is determined by the size of the pixels of the input image
%fft2 calculates the 2-D FFT, then we need to use fftshift to reshape the image 
%in order to shift the origin to the center 

dfy = 1/(Ny*dy_m);
dfx = 1/(Nx*dx_m);
ky  = (-0.5/dy_m:dfy:(0.5/dy_m-1/(Ny*dy_m)));
kx  = (-0.5/dx_m:dfx:(0.5/dx_m-1/(Nx*dx_m)));
FFT_inputimage = fftshift(fft2(inputimage));
[KX,KY] = meshgrid(kx,ky);

if MakeIntermediatePlots

    figure(FigHandles(3));clf(FigHandles(3));

    subplot(1,2,1)
    pcolor(KX,KY,log(abs(FFT_inputimage))); shading flat;
    colormap (gray); axis equal; axis tight;
    xlabel('k_x/k_0'); ylabel('k_y/k_0');
    title('log|Amplitude| ')
    
    subplot (1,2,2)
    pcolor(KX,KY,(angle(FFT_inputimage))); shading flat;
    colormap (gray); axis equal; axis tight;
    xlabel('k_x/k_0'); ylabel('k_y/k_0');
    title('Phase')

    sgtitle('Fourier transform of input image')
end


% %Test: Let's check that we get the same image by just doing anti-Fourier transform
% imageB = ifft2(ifftshift(FFT_input_image));
% figure(21);clf(21);
% imagesc(X1D,Y1D,abs(imageB));
% xlabel('x [\lambda]')
% ylabel('y [\lambda]')
% title('Original image (Amplitude only), |f(x,y)|, after Fourier and anti-Foruier transform')
% colormap(gray);
% 
% [sy,sx] = size(FFT_input_image);
% 
% 
% 	max_theta = asind(NA_image);
%     kmax = sind(max_theta);
%     kx_list = linspace(-kmax,kmax,sx);
%     ky_list = linspace(-kmax,kmax,sy);
%     [KX,KY] = meshgrid(kx,ky);


% Before performing the Fourier filtering, we need to make sure that the numerically calculated TFs are defined 
% on the same grid of (kx,ky) points as the Fourier Transform of the input image.
% To this aim, we interpolate the TFs over the grid of points defined by Kx and KY.

    tss_fitted_ampl = interp2(KX_TF,KY_TF, abs(tss),KX,KY,'linear',abs(DefaultValueTFs(1)));
    tss_fitted_phase = interp2(KX_TF,KY_TF, angle(tss),KX,KY,'linear',angle(DefaultValueTFs(1)));
    tpp_fitted_ampl = interp2(KX_TF,KY_TF, abs(tpp),KX,KY,'linear',abs(DefaultValueTFs(2)));
    tpp_fitted_phase = interp2(KX_TF,KY_TF, angle(tpp),KX,KY,'linear',angle(DefaultValueTFs(2)));
    tsp_fitted_ampl = interp2(KX_TF,KY_TF, abs(tsp),KX,KY,'linear',abs(DefaultValueTFs(3)));
    tsp_fitted_phase = interp2(KX_TF,KY_TF, angle(tsp),KX,KY,'linear',angle(DefaultValueTFs(3)));
    tps_fitted_ampl = interp2(KX_TF,KY_TF, abs(tps),KX,KY,'linear',abs(DefaultValueTFs(4)));
    tps_fitted_phase = interp2(KX_TF,KY_TF, angle(tps),KX,KY,'linear',angle(DefaultValueTFs(4)));

    tss_fitted = tss_fitted_ampl .* exp((1j)*tss_fitted_phase);
    tpp_fitted = tpp_fitted_ampl .* exp((1j)*tpp_fitted_phase);
    tsp_fitted = tsp_fitted_ampl .* exp((1j)*tsp_fitted_phase);
    tps_fitted = tps_fitted_ampl .* exp((1j)*tps_fitted_phase);

% Plot the interpolated TFs (just to check)
if MakeIntermediatePlots
    figure(FigHandles(4));clf(FigHandles(4));

        subplot(2,4,1)
        pcolor(KX,KY,abs(tss_fitted))
        shading flat        
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{ss}|')
        subplot(2,4,5)
        pcolor(KX,KY,angle(tss_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{ss})')

        subplot(2,4,2)
        pcolor(KX,KY,abs(tpp_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{pp}|')
        subplot(2,4,6)
        pcolor(KX,KY,angle(tpp_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{pp})')

        subplot(2,4,3)
        pcolor(KX,KY,abs(tsp_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{sp}|')
        subplot(2,4,7)
        pcolor(KX,KY,angle(tsp_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{sp})')

        subplot(2,4,4)
        pcolor(KX,KY,abs(tps_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();clim([0 1]);
        title('|t_{ps}|')
        subplot(2,4,8)
        pcolor(KX,KY,angle(tps_fitted))
        shading flat
        ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();
        title('phase(t_{ps})')

       sgtitle('Transfer Functions passed to the script and fitted over the sp.frequency range of the input image')
end

% Fourier Filtering

%% CALCULATIONS

% First, we need to calculate the elements of the matrix M which is needed to convert from s-p basis to x-y basis (see the paper)

%
%   M =  (  -cos theta sin phi, cos theta cos phi)    = (  h1   ,   h2)
%        (    cos phi            ,   sin phi      )     (  h3   ,   h4)
%

h3 = KX./(sqrt(KX.^2 + KY.^2));
h4 = KY./(sqrt(KX.^2 + KY.^2));

%The next two rows take care of fixingthe behaviour at normal incidence,
%where phi is not defined. With this choice, we ensure that at normal
%incidence s-pol coincides with y-pol and p-pol coincides with x-pol
h3(isnan(h3)) = 1;
h4(isnan(h4)) = 0;

h1 = -  sqrt(1-(KX.^2 + KY.^2)) .*h4 ;
h2 = +  sqrt(1-(KX.^2 + KY.^2)) .*h3 ;

if MakeIntermediatePlots
    figure(FigHandles(5));clf(FigHandles(5));
    subplot(2,2,1)
    pcolor(KX,KY,h1); ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();shading flat;
    title('-cos(theta)sin(phi)')
    colorbar()
    subplot(2,2,2)
    pcolor(KX,KY,h2); ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();shading flat;
    title('cos(theta)cos(phi)')
    colorbar()
    subplot(2,2,3)
    pcolor(KX,KY,h3); ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();shading flat;
    title('cos(phi)')
    colorbar()
    subplot(2,2,4)
    pcolor(KX,KY,h4); ylabel('k_y/k_0'); xlabel('k_x/k_0');set(gca,'Fontsize',16);colorbar();shading flat;
    title('sin(phi)')
    colorbar()

    sgtitle('Elements of the matrix M (see paper for definition)')
end
    
% We sweep over all input polarizations
if MakeIntermediatePlots
    figure(FigHandles(6));clf(FigHandles(6));
end
OutputImages = cell(1,Npol);
for j = 1:Npol
    Ex = inputpol(1,j);
    Ey = inputpol(2,j);
    norm = sqrt(abs(Ex)^2 + abs(Ey)^2);
    Ex = Ex/norm;
    Ey = Ey/norm;
    
    %Calculate input fields in s and p basis
    
    E_s_in = FFT_inputimage .*( Ex*h1 + Ey*h2 );
    E_p_in = FFT_inputimage .*( Ex*h3 + Ey*h4 );
    
    %Calculate transmitted fields in s and p basis 
    E_s_out  = tss_fitted.*E_s_in   +   tsp_fitted.*E_p_in;
    E_p_out  = tps_fitted.*E_s_in   +   tpp_fitted.*E_p_in;
    
    % To Transform to x-y basis we need to calcualte the inverse of M (see paper)
    %
    %
    %   inv(M) = 1/det(M) * (  h4   ,   -h2)
    %                       (  -h3   ,   h1)
    %
    detM = (h1.*h4)-(h2.*h3);
    
    Ex_out = ((1./detM).* ((      h4.*E_s_out)        -       (h2.*E_p_out))  );
    Ey_out = ((1./detM).* ((      -(h3.*E_s_out))     +       (h1.*E_p_out))  );
    
    %Now we apply the anti-Fourier transform to the filtered Fourier transform
    Ex_realspace_afterfilter = ifft2(ifftshift(Ex_out));
    Ey_realspace_afterfilter = ifft2(ifftshift(Ey_out));
    
    if MakeIntermediatePlots
        figure(FigHandles(6));
    
        subplot(Npol,2,1+(j-1)*2)
        imagesc(X1D,Y1D,abs(Ex_realspace_afterfilter).^2);
        colormap(gray);
        xlabel('x [\lambda]')
        ylabel('y [\lambda]')
        title(['After filter, |Ex|^2, InputPol = #',num2str(j)])
        colorbar
        subplot(Npol,2,2+(j-1)*2)
        imagesc(X1D,Y1D,abs(Ey_realspace_afterfilter).^2);
        colormap(gray);
        xlabel('x [\lambda]')
        ylabel('y [\lambda]')
        title(['After filter, |Ey|^2, InputPol = #',num2str(j)])
        colorbar
    end

OutputImages{j}{1} = Ex_realspace_afterfilter;
OutputImages{j}{2} = Ey_realspace_afterfilter;

end

X1D = X1D;
Y1D = Y1D;
InputImage = inputimage;
TFs_Fitted = {tss_fitted, tpp_fitted, tsp_fitted, tps_fitted};
Kgrids_Fitted = {KX,KY};

end