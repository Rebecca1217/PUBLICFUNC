function res = movingAvg(inputVector, win, nanFlag)
%MOVINGAVG 移动平均（不包含当前点）
% movavg函数不能设置nanomit， movavg和movmean都不能exclude current/center point
% win是不包含当前点，向上数的个数
% 错位的想法不可行，因为本质不是位置问题，是个数问题。
% 后来问了漫雪，下面这个做法就比较好了：

% inputVector 必须是竖列的

if nanFlag == 1
    res = movmean(inputVector, [win - 1, 0], 'omitnan'); % 这样是win天平均的结果，但是包含了当前值，这时候就转化为错位问题了，妙
    res = [nan(win - 1, 1); res(1 : end - win + 1)];
    
else
    res = movmean(inputVector, [win - 1, 0]);
    res = [nan(win - 1, 1); res(1 : end - win + 1)];
end
res(1 : win) = nan(win, 1); % 就是第win+1行之前的都不算
end

