function resRank = genRank(inputTable, ifReverse)
%GENRANK 输入因子数值，table，第一列是时间，后面是各品种的因子值
% 输出每个每个品种的因子秩

rankData = inputTable(:, 2:end);
res = cellfun(@(x, y) numRank(x, 2, ifReverse), num2cell(table2array(rankData), 2), 'UniformOutput', false);
resRank = array2table([inputTable.Date, cell2mat(res)], ...
    'VariableNames', inputTable.Properties.VariableNames);

end

