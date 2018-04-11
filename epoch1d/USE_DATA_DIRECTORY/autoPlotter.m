%autoPlotter.m
%A script to be called by the autoRun.sh BASH script in order to create a
%plot. MUST BE IN THE FORMAT 1234.sdf TO RUN!!!!

%Collect all files in the current working directory
myFolderInfo = dir('../USE_DATA_DIRECTORY');

%How many .sdf files are there? (Arranged alphabetically, so the last in 
%the loop is the last .sdf file).
for i = 1:length(myFolderInfo)
    testName = myFolderInfo(i).name;
    if length(testName) >= 8
        if testName(end-3:end) == ['.' 's' 'd' 'f']
            lastSDF = str2double(convertCharsToStrings(testName(1:end-4)));
        end
    end
end

%Extract data using functions in another folder
oldpath = path;
path(oldpath,'/home/sjm630/epoch-4.9.2/SDF/Matlab');

%PLOTTING PART STARTS HERE
lastID = 0;
k1=1;
k2=1;
k3=1;
range1(1,1:3)=0;
range2(1,1:3)=0;
range3(1,1:3)=0;
for i = 0:lastSDF
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
    data = GetDataSDF(name);
    
    %Make sure data contains photon information
    if numel(fieldnames(data)) ~= 2
        %Extract parameters
        px = data.Particles.Px.Photon.data;
        py = data.Particles.Py.Photon.data;
        pz = data.Particles.Pz.Photon.data;
        E = sqrt(px.*px + py.*py + pz.*pz)*(3e8);
        idAtIndex = data.Particles.ID.Photon.data;
        
        %indexAtID(ID) = index
        for j=1:length(idAtIndex)
            indexAtID(idAtIndex(j)) = j;
        end
        
        %Only sum over the newest ID, store time, energy, angle in range
        %arrays. Range1 is for all backwards travelling photons. Range 2
        %for photons +/- 18 degrees from negative laser axis. Range 3 for
        %+/- 1.8 degrees from laser axis. 
        for j=lastID+1:length(idAtIndex)
            if px(indexAtID(j)) < 0
                range1(k1,1) = data.time;
                range1(k1,2) = E(indexAtID(j));
                range1(k1,3) = atan(sqrt(py(indexAtID(j)).*py(indexAtID(j))+pz(indexAtID(j)).*pz(indexAtID(j)))./px(indexAtID(j)));
                if range1(k1,3) > -pi/10
                    range2(k2,:)=range1(k1,:);
                    k2=k2+1;
                    if range1(k1,3) > -0.0178
                        range3(k3,:)=range1(k1,:);
                        k3=k3+1;
                    end
                end
                k1=k1+1;
            end
        end
        lastID = j;        
    end
end

%Sum energies which are created in the same timestep
j=1;
energyPlot1(1,1) = range1(1,2);
energyPlot1(1,2) = range1(1,1);
for i = 2:length(range1(:,1))
    %If difference in the time column between successive values
    if range1(i,1) - range1(i-1,1) > 1e-20
        j=j+1;
        energyPlot1(j,1)=0;
        energyPlot1(j,2)=range1(i,1);
    end
    energyPlot1(j,1) = energyPlot1(j,1) + range1(i,2);
end
j=1;
energyPlot2(1,1) = range2(1,2);
energyPlot2(1,2) = range2(1,1);
for i = 2:length(range2(:,1))
    %If difference in the time column between successive values
    if range2(i,1) - range2(i-1,1) > 1e-20
        j=j+1;
        energyPlot2(j,1)=0;
        energyPlot2(j,2)=range2(i,1);
    end
    energyPlot2(j,1) = energyPlot2(j,1) + range2(i,2);
end
j=1;
energyPlot3(1,1) = range3(1,2);
energyPlot3(1,2) = range3(1,1);
for i = 2:length(range3(:,1))
    %If difference in the time column between successive values
    if range3(i,1) - range3(i-1,1) > 1e-20
        j=j+1;
        energyPlot3(j,1)=0;
        energyPlot3(j,2)=range3(i,1);
    end
    energyPlot3(j,1) = energyPlot3(j,1) + range3(i,2);
end

%Format figure
plot(energyPlot1(:,2)*1e15,energyPlot1(:,1)*6.241509647e12,'b','LineWidth',1);
hold on;
plot(energyPlot2(:,2)*1e15,energyPlot2(:,1)*6.241509647e12,'r','LineWidth',1);
plot(energyPlot3(:,2)*1e15,energyPlot3(:,1)*6.241509647e12,'g','LineWidth',1);
ax = gca;
xlabel("Time [fs]");
ylabel("Radiated Energy [MeV]");
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;
grid on;
legend('6.283 sr', '0.308 sr', '0.001 sr');

%Save figure
savefig('output.fig');
saveas(gcf,'output.png');

% PLOTTING PART ENDS HERE

%Restore old path
path(oldpath);

%Exit MATLAB
quit;

