function codeName = getVarietyCode()
%% 获取code和name 的对应表
contPath = '\\CJ-LMXUE-DT\futureData_fromWind\infoData';
load([contPath, '\basicInfo.mat']);

codeName = table(basicInfo.code, basicInfo.future, basicInfo.exchg, ...
    'VariableNames', {'ContCode', 'ContName', 'Suffix'});
end


