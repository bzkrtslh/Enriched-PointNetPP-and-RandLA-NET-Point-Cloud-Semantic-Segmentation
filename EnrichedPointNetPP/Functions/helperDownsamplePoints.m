function [ptCloudOut,labelsOut] = helperDownsamplePoints(ptCloud, ...
    labels,numPoints)
% helperDownsamplePoints selects the desired number of points by
% downsampling or replicating the point cloud data.
%
%   This is an example helper function that is subject to change or removal
%   in future releases.

% Copyright 2021 MathWorks, Inc.
persistent pt;
persistent lb;
if ceil(ptCloud.Count/numPoints)>=6
    ptCloudOut = pcdownsample(ptCloud, ...
        'nonuniformGridSample', ceil(ptCloud.Count/numPoints));
else
    ptCloudOut = pcdownsample(ptCloud, 'nonuniformGridSample', 6);
end
[~,LOCB] = ismembertol(ptCloudOut.Location,ptCloud.Location,'ByRows',true);
if ptCloudOut.Count<numPoints && (ptCloudOut.Count~=0)
    labelsOut = labels(LOCB);
    replicationFactor = ceil(numPoints/ptCloudOut.Count);
    ind = repmat(1:ptCloudOut.Count,1,replicationFactor);
    ptCloudOut = select(ptCloudOut,ind(1:numPoints));
    labelsOut = labelsOut(ind(1:numPoints),:);
    pt = ptCloudOut;
    lb = labelsOut;    
elseif ptCloudOut.Count==0
    ptCloudOut = pt;
    labelsOut = lb;
else
    ptCloudOut = select(ptCloud,LOCB(1:numPoints));
    labelsOut = labels(LOCB(1:numPoints));
    pt = ptCloudOut;
    lb = labelsOut; 
end
end