function uniqueElements = test(arr)  
    % 计算每个元素的频率  
    [uniqueElems, ~, idx] = unique(arr); % 获取唯一元素  
    counts = accumarray(idx, 1); % 计算每个唯一元素的出现次数  
    
    % 找到出现次数为1的元素  
    uniqueElements = uniqueElems(counts == 1);  
end