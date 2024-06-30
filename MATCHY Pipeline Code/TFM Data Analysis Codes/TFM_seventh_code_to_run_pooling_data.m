clc;clear;
clear all;
close all;

data_path = uigetdir('/Volumes/'); % this is the folder containing all the wells
fileList = dir(data_path); % i.e. well_07

total_data = [];

for k = 1:length(fileList)
    if startsWith(fileList(k).name, 'well_07') % change "well_07" if you're processing different wells
        PIV_path = [data_path,'/',fileList(k).name, '/PIV_Force'];
        seriesList = dir(PIV_path);   

        for j=1:length(seriesList) 
            if startsWith(seriesList(j).name, 'series')
                the_serie_data = [PIV_path, '/', seriesList(j).name, '/the_serie_data.txt'];
                if exist(the_serie_data) ~= 0 
                    the_serie_data = load(the_serie_data);
                    total_data = [total_data; the_serie_data];
                end
          
            end
        end
    end
end

% adjust thresholds based on your experiments 
sel_data = total_data(total_data(:,end) > 5, :);

DAPI = sel_data(:, 3);
CY5 = sel_data(:, 4);
FarRed = sel_data(:, 5);
GFP = sel_data(:, 6);
Pascal = sel_data(:, 10);

% then you can cluster data with different approaches e.g. TSNE,
% thresholding, etc. 
% below we showed a way to perform thresholding that we experimented with
% before

% adjust this based on your experiments
percentages = [80, 80, 80, 80];

thresholds = zeros(1, length(percentages));

for i = 1 :  length(percentages)
    thresholds(i) = prctile(sel_data(:, i + 2), percentages(i));
end

channels = {'DAPI', 'CY5', 'FarRed', 'GFP'};
chn_combs = {};
for i = 0 : 15
    if i == 0
        cur_comb = 'all_negative';
    elseif i == 15
        cur_comb = 'all_positive';
    else
        j = i;
        k = 1;
        cur_comb = 'positive';
        while j > 0
            if mod(j, 2) == 1
                cur_comb = [channels{5 - k} '_' cur_comb];
            end
            j = floor(j / 2);
            k = k + 1;
        end
    end
    chn_combs = {chn_combs{:}, cur_comb};
end
[m, n] = size(sel_data);

sorted_data = struct;
for i = 1 : m
    cmp_res = uint8(sel_data(i, 3:6) > thresholds);
    ind = cmp_res(1) * 8 + cmp_res(2) * 4 + cmp_res(3) * 2 + cmp_res(4) + 1;
    if ~isfield(sorted_data, chn_combs{ind})
        eval(['sorted_data.', chn_combs{ind}, ' =  [];']);
    end
    eval(['sorted_data.', chn_combs{ind}, ' = [sorted_data.', chn_combs{ind}, '; sel_data(i, :)];']);
end

columns = {'series','index', 'DAPI', 'CY5', 'FarRed', 'GFP', 'energy', 'force', 'displacement', 'pascal'};

combs = fieldnames(sorted_data);
for i = 1 : length(combs)
     eval(['sorted_data.', combs{i}, '= array2table(sorted_data.', combs{i}, ');']);
     eval(['sorted_data.', combs{i}, '.Properties.VariableNames = columns;']);
end

group_table.Properties.VariableNames = columns;



