function helperLabelColorbar(ax,classNames)
cmap = [[178 102 255]; % Building - Purple
		[153 76  0  ]; % Roof - Brown
		[255 255 102]; % Door - Yellow
	  % [102 255 255]; % Window - Cyan
	  % [0   255 0  ]; % Vegetation - Green
	  % [255 178 102]  % Ground - Orange
		];
		
cmap = cmap./255;
cmap = cmap(1:numel(classNames),:);
colormap(ax,cmap);

c = colorbar(ax);
c.Color = 'w';

numClasses   = size(classNames,1);
c.Ticks      = 1:1:numClasses;
c.TickLabels = classNames;

c.TickLength = 0;
end