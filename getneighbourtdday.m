%2 inputs:dateFrom, dateTo, return all trading date between from and to
function neighbourTradingDay = getneighbourtdday(targetDate, type)
% ������Ҫע��һ�����⣬targetDate�����ǽ�����
% ���targetDate���ǽ����գ���Ҫ�ж�ֱ��ѡ��end����ѡ��end - 1�������岻һ��
% Ŀǰȫ��Ĭ��targetDate�ǽ����մ���

% ����targetDate ������һ��double����

if nargin < 2
    error('Type should be specified as either ''last'' or ''next''.')
end

if ~ismember(type, {'last', 'next'})
    error('Arg ''type'' should be ''last'' or ''next''!')
end


% ��ǰ��15����Ϊ�˱�֤���ܹ������������ڵ�Ӱ��
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



