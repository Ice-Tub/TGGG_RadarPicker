clear 

%% Load metadata files
allFiles = dir('data/metadata/*.mat');
numberFiles = length(allFiles);

% load all metadata files into allMetadata
for ii = 1:numberFiles
    structName = append('metadata', num2str(ii));
    allMetadata.(structName) = load(fullfile(allFiles(ii).folder, allFiles(ii).name));
end

%% Concacenate layer data
% twt and number of rows is assumed to be the same for all metadata
merged.coordinator = allMetadata.metadata1.coordinator;
merged.operator = allMetadata.metadata1.operator;
merged.frequency = allMetadata.metadata1.frequency;
merged.radarType = allMetadata.metadata1.radarType;
merged.twt = allMetadata.metadata1.twt;


% Merge coordinates, layers, ... 
merged.psX = allMetadata.metadata1.psX;
merged.psY = allMetadata.metadata1.psY;
%merged.lon = allMetadata.metadata1.lon;
%merged.lat = allMetadata.metadata1.lat;
%merged.bottomBin = allMetadata.metadata1.bottom_bin;
merged.bottomTwt = allMetadata.metadata1.bottom_twt;
%merged.bottomRelSurfBin = allMetadata.metadata1.bottom_relto_surf_bin;
merged.bottomRelSurfTwt = allMetadata.metadata1.bottom_relto_surf_twt;
%.surfaceBin = allMetadata.metadata1.surface_bin;
merged.surfaceTwt = allMetadata.metadata1.surface_twt;
%merged.IRH_bin = allMetadata.metadata1.IRH_bin;
merged.IRH_twt = allMetadata.metadata1.IRH_twt;
%merged.IRH_RelSurfBin = allMetadata.metadata1.IRH_relto_surf_bin;
merged.IRH_RelSurfTwt = allMetadata.metadata1.IRH_relto_surf_twt;
merged.qualities = allMetadata.metadata1.qualities;
merged.interruption = allMetadata.metadata1.interruptions';
%merged.pickingDates = allMetadata.metadata1.pickingDates';

for kk = 2:numberFiles
    currentName = append('metadata', num2str(kk));
    merged.psX = cat(2,merged.psX, allMetadata.(currentName).psX);
    merged.psY = cat(2,merged.psY, allMetadata.(currentName).psY);
    %merged.lon = cat(2,merged.lon, allMetadata.(currentName).lon);
    %merged.lat = cat(2,merged.lat, allMetadata.(currentName).lat);
    %merged.bottomBin = cat(2,merged.bottomBin, allMetadata.(currentName).bottom_bin);
    merged.bottomTwt = cat(2,merged.bottomTwt, allMetadata.(currentName).bottom_twt);
    %merged.bottomRelSurfBin = cat(2,merged.bottomRelSurfBin, allMetadata.(currentName).bottom_relto_surf_bin);
    merged.bottomRelSurfTwt = cat(2,merged.bottomRelSurfTwt, allMetadata.(currentName).bottom_relto_surf_twt);
    %merged.surfaceBin = cat(2,merged.surfaceBin, allMetadata.(currentName).surface_bin);
    merged.surfaceTwt = cat(2,merged.surfaceTwt, allMetadata.(currentName).surface_twt);
    %merged.IRH_bin = cat(2,merged.IRH_bin, allMetadata.(currentName).IRH_bin);
    merged.IRH_twt = cat(2,merged.IRH_twt, allMetadata.(currentName).IRH_twt);
    %merged.IRH_RelSurfBin = cat(2,merged.IRH_RelSurfBin, allMetadata.(currentName).IRH_relto_surf_bin);
    merged.IRH_RelSurfTwt = cat(2,merged.IRH_RelSurfTwt, allMetadata.(currentName).IRH_relto_surf_twt);
    merged.qualities = cat(2,merged.qualities, allMetadata.(currentName).qualities);
    merged.interruption = cat(2,merged.interruption, allMetadata.(currentName).interruptions');
    %merged.pickingDates = cat(2,merged.pickingDates, allMetadata.(currentName).pickingDates');
end

% split the IRH into the individual layers
numberLayers = size(merged.IRH_twt,1);

for ll = 1:numberLayers
    currentIRH = append('twtIRH', num2str(ll));
    currentRelIRH = append('relToSurfTwtIRH', num2str(ll));
    merged.(currentIRH) = merged.IRH_twt(ll,:)';
    merged.(currentRelIRH) = merged.IRH_RelSurfTwt(ll,:)';
end

%% Save merged struct into txt file
mergedTable = [merged.bottomTwt' merged.bottomRelSurfTwt' merged.surfaceTwt'];
namesVariables = {'bottomTwt', 'bottomTwtRelToSurf', 'surfaceTwt'};

for nn = 1:numberLayers
    currentIRH = append('twtIRH', num2str(nn));
    currentRelIRH = append('relToSurfTwtIRH', num2str(nn));
    mergedTable = cat(2, mergedTable, merged.(currentIRH));
    mergedTable = cat(2, mergedTable, merged.(currentRelIRH));
end

outputFileName = "/mergedLayer.txt";
writetable(table(mergedTable), append(pwd,'/data/metadata', outputFileName), 'delimiter', ' ')