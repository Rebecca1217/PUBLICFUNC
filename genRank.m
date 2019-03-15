function resRank = genRank(inputTable, ifReverse)
%GENRANK ����������ֵ��table����һ����ʱ�䣬�����Ǹ�Ʒ�ֵ�����ֵ
% ���ÿ��ÿ��Ʒ�ֵ�������

rankData = inputTable(:, 2:end);
res = cellfun(@(x, y) numRank(x, 2, ifReverse), num2cell(table2array(rankData), 2), 'UniformOutput', false);
resRank = array2table([inputTable.Date, cell2mat(res)], ...
    'VariableNames', inputTable.Properties.VariableNames);

end

