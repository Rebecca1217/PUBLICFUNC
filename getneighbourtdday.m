%2 inputs:dateFrom, dateTo, return all trading date between from and to
function neighbourTradingDay = getneighbourtdday(targetDate, type)
% 这里需要注意一个问题，targetDate必须是交易日
% 如果targetDate不是交易日，需要判断直接选择end还是选择end - 1两个含义不一样
% 目前全部默认targetDate是交易日处理

% 参数targetDate 可以是一个double序列

if nargin < 2
    error('Type should be specified as either ''last'' or ''next''.')
end

if ~ismember(type, {'last', 'next'})
    error('Arg ''type'' should be ''last'' or ''next''!')
end


% 往前倒15天是为了保证不受国庆这样长假期的影响
dateFrom = str2double(datestr(datenum(num2str(targetDate(1)), 'yyyymmdd') - 15, 'yyyymmdd'));
dateTo = str2double(datestr(datenum(num2str(targetDate(end)), 'yyyymmdd') + 15, 'yyyymmdd'));
neighbourTradingDay = gettradingday(dateFrom, dateTo);
[~, idx, ~] = intersect(neighbourTradingDay, array2table(targetDate, 'VariableNames', {'Date'}));
switch type
    case 'last'
        neighbourTradingDay = neighbourTradingDay.Date(idx - 1);
    case 'next'
        if (idx + 1) > length(neighbourTradingDay.Date)
            error('The next tradingDay is not coming yet...')
        else
            neighbourTradingDay = neighbourTradingDay.Date(idx + 1);
        end
end

end



