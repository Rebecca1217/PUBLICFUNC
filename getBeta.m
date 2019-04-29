function res = getBeta(dateFrom, dateTo, pct)
%GETBETA��ȡÿ��Ʒ�֣�ÿ��������ڻ�ָ���Ħ£���Ϊһ��������sigma��ָ����������ɸѡ
% beta��������CAPM�ʱ��ʲ�����ģ��
% beta = (E(asset return) - risk-free rate) / (E(market return) - risk-free rate)
% ÿ��Ħ½�����ǹ�ȥ���ʱ���ƽ�������Դ�ÿ�������½���䶯����ܴ���͹̶�һ��ƽ���½����ȽϽӽ�
% �±���Ͳ���һ��˲ʱ�仯��ֵ�����ǽ�һ����Ʊ�Ħ�ϵ������һ���Ƚ��ȶ��Ľ��������������ȥһ�����һ���С

% �ܶ�ʱ��Ϊ�˼򻯼��㣬�᲻�����޷��������ʣ������ͱ��һ��һԪ�ع飬�¾��ǻع�ϵ��
% �ο���https://www.zhihu.com/question/22511118/answer/51604829
% ���������㱴��ͳһ�ù�ȥһ���daily return���лع�(Ŀǰ����������ݿ�ͨ�õ������������������ʿ���ȥ2���5��)


% ÿ��ع�Ļ��������б�Ҫ���������ɣ����꿴�����ݱ仯�󲻴��پ�����û�б�Ҫ
%% ��ȡ����������
tradingDay = gettradingday(dateFrom, dateTo);
basicData = getBasicData('future');

basicData.AdjClose = basicData.Close .* basicData.AdjFactor;
betaData = table(basicData.Date, basicData.ContName, basicData.AdjClose, ...
    'VariableNames', {'Date', 'ContName', 'AdjClose'});
betaData = unstack(betaData, 'AdjClose', 'ContName');
% @2019.03.21 �м۸�Ϊ0�Ļ���Ҫ���ϲ��룬��0��ΪNaN����Ϊ�ڻ��۸��ȡ������������������쳣��ѡ���ʱ��Ҳ����ѡ������Ʒ��
% ������ǰ�汾��basicData�۸��Ѿ�û��0ֵ�ˣ�ȱʧ�ľ���NaN���ǾͲ���Ҫ���
% �����Ʒ��daily return
betaData = array2table([betaData.Date, ...
    [nan(1, size(betaData, 2) - 1);...
    price2ret(table2array(betaData(:, 2:end)), [], 'Periodic')]], ...
    'VariableNames', betaData.Properties.VariableNames);
% ��ȡָ���۸񲢼���market daily return(�ϻ��ڻ�ָ��)
w = windmatlab;
% [w_wsd_data,w_wsd_codes,w_wsd_fields,w_wsd_times,w_wsd_errorid,w_wsd_reqid]=w.wsd('CCFI.WI,NH0100.NHF','close','2007-02-19','2019-03-20');
str = sprintf('[w_wsd_data, ~, ~, w_wsd_times, w_wsd_errorid, ~] = w.wsd(''NH0100.NHF'', ''close'', ''%s'', ''%s'');', ...
    datestr(datenum(num2str(dateFrom), 'yyyymmdd') - 400, 'yyyymmdd'), num2str(dateTo));
eval(str)
assert(w_wsd_errorid == 0, 'Wind Data Error!')
futureIndex = array2table([str2num(datestr(w_wsd_times, 'yyyymmdd')), w_wsd_data], ...
    'VariableNames', {'Date', 'FutureIndex'});
futureDR = array2table([futureIndex.Date, [NaN;price2ret(futureIndex.FutureIndex)]], ...
    'VariableNames', {'Date', 'FutureDR'});

%% �ع�����ֵ��ÿ��ÿ��Ʒ�ֶ�Ҫ��ָ���ع飩
% ����׼�� ʱ�䰴����
validDateFrom = tradingDay.Date(1);
[~, idxFrom, ~] = intersect(betaData.Date, validDateFrom);
useDateFrom = betaData.Date(idxFrom - 244);
betaData = betaData(betaData.Date >= useDateFrom & betaData.Date <= dateTo, :);
futureDR = futureDR(futureDR.Date >= useDateFrom & futureDR.Date <= dateTo, :);
assert(height(betaData) == height(futureDR), 'Different row numbers of futureData and indexData!')

% ѭ���ع�
betaDataRes = nan(height(tradingDay), width(betaData));
for iRow = 1:height(tradingDay)
    [~, rowIdx, ~] = intersect(betaData.Date, tradingDay.Date(iRow)); 
    regressYI = betaData(rowIdx - 244 : rowIdx, :);
    regressXI = futureDR(rowIdx - 244 : rowIdx, :);
    betaI = nan(1, width(regressYI) - 1);
    for jVar = 1:width(regressYI) - 1
        [~, betaI(1, jVar), ~] = regression(regressXI.FutureDR, table2array(regressYI(:, jVar + 1)), 'one');
    end
    betaDataRes(iRow, :) = [tradingDay.Date(iRow) betaI];
end

% ֻ��ȫ��NaN�Ż᷵�ئ�=0����0ȫ���滻ΪNaN

betaDataRes = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), betaDataRes);
betaDataRes = array2table(betaDataRes, 'VariableNames', betaData.Properties.VariableNames);


%% ɸѡ��λ������ǩ
dailyPrctile = prctile(table2array(betaDataRes(:, 2:end)), pct * 100, 2);
assert(size(betaDataRes, 1) == size(dailyPrctile, 1), ...
    'Please check the dimention of betaDataRes and quantile!')

%% �Ƚϻ��volatility��ǩ
res = [betaDataRes.Date, table2array(betaDataRes(:, 2:end)) > dailyPrctile];
res = array2table(res, 'VariableNames', betaDataRes.Properties.VariableNames);

end

