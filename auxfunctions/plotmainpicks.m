 function plotmainpicks(geoinfo,tp)
%figure(1)
imagesc(tp.clms,geoinfo.time_range,(mag2db(geoinfo.echogram)));
%imagesc(fliplr(clms),geoinfo.time_range,(mag2db(echogram)));
colormap(bone)
colorbar
hold on 
plot(tp.clms,geoinfo.traveltime_surface,'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_surface),'Linewidth',2)
hold on
plot(tp.clms,geoinfo.traveltime_bottom,'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_bottom),'Linewidth',2)
hold off

% Building a gui for tuning parameters:
%f = gcf;
%a = gca;

%apos=get(a,'position');
%set(a,'position',[apos(1) apos(2) apos(3)-0.15 apos(4)]);
%bpos=[apos(1)+apos(3)+0.03 apos(2)+apos(4)-0.1 0.12 0.05];
%bpos_txt=[apos(1)+apos(3)+0.03 apos(2)+apos(4)-0.045 0.12 0.03];
%dpos=[apos(3)/3+0.28 apos(2)-0.05 0.12 0.05];
%epos=[apos(3)/3+0.41 apos(2)-0.05 0.12 0.05];
%fpos=[apos(3)/3+0.54 apos(2)-0.05 0.12 0.05];

%S = "tp.rows = get(gcbo,'value');";
%ui_b = uicontrol('Parent',f,'Style','edit','Units','normalized','Position',bpos,...
%              'value',tp.rows,'callback',S); % Color slider. Atm it uses fixed max and min values, instead they could be adopted to the file values.
%bgcolor = f.Color;
%uicontrol('Parent',f,'Style','text','Units','normalized','Position',bpos_txt,...
%                'String','Rows','BackgroundColor',bgcolor);


 end