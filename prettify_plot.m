function prettify_plot(sameXLimits, sameYLimits, figureColor, titleFontSize, labelFontSize, generalFontSize, pointSize, lineThickness, textColor)
% make current figure pretty
% ------
% Inputs
% ------
% - sameXLimits: string. Either: 
%       - 'none': don't change any of the xlimits 
%       - 'all': set all xlimits to the same values 
%       - 'row': set all xlimits to the same values for each subplot row
%       - 'col': set all xlimits to the same values for each subplot col
% - sameYLimits: string. Either: 
%       - 'none': don't change any of the xlimits 
%       - 'all': set all xlimits to the same values 
%       - 'row': set all xlimits to the same values for each subplot row
%       - 'col': set all xlimits to the same values for each subplot col
% - figureColor: string (e.g. 'w', 'k', ..) or RGB value defining the plots
%       background color. 
% - titleFontSize: double
% - labelFontSize: double
% - generalFontSize: double
% - pointSize: double
% - lineThickness: double
% - textColor: double
% ------
% to do:
% - option to adjust vertical and horiz. lines 
% - padding
% - fit data to plot (adjust lims)
% - font 
% - padding / suptitles 
% ------
% Julie M. J. Fabre

    % Set default parameter values
    if nargin < 1 || isempty(sameXLimits)
        sameXLimits = 'all';
    end
    if nargin < 2 || isempty(sameYLimits)
        sameYLimits = 'all';
    end
    if nargin < 3 || isempty(figureColor)
        figureColor = 'w';
    end
    if nargin < 4 || isempty(titleFontSize)
        titleFontSize = 18;
    end
    if nargin < 5 || isempty(labelFontSize)
        labelFontSize = 15;
    end
    if nargin < 6 || isempty(generalFontSize)
        generalFontSize = 13;
    end
    if nargin < 7 || isempty(pointSize)
        pointSize = 15;
    end
    if nargin < 8 || isempty(lineThickness)
        lineThickness = 2;
    end
    if nargin < 9 || isempty(textColor)
        % Set default font color based on the input color
        switch figureColor
            case 'k'
                textColor = 'w';
            case 'none'
                textColor = [0.7, 0.7, 0.7]; % Gray
            otherwise
                textColor = 'k';
        end
    end
    
    % Get handles for current figure and axis
    currFig = gcf;
    
    
    % Set color properties for figure and axis
    set(currFig, 'color', figureColor);
    
    % get axes children 
    all_axes = find(arrayfun(@(x) contains(currFig.Children(x).Type, 'axes'), 1:size(currFig.Children,1)));

    for iAx = 1:size(all_axes,2)
        thisAx = all_axes(iAx);
        currAx = currFig.Children(thisAx);
        set(currAx, 'color', figureColor);
        if ~isempty(currAx)
            % Set font properties for the axis
            set(currAx.XLabel, 'FontSize', labelFontSize, 'Color', textColor);
            set(currAx.YLabel, 'FontSize', labelFontSize, 'Color', textColor);
            set(currAx.Title, 'FontSize', titleFontSize, 'Color', textColor);
            set(currAx, 'FontSize', generalFontSize, 'GridColor', textColor, ...
                        'YColor', textColor, 'XColor', textColor, ...
                        'MinorGridColor', textColor);
            
            % Adjust properties of line children within the plot
            childLines = findall(currAx, 'Type', 'line');
            for thisLine = childLines'
                if strcmp('.', get(thisLine, 'Marker'))
                    set(thisLine, 'MarkerSize', pointSize);
                end
                if strcmp('-', get(thisLine, 'LineStyle'))
                    set(thisLine, 'LineWidth', lineThickness);
                end
            end
            
            % Get x and y limits 
            xlims_subplot(iAx,:) = get(gca, 'XLim');
            ylims_subplot(iAx,:) = get(gca, 'YLim');

            % Get plot position
            pos_subplot(iAx,:) = currAx.Position(1:2); % [left bottom width height]
        end
    end


    % make x and y lims the same 
    if ismember(sameXLimits, {'all', 'row', 'col'}) || ismember(sameYLimits, {'all', 'row', 'col'})
        % get rows and cols 
        col_subplots = unique(pos_subplot(:,1));
        row_subplots = unique(pos_subplot(:,2));

        col_xlims = arrayfun(@(x) [min(min(xlims_subplot(pos_subplot(:,1)==col_subplots(x),:))),...
            max(max(xlims_subplot(pos_subplot(:,1)==col_subplots(x),:)))], 1:size(col_subplots,1), 'UniformOutput', false);
        row_xlims = arrayfun(@(x) [min(min(xlims_subplot(pos_subplot(:,2)==row_subplots(x),:))),...
            max(max(xlims_subplot(pos_subplot(:,2)==row_subplots(x),:)))], 1:size(row_subplots,1), 'UniformOutput', false);
        col_ylims = arrayfun(@(x) [min(min(ylims_subplot(pos_subplot(:,1)==col_subplots(x),:))),...
            max(max(ylims_subplot(pos_subplot(:,1)==col_subplots(x),:)))], 1:size(col_subplots,1), 'UniformOutput', false);
        row_ylims = arrayfun(@(x) [min(min(ylims_subplot(pos_subplot(:,2)==row_subplots(x),:))),...
            max(max(ylims_subplot(pos_subplot(:,2)==row_subplots(x),:)))], 1:size(row_subplots,1), 'UniformOutput', false);

        for iAx = 1:size(all_axes,2)
            thisAx = all_axes(iAx);
            currAx = currFig.Children(thisAx);
            if ~isempty(currAx)
                if ismember(sameXLimits, {'all'})
                    set(currAx, 'Xlim', [ min(min(xlims_subplot)), max(max(xlims_subplot))]);
                end
                if ismember(sameYLimits, {'all'})
                    set(currAx, 'Ylim', [ min(min(ylims_subplot)), max(max(ylims_subplot))]);
                end
                if ismember(sameXLimits, {'row'})
                    set(currAx, 'Xlim', row_xlims{pos_subplot(iAx,2)==row_subplots});
                end
                if ismember(sameYLimits, {'row'})
                    set(currAx, 'Ylim', row_ylims{pos_subplot(iAx,2)==row_subplots});
                end
                if ismember(sameXLimits, {'col'})
                    set(currAx, 'Xlim', col_xlims{pos_subplot(iAx,1)==col_subplots});
                end
                if ismember(sameYLimits, {'col'})
                    set(currAx, 'Ylim', col_ylims{pos_subplot(iAx,1)==col_subplots});
                end
            end
        end
    end
end


