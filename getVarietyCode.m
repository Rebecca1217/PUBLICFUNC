function codeName = getVarietyCode()
%% ��ȡcode��name �Ķ�Ӧ��
% contPath = '\\CJ-LMXUE-DT\futureData_fromWind\infoData';
contPath = 'E:\futureDataBasic\infoData';
load([contPath, '\basicInfo.mat']);

codeName = table(basicInfo.code, basicInfo.future, basicInfo.exchg, ...
    'VariableNames', {'ContCode', 'ContName', 'Suffix'});
end


