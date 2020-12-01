function [geoinfo, tp] = figure_tune(tp,filename_raw_data,filename_geoinfo,create_new_geoinfo,keep_old_picks)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Building a while loop for tuneing the figure parameters.
%presettings_ok = 0;
%while ~presettings_ok
%    
%    presettings_ok = 1;
%end

if isfile(filename_geoinfo) && ~create_new_geoinfo % For programming purposes; save preprocessed file on computer to save time.
    geoinfo = load(filename_geoinfo);
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; % Only needed for old data files
    tp.rows = geoinfo.tp.rows;
    tp.clms = geoinfo.tp.clms;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif 0 % Comment out to get new bottom and seed points of existing LayerData    

    echogram = geoinfo.echogram;
    geoinfo = pick_surface(geoinfo,echogram,tp.MinBinForSurfacePick,tp.smooth_sur);
    geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot);

    %wavelet part
    minscales=3;
    scales = minscales:tp.maxwavelet; % definition from ARESELP

    %calculate seedpoints
    [~,imAmp, ysrf,ybtm] = preprocessing(geoinfo,echogram);
    peakim = peakimcwt(imAmp,scales,tp.wavelet,ysrf,ybtm,tp.bgSkip); % from ARESELP
    geoinfo.peakim = peakim;
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; %
    
    clear peakim imAmp ysrf ybtm echogram scales
     
    geoinfo = rmfield(geoinfo,'layer');
    [geoinfo.psX,geoinfo.psY] = ll2ps(geoinfo.latitude,geoinfo.longitude); %convert to polar stereographic
    
    save(filename_geoinfo, '-struct', 'geoinfo')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    [geoinfo,echogram] = readdata2(filename_raw_data,tp.rows,tp.clms); % from ARESELP

    geoinfo.echogram=echogram;

    %pick main reflectors (the bottom pick is very important for background
    %noise associated with mexh wavelet (morl can handle more noise but give less accurate results)
    geoinfo = pick_surface(geoinfo,echogram,tp.MinBinForSurfacePick,tp.smooth_sur);
    geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot);

    %wavelet part
    minscales=3;
    scales = minscales:tp.maxwavelet; % definition from ARESELP

    %calculate seedpoints
    [~,imAmp, ysrf,ybtm] = preprocessing(geoinfo,echogram);
    peakim = peakimcwt(imAmp,scales,tp.wavelet,ysrf,ybtm,tp.bgSkip); % from ARESELP
    geoinfo.peakim = peakim;
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; %
    
    clear peakim imAmp ysrf ybtm echogram scales
     

    [geoinfo.psX,geoinfo.psY] = ll2ps(geoinfo.latitude,geoinfo.longitude); %convert to polar stereographic

    if isfile(filename_geoinfo) && keep_old_picks
        geoinfo_old = load(filename_geoinfo);
        geoinfo.num_layer = geoinfo_old.num_layer;
        geoinfo.layers = geoinfo_old.layers;
        geoinfo.qualities = geoinfo_old.qualities;
        clear geoinfo_old
    end
    
    geoinfo.tp = tp;
    save(filename_geoinfo, '-struct', 'geoinfo')
end

%make graphic to check main reflectors
figure(1)
plotmainpicks(geoinfo,tp)
end

