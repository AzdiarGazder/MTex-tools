function plot_saltykov(diameters, in, varargin)
%% Function description:
% Plots two figures:
% Figure 1: % the data histogram based on Saltykov's optimal number of bins
% and best-fit lognormal distribution (two-step method)
%
% Figure 2: Two sub-plots after applying the Saltykov method of: 
% (2.1) a bar plot of Saltykov frequency versus grain size, and
% (2.2) a line plot of Saltykov volume-weighted cumulative frequency.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgements:
% Dr. Marco A. Lopez-Sanchez
% For the original Python script at:
% https://github.com/marcoalopez/GrainSizeTools/blob/master/grain_size_tools/plot.py
%
% https://au.mathworks.com/matlabcentral/answers/1852048-how-to-fit-lognormal-distribution-on-my-data
%
%% Syntax:
% plot_saltykov(data)
%
%% Input:
% diameters              - @double, a data array
%
%% Output:
% none
%
%% Options:
% ci                - @double, the certainty of the confidence interval
%                     A positive scalar value ranging between 0 and 1;
%                     default = 0.95
% interval          - @double,  the percentile interval to estimate; 
%                     default = 2% 
%%


precision = get_option(varargin, 'precision', 0.05);

%% FOR FIGURE 1
% Calculate the data histogram based on Saltykov's optimal number of bins
[appCounts, appCenters] = hist(diameters, in.bins);
appFreq = appCounts ./ length(diameters);
appFreq = appFreq ./ sum(appFreq);


% Calculate the best-fit lognormal
expOfY = sum(in.centers .* in.freq);   % mean of the scores
Ysqr = in.centers.^2;
expOfYsqr = sum(Ysqr.*in.freq);
varOfY = expOfYsqr - expOfY^2;  % variance of the scores
normu = log(expOfY / sqrt(1 + varOfY / expOfY^2));
norvar = log(1 + varOfY / expOfY^2);
norsigma = sqrt(norvar);

% xFit = linspace(0.1, max(diameters), 1000);
xFit = generateGrid(0.1, max(diameters), 'precision', precision);
yFit = lognpdf(xFit, normu, norsigma);
yFit = yFit.* (max(appFreq)/max(yFit)); % re-scale


figH = figure;
ax = gca;
% Plot the data hisotgram
hp = bar(appCenters,appFreq);
hatchFill(hp,'single','HatchAngle',45,'hatchcolor',[0 0 0]);
hold all;

% Overlay the best-fit lognormal distribution
plot(ax, xFit,yFit,...
    'Color', [47/255, 72/255, 88/255],...
    'LineWidth', 2,...
    'DisplayName', 'best lognormal fit');
hold all;

area(ax, xFit, yFit,...
    'FaceColor', [0/255, 114/255, 178/255],...
    'EdgeColor', 'none',...
    'FaceAlpha', 0.55);
ylabel(ax, 'Density', 'FontSize', 16);
xlabel(ax, 'Diameter (\mum)', 'FontSize', 16);
hold off;

xlim([0 max(xFit)]);
ylim([0 (max(yFit) + 0.05)]);
set(figH,'Name','Grain diameter frequency histogram (experimental)','NumberTitle','on');
%%



%% FOR FIGURE 2
% Calculate the volume-weighted cumulative frequency distribution
dr = in.centers(2) - in.centers(1);
xVol = dr^3 * pi * (in.centers.^3);
freqVol = xVol .* in.freq;
cdf = cumsum(freqVol);
cdfNorm = cdf / cdf(end);

% Generate two plots after applying the Saltykov method:
% (ax1) a bar plot of frequency versus grain size and an overlaid lognormal best-fit
% (ax2) a volume-weighted cumulative frequency plot

figH = figure;
ax = gca;
% Plot frequency vs grain size
ax(1) = subplot(1,2,1);
bar(ax(1), in.centers, in.freq,...
    'FaceColor', [30/255, 144/255, 255/255],...
    'EdgeColor', [216/255, 216/255, 216/255],...
    'LineWidth', 1.5);
ylabel(ax(1), 'Density', 'FontSize', 16);
xlabel(ax(1), 'Diameter (\mum)', 'FontSize', 16);
hold all;

% Plot the volume-weighted cumulative frequency curve
ax(2) = subplot(1,2,2);
ylim(ax(2), [-2, 105]);
plot(ax(2), in.centers, cdfNorm,...
    'o-', 'Color', [237/255, 67/255, 86/255],...
    'LineWidth', 2,...
    'MarkerFaceColor', [237/255, 67/255, 86/255],...
    'MarkerSize', 5);
ylabel(ax(2), 'Cumulative volume (%)', 'FontSize', 16);
xlabel(ax(2), 'Diameter (\mum)', 'FontSize', 16);
hold off;

% Link the x-axes of ax1 and ax2
linkaxes(ax, 'x');

set(figH,'Name','Grain diameter frequency histogram (Saltykov)','NumberTitle','on');
%%


end