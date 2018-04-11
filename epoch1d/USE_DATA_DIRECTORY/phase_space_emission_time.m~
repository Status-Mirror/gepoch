%Plot a heat-map gif for the evolution of a phase space plot

clear all
close all

%Collect all files in the current working directory
myFolderInfo = dir('.');

%How many .sdf files are there? (Arranged alphabetically, so the last in 
%the loop is the last .sdf file).
for i = 1:length(myFolderInfo)
    testName = myFolderInfo(i).name;
    if length(testName) >= 8
        if testName(end-3:end) == ['.' 's' 'd' 'f']
            lastSdf = str2double(convertCharsToStrings(testName(1:end-4)));
        end
    end
end

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
    time(i+1) = saved.time;
end
intensity = intensitySum;
intensity(2:end) = intensitySum(2:end) - intensitySum(1:end-1);
for i = 2:length(intensity)
    intensity(i) = intensity(i)/(time(i)-time(i-1));
end
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
    
    %Create phase-space plot
    yZoom = 3;
    subplot(2,1,1);
    surf(xPlot*1e6,yPlot*1.872e24,zData'+1e-5,'EdgeColor','none'); %'FaceColor','interp');
    xlabel('x [\mum]');
    ylabel('px [keV]');
    axis([min(xData)*1e6,max(xData)*1e6,min(yData)*1.872e24/yZoom,max(yData)/yZoom,0,1e20]);
    colormap(map);
    ax = gca;
    ax.XAxis.FontSize = 14;
    ax.YAxis.FontSize = 14;
    view(2);
    timeLabel = ['t = ', num2str(saved.time*1e15,'%4.2f') , ' fs'];
    textTag = text(0.9*min(xData)*1e6, 0.9*min(yData)/yZoom, timeLabel);
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