%Plot a heat-map gif for the evolution of a phase space plot

clear all
close all

%Last sdf file to be created
lastSdf = 400;

%Create gif made from heat maps
figure(1);
axis tight manual;
filename = 'phase_space_evolution.gif';
map = ones(100,3);            %To view all points
map(1,:) = [0,0,0];
%map = 'hot';                 %Density information
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
    %Extract parameters
    saved = GetDataSDF(name);
    zData = saved.dist_fn.x_px.Electron.data;
    xData = saved.dist_fn.x_px.Electron.grid.x;
    yData = saved.dist_fn.x_px.Electron.grid.y;
    [xPlot,yPlot] = meshgrid(xData,yData);
    %Create plot
    yZoom = 1;
    surf(xPlot*1e6,yPlot*1.872e24,zData'+1e-5,'EdgeColor','none'); %'FaceColor','interp');
    xlabel('x [\mum]');
    ylabel('px [keV]');
    axis([min(xData)*1e6,max(xData)*1e6,min(yData)*1.872e24/yZoom,max(yData)*1.872e24/yZoom,0,1e20]);
    colormap(map);
    colorbar;
    ax = gca;
    ax.XAxis.FontSize = 14;
    ax.YAxis.FontSize = 14;
    view(2);
    timeLabel = ['t = ', num2str(saved.time*1e15,'%4.2f') , ' fs'];
    textTag = text(0.95*min(xData)*1e6, 0.95*min(yData)*1.872e24/yZoom, timeLabel);
    textTag.Color = [1 1 1];
    
    %gif commands
    drawnow;
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 0
        imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0.05);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.05);
    end
end