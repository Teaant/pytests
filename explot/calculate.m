% % 定义时间范围
% time =100:100:2000;
% % 从100ms到2000ms，以50ms为步长%计算数量
% quantity1 = floor(time /14); % 第一条曲线：数量 = 时间 /14ms
% quantity2 = floor(time /6); % 第二条曲线：数量 = 时间 /6ms
% % 创建图形figure;
% % 新建一个图形窗口
% % 绘制第一条曲线
% hold on; % 保持当前图形，以便绘制第二条曲线
% scatter(time, quantity1,50, 'b', 'filled');
% plot(time, quantity1, 'b-', 'LineWidth',2);
% % 绘制数量 = 时间 /14ms，使用蓝色实线，线宽为2
% hold on; % 保持当前图形，以便绘制第二条曲线
% % 绘制第二条曲线
% scatter(time, quantity2,50, 'r', 'filled'); % 绘制数量 = 时间 /6ms，使用红色实线，线宽为2
% plot(time, quantity2, 'r-', 'LineWidth',2);
% % 设置图形属性
% xlabel('active time (ms)', 'FontSize',12); % 设置横坐标标签
% ylabel('tags', 'FontSize',12); % 设置纵坐标标签
% title('Maximum tags in one cycle', 'FontSize',14); 
% % 设置图形标题grid on;
% % 添加网格线
% legend('Standard timeslot', 'Multi-layer timeslot', 'Location', 'NorthWest'); % 添加图例
% xlim([100 2000]); % 设置横坐标范围
% % xticks(100:50:2000); % 设置横坐标刻度，每50ms一个刻度
% % yticks(0:100:max(max(quantity1), max(quantity2))); % 设置纵坐标刻度，间隔为100% 显示图形
% hold off; %释放图形


% % 读取 CSV 文件  
% data = readtable('data1022.csv'); % 替换为你的文件名  
% 
% % 提取时间、节点号码和距离  
% time = data{:, 1}; % 时间列  
% nodeNumbers = data{:, 2}; % 节点号码  
% distances = data{:, 3}; % 距离数值  

% 获取所有唯一的节点号码  
% uniqueNodes = unique(nodeNumbers);  
time =100:100:2000;
% 从100ms到2000ms，以50ms为步长%计算数量
quantity1 = floor((time-2) /14); % 第一条曲线：数量 = 时间 /14ms
quantity2 = floor((time-2) /18)*3; % 第二条曲线：数量 = 时间 /6ms

% 创建一个图形  
figure;  

% 设定颜色  
colors = lines(2); % 生成不同的颜色  

hold on; % 保持当前图形  
% 为每个节点绘制线图和点标记  
plot(time, quantity1, 'DisplayName', "Standard timeslot", ...  
         'LineWidth', 1.25, 'Color', 'b', 'Marker', '^', ...  
         'MarkerSize', 6, 'MarkerFaceColor', 'b', ...  
         'MarkerEdgeColor', 'b'); % 设置边缘颜色为黑色  
plot(time, quantity2, 'DisplayName',"Layered timeslot", ...  
         'LineWidth', 1.25, 'Color', 'r', 'Marker', 'o', ...  
         'MarkerSize', 6, 'MarkerFaceColor', 'r', ...  
         'MarkerEdgeColor',  'r'); % 设置边缘颜色为黑色  

hold off; % 释放图形  

% % 添加图例  
% legend show;  
% 添加图例并设置字体大小  
lgd = legend('show'); % 显示图例并返回句柄  
set(lgd, 'FontSize', 12); % 设置图例文本的字体大小  


% 添加标签和标题  
xlabel('Active period(ms)', 'FontSize', 12);  
ylabel('Maximum tags', 'FontSize', 12);  
% title('Maximum tags in one cycle', 'FontSize', 24);  
% grid on; % 添加网格  
set(gca, 'FontSize', 10); % 设置坐标轴字体大小  

% 设置坐标轴范围以确保所有数据都可见  
xlim([100 2000]); % 设置横坐标范围

hold off; %释放图形
