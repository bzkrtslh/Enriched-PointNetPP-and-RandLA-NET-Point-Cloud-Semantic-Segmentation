function data = helperTransformToTestData(data)
	if ~iscell(data)
		data = {data};
	end
	
	numObservations = size(data,1);
	
	for i = 1:numObservations
	
		m_location = data{i,1}.Location;
		m_color   = data{i,1}.Color;
		m_color   = normalize(m_color,"range");
		tmp 	  = [m_location m_color];
		data{i,1} = permute(tmp,[1 3 2]);
		
	end
end