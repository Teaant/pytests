%节点数量任何增加吗？而且是增加到多少比较好？

tags =5:5:100;
% 从100ms到2000ms，以50ms为步长%计算数量 
%
quantity1 = tags * 7 *2; % 第一条曲线：数量 = 时间 /14ms    
quantity2 = ceil(tags/3.0) * 9 *2; % 第二条曲线：数量 = 时间 /6ms   你别说还可能真的是这样子的

% 创建一个图形  
figure;  

% 设定颜色  
colors = lines(2); % 生成不同的颜色  

hold on; % 保持当前图形  
% 为每个节点绘制线图和点标记  
plot(tags, quantity1, 'DisplayName', "Standard timeslot", ...  
         'LineWidth', 1.25, 'Color', 'b', 'Marker', '^', ...  
         'MarkerSize', 6, 'MarkerFaceColor', 'b', ...  
         'MarkerEdgeColor', 'b'); % 设置边缘颜色为黑色  
plot(tags, quantity2, 'DisplayName',"Layered timeslot", ...  
         'LineWidth', 1.25, 'Color', 'r', 'Marker', 'o', ...  
         'MarkerSize', 6, 'MarkerFaceColor', 'r', ...  
         'MarkerEdgeColor',  'r'); % 设置边缘颜色为黑色  

hold off; % 释放图形  

% % 添加图例  
% legend show;  
% 添加图例并设置字体大小  
lgd = legend('show'); % 显示图例并返回句柄  
set(lgd, 'FontSize', 12, 'Location',  'NorthWest'); % 设置图例文本的字体大小  


% 添加标签和标题  
xlabel('Tags num', 'FontSize', 12);  
ylabel('CFP duration (ms)', 'FontSize', 12);  
% title('Maximum tags in one cycle', 'FontSize', 24);  
% grid on; % 添加网格  
% set(gca, 'FontSize', 10); % 设置坐标轴字体大小  

% 设置坐标轴范围以确保所有数据都可见  
xlim([min(tags) max(tags)]); % 设置横坐标范围

hold off; %释放图形
