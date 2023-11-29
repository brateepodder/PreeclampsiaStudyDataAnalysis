% This is the function name
% If being applied in app with a table of x & y values already created, you can change the parameters to the x and y
% values directly and change x_data to the x argument and y_data to y
% argument

function [outputArg1,outputArg2] = untitled2(path)

%% Paths and argument assignments
% Path of the excel file - remove if not needed
path = '/Users/bratee/Documents/PreeclampsiaStudyDataAnalysis/Data for Waveform Analysis/Shape Data.xlsx';

% Reading values from excel file 
% You can change this to equal the table with the x and y values 
T = readtable(path);

% Displays the data from excel file (first column x values, second column y
% values)

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
%plot(x_data,y_data,x_data(TFminima),y_data(TFminima),'g*');

% Finding global maxima of individual waveforms (for finding peak systolic)
FullMaxima = islocalmax(y_data,'MinSeparation',0.7,'SamplePoints',x_data);
%plot(x_data,y_data,x_data(FullMaxima),y_data(FullMaxima),'b*');

% Finding local maximas of individual waveforms
TFmaxima = islocalmax(y_data, 'MinSeparation',0.01, 'SamplePoints',x_data);

% Finding values of local minima and maxima, assigning to variables
minIndexes = find(TFminima == 1);
PeakSystolicIndexes = find(FullMaxima == 1);
min_x = x_data(minIndexes);
min_y = y_data(minIndexes);
max_x = x_data(TFmaxima);
max_y = y_data(TFmaxima);
disp(min_y);

% Finding A through highest maximas
A_x = x_data(PeakSystolicIndexes);
A_y = y_data(PeakSystolicIndexes);

%% Finding important points
%A: Peak Systolic Flow - Global maximum of waveform
minVals = [min_x, min_y];
A = [A_x, A_y];

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

%D: Peak of Notch - First significant max after Nadir of Notch (C)
D_x = [];
D_y = [];

% Loop through each Nadir of Notch Value 
% Find the closest max value to each nadir of notch value
for i = 1:length(C_x)
    indicesAfterNotch = find(max_x > C_x(i));

    if ~isempty(indicesAfterNotch)
        indexAfterNotch = indicesAfterNotch(1);
        D_x = [D_x, max_x(indexAfterNotch)];
        D_y = [D_y, max_y(indexAfterNotch)];
    end
end

D = [D_x, D_y];

%B: End Diastolic - Start of the pulse waveform + Minimum before each Peak Systolic (A)
B_x = 0;
B_y = T{1,2};
B = [B_x, B_y];

%Loops through peak systolic values
%Finds the minimum that occurs right before the peak systolic 
if length(A_x) > 1
    for i = 2:length(A_x) 
        indicesBeforePeakSystolic = find(min_x < A_x(i));
        
        if ~isempty(indicesBeforePeakSystolic)
            indexBeforePeakSystolic = indicesBeforePeakSystolic(end);
            B_x = [B_x, min_x(indexBeforePeakSystolic)];
            B_y = [B_y, min_y(indexBeforePeakSystolic)];
        end
    end
end

fprintf('Peak Systolic Flow | A = [%f, %f]\n', A);
fprintf('End Diastolic Flow | B = [%f, %f]\n', B);
fprintf('Nadir of Notch | C = [%f, %f]\n', C);
fprintf('Peak of Notch | D = [%f, %f]\n', D);

% Finding M: Mean of flow through average of y values
M = mean(y_data);
fprintf('Mean/M = %f\n', M);

fprintf('\n');

% Finding Every Pulsatility Index (if more than 1) 
if length(A_y) > 1
    fprintf('Pulsality Index(es):\n')
    for i = 1:length(A_y)
        pulse = (A_y(i) - B_y(i)) / M;
        fprintf('%i) Pulsatility: %f\n', i, pulse);
    end
end

% Finding Average Pulsatility Index
A_avg = mean(A_y);
B_avg = mean(B_y);
avg_pulse = (A_avg - B_avg)/M;
fprintf('Average Pulsatility: %f\n', avg_pulse);

% Finding Every Notch Index (if more than 1) 
if length(C_y) > 1
    fprintf('Notch Index(es):\n')
    for i = 1:length(C_y)
        notch = (D_y(i) - C_y(i)) / M;
        fprintf('%i) Notch: %f\n', i, notch);
    end
end

% Finding Average Notch Index
C_avg = mean(C_y);
D_avg = mean(D_y);
avg_notch = (D_avg - C_avg)/M;
fprintf('Average Notch Index: %f\n', avg_notch);

end