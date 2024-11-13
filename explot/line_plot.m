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

% 为每个节点绘制曲线  
hold on; % 保持当前图形  
for i = 1:length(uniqueNodes)  
    node = uniqueNodes(i); % 当前节点号码  
    % 找到当前节点的数据  
    idx = (nodeNumbers == node);  

    hexNode = dec2hex(node);  

    % 绘制当前节点的距离曲线  
    plot(time(idx), distances(idx), 'DisplayName', ['Node 0x' num2str(hexNode)], 'LineWidth', 1.25);  
end  
hold off; % 释放图形  

% 添加图例  
legend show;  

% 添加标签和标题  
xlabel('time');  
ylabel('distance');  
title('test 4 nodes with 2 move');  
grid on; % 添加网格