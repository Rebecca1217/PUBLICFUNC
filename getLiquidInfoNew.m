function res = getLiquidInfoNew(dateFrom, dateTo, n, type, pctOrVolumeBoundary, nListDays)
% get all liquid varieties between dateFrom and dateTo
% n表示过去n天的交易金额均值，pct表示当日成交金额的pct分为点, prctile函数是从小到大排序求分位点的
% 分位数默认是从高到低排序
% 相对流动性，用交易量做筛选标准，不是成交金额
% type 可取'relative' 或者'absolute' 表示按照相对还是绝对标准筛选
% 举例： liquid = getLiquidInfoNew(20080101, 20181231, 20, 'absolute', 10000, 0);
% 举例： liquid = getLiquidInfoNew(20080101, 20181231, 60, 'relative', 0.4, 0);
% 注意：nListDays用的是自然日，不是交易日，因为算法是当前日期减去上市日期>nListDays而不是当中tradingDay Series的长度
assert(ismember(type, {'absolute', 'relative'}), '''type'' should be ''absolute'' or ''relative''!')
switch type
    case 'absolute'
        volumeBoundary = pctOrVolumeBoundary;
    case 'relative'
        pct = pctOrVolumeBoundary;
end

% liquidityInfo获取和保存的时候就剔除股指和国债，因为要涉及一些排序运算，先剔除比较清楚
readDateFrom = str2double(datestr((datenum(num2str(dateFrom), 'yyyymmdd') - 4 * n), 'yyyymmdd'));
tradingDay = gettradingday(readDateFrom, dateTo);

% 得到每天每个品种的交易量
basicData = getBasicData('future');
basicData = table(basicData.Date, basicData.ContName, basicData.Volume, ...
    'VariableNames', {'Date', 'ContName', 'Volume'});
futureData = unstack(basicData, 'Volume', 'ContName');
futureData = delStockBondIdx(futureData); % 原始数据本来就没有TS，所以只删除了5列
futureData = outerjoin(tradingDay, futureData, 'type', 'left', 'mergekeys', true);

%% 计算均值和分位数
% 过去60日平均成交量
% 这个movmean在过去市场不满足n-1的时候会出幺蛾子。。
resMovN = [futureData.Date, movmean(table2array(futureData(:, 2:end)), [n - 1, 0])];

if strcmp(type, 'relative')
    dailyPrctile = prctile(table2array(futureData(:, 2:end)), pct * 100, 2);    
    assert(size(resMovN, 1) == size(dailyPrctile, 1), 'Please check the dimention of movmean and quantile!');
    % 比较获得liquidity标签   
    tmpRes = [futureData.Date, resMovN(:, 2:end) >= dailyPrctile];
elseif strcmp(type, 'absolute')
    tmpRes = [futureData.Date, resMovN(:, 2:end) > volumeBoundary];
end
tmpRes = array2table(tmpRes, 'VariableNames', futureData.Properties.VariableNames);
res = tmpRes;
%% 这里需要做个处理，1,把原本价格为NaN的部分，流动性标签调整为NaN；2，把上市不满nListDays的部分调整为NaN
nanLabel = arrayfun(@(x, y, z) ifelse(~isnan(x), 1, NaN), table2array(futureData(:, 2:end)));
% 上市满nListDays的标签
load('\\CJ-LMXUE-DT\futureData_fromWind\infoData\basicInfo.mat')
listDate = basicInfo(:, {'future', 'listDate'});
listDate = unstack(listDate, 'listDate', 'future');
listDate = delStockBondIdx(listDate);
assert(all(strcmp(listDate.Properties.VariableNames, res.Properties.VariableNames(2:end))), ...
    'Make sure the listDate Info has the same vol sequence with res!')
longTimeLabel = [res.Date, table2array(repmat(listDate, height(res), 1))];
% arrayfun在这里很慢，怎么提升？
longTimeLabel = repmat(datenum(num2str(longTimeLabel(:, 1)), 'yyyymmdd'), 1, width(res) - 1) - ...
    arrayfun(@(x, y) datenum(x, 'yyyymmdd'), arrayfun(@num2str, longTimeLabel(:, 2:end), 'UniformOutput', false));
longTimeLabel = arrayfun(@(x, y, z) ifelse(x >= nListDays, 1, NaN), longTimeLabel);

res = array2table([res.Date, table2array(res(:, 2:end)) .* nanLabel .* longTimeLabel], ...
    'VariableNames', res.Properties.VariableNames);
res = res(res.Date >= dateFrom & res.Date <= dateTo, :);  % n以前的那些可能是错的，但是剔除后不影响
% res中NaN都调整为0 是上市不满nListDays的品种
res = array2table(arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(res)), ...
    'VariableNames', res.Properties.VariableNames);
clear tmpRes nanLabel longTimeLabel
end


