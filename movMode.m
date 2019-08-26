function res = movMode(inputSeries, win)
%MOVMODE �ƶ������� movavg����Ҳ����ѭ��������
% Ĭ��inputSeries��n*1������
% numeric���mode��ֹһ�������ص�����Сֵ
% char���mode��ֹһ�������ص������ȳ��ֵ��Ǹ������unique������дstable�Ļ����ص������ַ�����ǰ���Ǹ���

res = nan(size(inputSeries, 1), 1);
if size(inputSeries, 1) >= win
    switch class(inputSeries)
        case 'double'
            % numeric
            for iRow = win:size(inputSeries, 1)
                dataUniv = inputSeries(iRow - win + 1 : iRow);
                res(iRow) = mode(dataUniv);
            end
        case 'cell'
            % char
            res = num2cell(res);
            switch class(inputSeries{1})
                case 'char'
                    for iRow = win:size(inputSeries, 1)
                        dataUniv = inputSeries(iRow - win + 1 : iRow);
                        [unique_strings, ~, string_map] = unique(dataUniv, 'stable');
                        res(iRow) = unique_strings(mode(string_map));
                    end
                case 'double'
                    for iRow = win:size(inputSeries, 1)
                        dataUniv = inputSeries(iRow - win + 1 : iRow);
                        res(iRow) = {mode(cell2mat(dataUniv))};
                    end
                    
            end
            
    end
    
else
    if isa(inputSeries, 'cell')
        res = num2cell(res);
    end
end


end

