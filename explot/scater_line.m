% 读取 CSV 文件  
data = readtable('data1024(3).csv'); % 替换为你的文件名  

% 提取时间、节点号码和距离  
time = data{:, 1}; % 时间列  
nodeNumbers = data{:, 2}; % 节点号码  
distances = data{:, 3}; % 距离数值  

% 获取所有唯一的节点号码  
uniqueNodes = unique(nodeNumbers);  

% 创建一个图形  
figure;  

% 设定颜色  
colors = lines(length(uniqueNodes)); % 生成不同的颜色  
markers = {'o', 's', '^', 'd', 'p', 'x', '*', '+', 'h', '.'};

hold on; % 保持当前图形  
% 为每个节点绘制线图和点标记  
for i = 1:length(uniqueNodes)  
    node = uniqueNodes(i); % 当前节点号码  
    % 找到当前节点的数据  
    idx = (nodeNumbers == node);  
    
    % 将节点号码转换为十六进制  
    hexNode = dec2hex(node);  
    
    % 绘制当前节点的距离线图，设置线宽  
    % plot(time(idx), distances(idx), 'DisplayName', ['Node ' hexNode], ...  
    %      'LineWidth', 2, 'Color', colors(i, :), 'Marker', 'o', ...  
    %      'MarkerSize', 6, 'MarkerFaceColor', colors(i, :), ...  
    %      'MarkerEdgeColor', 'k'); % 设置边缘颜色为黑色  
    plot(time(idx), distances(idx), 'DisplayName', ['Tag 0x' hexNode], ...  
         'LineWidth', 1.25, 'Color', colors(i, :), 'Marker', markers{i}, ...  
         'MarkerSize', 7, 'MarkerFaceColor', colors(i, :), ...  
         'MarkerEdgeColor', colors(i, :)); % 设置边缘颜色为黑色  
    
end  
hold off; % 释放图形  

% % 添加图例  
% legend show;  
% 添加图例并设置字体大小  
lgd = legend('show', 'Location', 'NorthWest'); % 显示图例并返回句柄  
% set(lgd,'LooseInset',get(lgd,'TightInset'))

set(lgd, 'FontSize', 14); % 设置图例文本的字体大小  


% 添加标签和标题  
xlabel('time(s)', 'FontSize', 14);  
ylabel('Distance(cm)', 'FontSize', 14);  
% grid on; % 添加网格  
% set(gca, 'FontSize', 10, ''); % 设置坐标轴字体大小  

% 设置坐标轴范围以确保所有数据都可见  
xlim([min(time) max(time)+2]);  
ylim([0 max(distances)+30]);  

% 保存图形为高质量的图片（可选）  
saveas(gcf, 'node_distance_plot.png'); % 保存为 PNG 格式