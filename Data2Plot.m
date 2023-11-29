% This is the function name
% If being applied in app with a table of x & y values already created, you can change the parameters to the x and y
% values directly and change x_data to the x argument and y_data to y
% argument

function [outputArg1,outputArg2] = untitled2(path)

%% Paths and argument assignments
% Path of the excel file - remove if not needed
path = '/Users/bratee/Documents/PreeclampsiaStudyDataAnalysis/Data for Waveform Analysis/TH-0002-SMT-3-LUA_V_Cycle3.csv';

% Reading values from excel file 
% You can change this to equal the table with the x and y values 
T = readtable(path);

% Displays the data from excel file (first column x values, second column y
% values)
%disp(T);

% Extract x and y columns from the table T
x_data = T(:, 1).Variables; % Assuming x is in the first column
y_data = T(:, 2).Variables; % Assuming y is in the second column

%% Plotting graph of points
plot(x_data, y_data, 'LineWidth', 2);
xlabel('Velocity (cm/s)'); % Replace with your actual x-axis label
ylabel('Time (s)'); % Replace with your actual y-axis label
title('Pre-Ecclampsia Plot Detection'); % Replace with your actual plot title

%% Finding local minima and maxima 
% Local minima on graph
TFminima = islocalmin(y_data,'MinSeparation',0.01,'SamplePoints',x_data);
plot(x_data,y_data,x_data(TFminima),y_data(TFminima),'g*');

% Full maxima of waveform (for finding peak systolic)
FullMaxima = islocalmax(y_data,'MinSeparation',0.7,'SamplePoints',x_data);
%plot(x_data,y_data,x_data(FullMaxima),y_data(FullMaxima),'b*');

% Finding values of local minima and maxima
minIndexes = find(TFminima == 1);
PeakSystolicIndexes = find(FullMaxima == 1);
min_x = x_data(minIndexes);
min_y = y_data(minIndexes);
A_x = x_data(PeakSystolicIndexes);
A_y = y_data(PeakSystolicIndexes);

%% Averaging plots
%Peak of minimims = D
% Separated by local maxima and last minima
% Find when a minima occurs before a maxima, and cut off the plot according
% to where the last minima occurs 
TF_lastminima = islocalmin(y_data);
TF_mostmaxima = islocalmax(y_data);
%plot(x_data,y_data,x_data(TF_lastminima),y_data(TF_lastminima),'g*');
%plot(x_data,y_data,x_data(TF_mostmaxima),y_data(TF_mostmaxima),'b*');
% For loop through an array of mins and maxs

%% Finding important points
%A: Peak Systolic Flow - Global maximum of waveform
minVals = [min_x, min_y];
disp(minVals);
A = [A_x, A_y];
disp(A);

%C: Nadir of Notch - First significant dip after Peak Systolic Flow (A)
C_x = [];
C_y = [];
% Loop through each peak systolic x-value
for i = 1:length(A_x)
    % Find the indices of the minima that come after the current peak systolic x-value
    indicesAfterPeakSystolic = find(min_x > A_x(i));

    % Check if there are any minima after the current peak systolic x-value
    if ~isempty(indicesAfterPeakSystolic)
        % Get the index of the first minimum after the current peak systolic x-value
        indexFirstMinAfterPeakSystolic = indicesAfterPeakSystolic(1);

        % Get the x-value of the first minimum after the current peak systolic x-value
        C_x = [C_x, min_x(indexFirstMinAfterPeakSystolic)];
        C_y = [C_y, min_y(indexFirstMinAfterPeakSystolic)];
    end
end
C = [C_x, C_y];
disp(C);

%D: Peak of Notch - First significant max after Nadir of Notch (C)
% [D_value,D_index]=maxk(maxYVals, 2); 
% D_y = min(D_value);
% D_x = max(maxXVals(D_index));
% D = [D_x, D_y];
% disp(D);

%B: End Diastolic - Start of the pulse waveform + Minimum before each Peak Systolic (A)
B_x = 0;
B_y = T{1,2};
B = [B_x, B_y];

%Loops through peak systolic values
%Finds the minimum that occurs right before the peak systolic 
if length(A_x) > 1
    for i = 2:length(AXValues) 
        indicesBeforePeakSystolic = find(min_x < A_x(i));
        
        if ~isempty(indicesBeforePeakSystolic)
            indexBeforePeakSystolic = indicesBeforePeakSystolic(end);
            B_x = [B_x, min_x(indexBeforePeakSystolic)];
            B_y = [B_y, min_y(indexBeforePeakSystolic)];
        end
    end
end
disp(B);


%Finding M: Mean of flow through trapezoidal integration
M = trapz(x_data,y_data);
plot

%Finding Pulsatility Index
pulsality_index = (A-B)/M;

%Finding Notch Index
notch_index = (D-C)/M;

end