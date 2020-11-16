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
window=8; %vertical window, keep small to avoid jumping
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

%seedpt = selectseedpt(geoinfo.peakim); %select seedpoints according to lognormal list, not needed since later we define a threshold
%geolayers = echogram_topo(geolayers,geoinfo,RefHeight);

%%
ind = find(geoinfo.peakim>seedthresh);
[sy,sx]=ind2sub(size(geoinfo.peakim), ind);
[geoinfo.psX,geoinfo.psY] = ll2ps(geoinfo.latitude,geoinfo.longitude); %convert to polar stereographic

f = figure(2); % of flat data with seed points
imagesc(mag2db(geoinfo.echogram));
cmin = -200;
colormap(jet)
hold on
plot(sx,sy,'r*') % plot seedpoints
set(gcf,'doublebuffer','on');
a = gca;
set(a,'CLim',[cmin cmin+100]);
pos=get(a,'position');
set(a,'position',[pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);

npos=[pos(1) pos(2)-0.05 pos(3)/2 0.05];
S = "set(gca,'CLim',[get(gcbo,'value'), get(gcbo,'value')+100])";

b = uicontrol('Parent',f,'Style','slider','Units','normalized','Position',npos,...
              'value',cmin,'min',-350, 'max',-150,'callback',S);
bgcolor = f.Color;
bl1 = uicontrol('Parent',f,'Style','text','Units','normalized','Position',[npos(1)-0.05,npos(2),0.05,npos(4)],...
                        'String','-350','BackgroundColor',bgcolor);
bl2 = uicontrol('Parent',f,'Style','text','Units','normalized','Position',[npos(1)+npos(3)-0.05,npos(2),0.05,npos(4)],...
                'String','-150','BackgroundColor',bgcolor);
bl3 = uicontrol('Parent',f,'Style','text','Units','normalized','Position',[npos(1)+npos(3)/2-0.15,npos(2)-0.05,0.3,0.05],...
                'String','Color limits (min, min+100)','BackgroundColor',bgcolor);



[dlength dwidth]=size(geoinfo.echogram);
nmax=dwidth;

%make logical matrix of seeds 
seeds = geoinfo.peakim>seedthresh; % 0 or 1 matrix
seeds2 = seeds.*geoinfo.peakim; %back to values

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

[x,y]=ginput() %gathers points until return

startsx=round(x);
%startsx=1; %always start at position 1 - change this later - work in progress
startsy=round(y);
%startsx=1; %starting position is important for success
%startsy=518;
layer1(1,1)=startsx;
layer1(1,2)=startsy;

%% Propagate first layer
for kk=2:(nmax-startsx) %kk is working through the traceskk
    ltrace = layer1(kk-1,1)+1; %moves along the traces progressively, needs to start at 1... 
    %so that trace and index are 1
    layer1(kk,1)=ltrace; %moves along the traces progressively, gives index trace for tracked line
    %%% Step 1 to implement Check if Seed Point is in search windw. If yes take seed point
    current_wind=round(layer1(kk-1,2)-window/2):round(layer1(kk-1,2)+window/2);
    lmid=round((length(current_wind))/2);
    if sum(seeds(current_wind,ltrace))>0
        [lind, type] = find(seeds2(current_wind,ltrace));
        if length(lind)>1
            display('###closest seed')     
            %ldistance = abs(round((lind - lmid)/(window/2));%zwischen 0 und 1 with 0 being the best
            ldistance = abs(round(lind - lmid));%zwischen 0 und 1 with 0 being the best
            [~, indprob] = min(ldistance);
            lind = lind(indprob);
        else
            lind = lind;
            display('One seed - yay')     
        end
      else
        %[lamp, lind,w,p] = findpeaks(geoinfo.echogram(round(layer1(kk-1,2)-window/2):round(layer1(kk-1,2)+window/2),ltrace)); %need to do this on the bare data
        [lamp,lind,w,p] = findpeaks(mag2db(geoinfo.echogram(current_wind,ltrace))); %need to do this on the 
        if length(lind)>1
            display('***largest & closest peak.')     
            ldistance = 1-(abs(round(lind - lmid))/(window/2));%zwischen 0 und 1, with 1 being closer, so it will have more weight in next step
            lprobability = 1.0*ldistance+1.0*p/mean(p); %not perfect, but gives a tool to weigh proximity relativ to brightness 
            [~, indprob] = max(lprobability);
            lind = lind(indprob);
        elseif length(lind)==0
            display('No peak. Use previous index for now.')
            lind = lindlocal(kk-1);
        else
            lind = lind;
            display('One peak')
        end     
      end
    lindlocal(kk)=lind;
    layer1(kk,2) = lind+round(layer1(kk-1,2)-window/2)-1; %upscale local layer to global
end
plot(layer1(:,1),layer1(:,2),'b-x')
repeat_ind =1; 
%% make loop to perfect line with Golden Points
while repeat_ind ==1;
    
%% Clear Golden Points
clear lgpx
clear lgpy
clear gp_layer1

%% Select Golden Points

[lgpx lgpy] = ginput();

%%Save Golden Points
gp_layer1(:,1) = lgpx;
gp_layer1(:,2) = lgpy;

startx=round(lgpx(1,1));

%repeat = 1;

%% Rerun loop with Golden Points

% only fill layer 1 from first golden point onwards

for kk=startx:(nmax-startsx)
    ltrace = layer1(kk-1,1)+1; %moves along the traces progressively
    layer1(kk,1)=ltrace; %moves along the traces progressively, gives index trace for tracked line
    IndexGoldenSeedPoint = find((round(gp_layer1(:,1))-ltrace)==0); %forced through golden point for this trace regardless of window size
    current_wind=round(layer1(kk-1,2)-window/2):round(layer1(kk-1,2)+window/2);
    lmid=round((length(current_wind))/2);  
    qualind(kk,1)=ltrace;%
    if (length(IndexGoldenSeedPoint)>0) 
          display('Golden Point. Oh yes. So easy, take this one.') 
          gind =  round(gp_layer1(IndexGoldenSeedPoint,2)); % this is in global space
          %lind=round(window/2+1)+(gind-(round(layer1(kk-1,2)-window/2)-1)); %translated into local space
          %lind=(gind-(round(layer1(kk-1,2)-window/2)-1));%translated into local space
          lind=(gind-(round(layer1(kk-1,2)-window/2))-1);
          qual=1;
    elseif sum(seeds(current_wind,ltrace))>0
        [lind, type] = find(seeds2(current_wind,ltrace));
        if length(lind)>1
            display('###closest seed')     
            %ldistance = abs(round((lind - lmid)/(window/2));%zwischen 0 und 1 with 0 being the best
            ldistance = abs(round(lind - lmid));%zwischen 0 und 1 with 0 being the best
            [~, indprob] = min(ldistance);
            lind = lind(indprob); % local space
            qual=2;
        else
            lind = lind;
            display('One seed - yay')
            qual=3;
        end
    else
        [lamp, lind,w,p] = findpeaks(mag2db(geoinfo.echogram(current_wind,ltrace))); %need to do this on the 
        if length(lind)>1
            display('***largest & closest peak.')     
            ldistance = 1-(abs(round(lind - lmid))/(window/2));%zwischen 0 und 1, with 1 being closer, so it will have more weight in next step
            lprobability = 1.0*ldistance+1.0*p/mean(p); %not perfect, but gives a tool to weigh proximity relativ to brightness 
            [~, indprob] = max(lprobability);
            lind = lind(indprob);
            qual=4;
        elseif length(lind)==0
            display('No peak. Use previous index for now.')
            lind = lindlocal(kk-1);
            qual=5;
        else
            lind = lind;
            display('One peak')
            qual=6;
        end  
    end
    
%layer1(kk,2) = lind;
    lindlocal(kk)=lind;
    layer1(kk,2) = lind+round(layer1(kk-1,2)-window/2)-1; %upscale local layer to global
    qualind(kk,2) = qual; %populate the quality inducator
%plot(layer1(:,1),layer1(:,2),'r-x')

end
%% plot golden points
figure(2)
imagesc(mag2db(geoinfo.echogram));
caxis([-200 -100])
colormap(jet)
hold on
plot(sx,sy,'r*') % plot seedpoints
plot(layer1(:,1),layer1(:,2),'b-x')

%% prompt to check whether more golden points are needed
    prompt = {'\fontsize{14}Finished line? No=1, Yes=0:'};
    dlg_title = '1';
    num_lines = 1;
    p = 0.5;
    defaultanswer = {'1'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    repeat=inputdlg(prompt,dlg_title,num_lines,defaultanswer,options);
    repeat_ind=str2double(cell2mat(repeat));
end
picked_layers(:,1)=1:1:dwidth;
picked_layers(:,2)=layer1(:,2);
%% stop layer
% select the end of the layer and the add NaNs, i.e. stop layer
[lspx lspy] = ginput()
lspx=round(lspx);
%%Save everything as NaN behind x stop point, y not important since NaN
stoplayer=layer1(:,1)<lspx;
layer1(:,2)=layer1(:,2).*stoplayer;
layer1(layer1==0)=NaN;
%% save layer
geoinfo.layer1=layer1;
geoinfo.layer1(geoinfoidx,2)=geoinfolayer1_ind; %still keep the overlapping point in the data
