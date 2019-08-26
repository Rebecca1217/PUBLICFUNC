function dataRes = codeConvertCZC(dataInput)
% codeConvertCZC WindCode ��֣������һλ
% ��CZC�ó���������CZC�Ĳ��֣�trim�Ͳ�trim�Ķ���Wind���ݿ���ƥ����룬��ƥ���ϵı���
% dataInput ����targetList�ĸ�ʽ����
%% ��������
dataInput.ContName = regexp(dataInput.futCont, '[A-Z]+', 'match');
dataInput.ContName = cellfun(@char, dataInput.ContName, 'UniformOutput', false);
% load('\\CJ-LMXUE-DT\futureData_fromWind\infoData\basicInfo.mat')
load('E:\futureDataBasic\infoData\basicInfo.mat')
dataInput = outerjoin(dataInput, basicInfo(:, {'future', 'exchg'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', 'ContName', 'RightKeys', 'future');

dataCZC = dataInput(strcmp(dataInput.exchg, 'CZC'), :);
dataOther = dataInput(~strcmp(dataInput.exchg, 'CZC'), :);

% dataCZC ��Ҫ��mainCont��ݵĵ�һλ����ȥ��(�е�ȥ�еĲ�ȥ����)
mainContNum = regexp(dataCZC.futCont, '[0-9]+', 'match');
mainContNum = cellfun(@(x) {x{1}(2:end)}, mainContNum);
mainContNew = join(horzcat(dataCZC.ContName_future, mainContNum), '');
dataCZC.futCont2 = mainContNew; % ������������û���˳��

%% ��ȡWind����
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
windData = array2table(windData, 'VariableNames', {'WindCode', 'Date', 'Object_ID'}); % ѡobjectID����Ϊ�����ȷ���ģ���close����settle��������NULL

windData.WindCont = regexp(windData.WindCode, '.*(?=\.)', 'match');
windData.Date = cellfun(@str2double, windData.Date);
windData.WindCont = cellfun(@char, windData.WindCont, 'UniformOutput', false);

%% Wind����ƥ�䣬ѡ�����մ���
dataCZC = outerjoin(dataCZC, windData(:, {'Date', 'WindCont', 'Object_ID'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date', 'futCont'}, 'RightKeys', {'Date', 'WindCont'});
[~, idIdx] = ismember('Object_ID', dataCZC.Properties.VariableNames);
dataCZC.Properties.VariableNames{idIdx} = 'Object_ID_Ori';
% ƥ���޸ĺ�Ĵ���
dataCZC = outerjoin(dataCZC, windData(:, {'Date', 'WindCont', 'Object_ID'}), 'type', 'left', 'MergeKeys', true, ...
    'LeftKeys', {'date_Date', 'futCont2'}, 'RightKeys', {'Date', 'WindCont'});
[~, idIdx] = ismember('Object_ID', dataCZC.Properties.VariableNames);
dataCZC.Properties.VariableNames{idIdx} = 'Object_ID_Convert';
% ѡ�����Object_ID_Ori�ǿգ���ѡfut_Cont_WindCont�����Object_ID_Convert�ǿգ���ѡfutCont2_WindCont

newRight = strcmp(dataCZC.Object_ID_Ori, '') & ~strcmp(dataCZC.Object_ID_Convert, '');
oldRight = ~strcmp(dataCZC.Object_ID_Ori, '') & strcmp(dataCZC.Object_ID_Convert, '');

dataCZC.Label = newRight + oldRight * 2; % Label == 1 ȡ�޸ĺ�ģ�Label = 2��ȡ�޸�ǰ��
assert(all(dataCZC.Label >= 1 & dataCZC.Label <= 2), 'Strange WindCode!')

dataCZC.Final_FutCont = arrayfun(@(x, y, z) ifelse(x == 1, y, z), dataCZC.Label, dataCZC.futCont2_WindCont, dataCZC.futCont_WindCont);

dataCZC = dataCZC(:, {'date_Date_Date', 'time', 'Final_FutCont', 'hands', 'targetP', 'targetC', 'Mark', 'ContName_future', 'exchg'});
dataCZC.Properties.VariableNames = dataOther.Properties.VariableNames;
%% ��������
dataRes = vertcat(dataCZC, dataOther);
dataRes = sortrows(dataRes, {'date', 'futCont'});
dataRes = dataRes(:, 1:7);
end

