%2 inputs:dateFrom, dateTo, return all trading date between from and to
function res = gettradingday(dateFrom, dateTo)
% % ������ʱΪʲôҪ�����ݿ�ȥȡ����
% �����ݿ���Tdays��һ�㣬����08������ȡ������1��֮�ڣ��ɺ��Բ��ơ�Tdaysֻ�ܸ��µ��н������ݵĽ����գ����ݿ�Ļ�����һֱ��������
conn = database('wind_fsync','query','query','com.microsoft.sqlserver.jdbc.SQLServerDriver',...
    'jdbc:sqlserver://10.201.4.164:1433;databaseName=wind_fsync');
sql = ['select TRADE_DAYS from CFuturesCalendar where S_INFO_EXCHMARKET= ','''czce''',...
    ' and TRADE_DAYS>=''',num2str(dateFrom),''' and TRADE_DAYS<=''',num2str(dateTo),''' order by TRADE_DAYS'];
cursorA = exec(conn,sql);
cursorB = fetch(cursorA);
res = str2double(cursorB.Data);
res = array2table(res, 'VariableNames', {'Date'});

% load \\CJ-LMXUE-DT\futureData_fromWind\infoData\Tdays.mat
% res = Tdays(Tdays(:, 1) >= dateFrom & Tdays(:, 1) <= dateTo, 1);
% res = table(res, 'VariableNames', {'Date'});
% clear Tdays
end



