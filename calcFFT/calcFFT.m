function outgrains = calcFFT(inebsd,ingrains)
%% Function description:
% Returns the Fast Fourier Transforms (FFTs) of individual grains.
% The real and complex FFTs are returned in grided format within the 
% 'grains.prop.fftReal' and 'grains.prop.fftComplex' structure variables.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax:
%  [grains] = calcFFT(ebsd,grains)
%
%% Input:
%  ebsd         - @EBSD
%  grains       - @grain2d
%
%% Output:
%  grains       - @grain2d
%%

if isempty(inebsd) || isempty(ingrains)
    return; 
end

if ~isa(inebsd,'EBSD')
    error('To create FFTs, first input must be an EBSD variable.');
    return;
end

if ~isa(ingrains,'grain2d')
    error('To create FFTs, second input must be a grain2d variable.');
    return;
end

outgrains = ingrains;

for ii = 1:length(outgrains)

    ggrain = gridify(inebsd(ingrains(ii)));

    % create a grid of the grain
    if any(ismember(fields(ggrain.prop),'imagequality'))
        binaryImg = ggrain.prop.imagequality;
    elseif any(ismember(fields(ggrain.prop),'iq'))
        binaryImg = ggrain.prop.iq;
    elseif any(ismember(fields(ggrain.prop),'bandcontrast'))
        binaryImg = ggrain.prop.bandcontrast;
    elseif any(ismember(fields(ggrain.prop),'bc'))
        binaryImg = ggrain.prop.bc;
    elseif any(ismember(fields(ggrain.prop),'bandslope'))
        binaryImg = ggrain.prop.bandslope;
    elseif any(ismember(fields(ggrain.prop),'bs'))
        binaryImg = ggrain.prop.bs;
%     elseif any(ismember(fields(ggrain.prop),'oldId'))
%         binaryImg = ggrain.prop.oldId;
%     elseif any(ismember(fields(ggrain.prop),'grainId'))
%         binaryImg = ggrain.prop.grainId;
%     elseif any(ismember(fields(ggrain.prop),'confidenceindex'))
%         binaryImg = ggrain.prop.confidenceindex;
%     elseif any(ismember(fields(ggrain.prop),'ci'))
%         binaryImg = ggrain.prop.ci;
%     elseif any(ismember(fields(ggrain.prop),'fit'))
%         binaryImg = ggrain.prop.fit;
%     elseif any(ismember(fields(ggrain.prop),'semsignal'))
%         binaryImg = ggrain.prop.semsignal;
%     elseif any(ismember(fields(ggrain.prop),'mad'))
%         binaryImg = ggrain.prop.mad;
%     elseif any(ismember(fields(ggrain.prop),'error'))
%         binaryImg = ggrain.prop.error;
    end

    % replace NaNs with zeros
    binaryImg(isnan(binaryImg)) =  0;

    % pad binary image to the nearest square
    % From https://au.mathworks.com/matlabcentral/answers/1853683-change-an-image-from-rectangular-to-square-by-adding-white-area
    nrows = size(binaryImg,1);
    ncols = size(binaryImg,2);
    d = abs(ncols-nrows);    % find the difference between ncols and nrows
    if(mod(d,2) == 1)        % if the difference is an odd number
        if (ncols > nrows)   % add a row at the end
            binaryImg = [binaryImg; zeros(1, ncols)];
            nrows = nrows + 1;
        else                 % add a col at the end
            binaryImg = [binaryImg zeros(nrows, 1)];
            ncols = ncols + 1;
        end
    end
    if ncols > nrows
        binaryImg = padarray(binaryImg, [(ncols-nrows)/2 0]);
    else
        binaryImg = padarray(binaryImg, [0 (nrows-ncols)/2]);
    end

    % FFT of the greyscale grain (complex)
    fftComplex = fftshift(fft2((binaryImg)));


    % FFT of the binarised grain (real)
    binaryImg(binaryImg>0) =  1;
    fftReal = abs(log2(fftshift(fft2(binaryImg))));

    % save the FFTs to the grain variable
    outgrains.prop.fftComplex{ii,1} = fftComplex;
    outgrains.prop.fftReal{ii,1} = fftReal;

    % update progress
    progress(ii,length(outgrains));
    pause(0.0001);
end

% check if the user has not specified an output variable
if nargout == 0
    assignin('base','grains',outgrains);
end
end
