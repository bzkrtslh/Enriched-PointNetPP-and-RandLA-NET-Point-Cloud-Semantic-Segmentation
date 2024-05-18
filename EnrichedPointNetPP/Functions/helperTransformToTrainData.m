function [cellout,dataout] = helperTransformToTrainData(data,
														numPoints,info,...
                                                        labelIDs,
														classNames)
	if ~iscell(data)
		data = {data};
	end
	
	numObservations = size(data,1);
	cellout 	    = cell(numObservations,2);
	dataout 	    = cell(numObservations,2);
	
	for i = 1:numObservations 
		classification = info.PointAttributes(i).Classification;

		[ptCloudOut,labelsOut] = helperDownsamplePoints(data{i,1}, ...
		classification,numPoints);

		limits = [ptCloudOut.XLimits;
				  ptCloudOut.YLimits;...
				  ptCloudOut.ZLimits];
				  
		ptCloudSparseLocation 	     = ptCloudOut.Location;
		ptCloudSparseLocation(1:2,:) = limits(:,1:2)';
		ptCloudSparseUpdated = pointCloud(ptCloudSparseLocation, ...
										 'Intensity', ptCloudOut.Intensity, ...
										 'Color'    , ptCloudOut.Color, ...
										 'Normal'   , ptCloudOut.Normal);
    
		ptCloudOutSparse = helperNormalizePointCloud(ptCloudSparseUpdated);
		m_location 	     = ptCloudOutSparse.Location;
		m_color 	     = ptCloudOutSparse.Color;
		m_color 	     = normalize(m_color,"range");		
		tmp 		     = [m_location m_color];

		cellout{i,1} = permute(tmp,[1 3 2]);
		cellout{i,2} = permute(categorical(labelsOut,labelIDs,classNames),[1 3 2]);

		dataout{i,1} = ptCloudOutSparse;
		dataout{i,2} = labelsOut;
	end
end