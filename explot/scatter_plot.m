% 读取CSV文件  
data = readtable('data_record.csv'); % 替换为你的文件名  

% 提取时间、节点号码和距离  
time = data{:, 1}; % 时间列  
nodeNumbers = data{:, 2}; % 节点号码  
distances = data{:, 3}; % 距离数值  

% 获取所有唯一的节点号码  
uniqueNodes = unique(nodeNumbers);  

% 创建一个图形  
figure;  

% 定义不同的点标记  
markers = {'o', 's', '^', 'd', 'p', 'h', '.', 'x', '+', '*'}; % 你可以添加更多标记  
numMarkers = length(markers);  

% 为每个节点绘制散点图  
hold on; % 保持当前图形  
for i = 1:length(uniqueNodes)
    node = uniqueNodes(i); % 当前节点号码  
    % 找到当前节点的数据  
    idx = (nodeNumbers == node);  
    % 将节点号码转换为十六进制  
    hexNode = dec2hex(node);  
    % 选择当前节点的标记样式 

    %markerStyle = markers{mod(i-1, numMarkers) + 1}; % 循环使用标记  
    markerStyle = markers{i}; 

    % 绘制当前节点的距离散点图    
    scatter(time(idx), distances(idx), 36, markerStyle, 'filled', ... % 36是点的大小  
            'DisplayName', ['Node 0x' hexNode]);  
end  
hold off; % 释放图形  

% 添加图例  
legend show;  

% 添加标签和标题  
xlabel('time');  
ylabel('distance');  
title('test 4 Nodes with 2 move');  
grid on; % 添加网格