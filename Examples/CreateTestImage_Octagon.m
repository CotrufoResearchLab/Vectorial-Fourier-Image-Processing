function image = CreateTestImage_Octagon(Nx,Ny)
%Make Octagon
    pgon1 = nsidedpoly(8);
    factor = Nx/3;
    xi = pgon1.Vertices(:,1) + 1.5;
    yi = pgon1.Vertices(:,2) + 1.5;
    image = poly2mask(factor*xi,factor*yi,Nx,Ny);
    image = double(image);
    %
    image = image - min(min(image));
    image = image./max(max(image));
end

