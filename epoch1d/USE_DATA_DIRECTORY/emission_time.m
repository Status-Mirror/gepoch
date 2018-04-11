%Creates a plot of photon emission against time, only for .sdf files which
%have photons which are immobile.

clear all

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
currentCount = 0;
oldCount = 0;
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

%Ensure we only plot change in intensity
intensity = intensitySum;
intensity(2:end) = intensitySum(2:end) - intensitySum(1:end-1);

plot(time(3:end-1)*1e15,intensity(3:end-1),'LineWidth', 1);
xlabel('Time [fs]');
ylabel('Emission [A.U.]');