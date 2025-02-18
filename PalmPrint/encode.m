function [template, mask] = encode(polar_array, nscales, minWaveLength, mult, sigmaOnf)

[Lx,Ly]=size(polar_array);
if mod(Lx,2)==1
    polar_array = polar_array(1:end-1,:);
end
if mod(Ly,2)==1
    polar_array = polar_array(:,1:end-1);
end

% convolve normalised region with Gabor filters
[E0] = gaborconvolve(polar_array, nscales, minWaveLength, mult, sigmaOnf);

mylength = size(polar_array,2)*2*nscales;

template = zeros(size(polar_array,1), mylength);

length2 = size(polar_array,2);
h = 1:size(polar_array,1);

%create the iris template

mask = zeros(size(template));

for k=1:nscales

    E1 = E0{k};

    %Phase quantisation
    H1 = real(E1) > 0;
    H2 = imag(E1) > 0;

    % if amplitude is close to zero then
    % phase data is not useful, so mark off
    % in the noise mask
    H3 = abs(E1) < 0.0001;


    for i=0:(length2-1)

        ja = double(2*nscales*(i));
        %construct the biometric template
        template(h,ja+(2*k)-1) = H1(h, i+1);
        template(h,ja+(2*k)) = H2(h,i+1);

        %create noise mask
        mask(h,ja+(2*k)-1) = H3(h, i+1);
        mask(h,ja+(2*k)) =   H3(h, i+1);

    end

end