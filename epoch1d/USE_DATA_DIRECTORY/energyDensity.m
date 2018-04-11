%Plot a heat-map of photon energy density

clear all
close all

%Last sdf file to be created
lastSdf = 400;

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
    heatDataNumDens = saved.Derived.Number_Density.Photon.data;
    heatDataEkbar = saved.Derived.EkBar.Photon.data;
    heatData = heatDataNumDens.*heatDataEkbar;
    zData(1:length(heatData), i+1) = heatData;
    xData = saved.Derived.Number_Density.grid.x;
    yData(i+1) = saved.time;
end

deltaX = abs(xData(1)-xData(2))*0.5;
xData(:) = xData(:)+deltaX; 
xData = xData(1:end-1);
[xPlot,yPlot] = meshgrid(xData,yData);

zDataSum = zData;
for i = 2:length(zData(1,:))
    zData(:,i) = zData(:,i)-zDataSum(:,i-1);
end

%Heat map for emitted energy per cell over time
figure;
surf(xPlot*1e6,yPlot*1e15,zData'+1e-5,'EdgeColor','none'); %'FaceColor','interp');
xlabel('x [\mum]');
ylabel('Time [fs]');
axis([min(xData)*1e6,max(xData)*1e6,0,max(yData)*1e15]);
axis ij;
colormap hot;
colorbar;
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;
view(2);

%Plot showing energy emission integrated over position over time
figure;
startX = 313;
endX = 446;
startY = 151;
endY = 191;
for i = 1:length(zData(1,startY:endY))        %time subset
    fig2x(i) = yData(i+(startY-1))*1e15;         %get times
    fig2y(i) = sum(zData(startX:endX,i+(startY-1))); %get energies from subset of positions
end
plot(fig2x,fig2y, 'LineWidth', 1);
xlabel('Time [fs]');
ylabel('Emission [A.u.]');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

%Fourier transform of emission data
figure(1);
fftIn = fig2y;
L = length(fig2y);
if mod(fig2y,2) == 1
    L = L-1;
    fftIn = fftIn(1:end-1);
end
fftOut = fft(fftIn);
P2 = abs(fftOut/L);
P1 = P2(1:L/2 + 1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1/(yData(2)-yData(1))*(0:L/2)/L;
T = 1./f;
plot(T*1e15,P1/max(P1),'LineWidth',1);
xlabel('Period [fs]');
ylabel('Amplitude [A.u.]');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;