clear;
load('SWDP.mat')
load('SWobj.mat')
%double(rgb2gray(imread([pwd '\lena_support_diff.png']))).^(1/2)
im_diff = fftshift(I2.^(1/2));
cutoff1 = 0.04; %first mask cutoff
cutoff2 = 0.2; %second mask cutoff
beta = 0.9; %feedback parameter for HIO
n_iter = 30; %number of iterations of HIO per generation
sigma = 3; %start value of sigma for gaussian
gen = 1000; %number of generations

s = abs(ifftshift(ifft2(ifftshift(im_diff.^2)))); %autocorrelation of object
s = s > cutoff1*max(s(:)); %first estimate of support mask

%set up space (R is realspace of object, Sup is suppport mask)
R   = zeros( size(im_diff, 1), size(im_diff, 2), gen+1);
Sup = false( size(im_diff, 1), size(im_diff, 2), gen+1);
Sup(:,:,1) = s;

%Fourier coefficients of diffraction image
F0 = im_diff;

%first iteration
R(:,:,1) = HIO(im_diff,s,F0,beta,n_iter);

% set up Gaussian kernel
x = (1:size(s,2)) - size(s,2)/2;
y = (1:size(s,1)) - size(s,1)/2;
[X, Y] = meshgrid(x, y);
rad = sqrt(X.^2 + Y.^2);

for g = 1:gen %for each further generation
    H = (1/(2*pi*sigma))*exp(-(rad.^2)./(2.*sigma.^2)); %current Guassian
    %apply Guassian filter
    M = abs(ifftshift(ifft2(ifftshift(fftshift(fft2(fftshift(abs(R(:,:,g))))) .* fftshift(fft2(fftshift(H)))))));
    %get new support mask
    Sup(:,:,g+1) = (M >=cutoff2*max(M(:)));
    %get next generation of real space object
    R(:,:,g+1) = HIO(fftshift(fft2(fftshift(R(:,:,g)))),Sup(:,:,g+1),F0,beta,n_iter);
    sigma = 0.99*sigma; %lose 1% of sigma each generation
    if sigma<1.5; sigma = 1.5; end %to minimum of 1.5
    imagesc(abs(R(:,:,g+1))); %display progress
    drawnow;
end
figure;%final result
subplot(1,2,1);
imagesc(abs(R(:,:,gen+1)));
subplot(1,2,2);
imagesc(abs(f));
