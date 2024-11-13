% 假设生成的包含0和1的数组  
transmission_array = [0, 1, 1, 0, 1, 0, 0, 1, 1, 0]; % 示例数组  
num_slots = length(transmission_array); % 时隙数量  

% 设置时间参数  
slot_duration = 2; % 每个时隙的持续时间为2ms  
packet_duration = 1.2; % 数据包传输持续时间为1.2ms  
no_packet_duration = slot_duration - packet_duration; % 无数据包持续时间为0.8ms  

% 生成时间序列  
time_series = []; % 初始化时间序列  
data_series = []; % 初始化数据序列  

% 遍历每个时隙，生成时间序列和数据序列  
for i = 1:num_slots  
    if transmission_array(i) == 1  
        % 数据包传输的时间段  
        time_series = [time_series, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series = [data_series, 1, 1]; % 数据包传输状态  
        
        % 无数据包的时间段  
        time_series = [time_series, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series = [data_series, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series = [time_series, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series = [data_series, 0, 0]; % 无数据包状态  
    end  
end  

% 保证data_series的长度与time_series匹配  
% data_series = data_series(1:end-1); % 删除最后一个冗余的0    

% 绘图  
figure;  
plot(time_series, data_series, 'LineWidth', 2);  
xlabel('时间 (ms)');  
ylabel('数据包状态');  
title('数据包传输过程');  
ylim([-0.5 1.5]); % 设置y轴范围  
yticks([0 1]); % 设置y轴刻度  
grid on;