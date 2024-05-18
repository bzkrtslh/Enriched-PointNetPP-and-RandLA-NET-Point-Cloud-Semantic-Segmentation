function finalLabels = helperInterpolate(densePtCloud, sparsePtCloud, ...
    sparsePredLabels,k,r,maxLabel,numClasses)
% helperInterpolate calculates labels for points in the dense point cloud
% using sparse point cloud and labels predicted on sparse point cloud.
%
%   This is an example helper function that is subject to change or removal
%   in future releases.

% Copyright 2021 MathWorks, Inc.
finalLabels = uint8(zeros(densePtCloud.Count,1));
if canUseParallelPool
    parfor i=1:densePtCloud.Count
        seedPoint = densePtCloud.Location(i,:);
        [indices1,dists] = findNearestNeighbors(sparsePtCloud,seedPoint,k);
        indices = indices1(dists<=r);
        map = zeros(numClasses,1);
        if ~isempty(indices)
            for j=1:length(indices)
                map(sparsePredLabels(indices(j))) = map( ...
                    sparsePredLabels(indices(j)))+1;
            end
            [~,idx] = max(map);
            finalLabels(i) = idx;
        else
            % Assign the most frequent label, in case of no nearest
            % neighbors are found
            finalLabels(i) = maxLabel;
        end
    end
else
    for i=1:densePtCloud.Count
        seedPoint = densePtCloud.Location(i,:);
        [indices1,dists] = findNearestNeighbors(sparsePtCloud,seedPoint,k);
        indices = indices1(dists<=r);
        map = zeros(numClasses,1);
        if ~isempty(indices)
            for j=1:length(indices)
                map(sparsePredLabels(indices(j))) = map( ...
                    sparsePredLabels(indices(j)))+1;
            end
            [~,idx] = max(map);
            finalLabels(i) = idx;
        else
            % Assign the most frequent label, in case of no nearest
            % neighbors are found
            finalLabels(i) = maxLabel;
        end
    end
end
end