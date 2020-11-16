 function plotmainpicks(geoinfo,clms)
%figure(1)
imagesc(clms,geoinfo.time_range,(mag2db(geoinfo.echogram)));
%imagesc(fliplr(clms),geoinfo.time_range,(mag2db(echogram)));
colormap(bone)
colorbar
hold on 
plot(clms,geoinfo.traveltime_surface,'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_surface),'Linewidth',2)
hold on
plot(clms,geoinfo.traveltime_bottom,'Linewidth',2)
%plot(fliplr(clms),(geoinfo.traveltime_bottom),'Linewidth',2)
hold off
 end