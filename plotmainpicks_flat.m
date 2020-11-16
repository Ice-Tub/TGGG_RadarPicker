 function plotmainpicks_flat(geoinfo,clms,rows)
%figure(1)
imagesc(clms,rows,mag2db(geoinfo.FlatData));
%imagesc(fliplr(clms),geoinfo.time_range,(mag2db(echogram)));
colormap(bone)
colorbar
hold on 
plot(clms,fliplr(geoinfo.traveltime_surface),'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_surface),'Linewidth',2)
hold on
plot(clms,fliplr(geoinfo.traveltime_bottom),'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_bottom),'Linewidth',2)
hold off
 end