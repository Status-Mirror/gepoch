%Attempts to model synchrotron emission by calculating eta at all points
%using simulation parameters

clear all

%User input
lastSdf = 200; %Last sdf file to be created
cutMean = 0; %What factor * Ps (non-zero values) are we cutting out?

saved = GetDataSDF('0000.sdf');
gridEdges = saved.Grid.Grid.x;
gridWidth = abs(gridEdges(1)-gridEdges(2));
noOfGridPoints = length(saved.Grid.Grid.x);
Ps = zeros(noOfGridPoints-1, lastSdf+1);

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
    
    %Pull out relevant parameters
    vx = saved.Particles.Vx.Electron.data;
    vy = saved.Particles.Vy.Electron.data;
    v = sqrt(vx.^2 + vy.^2);
    gamma = 1./sqrt(1-v.*v/299792458^2);
    ePos = saved.Particles.Vx.Electron.grid.x;
    Ey = saved.Electric_Field.Ey.data;
    Bz = saved.Magnetic_Field.Bz.data;
    
    %Convert ePos to eIndex - the index of the nearest grid-centre
    eIndex = ceil((ePos-gridEdges(1))/gridWidth);
    eta = zeros(length(vx),1);
    for j = 1:length(vx)
        eta(j) = gamma(j)*sqrt((Ey(eIndex(j))-vx(j)*Bz(eIndex(j))).^2)/1.32e18;
        %eta(j) = gamma(j)*sqrt((Ey(eIndex(j))-vx(j)*Bz(eIndex(j))).^2 + (vy(j).*Bz(eIndex(j))).^2)/1.32e18;
        geta = (1 + 4.8*(1+eta(j))*log(1 + 1.7*eta(j)) + 2.44*eta(j)^2)^(-2/3);
        Ps(eIndex(j), i+1) = Ps(eIndex(j),i+1) + 309294.8907*eta(j)*geta;
    end
    
    yData(i+1) = saved.time;
end

%Fix axes for figure
deltaX = gridWidth*0.5;
gridEdges = gridEdges+deltaX; 
gridEdges = gridEdges(1:end-1);
[xPlot,yPlot] = meshgrid(gridEdges,yData);
xData=gridEdges;

%Cut out Ps values up to this factor * mean of non zero cells
k = 1;
PsTemp= zeros(length(Ps(:,1))*length(Ps(1,:)),1);
for i = 1:length(Ps(:,1))
    for j = 1:length(Ps(1,:))
        if Ps(i,j) > 0
            PsTemp(k) = Ps(i,j);
            k = k+1;
        end
    end
end
PsTemp = PsTemp(1:k-1);
meanNonZero = mean(PsTemp); %Found non-zero mean
for i = 1:length(Ps(:,1))
    for j = 1:length(Ps(1,:))
        if Ps(i,j) < cutMean*meanNonZero
            Ps(i,j) = 0;
        end
    end
end

% figure;
surf(xPlot*1e6,yPlot*1e15,Ps'*1e24,'EdgeColor','none'); %'FaceColor','interp');
xlabel('Distance from plasma surface [\mum]');
ylabel('Time [fs]');
axis([min(xData)*1e6,max(xData)*1e6,0,max(yData)*1e15]);
axis ij;
% %Get map:
RED = linspace(1,0,20);
BLUE = linspace(1,1,20);
GREEN = linspace(1,0,20);
colormap([RED(:),GREEN(:),BLUE(:)]);
colormap hot;
colorbar;
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;
view(2);

