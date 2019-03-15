function res = numRank(inputVector, dim, ifReverse)
%RANK 返回一列数值的秩 dim表示行列，dim = 1列排序返回一列 dim = 2 行排序返回一行
% NaN的秩返回NaN

if isa(ifReverse, 'double')
    ifReverse = ifelse(ifReverse == 1, true, false); % 好像不写也可以，number 1也可以直接当logic处理
end
% sort 会把NaN 排到最大 但逆序的时候希望从第一个非NaN开始排
idxNonNaN = ~isnan(inputVector);

switch ifReverse
    case true       
        [~, idx] = sort(inputVector(idxNonNaN), 'descend');
    case false
        [~, idx] = sort(inputVector(idxNonNaN), 'ascend');
end
[~, ~, idx] = intersect(1:length(idx), idx);

res = nan(length(inputVector), 1);
res(idxNonNaN) = idx;

if dim == 2
    res = res';
end

end

