function res = getBasicData(type, spotVersion)
%GETMAINCONT �õ�ÿ�����Ʒ�ֵ�������Լ����
% type ȡfuture��spot��Ŀǰfuture��priceType����Close��û�����󻻱�ļ۸���������Ҳ�Ƚ����׵���
% spotVersion v1 v2 v3�õ���\\Cj-lmxue-dt\�ڻ�����2.0\SpotGoodsData_v2\spotData.mat
% v4�õ������¹�����ֻ�����E:\futureData\dataSpot.mat

%% ��ȡcode��name �Ķ�Ӧ��
codename = getVarietyCode();
contPath = '\\CJ-LMXUE-DT\futureData_fromWind\priceData\Dly';
if strcmp(type, 'future')
    %% ��ȡÿ���code
    load([contPath, '\TableData_main_v2.mat'])
    res = table(TableData.date, TableData.code, TableData.volume, TableData.OI, TableData.mainCont, ...
        TableData.close, TableData.multifactor, TableData.adjfactor, TableData.atrABS, TableData.status, TableData.minTick, ...
        'VariableNames', {'Date', 'ContCode', 'Volume', 'OI', 'MainCont', 'Close', 'MultiFactor', 'AdjFactor', 'ATRABS', 'LiqStatus', 'MiniTick'});
elseif ismember(spotVersion, {'v1', 'v2', 'v3'}) 
    % ����ѩ���ݻ�ȡÿ����ֻ�����    
    load('\\Cj-lmxue-dt\�ڻ�����2.0\SpotGoodsData_v2\spotData.mat')
    str = sprintf('res = table(spotData.date, spotData.code, spotData.%s, ''VariableNames'', {''Date'', ''ContCode'', ''SpotPrice''});', spotVersion);
    eval(str)
elseif strcmp(spotVersion, 'v4') % ��������ֻ�����
    load('E:\futureData\dataSpotNew.mat')
    res = dataSpotNew;
else % v4Lag1
    load('E:\futureData\dataSpotNewLag1.mat')
    res = dataSpotNewLag1;
end

%% match��ÿ���contname
res = outerjoin(res, codename, 'type', 'left', 'MergeKeys', true);

end

