function res = movingAvg(inputVector, win, nanFlag)
%MOVINGAVG �ƶ�ƽ������������ǰ�㣩
% movavg������������nanomit�� movavg��movmean������exclude current/center point
% win�ǲ�������ǰ�㣬�������ĸ���
% ��λ���뷨�����У���Ϊ���ʲ���λ�����⣬�Ǹ������⡣
% ����������ѩ��������������ͱȽϺ��ˣ�

% inputVector ���������е�

if nanFlag == 1
    res = movmean(inputVector, [win - 1, 0], 'omitnan'); % ������win��ƽ���Ľ�������ǰ����˵�ǰֵ����ʱ���ת��Ϊ��λ�����ˣ���
    res = [nan(win - 1, 1); res(1 : end - win + 1)];
    
else
    res = movmean(inputVector, [win - 1, 0]);
    res = [nan(win - 1, 1); res(1 : end - win + 1)];
end
res(1 : win) = nan(win, 1); % ���ǵ�win+1��֮ǰ�Ķ�����
end

