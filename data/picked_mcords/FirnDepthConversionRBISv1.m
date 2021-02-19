clear all
close all

%needs the path to other functions
addpath('D:\Radar\src\AuxFunctions');
%addpath('D:\Radar\src\AuxFunctions\segymat-master');

%create a string of file names
myDir = cd; %folder with data to be processed, needs to be open as 'Current Folder'
myFiles = dir(fullfile(myDir,'LayerData_002.mat')); %gets all mat files in struct

MaxDepth=1000;dz=0.001; % in meters.
%% Get a density-depth profile
z=0:dz:MaxDepth;rho = 910-460*exp(-0.025*z);%for DIR, RBIS 910-460*exp(-0.033*z)
%% Get velocity-depth profile 
%% Kovacs et al.; Cold Regions Science and Technology 23 (1995) 245-256 
%% (Kovacs this makes v_ice approx 1.685e8, check specific gravity again)
er = (1 + 0.845*rho/985).^2; % 985 empiric to derive specific density (unitless)
v = 3e8./sqrt(er);

%% link between velocity and traveltime
%% consider for small delta t that the density/velocity is constant
IntervalDeltaT = [0 diff(z)]./v;            %Delta t needed to travel through dz at depth z
TravelTimeDepth = cumsum(IntervalDeltaT);   %Time at depth z

%loop through data and create flattened files
for k = 1:length(myFiles)
    FileName = myFiles(k).name;
    fprintf(1, 'Now reading %s\n', FileName);
    Data = importdata(FileName);  
    dt=Data.time_range(91)-Data.time_range(90);
    DistanceIRH = Data.distance;
    Data.layers_time=Data.layers_relto_surface*dt;
    Data.layers_firncorr_depth=Data.layers_time;

 for nn = 1:size(Data.layers_relto_surface,1)
    %bottom_relto_surface=Data.traveltime_bottom-Data.traveltime_surface;
    %Bed_layer=bottom_relto_surface;
    %Traveltime_bed = Bed_layer;
    TraveltimeIRH=Data.layers_time(nn,:);
   
%% Now find the closest TravelTime to the IRH TravelTime
for kk=1:length(DistanceIRH)
   [MinVal, IndMinVal] = min(abs(TravelTimeDepth-TraveltimeIRH(kk)));
   DepthIRH(kk) = z(IndMinVal)/2;
   DepthIRH(kk)=DepthIRH(kk)-Data.elevation_surface(kk); 
end

%DepthIRH(DepthIRH==0)=NaN;
%elevation_bed=Data.elevation_surface-DepthIRH; 
Data.layers_firncorr_depth(nn,:)=DepthIRH;
%Data.layers_firncorr_depth(Data.layers_time==NaN)=NaN;   

 end
end

