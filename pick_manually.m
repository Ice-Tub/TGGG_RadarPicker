%to fix next
%optimize loop below
%how to start & stop a layer?
%automatically name layers by e.g. profile name and ind below surface pick
%(&maybe by polar x and y)
%automatically zoom into layer
%automatically adjust color bar - by setting the maximum a certain color in

clear all; 
close all;

%TUNING PARAMETERS
window=9; %vertical window, keep small to avoid jumping. Even numbers work as next odd number.
seedthresh=5;% 5 seems to work ok, make bigger to have less, set 0 to take all (but then the line jumps automatically...)
window2=20; %20 slope seems to work, window over which the linear propagation works
%wavelet parameters
wavelet = 'mexh';% choose the wavelet 'mexh' or 'morl' - Mexican Hat (mexh) gives cleaner results 
%wavelet = 'morl';
% define the wavelet scales:
maxwavelet=16; %min is always3, layers size is half the wavelet scale
% decide how many pixels below bed layer is counted as background noise:
%bgSkip = 150; %default is 50 - makes a big difference for m-exh, higher is better
bgSkip = 150;
filename = append(pwd,'\TopoallData_20190107_01_006.mat');
filename_struct = append(pwd,'\geoinfo.mat');
MinBinForSurfacePick = 10;% when already preselected, this can be small
smooth=40; %between 30 and 60 seems to be good
%MinBinForBottomPick = 1500; %should be double-checked on first plot (as high as possible)
MinBinForBottomPick = 1800; 
smooth2=60; %smooth bottom pick, needs to be higher than surface pick, up to 200 ok
RefHeight=500; %set the maximum height for topo correction of echogram, extended to 5000 since I got an error in some profiles
rows=1000:5000; %cuts the radargram to limit processing (time) (top and bottom)
clms=6200:7200; %for 6 
%%
Bottom = clms*0.0+11e-6; %set initial bottom pick as horizontal line 
%will be overwritten by the following

if isfile(filename_struct) % For programming purposes; save preprocessed file on computer to save time.
    load(filename_struct);
else
    [geoinfo,echogram] = readdata2(filename,rows,clms,Bottom); % from ARESELP

    geoinfo.echogram=echogram;

    %pick main reflectors (the bottom pick is very important for background
    %noise associated with mexh wavelet (morl can handle more noise but give less accurate results)
    geoinfo = pick_surface(geoinfo,echogram,MinBinForSurfacePick,smooth);
    geoinfo = pick_bottom(geoinfo,echogram,MinBinForBottomPick,smooth2);

    %make graphic to check main reflectors
    figure(1)
    plotmainpicks(geoinfo,clms)

    %wavelet part
    minscales=3;
    scales = minscales:maxwavelet; % definition from ARESELP
    DIST = (maxwavelet/2); 

    %calculate seedpoints
    [imDat,imAmp, ysrf,ybtm] = preprocessing(geoinfo,echogram);
    peakim = peakimcwt(imAmp,scales,wavelet,ysrf,ybtm,bgSkip); % from ARESELP
    geoinfo.peakim=peakim;

    save(filename_struct, 'geoinfo')
end

[ny nx]=size(geoinfo.echogram);

%seedpt = selectseedpt(geoinfo.peakim); %select seedpoints according to lognormal list, not needed since later we define a threshold
%geolayers = echogram_topo(geolayers,geoinfo,RefHeight);

%%
ind = find(geoinfo.peakim>seedthresh);
[sy,sx]=ind2sub(size(geoinfo.peakim), ind);
[geoinfo.psX,geoinfo.psY] = ll2ps(geoinfo.latitude,geoinfo.longitude); %convert to polar stereographic

f = figure(2); % of flat data with seed points
imagesc(mag2db(geoinfo.echogram));
cini = -150;
colormap(jet)
hold on
plot(sx,sy,'r*') % plot seedpoints
set(gcf,'doublebuffer','on');
a = gca;
set(a,'CLim',[cini-50 cini+50]); % Initial color range

apos=get(a,'position');
set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
bpos=[apos(1) apos(2)-0.05 apos(3)/3 0.05];
cpos=[apos(3)/3+0.15 apos(2)-0.05 0.15 0.05];
dpos=[apos(3)/3+0.32 apos(2)-0.05 0.15 0.05];
epos=[apos(3)/3+0.49 apos(2)-0.05 0.15 0.05];


cmin = round(min(mag2db(geoinfo.echogram),[],'all')+50); 
cmax = round(max(mag2db(geoinfo.echogram),[],'all')-50);

% Create color slider
S = "set(gca,'CLim',[get(gcbo,'value')-50, get(gcbo,'value')+50])";
ui_b = uicontrol('Parent',f,'Style','slider','Units','normalized','Position',bpos,...
              'value',cini,'min',cmin,'max',cmax,'callback',S); % Color slider. Atm it uses fixed max and min values, instead they could be adopted to the file values.
bgcolor = f.Color;
uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)-0.05,bpos(2),0.05,bpos(4)],...
                        'String',num2str(cmin),'BackgroundColor',bgcolor);
uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)-0.05,bpos(2),0.05,bpos(4)],...
                'String',num2str(cmax),'BackgroundColor',bgcolor);
uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)/2-0.15,bpos(2)-0.05,0.3,0.05],...
                'String',append('Color range (value ',char(177),' 50)'),'BackgroundColor',bgcolor);

cl = 1; % Set number of current layers
S = "cl = get(gcbo,'value');";
ui_c = uicontrol('Parent',f,'Style','popupmenu', 'String', {'Layer 1','Layer 2','Layer 3','Layer 4','Layer 5','Layer 6','Layer 7','Layer 8'},'Units','normalized','Position',cpos,...
              'value',cl,'callback',S); % Select to go left or right.
            
leftright = 1; % Go to left or right. lr = 1 -> right, lr = -1 -> left.
S = "leftright = get(gcbo,'value');";
ui_d = uicontrol('Parent',f,'Style','togglebutton', 'String', 'Go to left','Units','normalized','Position',dpos,...
              'value',leftright,'min',1,'max',-1,'callback',S); % Select to go left or right.
          
selection_active = 1; % Selection active, 1 = yes, 0 = no
S = "selection_active = get(gcbo,'value');";
ui_e = uicontrol('Parent',f,'Style','pushbutton', 'String', 'End Selection','Units','normalized','Position',epos,...
              'value',1,'max',0,'callback',S); % Finish selection


%make logical matrix of seeds 
seeds = geoinfo.peakim>seedthresh; % 0 or 1 matrix

%% Figure out cross-overs (load geoinfo3 in this case)
% need to load geoinfo3 manually 

load('geoinfo_3.mat') % added by Falk
%[geoinfo3.psX,geoinfo3.psY] = ll2ps(geoinfo3.latitude,geoinfo3.longitude); %convert to polar stereographic

[xi,yi] = polyxpoly(geoinfo.psX,geoinfo.psY,geoinfo3.psX,geoinfo3.psY); %selecting the polar stereographic 
%coordinates of overlapping profiles
%check
%figure(3)
%plot(geoinfo.psX,geoinfo.psY,'b-o')
%hold on
%plot(geoinfo3.psX,geoinfo3.psY,'r-o')
%plot(xi,yi,'g*')

%round to closest intercept (only use longitude?)
[geoinfoval,geoinfoidx]=min(abs(geoinfo.psX-xi));
geoinfominVal=geoinfo.psX(geoinfoidx);

[geoinfo3val,geoinfo3idx]=min(abs(geoinfo3.psX-xi));
geoinfo3minVal=geoinfo3.psX(geoinfo3idx);

geoinfo3layer1=geoinfo3.layer1(geoinfo3idx,2); %picked index (row below cut data) to move across to other trace
dt=geoinfo3.time_range(2)-geoinfo3.time_range(1);%time step (for traces)

geoinfo3.time_pick_abs=geoinfo3.traveltime_surface(geoinfo3idx)-geoinfo3.time_range(1);
geoinfo3layer1_ind=geoinfo3layer1-(geoinfo3.time_pick_abs/dt); % gives 430 - 215 (surface pick)

%geoinfo.time_range(geoinfo3layer1_ind)-geoinfo3.traveltime_surface(1);
geoinfo.time_pick_abs=geoinfo.traveltime_surface(geoinfoidx)-geoinfo3.time_range(1);
geoinfolayer1_ind=(geoinfo.time_pick_abs/dt)+geoinfo3layer1_ind;
geoinfo.layer1=geoinfo.traveltime_surface*0;
geoinfo.layer1(1,geoinfoidx)=geoinfolayer1_ind;

plot(geoinfoidx,geoinfolayer1_ind,'b*', 'MarkerSize', 16)% this plots the overlapping point in this graph

%% Select starting point
% Make NaN matrix for 8 possible layers
layers = NaN(8,nx);
qualities = NaN(8,nx);
picks = cell(8, 1);

lmid = round(window/2);
while selection_active ==1
disp('Move and zoom if needed. Press any button to start picking the next point.')
pan on;

pause() % you can zoom with your mouse and when your image is okay, you press any key
pan off; % to escape the zoom mode
[x,y,type]=ginput(); %gathers points until return
[x_in,y_in,type_in] = deal(round(x(end)),round(y(end)),type(end));


if type_in == 1
    picks{cl}(end+1,:) = [x_in, y_in]; % Add new picks to pick-cell
    
    layer = layers(cl,:);
    quality = qualities(cl,:);
    isnewlayer = all(isnan(layer), 'all'); % Check if layer is empty (True/False).

    %% Propagate first layer

    x_trace = x_in;
    while ismember(x_trace, 1:nx)

        if x_trace == x_in
            disp('Pick.')
            y_trace = y_in;
            quality(x_trace) = 1;
        elseif any(seeds(current_window,x_trace)) % Check if any seed is in window.
            [lind, ~, value] = find(geoinfo.peakim(current_window,x_trace)); % Q: Does value refer to the strongest seed?
            if length(lind)==1
                disp('One seed - yay')
                y_trace = current_window(lind);
                quality(x_trace)=2;
            else
                disp('###closest seed')
                wdist = abs(lind - lmid);
                lind = lind(value == max(value(wdist == min(wdist)))); % Find closest seed with biggest value. Q: Is biggest the best?
                y_trace = current_window(lind);
                quality(x_trace)=3;
            end
        else
            [~,lind,~,p] = findpeaks(mag2db(geoinfo.echogram(current_window,x_trace))); %need to do this on the bare data.
            if length(lind)==1
                disp('One peak')
                y_trace = current_window(lind);
                quality(x_trace)=4;
            elseif length(lind)>1
                disp('***largest & closest peak.')     
                wdist = 1-abs(2*(lind - lmid)/(window-1));%zwischen 0 und 1, with 1 being closer, so it will have more weight in next step
                lprobability = wdist+p/mean(p); %not perfect, but gives a tool to weigh proximity relativ to brightness 
                [~, indprob] = max(lprobability);
                y_trace = current_window(lind(indprob));
                quality(x_trace)=5;
            else
                disp('No peak. Use previous index for now.')
                % y_trace does not change
                quality(x_trace)=6;
            end  
        end
        layer(x_trace) = y_trace;

        current_window=ceil(y_trace-window/2):floor(y_trace+window/2);

        x_trace = x_trace + leftright; %moves along the traces progressively, according to selected direction
    end
elseif type_in==3
    if leftright ==1
        layer(x_in+1:end) = NaN;
    else
        layer(1:x_in-1) = NaN;
    end
else
    disp('Input type unknown. Only pick with left and right mouse buttons.')
end

layers(cl,:) = layer;
% Plot updated layer
try
    delete(layerplot);
end
    layerplot = plot(1:length(layers),layers,'b-x')
end
%% make loop to perfect line with Golden Points
% Clear Golden Points
clear lgpx
clear lgpy
clear gp_layer1

% Select Golden Points
pan on;
pause() % you can move with your mouse and when your image is okay, you press any key
pan off; % to escape the pan mode
[lgpx lgpy] = ginput();

%%Save Golden Points
gp_layer1(:,1) = lgpx;
gp_layer1(:,2) = lgpy;

startx=round(lgpx(1,1));

%repeat = 1;


% picked_layers(:,1)=1:1:dwidth;
% picked_layers(:,2)=layer1(:,2);
picked_layers=layer1(:,2);
%% stop layer
% select the end of the layer and the add NaNs, i.e. stop layer
[lspx lspy button] = ginput()
lspx=round(lspx);
%%Save everything as NaN behind x stop point, y not important since NaN
stoplayer=layer1(:,1)<lspx;
layer1(:,2)=layer1(:,2).*stoplayer;
layer1(layer1==0)=NaN;
%% save layer
geoinfo.layer1=layer1;
geoinfo.layer1(geoinfoidx,2)=geoinfolayer1_ind; %still keep the overlapping point in the data
