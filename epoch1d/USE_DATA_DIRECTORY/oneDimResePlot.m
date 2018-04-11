%Plot a heat-map of a parameter in 1D PIC as a function of time

clear all

%Last sdf file to be created
lastSdf = 200;

%Create array of electron number densities for temporal heat map
for i = 0:lastSdf
    %Filename formatting
    if i < 10
        name = ['000', int2str(i),'.sdf'];
    elseif i < 100
        name = ['00', int2str(i), '.sdf'];
    elseif i < 1000
        name = ['0', int2str(i), '.sdf'];
    else
        name = [int2str(i), '.sdf'];
    end
       
    saved = GetDataSDF(name);
    %heatData = saved.Derived.Number_Density.Electron.data;
    heatData = saved.Electric_Field.Ey.data;
    zData(1:length(heatData), i+1) = heatData;
    xData = saved.Derived.Number_Density.grid.x;
    yData(i+1) = saved.time;
end

deltaX = abs(xData(1)-xData(2))*0.5;
xData(:) = xData(:)+deltaX; 
xData = xData(1:end-1);
[xPlot,yPlot] = meshgrid(xData,yData);

% figure;
surf(xPlot*1e6,yPlot*1e15,zData'+1e-5,'EdgeColor','none'); %'FaceColor','interp');
xlabel('Distance from plasma surface [\mum]');
ylabel('Time [fs]');
axis([min(xData)*1e6,max(xData)*1e6,0,max(yData)*1e15]);
axis ij;
colormap hot;
colorbar;
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;
view(2);