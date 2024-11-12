    
%% This script performs a series of sanity checks by considering trivial scenarios for input images and/or transfer functions, 
% and checking that the output image is the expected one

function BasicTests()

    clear all; close all;
    addpath('../vfip/')
    
    MakeIntermediatePlots = false;
    
    tol1 = 1e-3;
    
    
    %% Create Flat Image
    Nx = 100;
    Ny = 100;
    input_image_flat = ones(Ny, Nx);

    %% Create Octagon

    Nx = 200;
    Ny = 200;
    pgon1 = nsidedpoly(8);
    factor = Nx/3;
    xi = pgon1.Vertices(:,1) + 1.5;
    yi = pgon1.Vertices(:,2) + 1.5;
    input_image = poly2mask(factor*xi,factor*yi,Nx,Ny);
    input_image = double(input_image);
    input_image = input_image - min(min(input_image));
    input_image = 0.9*input_image./max(max(input_image));
    input_image = imgaussfilt(input_image,1); %This step is used to make edges a bit smoother, and avoid numerical infinities

    input_image_octagon = input_image;

    %% TEST GROUP 1. Flat Image. Image NA = 0.2. Flat TFs defined over NA = 0.5
    
        input_image = input_image_flat;
        % Set Image Size
        MaxSpatialFrequency = 0.2; %in units of 1\lambda. 
        dx_m = 0.5/MaxSpatialFrequency; % Size of each real space x pixel in units of lambda. 
        dy_m = 0.5/MaxSpatialFrequency; % Size of each real space y pixel in units of lambda 
        
        % Define the TFs
        kx = linspace(-0.5,0.5,50);
        ky = linspace(-0.5,0.5,50);
        [KX_TF,KY_TF] = meshgrid(kx,ky);
        input_polarizations = [ [1;0], [0;1] ];

        DefaultValueTFs = [0,0,0,0];
    
        TestGroup = '1';
        TestGroupDesc = 'Flat Image. Image NA = 0.2. Flat TFs defined over NA = 0.5';
        disp(['Test Group #',TestGroup,':',TestGroupDesc,'...']);
        testset_1()
    
    %% TEST GROUP 2. Flat Image. Image NA = 0.5. Flat TFs defined over NA = 0.2
    
        input_image = input_image_flat;
        % Set Image Size
        MaxSpatialFrequency = 0.5; %in units of 1\lambda. 
        dx_m = 0.5/MaxSpatialFrequency; % Size of each real space x pixel in units of lambda. 
        dy_m = 0.5/MaxSpatialFrequency; % Size of each real space y pixel in units of lambda 
        
        % Define the TFs
        kx = linspace(-0.2,0.2,50);
        ky = linspace(-0.2,0.2,50);
        [KX_TF,KY_TF] = meshgrid(kx,ky);
        input_polarizations = [ [1;0], [0;1] ];

        DefaultValueTFs = [0,0,0,0];
    
        TestGroup = '2';
        TestGroupDesc = 'Flat Image. Image NA = 0.5. Flat TFs defined over NA = 0.2';
        disp(['Test Group #',TestGroup,':',TestGroupDesc,'...']);
        testset_1()    
    
    
    %% TEST GROUP 3. Structured Image. Image NA = 0.2. Flat TFs defined over NA = 0.5

        input_image = input_image_octagon;
        % Set Image Size
        MaxSpatialFrequency = 0.2; %in units of 1\lambda. 
        dx_m = 0.5/MaxSpatialFrequency; % Size of each real space x pixel in units of lambda. 
        dy_m = 0.5/MaxSpatialFrequency; % Size of each real space y pixel in units of lambda 
        
        % Define the TFs
        kx = linspace(-0.5,0.5,50);
        ky = linspace(-0.5,0.5,50);
        [KX_TF,KY_TF] = meshgrid(kx,ky);
        input_polarizations = [ [1;0], [0;1] ];

        DefaultValueTFs = [0,0,0,0];
    
        TestGroup = '3';
        TestGroupDesc = 'Structured Image. Image NA = 0.2. Flat TFs defined over NA = 0.5';
        disp(['Test Group #',TestGroup,':',TestGroupDesc,'...']);
        testset_2()  
    %% TEST GROUP 4. Structured Image. Image NA = 0.5. Flat TFs defined over NA = 0.2

        input_image = input_image_octagon;
        % Set Image Size
        MaxSpatialFrequency = 0.5; %in units of 1\lambda. 
        dx_m = 0.5/MaxSpatialFrequency; % Size of each real space x pixel in units of lambda. 
        dy_m = 0.5/MaxSpatialFrequency; % Size of each real space y pixel in units of lambda 
        
        % Define the TFs
        kx = linspace(-0.2,0.2,50);
        ky = linspace(-0.2,0.2,50);
        [KX_TF,KY_TF] = meshgrid(kx,ky);
        input_polarizations = [ [1;0], [0;1] ];

        DefaultValueTFs = [1,1,0,0];
    
        TestGroup = '4';
        TestGroupDesc = 'Structured Image. Image NA = 0.5. Flat TFs defined over NA = 0.2';
        disp(['Test Group #',TestGroup,':',TestGroupDesc,'...']);
        testset_2() 
%%
function testset_1()    
    % TEST X.1 - Free space, tss = tpp = 1, tsp = tps = 0
        Test = [TestGroup,'.1'];
        TestDesc = 'Free space, tss = tpp = 1, tsp = tps = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = ones(size(KX_TF));
        tpp = ones(size(KX_TF));
        tsp = 0*tss;
        tps = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image remains x-pol when input is x-pol, and viceversa
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},1,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},1,tol1),...
                           ]);
        TestResult(Test,Result);
    
    % TEST X.2 - Anisotropic Free space, tss = 1, tpp = tsp = tps = 0
        Test = [TestGroup,'.2'];
        TestDesc = 'Anisotropic Free space, tss = 1, tpp = tsp = tps = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = ones(size(KX_TF));
        tpp = 0*tss;
        tsp = 0*tss;
        tps = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image remains y-pol when input is y-pol, and otherwise is zero
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},1,tol1),...
                           ]);
        TestResult(Test,Result);
    
    % TEST X.3 - Anisotropic Free space, tpp = 1, tss = tsp = tps = 0
        Test = [TestGroup,'.3'];
        TestDesc = 'Anisotropic Free space, tpp = 1, tss = tsp = tps = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = zeros(size(KX_TF));
        tpp = ones(size(KX_TF));
        tsp = 0*tss;
        tps = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image remains x-pol when input is x-pol, and otherwise is zero
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},1,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},0,tol1),...
                           ]);
        TestResult(Test,Result);
    
    % TEST X.4 - Anisotropic Free space, tsp = 1, tpp = tss = tps = 0
        Test = [TestGroup,'.4'];
        TestDesc = 'Anisotropic Free space, tsp = 1, tpp = tss = tps = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = zeros(size(KX_TF));
        tpp = zeros(size(KX_TF));
        tsp = ones(size(KX_TF));
        tps = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image is y-pol when input is x-pol, and otherwise is zero
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},1,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},0,tol1),...
                           ]);
        TestResult(Test,Result);
    
    % TEST X.5 - Anisotropic Free space, tps = 1, tpp = tss = tsp = 0
        Test = [TestGroup,'.5'];
        TestDesc = 'Anisotropic Free space, tps = 1, tpp = tss = tsp = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = zeros(size(KX_TF));
        tpp = zeros(size(KX_TF));
        tps = ones(size(KX_TF));
        tsp = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image is x-pol when input is y-pol, and otherwise is zero
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},1,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},0,tol1),...
                           ]);
        TestResult(Test,Result);
    
    % TEST X.6 - No transmission, tpp = tss = tsp = tps = 0
        Test = [TestGroup,'.6'];
        TestDesc = 'Anisotropic Free space, tp = 1, tpp = tss = tsp = 0';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = zeros(size(KX_TF));
        tpp = zeros(size(KX_TF));
        tps = tss;
        tsp = tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        %Check the output image is always zero
        Result = all([ CheckImageIsFlatWithinTolerance(OutputImages{1}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           CheckImageIsFlatWithinTolerance(OutputImages{2}{2},0,tol1),...
                           ]);
        TestResult(Test,Result);
end

function testset_2()    
    % TEST X.1 - Free space, tss = tpp = 1, tsp = tps = 0
        Test = [TestGroup,'.1'];
        TestDesc = 'Free space, tss = tpp = 1, tsp = tps = 0. Check Input Image is preserved and with correct polarization';
        disp(['    Test #',Test,':',TestDesc,'...']);
        input_image = input_image_flat;
        
        tss = ones(size(KX_TF));
        tpp = ones(size(KX_TF));
        tsp = 0*tss;
        tps = 0*tss;
    
        [OutputImages, X1D, Y1D, InputImage,TFs_Fitted,Kgrids_Fitted] = vfip(   input_image, [dx_m,dx_m], ...
                                                                                input_polarizations, ...
                                                                                {tss,tpp,tsp,tps}, ...
                                                                                {KX_TF,KY_TF}, ...
                                                                                DefaultValueTFs, MakeIntermediatePlots);
        
        Result = all([  CheckImagesEqualWithinTolerance(abs(OutputImages{1}{1}) , abs(InputImage),tol1),...
                        CheckImagesEqualWithinTolerance(abs(OutputImages{2}{2}) , abs(InputImage),tol1),...
                        CheckImageIsFlatWithinTolerance(OutputImages{1}{2},0,tol1),...
                        CheckImageIsFlatWithinTolerance(OutputImages{2}{1},0,tol1),...
                           ]);
        TestResult(Test,Result);    
end
%% General Purpose Functions
function result = CheckImageIsFlatWithinTolerance(image,constvalue,tol)
    result = and( abs((min(min(image)) - constvalue)) < tol, abs((max(max(image)) - constvalue)) < tol);
end

function result = CheckImagesEqualWithinTolerance(image1,image2,tol)
    result = max(max(abs(image1-image2))) < tol;
end

function TestResult(Test,Result)
    if Result
        disp('Test OK')
    else
        disp('Test not Passed')
    end
end
end