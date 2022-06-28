clear 

%% Set options
save_qualities = 0;   % 0 if qualities should not be saved, 1 if qualities are saved
save_bottom = 1;        % 0 if bottom twt should not be saved, 1 otherwise

%% Set saving location etc. 
loc_all_files = 'data/metadata/mergeMCoRDS/*.mat';
outputFileNameBasics = "/mergedLayer_MCoRDS_basics.txt";
outputFileNameIRH = "/mergedLayer_MCoRDS_IRH.txt";

%% Load metadata files
<<<<<<< HEAD
allFiles = dir('data/metadata/06_02/*.mat');
=======
allFiles = dir(loc_all_files);
>>>>>>> 27479309589d7da7e4d674cd1b1d7c99ce9239c6
numberFiles = length(allFiles);

% load all metadata files into allMetadata
for ii = 1:numberFiles
    structName = append('metadata', num2str(ii));
    allMetadata.(structName) = load(fullfile(allFiles(ii).folder, allFiles(ii).name));
end

%% Concacenate layer data
% twt and number of rows is assumed to be the same for all metadata
merged.coordinator = {allMetadata.metadata1.coordinator};
merged.operator = {allMetadata.metadata1.operator};
merged.frequency = allMetadata.metadata1.frequency;
merged.radarType = allMetadata.metadata1.radarType;
merged.twt = allMetadata.metadata1.twt;


% Merge coordinates, layers, ... 
merged.psX = allMetadata.metadata1.psX;
merged.psY = allMetadata.metadata1.psY;
merged.lon = allMetadata.metadata1.lon;
merged.lat = allMetadata.metadata1.lat;
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
merged.interruption = allMetadata.metadata1.interruptions;
merged.filename = allMetadata.metadata1.filename;
merged.trace = allMetadata.metadata1.trace; 

for kk = 2:numberFiles
    currentName = append('metadata', num2str(kk));
    merged.coordinator{kk} = allMetadata.(currentName).coordinator;
    merged.operator{kk} = allMetadata.(currentName).operator;
    merged.psX = cat(2,merged.psX, allMetadata.(currentName).psX);
    merged.psY = cat(2,merged.psY, allMetadata.(currentName).psY);
    merged.lon = cat(2,merged.lon, allMetadata.(currentName).lon);
    merged.lat = cat(2,merged.lat, allMetadata.(currentName).lat);
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
    merged.interruption =  cat(1, merged.interruption, allMetadata.(currentName).interruptions);
    merged.filename = cat(2,merged.filename, allMetadata.(currentName).filename);
    merged.trace = cat(2,merged.trace, allMetadata.(currentName).trace);
end

% split the IRH into the individual layers
numberLayers = size(merged.IRH_twt,1);

for ll = 1:numberLayers
    currentRelIRH = append('relToSurfTwtIRH', num2str(ll));
    currentQuality = append('qualityIRH', num2str(ll));
    merged.(currentRelIRH) = merged.IRH_RelSurfTwt(ll,:)';
    merged.(currentQuality) = merged.qualities(ll,:)';
end

%% Save merged struct into txt files

% save bottom only if desired
if save_bottom
    namesVariables = {'psX', 'psY', 'lon', 'lat', 'trace', 'base', 'surface', 'filename'};
    mergedTable = table(merged.psX', merged.psY', merged.lon', merged.lat', merged.trace', merged.bottomRelSurfTwt', merged.surfaceTwt', merged.filename', 'VariableNames', namesVariables);
else
    namesVariables = {'psX', 'psY', 'lon', 'lat', 'trace', 'surface', 'filename'};
    mergedTable = table(merged.psX', merged.psY', merged.lon', merged.lat', merged.trace', merged.surfaceTwt', merged.filename', 'VariableNames', namesVariables);
end

% save twt of layers first 
for nn = 1:numberLayers
    currentRelIRH = append('relToSurfTwtIRH', num2str(nn));
    %do not save layers if they are not picked
    if sum(isnan(merged.(currentRelIRH))) == length(merged.(currentRelIRH))
        continue
    end
    currentTable = table(merged.(currentRelIRH), 'VariableNames', {append('IRH', num2str(nn))});
    mergedTable = [mergedTable currentTable];
end

% then save quality of layer (if desired)
if save_qualities
    for nn = 1:numberLayers
        currentRelIRH = append('relToSurfTwtIRH', num2str(nn));
        currentQuality = append('qualityIRH', num2str(nn));
        
        %do not save layers if they are not picked
        if sum(isnan(merged.(currentRelIRH))) == length(merged.(currentRelIRH))
            continue
        end
        % correction step for quality due to problem in old picker version
        quality = merged.(currentQuality);
        logInd = isnan(merged.(currentRelIRH));
        quality(logInd) = NaN;

        currentTable = table(quality, 'VariableNames', {append('qualityIRH', num2str(nn))});
        mergedTable = [mergedTable currentTable];
    end
end

% save table to file
<<<<<<< HEAD
outputFileNameIRH = "/mergedLayer.txt";
=======
>>>>>>> 27479309589d7da7e4d674cd1b1d7c99ce9239c6
writetable(mergedTable, append(pwd,'/data/metadata/txtfiles', outputFileNameIRH), 'delimiter', ',')

% write remaining info to extra file
infoCell = {append('frequency: ', merged.frequency), append('radar type: ', merged.radarType), append('Picking date: ', date)};

infoCell{end+1} = [];

for mm = 1:numberFiles
    infoCell{end+1} = append('coordinator', num2str(mm),': ', merged.coordinator{mm});
    infoCell{end+1} = append('operator', num2str(mm),': ', merged.operator{mm});
    infoCell{end+1} = append('original filename', num2str(mm), ': ');
    infoCell{end+1} = append('acquisition date', num2str(mm), ': ');
    %infoCell{end+1} = [append("interruption", num2str(mm), ": "), merged.interruption(mm,:)];
    infoCell{end+1} = [];
end

infoCell{end+1} = 'Column headers are:';
infoCell{end+1} = 'psX: x-coordinate in polar stereographic project 71 south';
infoCell{end+1} = 'psY: y-coordinate in polar stereographic project 71 south';
infoCell{end+1} = 'trace: trace number of the radar transect along-track';
infoCell{end+1} = 'surface: two-way travel time of the surface (when applicable)';
infoCell{end+1} = 'base: two-way travel time of the ice base in seconds from the surface';
infoCell{end+1} = 'IRHx: two-way travel time of the IRH x in seconds from the surface';


infoCell = infoCell';

<<<<<<< HEAD
outputFileNameBasics = "/mergedLayer_basics.txt";
=======
>>>>>>> 27479309589d7da7e4d674cd1b1d7c99ce9239c6
writecell(infoCell, append(pwd,'/data/metadata/txtfiles', outputFileNameBasics), 'delimiter', ' ')