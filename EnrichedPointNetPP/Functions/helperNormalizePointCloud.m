function ptCloudOut = helperNormalizePointCloud(ptCloud)
% The helperNormalizePointCloud function is used to normalize the
% point cloud, such that X-Limits, Y-Limits, Z-Limits of the point cloud
% are in the range [0,1].
%
%   This is an example helper function that is subject to change or removal
%   in future releases.

% Copyright 2021 MathWorks, Inc.

% Normalize the range of the point cloud.
xlim = ptCloud.XLimits;
ylim = ptCloud.YLimits;
zlim = ptCloud.ZLimits;

xyzMin = [xlim(1) ylim(1) zlim(1)];
xyzDiff = [diff(xlim) diff(ylim) diff(zlim)]+eps;


loc = (ptCloud.Location - xyzMin) ./ xyzDiff;


ptCloudOut = pointCloud(loc,'Intensity',ptCloud.Intensity, ...
    'Color',ptCloud.Color, ...
    'Normal',ptCloud.Normal);
end