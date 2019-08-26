function res = movMode(inputSeries, win)
%MOVMODE 移动众数， movavg里面也是用循环操作的
% 默认inputSeries是n*1的向量
% numeric如果mode不止一个，返回的是最小值
% char如果mode不止一个，返回的是最先出现的那个（如果unique参数不写stable的话返回的是首字符排最前面那个）

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

