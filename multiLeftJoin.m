function res = multiLeftJoin(key, varargin)
%MULTILEFTJOIN left join multiple tables with the same keyname
res = varargin{1};
for iTable = 2:nargin-1
    res = outerjoin(res, varargin{iTable}, 'type', 'left', 'MergeKeys', true, 'Keys', key);
end

end

