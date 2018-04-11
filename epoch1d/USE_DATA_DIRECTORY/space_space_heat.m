saved = GetDataSDF('0150.sdf');
heatData = saved.dist_fn.px_py.Photon.data;
xData = saved.dist_fn.px_py.Photon.grid.x;
yData = saved.dist_fn.px_py.Photon.grid.y ;

% % Not needed for dist_fn data
% deltaX = abs(xData(1)-xData(2))*0.5;
% xData(:) = xData(:)+deltaX; 
% xData = xData(1:end-1);
% 
% deltaY = abs(yData(1)-yData(2))*0.5;
% yData(:) = yData(:)+deltaY; 
% yData = yData(1:end-1);

[xPlot,yPlot] = meshgrid(xData,yData);

% for i = 1:200
%     for j = 1:200
%         if heatData(i,j) > 10^20
%             heatData(i,j) = 0;
%         end
%     end
% end

surf(xPlot*3e8/1.6e-19,yPlot*3e8/1.6e-19,heatData','EdgeColor','none','FaceColor','interp');
view(2);