for i = 2:length(intensity)
    intensity(i) = intensity(i)/(time(i)-time(i-1))
end
plot(time(3:end-1)*1e15,intensity(3:end-1),'LineWidth', 1);
xlabel('Time [fs]');
ylabel('Emission rate [A.U.]');