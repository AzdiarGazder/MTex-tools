

function rowIdx = nestedLoopCounter(currentLoopIdx,varargin)
%% Function description:
% Returns the current count (or specifically, the row index) for a series 
% of running nested loops. The function currently employs two and three 
% nested loops but can be extended to multiple nested loops.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Syntax
%
%  [idx] = nestedLoopCounter(currentLoop,varargin)
%
% Input
%  currentLoop      - @numeric
%
% Output
%  idx              - @numeric
%%

% check if the number of columns of the current loop matches the number of
% varargin
if size(currentLoopIdx,2) ~= length(varargin)
    error('The size of the current loop should match the number of varargin.')
    return;
end


if size(currentLoopIdx,2) == 2
    % define the indices of the nested loop
    [outerLoop,innerLoop] = ndgrid(varargin{1},varargin{2});
    loopIdx = [outerLoop(:),innerLoop(:)];
    loopIdx = sortrows(loopIdx,[1 2]);

elseif size(currentLoopIdx,2) == 3
    % define the indices of the nested loop
    [outerLoop,middleLoop,innerLoop] = ndgrid(varargin{1},varargin{2},varargin{3});
    loopIdx = [outerLoop(:),middleLoop(:),innerLoop(:)];
    loopIdx = sortrows(loopIdx,[1 2 3]);

end

% find the row index of the current loop within the nested loop indices
rowIdx = find(ismember(loopIdx,currentLoopIdx,'rows') == 1);

end
.rtcContent { padding: 30px; }.lineNode {font-size: 10pt; font-family: Menlo, Monaco, Consolas, "Courier New", monospace; font-style: normal; font-weight: normal; }
