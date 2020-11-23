function [ylin]= linear_fit(layer1,kk,window2)
x = layer1(kk-window2:kk-1,1); %trace, average 20 traces
y = layer1(kk-window2:kk-1,2); %yaxis
p = polyfit(x,y,1);
m=p(1,1);
b=p(1,2);
ylin = m*kk+b; %give y value for kk loop 
ylin = round(ylin);
%[r,p_val] = corrcoef(x,y);
end