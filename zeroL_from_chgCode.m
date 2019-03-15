function zeroL = zeroL_from_chgCode(code, fillVar)
%ZEROL_FROM_CHGCODE 处理价格数据的时候需要把0向上补齐，可以选择先unstack补齐完了再stack
% 这里选择直接补齐以后再把不需要补的部分恢复原值来操作，熟悉一下这种方式
%  输入的code必须是按顺序排列的！！！！

chgL = find([0;diff(code)~=0]~=0); %换品种行，标记的是新品种的起始行
zeroL = zeros(length(code), 1);
for n = 1:length(chgL)
    if n ~= length(chgL)
        oriL = chgL(n) : chgL(n+1) - 1; % 一组的全部Idx
    else
        oriL = chgL(n) : length(fillVar);
    end
    
    idx0 = fillVar(oriL) == 0;
    if idx0(1) == 1 % 只有本组数据从第一个开始为0的后面的0Idx才是需要纠正的
        oriL = oriL(idx0);
        if isempty(find(zeroL, 1))
            zeroL(1:length(oriL)) = oriL;
        else
            zeroL(find(zeroL, 1, 'last') + 1 : find(zeroL, 1, 'last') + length(oriL)) = oriL;
        end
    end
    
end

zeroL = zeroL(zeroL~=0);

% nanL = unique(nanL(:)); %如果有新股上市，其数据长度可能会比nannum短 % 以前是固定长度有这个问题，现在不固定不需要

end

