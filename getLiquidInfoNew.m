function res = getLiquidInfoNew(dateFrom, dateTo, n, type, pctOrVolumeBoundary, nListDays)
% get all liquid varieties between dateFrom and dateTo
% n��ʾ��ȥn��Ľ��׽���ֵ��pct��ʾ���ճɽ�����pct��Ϊ��, prctile�����Ǵ�С�����������λ���
% ��λ��Ĭ���ǴӸߵ�������
% ��������ԣ��ý�������ɸѡ��׼�����ǳɽ����
% type ��ȡ'relative' ����'absolute' ��ʾ������Ի��Ǿ��Ա�׼ɸѡ
% ������ liquid = getLiquidInfoNew(20080101, 20181231, 20, 'absolute', 10000, 0);
% ������ liquid = getLiquidInfoNew(20080101, 20181231, 60, 'relative', 0.4, 0);
% ע�⣺nListDays�õ�����Ȼ�գ����ǽ����գ���Ϊ�㷨�ǵ�ǰ���ڼ�ȥ��������>nListDays�����ǵ���tradingDay Series�ĳ���
assert(ismember(type, {'absolute', 'relative'}), '''type'' should be ''absolute'' or ''relative''!')
switch type
    case 'absolute'
        volumeBoundary = pctOrVolumeBoundary;
    case 'relative'
        pct = pctOrVolumeBoundary;
end

% liquidityInfo��ȡ�ͱ����ʱ����޳���ָ�͹�ծ����ΪҪ�漰һЩ�������㣬���޳��Ƚ����
readDateFrom = str2double(datestr((datenum(num2str(dateFrom), 'yyyymmdd') - 4 * n), 'yyyymmdd'));
tradingDay = gettradingday(readDateFrom, dateTo);

% �õ�ÿ��ÿ��Ʒ�ֵĽ�����
basicData = getBasicData('future');
basicData = table(basicData.Date, basicData.ContName, basicData.Volume, ...
    'VariableNames', {'Date', 'ContName', 'Volume'});
futureData = unstack(basicData, 'Volume', 'ContName');
futureData = delStockBondIdx(futureData); % ԭʼ���ݱ�����û��TS������ֻɾ����5��
futureData = outerjoin(tradingDay, futureData, 'type', 'left', 'mergekeys', true);

%% �����ֵ�ͷ�λ��
% ��ȥ60��ƽ���ɽ���
% ���movmean�ڹ�ȥ�г�������n-1��ʱ�����۶��ӡ���
resMovN = [futureData.Date, movmean(table2array(futureData(:, 2:end)), [n - 1, 0])];

if strcmp(type, 'relative')
    dailyPrctile = prctile(table2array(futureData(:, 2:end)), pct * 100, 2);    
    assert(size(resMovN, 1) == size(dailyPrctile, 1), 'Please check the dimention of movmean and quantile!');
    % �Ƚϻ��liquidity��ǩ   
    tmpRes = [futureData.Date, resMovN(:, 2:end) >= dailyPrctile];
elseif strcmp(type, 'absolute')
    tmpRes = [futureData.Date, resMovN(:, 2:end) > volumeBoundary];
end
tmpRes = array2table(tmpRes, 'VariableNames', futureData.Properties.VariableNames);
res = tmpRes;
%% ������Ҫ��������1,��ԭ���۸�ΪNaN�Ĳ��֣������Ա�ǩ����ΪNaN��2�������в���nListDays�Ĳ��ֵ���ΪNaN
nanLabel = arrayfun(@(x, y, z) ifelse(~isnan(x), 1, NaN), table2array(futureData(:, 2:end)));
% ������nListDays�ı�ǩ
load('\\CJ-LMXUE-DT\futureData_fromWind\infoData\basicInfo.mat')
listDate = basicInfo(:, {'future', 'listDate'});
listDate = unstack(listDate, 'listDate', 'future');
listDate = delStockBondIdx(listDate);
assert(all(strcmp(listDate.Properties.VariableNames, res.Properties.VariableNames(2:end))), ...
    'Make sure the listDate Info has the same vol sequence with res!')
longTimeLabel = [res.Date, table2array(repmat(listDate, height(res), 1))];
% arrayfun�������������ô������
longTimeLabel = repmat(datenum(num2str(longTimeLabel(:, 1)), 'yyyymmdd'), 1, width(res) - 1) - ...
    arrayfun(@(x, y) datenum(x, 'yyyymmdd'), arrayfun(@num2str, longTimeLabel(:, 2:end), 'UniformOutput', false));
longTimeLabel = arrayfun(@(x, y, z) ifelse(x >= nListDays, 1, NaN), longTimeLabel);

res = array2table([res.Date, table2array(res(:, 2:end)) .* nanLabel .* longTimeLabel], ...
    'VariableNames', res.Properties.VariableNames);
res = res(res.Date >= dateFrom & res.Date <= dateTo, :);  % n��ǰ����Щ�����Ǵ�ģ������޳���Ӱ��
% res��NaN������Ϊ0 �����в���nListDays��Ʒ��
res = array2table(arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(res)), ...
    'VariableNames', res.Properties.VariableNames);
clear tmpRes nanLabel longTimeLabel
end


