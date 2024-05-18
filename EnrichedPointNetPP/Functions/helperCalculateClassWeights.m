function [weights, maxLabel, maxWeight] = helperCalculateClassWeight(fileset,numClasses)
% helperCalculateClassWeights computes weights of each class in the point cloud.
%
% This is an example helper function that is subject to change or removal
% in future releases.

% Copyright 2022 MathWorks, Inc.
weights = zeros(1,numClasses);

for i = 1:fileset.NumFiles
    lasReader = lasFileReader(fileset.FileInfo.Filename(i));
    for j=1:numClasses
        try
            weights(j) = weights(j) + lasReader.ClassificationInfo.("Number of Points by Class")(lasReader.ClassificationInfo.("Classification Value") == j);
        catch
            continue
        end
    end
end

[maxWeight,maxLabel] = max(weights);
weights = sqrt(maxWeight./weights);
end