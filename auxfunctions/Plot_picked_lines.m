figure(3)
imagesc(mag2db(geoinfo.echogram));
colormap(bone)
caxis([-250 -100])
hold on
plot(geoinfo.layer1(:,1),geoinfo.layer1(:,2),'y*') %plot picked line
plot(geoinfoidx,geoinfolayer1_ind,'b*', 'MarkerSize', 16)% this plots the overlapping point in this graph
% smoothed_layer1 = movmean(geoinfo.layer1(:,2),50);
% plot(geoinfo.layer1(:,1),smoothed_layer1,'b*') %plot picked line

figure(4)
imagesc(mag2db(geoinfo3.echogram));
colormap(bone)
caxis([-250 -100])
hold on
plot(geoinfo3.layer1(:,1),geoinfo3.layer1(:,2),'y*') %plot picked line
%plot(geoinfoidx,geoinfolayer1_ind,'b*', 'MarkerSize', 16)% this plots the overlapping point in this graph
% smoothed_layer2 = movmean(geoinfo3.layer1(:,2),50);
% plot(geoinfo3.layer1(:,1),smoothed_layer2,'b*') %plot picked line