function [geoinfo, opt] = compute_seeds(geoinfo,tp,opt)
%COMPUTE_SEEDS Summary of this function goes here
%   Detailed explanation goes here
if ~isfield(opt,'update_seeds')
    opt.update_seeds = 0;
end

if strcmpi(opt.input_type, 'MCoRDS')
    minscales=3;
    scales = minscales:tp.maxwavelet; % definition from ARESELP

    %calculate seedpoints
    [~,imAmp, ysrf,ybtm] = preprocessing(geoinfo);
    peakim = peakimcwt(imAmp,scales,tp.wavelet,ysrf,ybtm,tp.bgSkip); % from ARESELP
    geoinfo.peakim = peakim;
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; %

    clear peakim imAmp ysrf ybtm echogram scales
elseif strcmpi(opt.input_type, 'GPR_LF')
    geoinfo.peakim =  zeros(size(geoinfo.data));
end
end

