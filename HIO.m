function [rs_output] = HIO(init_input,support,F0,beta, n_iter)
%% Hybrid input output algorithm, [Fienup, 1982]
%Inputs:
%   init_input: initial diffraction pattern
%   support: support mask
%   F0: original diffraction pattern
%   beta: feedback parameter
%   n_iter: number of iterations
%Ouputs:
%   rs_output: the real space estimatation of the object

g = ifftshift(ifft2(ifftshift((init_input)))); %initial i
for iter = 1:n_iter
    
    F = fftshift(fft2(fftshift((g))));
    F_satis = F0.*exp(1j.*angle(F));
    g_dash = ifftshift(ifft2(ifftshift((F_satis))));
    violate_cond = ~support | (real(g_dash)<0);
    g_next = g_dash;
    g_next(violate_cond) =  g(violate_cond) - beta.*g_dash(violate_cond);
    
    g = g_next;

end
rs_output = g_dash;
end

