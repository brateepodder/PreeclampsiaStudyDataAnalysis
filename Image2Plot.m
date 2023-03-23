function [x_new, y_new] = Image2Plot(path, image_name,image_type, x_min, x_max, y_min, y_max, dx)
%% Notes
% Purpose: The purpose of this function is to convert an image of a plot
% into its data points.

% Disclaimer: The image must be compirsed of a single, black plot with one
% unique y value for each x value. The bounds of the plot (x_min, etc.) 
% must match the horizontal and vertical edges of the image. The image
% should only include the plot, and not include the axes, numbers, legend,
% or any other data. See example in the script "Extract_Plot.m" applied to
% Figure 4A (bottom) from Reymond 2009.

%% Example Inputs
% % File name Information
path = '/Users/bratee/Documents/MATLAB/PreeclampsiaStudyDataAnalysis/Test plots/Test Plots/';
image_name = 'CROPPED US';
image_type = '.png';

% % Input axis bounds of image
x_min = 0; % Min Time [s]
x_max = 0.8; % Max Time [s]
y_min = -33; % Min Flow rate [mL/s]
y_max = 500; % Max Flow rate [mL/s]

% % Desired dx for final plot data points
dx = (x_max-x_min)/500;

% Image2Plot('/Users/juliawoodall/Dropbox (GaTech)/Documents/MATLAB/Test Plots/', 'Reymond 2009 Fig 4A','.jpg', 0, 0.8, -0.3, 17, 0.5*10^-2)

%% Read image
% Reads image file
Raw_File_and_Path = strcat(path, image_name, image_type);
I = imread(Raw_File_and_Path);

%% Convert to black and white and create black pixel mask
BW = imcomplement(I);
blackpixelsmask = BW<15;
% Array for black pixels mask, where values will be 1 if the pixel is 
% "black" (i.e. BW value is <15) and otherwise 0.

%% Extract pixel data points and convert to graphical values
% Now we must create an array where each column has only one row with a
% value of 1. To do this, we will loop through the colmns and determine the
% "average" location of all points.

W = width (blackpixelsmask);
x_extract = [];
y_extract = [];

% imshow(~blackpixelsmask*155)

for i=1:W
    if any(blackpixelsmask(:,i))
        [row,~] = find(blackpixelsmask(:,i));
        x_extract = [x_extract, i];
        r = row(round(height(row)/2),1); 
        
        %"r" is the selected row # that is the median location of the pixels in 
        %that column. This must then be vertically "flipped" because while
        %the rows of the image go from 1 to height(blackpixelsmask) (ex. 321) 
        %DOWNWARDS, a translation of this graphically would show the values
        % from 1 to height UPWARDS!
        
        y_extract = [y_extract, height(blackpixelsmask)-r];
        
    end       
end

% Scale values to reflect graphical bounds and minima
x_extract = x_extract/width(blackpixelsmask)*(x_max-x_min) + x_min;
y_extract = y_extract/height(blackpixelsmask)*(y_max-y_min) + y_min;

%% Y Values for New X values
% Uses the Piecewise Cubic Hermite Interpolating Polynomial (PCHIP)) to 
% interpolate the plots values for y at prescribed x values (i.e.,  based 
% on the extracted x and y data points (i.e., 'x_extract' and 'y_extract')

x_new = x_min:dx:x_max;
y_new = pchip(x_extract, y_extract, x_new);

%% Plot
plot(x_new,y_new,'LineWidth',2)
hold on
title(strcat('\fontsize{18}', 'MATLAB Plot of US')) %' ',image_name)
axis([x_min x_max y_min y_max]);
set(gca,'FontSize',10)
set(gca, 'XTick', x_min: (x_max-x_min)/2: x_max)
set(gca, 'YTick', y_min:(y_max-y_min)/6:y_max)
xlabel('\fontsize{14}TIME?? (sec)')
ylabel('\fontsize{14}VELOCITY (cm/s)')
%ylabel('\fontsize{14}PRESSURE (mmHg)')

%% Finding local minima and maxima 
% Local minima on graph
TFminima = islocalmin(y_new,'MinSeparation',0.11,'SamplePoints',x_new);
plot(x_new,y_new,x_new(TFminima),y_new(TFminima),'r*');

% Local maxima on graph
TFmaxima = islocalmax(y_new,'MinSeparation',0.1,'SamplePoints',x_new);
plot(x_new,y_new,x_new(TFmaxima),y_new(TFmaxima),'g*');

% Finding values of local minima and maxima
minIndexes = find(TFminima == 1);
maxIndexes = find(TFmaxima == 1);
minXVals = x_new(minIndexes);
minYVals = y_new(minIndexes);
maxXVals = x_new(maxIndexes);
maxYVals = y_new(maxIndexes);

% Writing to excel sheet
filename = "US Data.xlsx";
maximumVals = ["Max X-Values", "Max Y-Values";
                maxXVals', maxYVals';];
minimumVals = ["Min X-Values", "Min Y-Values";
                minXVals', minYVals';];
writematrix(maximumVals,filename,'Sheet',1,'Range','A1');
writematrix(minimumVals, filename, 'Sheet', 1, 'Range', 'D1');

% %% Compare Plot to Image
% figure
% %Paper Image
% subplot(2,2,1)
% Raw_File_and_Path = strcat(path,'Test Plots/ORIGINAL Reymond 2009 Fig 4A.jpg');
% imshow(Raw_File_and_Path);
% title('\fontsize{12}REYMOND Image')
% 
% %Adapted Image Input
% subplot(2,2,2)
% imshow(I)
% title('\fontsize{12}MATLAB Input Image')
% 
% %MATLAB Plot
% subplot(2,2,3)
% plot(x_new,y_new,'LineWidth',2)
% title('\fontsize{12}MATLAB Output Plot')
% axis([x_min x_max y_min y_max]);
% set(gca,'FontSize',8)
% set(gca, 'XTick', x_min: (x_max-x_min)/2: x_max)
% set(gca, 'YTick', y_min:(y_max-y_min)/6:y_max)
% xlabel('\fontsize{8}TIME (sec)')
% ylabel('\fontsize{8}FLOW RATE (mL/sec)')


end
