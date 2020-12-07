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
    tp.num_bottom_peaks = geoinfo.tp.num_bottom_peaks; 
else
    geoinfo = readdata2(filename_raw_data,tp.rows,tp.clms); % from ARESELP
end
%pick main reflectors (the bottom pick is very important for background
%noise associated with mexh wavelet (morl can handle more noise but give less accurate results)
geoinfo = pick_surface(geoinfo,geoinfo.echogram,tp.MinBinForSurfacePick,tp.smooth_sur);
geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot, tp.num_bottom_peaks);
   

%make graphic to check main reflectors
f1 = figure(1);
imagesc(tp.clms,geoinfo.time_range,(mag2db(geoinfo.echogram)));
%imagesc(fliplr(clms),geoinfo.time_range,(mag2db(echogram)));
colormap(bone)
colorbar
hold on 
plot(tp.clms,geoinfo.traveltime_surface,'Linewidth',2);
hold on
botplot = plot(tp.clms,geoinfo.traveltime_bottom,'Linewidth',2);
hold on
set(gcf,'doublebuffer','on');
a = gca;

apos=get(a,'position');
set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
bpos=[apos(1) apos(2)-0.03 0.12 0.05];
%cpos=[0.27 apos(2)-0.05 0.12 0.05];
%dpos=[0.40 apos(2)-0.05 0.12 0.05];
epos=[0.53 apos(2)-0.05 0.12 0.05];
fpos=[0.66 apos(2)-0.05 0.12 0.05];

S = "tp.num_bottom_peaks = get(gcbo,'value'); geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot, tp.num_bottom_peaks); set(botplot(end),'YData',geoinfo.traveltime_bottom)";
ui_b = uicontrol('Parent',f1,'Style','edit','String',int2str(tp.num_bottom_peaks),'Units','normalized','Position',bpos,...
    'value',tp.num_bottom_peaks,'callback',S); % Choose layer.
uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[bpos(1),bpos(2)-0.05,bpos(3),bpos(4)],...
                'String','num_bottom_peaks','BackgroundColor',f1.Color);
            
%S = "disp(get(gcbo,'value')); tp.clms = [get(gcbo,'value'):tp.clms(end)]";
%ui_c = uicontrol('Parent',f1,'Style','edit','String',int2str(tp.clms(1)),'Units','normalized','Position',cpos,...
%    'value',tp.num_bottom_peaks,'callback',S); % Choose layer.
%uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[cpos(1),cpos(2)-0.05,cpos(3),cpos(4)],...
%                'String','start','BackgroundColor',f1.Color);
            
%S = "tp.num_bottom_peaks = get(gcbo,'value'); geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot, tp.num_bottom_peaks); set(botplot(end),'YData',geoinfo.traveltime_bottom)";
%ui_d = uicontrol('Parent',f1,'Style','edit','String',int2str(tp.clms(end)),'Units','normalized','Position',dpos,...
%    'value',tp.num_bottom_peaks,'callback',S); % Choose layer.
%uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[dpos(1),dpos(2)-0.05,dpos(3),dpos(4)],...
%                'String','end','BackgroundColor',f1.Color);
        
leftright = 1; % Go to left or right. lr = 1 -> right, lr = -1 -> left.
S = "leftright = get(gcbo,'value');";
ui_e = uicontrol('Parent',f1,'Style','togglebutton', 'String', 'Go left','Units','normalized','Position',epos,...
              'value',leftright,'min',1,'max',-1,'callback',S); % Select to go left or right.
 
S = "set(ui_f, 'UserData', 0);";
ui_f = uicontrol('Parent',f1,'Style','pushbutton', 'String', 'Bottom correct','Units','normalized','Position',fpos,...
              'Callback',S,'UserData', 1); % Finish selection

dt=geoinfo.time_range(2)-geoinfo.time_range(1);
t1=geoinfo.time_range(1);
    
iteration = 1;
while get(ui_f, 'UserData')
    if iteration == 1
        disp('Move and zoom if needed. Press enter to start picking.')
        pan on;
        pause(); % you can zoom with your mouse and when your image is okay, you press any key
        pan off; % to escape the zoom mode
        if ~get(ui_f, 'UserData')
            break
        end
        disp('Pick the first point. Only the last click is saved, confirm pick with enter.')
        iteration = iteration + 1;
    else
        disp('Pick next point. To move or zoom, press enter.')
    end

    [x,y,type]=ginput(); %gathers points until return

    if ~get(ui_f, 'UserData')
        break
    end

    if ~isempty(x)
        [x_in,y_in,type_in] = deal(round(x(end)),y(end),type(end));
    else
        [x_in,y_in,type_in] = deal(x,y,type);
    end
    
    if type_in == 1
        pos = x_in - (tp.clms(1) - 1);
        Ind = round((y_in - t1)/dt)-tp.MinBinForBottomPick; % Add new picks to pick-cell
        
        
        db_echogram = mag2db(geoinfo.echogram);
        horizontal_mean = mean(db_echogram,2);    
        normalized_echogram = db_echogram - horizontal_mean;
        
        FirstArrivalInds = ((geoinfo.traveltime_bottom - t1)/dt);
        FirstArrivalInds(pos) = Ind + tp.MinBinForBottomPick;
        for n=pos+1:min([geoinfo.num_trace,pos+100])
            [~,Ind] = findpeaks(normalized_echogram(tp.MinBinForBottomPick:end,n));
            [~, pos] = min(abs(Ind-FirstArrivalInds(n-1)));
            FirstArrivalInds(n) = Ind(pos) + tp.MinBinForBottomPick;
        end
    
    %FirstArrivalInds = floor(movmean(FirstArrivalInds,smooth2));
    FirstArrivalInds = FirstArrivalInds;

    Bottom_pick_time=(FirstArrivalInds*dt)+t1;
    geoinfo.traveltime_bottom=Bottom_pick_time;
    elseif type_in==3
    elseif isempty(type_in)
        disp('Move and zoom. To continue picking, press enter.')
        pan on;
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        pan off; % to escape the zoom mode
        if ~get(ui_f, 'UserData')
            break
        end
    else
        disp('Input type unknown. Only pick with left and right mouse buttons.')
    end
    
try
    delete(botplot);
end
botplot = plot(tp.clms,geoinfo.traveltime_bottom,'Linewidth',2);
hold on
end
hold off
