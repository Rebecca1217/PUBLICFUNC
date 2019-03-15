function res = getBasicData(type, spotVersion)
%GETMAINCONT 得到每天各个品种的主力合约代码
% type 取future或spot，目前future的priceType都是Close，没有需求换别的价格，如有需求也比较容易调整
% spotVersion v1 v2 v3用的是\\Cj-lmxue-dt\期货数据2.0\SpotGoodsData_v2\spotData.mat
% v4用的是重新构造的现货数据E:\futureData\dataSpot.mat

%% 获取code和name 的对应表
codename = getVarietyCode();
contPath = '\\CJ-LMXUE-DT\futureData_fromWind\priceData\Dly';
if strcmp(type, 'future')
    %% 获取每天的code
    load([contPath, '\TableData_main_v2.mat'])
    res = table(TableData.date, TableData.code, TableData.volume, TableData.OI, TableData.mainCont, ...
        TableData.close, TableData.multifactor, TableData.adjfactor, TableData.atrABS, TableData.status, TableData.minTick, ...
        'VariableNames', {'Date', 'ContCode', 'Volume', 'OI', 'MainCont', 'Close', 'MultiFactor', 'AdjFactor', 'ATRABS', 'LiqStatus', 'MiniTick'});
elseif ismember(spotVersion, {'v1', 'v2', 'v3'}) 
    % 从漫雪数据获取每天的现货数据    
    load('\\Cj-lmxue-dt\期货数据2.0\SpotGoodsData_v2\spotData.mat')
    str = sprintf('res = table(spotData.date, spotData.code, spotData.%s, ''VariableNames'', {''Date'', ''ContCode'', ''SpotPrice''});', spotVersion);
    eval(str)
elseif strcmp(spotVersion, 'v4') % 新整理的现货数据
    load('E:\futureData\dataSpotNew.mat')
    res = dataSpotNew;
else % v4Lag1
    load('E:\futureData\dataSpotNewLag1.mat')
    res = dataSpotNewLag1;
end

%% match到每天的contname
res = outerjoin(res, codename, 'type', 'left', 'MergeKeys', true);

end

