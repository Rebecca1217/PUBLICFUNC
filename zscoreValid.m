function res = zscoreValid(inputTable)
%zscoreValid zscore函数对NaN的行或列全部返回NaN，zscoreValid 调整为omitnan
% 先只考虑对行标准化的table inputTable的第一列是时间

%% 先去掉[mu - 3sigma, mu + 3sigma]之外的点
mu = mean(table2array(inputTable(:, 2:end)), 2, 'omitnan');
sigma = std(table2array(inputTable(:, 2:end)), 0, 2, 'omitnan');

validLabel = table2array(inputTable(:, 2:end)) > mu - 3 * sigma & ...
    table2array(inputTable(:, 2:end)) < mu + 3 * sigma;
validLabel = double(validLabel);

% 注意validLabel需要把0都改为NaN，不然会把本来应该是NaN的因子值改为0 因为NaN > 1返回结果是0 而不是NaN
validLabel = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), validLabel);

%% 再做z-score
res = table2array(inputTable(:, 2:end)) .* validLabel;
res = (res - mu) ./ sigma;
res = array2table([inputTable.Date, res], 'VariableNames', inputTable.Properties.VariableNames);


end

