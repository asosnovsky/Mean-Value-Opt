function [ found, names ] = findlocSubstrings( str, list )
%findlocSubstrings finds index of list in str
%   Detailed explanation goes here
    
    % locals
    found = [];names = [];
    % search for list
    for item=1:length(list)
        match = strmatch(list(item),str,'exact');
        if(~isempty(match))
            found = [found match];
            names = [names item];
        end
    end

end

