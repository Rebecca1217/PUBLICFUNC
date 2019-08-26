function res = getStockBondCode()
%GETSTOCKBONDCODE 读取basicInfo 挑出股指和国债期货的Code

% basicInfoPath = '\\CJ-LMXUE-DT\futureData_fromWind\infoData';
basicInfoPath = 'E:\futureDataBasic\infoData';
load([basicInfoPath, '\basicInfo.mat']);

basicInfoSB = basicInfo(ismember(basicInfo.windType, {'stkF', 'bondF'}), :);
% basicInfoSB = basicInfo(ismember(basicInfo.future, {'IC', 'IF', 'IH', 'T', 'TF', 'TS'}), :);
res = basicInfoSB.code;

end

