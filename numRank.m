function res = numRank(inputVector, dim, ifReverse)
%RANK ����һ����ֵ���� dim��ʾ���У�dim = 1�����򷵻�һ�� dim = 2 �����򷵻�һ��
% NaN���ȷ���NaN

if isa(ifReverse, 'double')
    ifReverse = ifelse(ifReverse == 1, true, false); % ����дҲ���ԣ�number 1Ҳ����ֱ�ӵ�logic����
end
% sort ���NaN �ŵ���� �������ʱ��ϣ���ӵ�һ����NaN��ʼ��
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

