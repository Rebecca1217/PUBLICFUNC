function res = zscoreValid(inputTable)
%zscoreValid zscore������NaN���л���ȫ������NaN��zscoreValid ����Ϊomitnan
% ��ֻ���Ƕ��б�׼����table inputTable�ĵ�һ����ʱ��

%% ��ȥ��[mu - 3sigma, mu + 3sigma]֮��ĵ�
mu = mean(table2array(inputTable(:, 2:end)), 2, 'omitnan');
sigma = std(table2array(inputTable(:, 2:end)), 0, 2, 'omitnan');

validLabel = table2array(inputTable(:, 2:end)) > mu - 3 * sigma & ...
    table2array(inputTable(:, 2:end)) < mu + 3 * sigma;
validLabel = double(validLabel);

% ע��validLabel��Ҫ��0����ΪNaN����Ȼ��ѱ���Ӧ����NaN������ֵ��Ϊ0 ��ΪNaN > 1���ؽ����0 ������NaN
validLabel = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), validLabel);

%% ����z-score
res = table2array(inputTable(:, 2:end)) .* validLabel;
res = (res - mu) ./ sigma;
res = array2table([inputTable.Date, res], 'VariableNames', inputTable.Properties.VariableNames);


end

