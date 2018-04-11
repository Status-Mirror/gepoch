%figureExtractor.m
%Opens a MATLAB .fig figure and saves the data used to plot it.
clear all

%Open and get current figure handle
open('plot-I5.8e+22-n3.9e+22.fig');
h = gcf;

axesObjs = get(h, 'Children');
dataObjs = get(axesObjs, 'Children');

xdata = get(dataObjs, 'XData');
ydata = get(dataObjs, 'YData');

close all;

%Do stuff with data
k=1;
for i=1:length(xdata)
    for j=1:length(xdata{i,1})
        if(abs(xdata{i,1}(j)) > 1e-6 && abs(ydata{i,1}(j)) > 1)
            xdataAll(k) = xdata{i,1}(j);
            ydataAll(k) = ydata{i,1}(j);
            k=k+1;
        end
    end
 end
plot(xdataAll,ydataAll);

[r,p] = corr(xdataAll',ydataAll');