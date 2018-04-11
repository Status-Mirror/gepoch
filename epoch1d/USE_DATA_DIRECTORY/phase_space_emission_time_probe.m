%Plot a heat-map gif for the evolution of a phase space plot

clear all
close all

%Last sdf file to be created
lastSdf = 400;

%Quick pass through entries to find maximum intensity and maximum time
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
    intensitySum(i+1) = sum(saved.Derived.EkBar.Photon.data.*saved.Derived.Number_Density.Photon.data);
end
intensity = intensitySum;
intensity(2:end) = intensitySum(2:end) - intensitySum(1:end-1);
maxInten = max(intensity);
maxTime = saved.time;

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
    probeData = saved.dist_fn.x_px.Probe.data;
    jMax = length(probeData(:,1));
    kMax = length(probeData(1,:));
    probeCounter = 1;
    clear probePlot;
    for j=1:jMax
        for k = 1:kMax
            if probeData(j,k) ~=0
                probePlot(probeCounter,1:3) = [xData(j)*1e6,yData(k)*1.872e24,probeData(j,k)];
                probeCounter = probeCounter+1;
            end
        end
    end
    
    %Create phase-space plot
    yZoom = 1;
    subplot(2,1,1);
    surf(xPlot*1e6,yPlot*1.872e24,zData'+1e-5,'EdgeColor','none'); %'FaceColor','interp');
    hold on;
    plot3(probePlot(:,1),probePlot(:,2),probePlot(:,3),'o', 'MarkerSize', 3, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
    hold off;
    xlabel('x [\mum]');
    ylabel('px [keV]');
    axis([min(xData)*1e6,max(xData)*1e6,min(yData)*1.872e24/yZoom,max(yData)*1.872e24/yZoom,0,1e25]);
    colormap(map);
    ax = gca;
    ax.XAxis.FontSize = 14;
    ax.YAxis.FontSize = 14;
    view(2);
    timeLabel = ['t = ', num2str(saved.time*1e15,'%4.2f') , ' fs'];
    textTag = text(0.9*min(xData)*1e6, 0.9*min(yData)*1.872e24/yZoom, timeLabel);
    textTag.Color = [1 1 1];
    
    %Create intensity plot
    subplot(2,1,2);    
    times(i+1) = saved.time*1e15;
    plot(times,intensity(1:i+1), 'LineWidth', 2.0);
    ax = gca;
    ax.XAxis.FontSize = 14;
    ax.YAxis.FontSize = 14;
    xlabel('Time [fs]');
    ylabel('Intensity [A.U.]');
    axis([0,maxTime*1e15,0,maxInten*1.05]);
    
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