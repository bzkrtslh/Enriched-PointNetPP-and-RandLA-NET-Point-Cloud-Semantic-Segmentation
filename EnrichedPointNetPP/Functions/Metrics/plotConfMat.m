function plotConfMat(varargin)

	switch (nargin)
		case 0
		   confmat = 1;
		   labels = {'1'};
		case 1
		   confmat = varargin{1};
		   labels = 1:size(confmat, 1);
		otherwise
		   confmat = varargin{1};
		   labels = varargin{2};
	end

	confmat(isnan(confmat))=0; 
	numlabels = size(confmat, 1);

	confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1);

	% plotting the colors
	imagesc(confpercent);
	title(sprintf('Accuracy: %.2f%%', 100*trace(confmat)/sum(confmat(:))));
	ylabel('True Class'); xlabel('Predicted Class');

	colormap(flipud(gray(256)));

	textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
	textStrings = strtrim(cellstr(textStrings));

	[x,y] = meshgrid(1:numlabels);
	hStrings = text(x(:),y(:),
				    textStrings(:), ...
				   'HorizontalAlignment','center');

	midValue = mean(get(gca,'CLim'));

	textColors = repmat(confpercent(:) > midValue,1,3);
	set(hStrings,{'Color'},num2cell(textColors,2));

	labels = ["Building","Ground","Roof"];

	if numlabels == 3
		labels = ["Building","Roof","Ground"];
	elseif numlabels == 4
		labels = ["Building","Roof","Door","Window"];
	elseif numlabels == 6
		labels = ["Building","Roof","Door","Window","Vegetation","Ground"];
	end


	% Setting the axis labels
	set(gca,'XTick',1:numlabels,...
			'XTickLabel',labels,...
			'YTick',1:numlabels,...
			'YTickLabel',labels,...
			'TickLength',[0 0]);
end





