function zeroL = zeroL_from_chgCode(code, fillVar)
%ZEROL_FROM_CHGCODE ����۸����ݵ�ʱ����Ҫ��0���ϲ��룬����ѡ����unstack����������stack
% ����ѡ��ֱ�Ӳ����Ժ��ٰѲ���Ҫ���Ĳ��ָֻ�ԭֵ����������Ϥһ�����ַ�ʽ
%  �����code�����ǰ�˳�����еģ�������

chgL = find([0;diff(code)~=0]~=0); %��Ʒ���У���ǵ�����Ʒ�ֵ���ʼ��
zeroL = zeros(length(code), 1);
for n = 1:length(chgL)
    if n ~= length(chgL)
        oriL = chgL(n) : chgL(n+1) - 1; % һ���ȫ��Idx
    else
        oriL = chgL(n) : length(fillVar);
    end
    
    idx0 = fillVar(oriL) == 0;
    if idx0(1) == 1 % ֻ�б������ݴӵ�һ����ʼΪ0�ĺ����0Idx������Ҫ������
        oriL = oriL(idx0);
        if isempty(find(zeroL, 1))
            zeroL(1:length(oriL)) = oriL;
        else
            zeroL(find(zeroL, 1, 'last') + 1 : find(zeroL, 1, 'last') + length(oriL)) = oriL;
        end
    end
    
end

zeroL = zeroL(zeroL~=0);

% nanL = unique(nanL(:)); %������¹����У������ݳ��ȿ��ܻ��nannum�� % ��ǰ�ǹ̶�������������⣬���ڲ��̶�����Ҫ

end

