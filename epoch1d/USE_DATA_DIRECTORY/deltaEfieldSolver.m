%deltaEfieldSolver calculates synchrotron emission based on decrease in
%laser energy

clear all

%Last sdf file to be created
lastSdf = 200;
intensity = 1.0e22; % In W/cm2
wavelength = 1e-6; % In m

E2Amp = 2*intensity*1.0e4/3e8/8.854e-12;
omega = 1.885e9/wavelength;

saved = GetDataSDF('0000.sdf');
gridEdges = saved.Grid.Grid.x;
gridWidth = abs(gridEdges(1)-gridEdges(2));
gridCentres = gridEdges(1:end-1) + 0.5 * gridWidth;
noOfGridPoints = length(saved.Grid.Grid.x);

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
    heatData = saved.Electric_Field.Ey.data;
    zData(1:length(heatData), i+1) = heatData.^2;
    xData = saved.Derived.Number_Density.grid.x;
    yData(i+1) = saved.time;
end

deltaX = abs(xData(1)-xData(2))*0.5;
xData(:) = xData(:)+deltaX; 
xData = xData(1:end-1);
[xPlot,yPlot] = meshgrid(xData,yData);

%Obtain a matrix detailing the expected EM field without loss
zDataNoLoss = zData*0;
for i = 1:length(yData)
    numGrid = 1;
    if (3e8*yData(i) < gridCentres(end)-gridCentres(1))
        while gridCentres(numGrid) < 3e8*(yData(i)) + gridCentres(1)
            zDataNoLoss(numGrid,i) = E2Amp*sin(omega*(yData(i) - gridCentres(numGrid)/3e8)).^2;
            numGrid = numGrid + 1;
        end
    else
        zDataNoLoss(numGrid,i) = E2Amp*sin(omega*(yData(i) - gridCentres(numGrid)/3e8)).^2;
        numGrid = numGrid + 1;
    end
end

yDataEnergyLoss = yData*0;
for i = 2:length(yData)
    yDataEnergyLoss(i) = sum(zDataNoLoss(:,i)-zData(:,i));
end

plot(yData*1e15,yDataEnergyLoss/max(yDataEnergyLoss),'LineWidth', 1);
xlabel('Time [fs]');
ylabel('Cumulative Energy Loss [A.U.]');