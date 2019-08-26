function dataRes = codeConvertCZC(dataInput)
% codeConvertCZC WindCode 在郑商所少一位
% 非CZC拿出来不动，CZC的部分，trim和不trim的都在Wind数据库中匹配代码，能匹配上的保留
% dataInput 按照targetList的格式输入
%% 数据整理
dataInput.ContName = regexp(dataInput.futCont, '[A-Z]+', 'match');
dataInput.ContName = cellfun(@char, dataInput.ContName, 'UniformOutput', false);
% load('\\CJ-LMXUE-DT\futureData_fromWind\infoData\basicInfo.mat')
load('E:\futureDataBasic\infoData\basicInfo.mat')
dataInput = outerjoin(dataInput, basicInfo(:, {'future', 'exchg'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', 'ContName', 'RightKeys', 'future');

dataCZC = dataInput(strcmp(dataInput.exchg, 'CZC'), :);
dataOther = dataInput(~strcmp(dataInput.exchg, 'CZC'), :);

% dataCZC 需要把mainCont年份的第一位数字去掉(有的去有的不去。。)
mainContNum = regexp(dataCZC.futCont, '[0-9]+', 'match');
mainContNum = cellfun(@(x) {x{1}(2:end)}, mainContNum);
mainContNew = join(horzcat(dataCZC.ContName_future, mainContNum), '');
dataCZC.futCont2 = mainContNew; % 上述几步操作没变过顺序

%% 读取Wind代码
dateFrom = min(dataInput.date);
dateTo = max(dataInput.date);
conn = database('wind_fsync','query','query','com.microsoft.sqlserver.jdbc.SQLServerDriver',...
    'jdbc:sqlserver://10.201.4.164:1433;databaseName=wind_fsync');
sql = ['select S_INFO_WINDCODE, TRADE_DT, OBJECT_ID from CCOMMODITYFUTURESEODPRICES where ',...
    ' TRADE_DT >=',num2str(dateFrom),' and TRADE_DT <=',num2str(dateTo), ...
    'and S_INFO_WINDCODE like ''%.CZC'''];
cursorA = exec(conn,sql);
cursorB = fetch(cursorA);
windData = cursorB.Data;
windData = array2table(windData, 'VariableNames', {'WindCode', 'Date', 'Object_ID'}); % 选objectID是因为这个是确定的，用close或者settle都可能有NULL

windData.WindCont = regexp(windData.WindCode, '.*(?=\.)', 'match');
windData.Date = cellfun(@str2double, windData.Date);
windData.WindCont = cellfun(@char, windData.WindCont, 'UniformOutput', false);

%% Wind代码匹配，选择最终代码
dataCZC = outerjoin(dataCZC, windData(:, {'Date', 'WindCont', 'Object_ID'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date', 'futCont'}, 'RightKeys', {'Date', 'WindCont'});
[~, idIdx] = ismember('Object_ID', dataCZC.Properties.VariableNames);
dataCZC.Properties.VariableNames{idIdx} = 'Object_ID_Ori';
% 匹配修改后的代码
dataCZC = outerjoin(dataCZC, windData(:, {'Date', 'WindCont', 'Object_ID'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date_Date', 'futCont2'}, 'RightKeys', {'Date', 'WindCont'});
[~, idIdx] = ismember('Object_ID', dataCZC.Properties.VariableNames);
dataCZC.Properties.VariableNames{idIdx} = 'Object_ID_Convert';
% 选择：如果Object_ID_Ori非空，就选fut_Cont_WindCont；如果Object_ID_Convert非空，就选futCont2_WindCont

newRight = strcmp(dataCZC.Object_ID_Ori, '') & ~strcmp(dataCZC.Object_ID_Convert, '');
oldRight = ~strcmp(dataCZC.Object_ID_Ori, '') & strcmp(dataCZC.Object_ID_Convert, '');

dataCZC.Label = newRight + oldRight * 2; % Label == 1 取修改后的，Label = 2，取修改前的
assert(all(dataCZC.Label >= 1 & dataCZC.Label <= 2), 'Strange WindCode!')

dataCZC.Final_FutCont = arrayfun(@(x, y, z) ifelse(x == 1, y, z), dataCZC.Label, dataCZC.futCont2_WindCont, dataCZC.futCont_WindCont);

dataCZC = dataCZC(:, {'date_Date_Date', 'time', 'Final_FutCont', 'hands', 'targetP', 'targetC', 'Mark', 'ContName_future', 'exchg'});
dataCZC.Properties.VariableNames = dataOther.Properties.VariableNames;
%% 数据整合
dataRes = vertcat(dataCZC, dataOther);
dataRes = sortrows(dataRes, {'date', 'futCont'});
dataRes = dataRes(:, 1:7);
end

