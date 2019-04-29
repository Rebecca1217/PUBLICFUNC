function res = getBeta(dateFrom, dateTo, pct)
%GETBETA获取每个品种，每天相对于期货指数的β，作为一个类似于sigma的指标用于因子筛选
% beta计算来自CAPM资本资产定价模型
% beta = (E(asset return) - risk-free rate) / (E(market return) - risk-free rate)
% 每天的β结果都是过去这段时间的平均，所以从每天来看β结果变动不会很大，这和固定一个平均β结果会比较接近
% β本身就不是一个瞬时变化的值，我们讲一个股票的β系数，是一个比较稳定的结果，不会跳来跳去一会儿大一会儿小

% 很多时候为了简化计算，会不考虑无风险收益率，这样就变成一个一元回归，β就是回归系数
% 参考：https://www.zhihu.com/question/22511118/answer/51604829
% 本函数计算贝塔统一用过去一年的daily return进行回归(目前国外各大数据库通用的做法往往是周收益率看过去2年或5年)


% 每天回归的话很慢，有必要吗？你先做吧，做完看看数据变化大不大再决定有没有必要
%% 获取收益率数据
tradingDay = gettradingday(dateFrom, dateTo);
basicData = getBasicData('future');

basicData.AdjClose = basicData.Close .* basicData.AdjFactor;
betaData = table(basicData.Date, basicData.ContName, basicData.AdjClose, ...
    'VariableNames', {'Date', 'ContName', 'AdjClose'});
betaData = unstack(betaData, 'AdjClose', 'ContName');
% @2019.03.21 有价格为0的话不要向上补齐，把0改为NaN，因为期货价格获取不到的情况本来就是异常，选择的时候也不会选这样的品种
% 调整后当前版本的basicData价格已经没有0值了，缺失的就是NaN，那就不需要填补了
% 计算各品种daily return
betaData = array2table([betaData.Date, ...
    [nan(1, size(betaData, 2) - 1);...
    price2ret(table2array(betaData(:, 2:end)), [], 'Periodic')]], ...
    'VariableNames', betaData.Properties.VariableNames);
% 获取指数价格并计算market daily return(南华期货指数)
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

%% 回归计算β值（每天每个品种都要跟指数回归）
% 数据准备 时间按对齐
validDateFrom = tradingDay.Date(1);
[~, idxFrom, ~] = intersect(betaData.Date, validDateFrom);
useDateFrom = betaData.Date(idxFrom - 244);
betaData = betaData(betaData.Date >= useDateFrom & betaData.Date <= dateTo, :);
futureDR = futureDR(futureDR.Date >= useDateFrom & futureDR.Date <= dateTo, :);
assert(height(betaData) == height(futureDR), 'Different row numbers of futureData and indexData!')

% 循环回归
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

% 只有全是NaN才会返回β=0，把0全部替换为NaN

betaDataRes = arrayfun(@(x, y, z) ifelse(x == 0, NaN, x), betaDataRes);
betaDataRes = array2table(betaDataRes, 'VariableNames', betaData.Properties.VariableNames);


%% 筛选分位数贴标签
dailyPrctile = prctile(table2array(betaDataRes(:, 2:end)), pct * 100, 2);
assert(size(betaDataRes, 1) == size(dailyPrctile, 1), ...
    'Please check the dimention of betaDataRes and quantile!')

%% 比较获得volatility标签
res = [betaDataRes.Date, table2array(betaDataRes(:, 2:end)) > dailyPrctile];
res = array2table(res, 'VariableNames', betaDataRes.Properties.VariableNames);

end

