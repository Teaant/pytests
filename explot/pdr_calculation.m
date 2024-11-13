
%由于干扰出现的时间所引发的失败 → 计算信道利用率
%由于数据包传输所引发的失败  → 信道利用率          数据包传输失败概率如何随机产生？ 
%持续时间以2s暂时
%相当于随机选择在系统当中加入干扰
clear;

Test = 2;

T = 2;
once_slot = 125;
num_slots = once_slot * T;          % 时隙数量  

slot_length = 2;       % 每个时隙的长度（ms）  

standard_slots = 6;

% 125 / 6 = 20
N = floor(once_slot/standard_slots);  %每一轮节点数

% IDs = randperm(maxID - minID + 1, N) + minID - 1;  
IDs = 1:N*T;
%计算cap的开始时隙号  
k1 = floor(N/3);
if mod(N, 3) > 0 
    k1 = k1 +1;
end
cap_start = 9* k1 + 1 + 1; 
rest_cap = once_slot - cap_start  + 1;
%可以有多少个 ~
NN = floor(rest_cap / standard_slots);  

% 随机生成符合负指数分布的干扰时间间隔
lambda = 80;           % 负指数分布的参数（可以根据需要调整）   干扰发生的频率，以s为单位     
num_interferences = 100;       %就是很容易击中的啊

%记录成功的测距
ds_twr1 = ones(1, N * T);
ds_twr2 = ones(1, N * T);

%因为我是按照时间顺序遍历的干扰，所以在前面我应该是可以实现了，现在我考虑这种情形了哈

data_array1 = zeros(1, num_slots);  % 初始化为0 
data_array2 = zeros(1, num_slots);  % 初始化为0  

data_array11 = zeros(1, num_slots);  % 初始化为0  
data_array22 = zeros(1, num_slots);  % 初始化为0  

%要考虑假设说现在是第三个数据包传输失败了，此时标签根本不知道这次失败了，也就不会在下次重传了 ~ 【这个情况需要考虑的是】
%重传的节点在ds_twr2当中的索引号以及对应的时隙
retrys = zeros(N*T, 4);    %在ds_twr2当中的索引 + slot 1 + slot 2 + slot 3

positioning = ones(T, N); % 0 测距失败   1 测距一次   2 测距两次   


%正常无干扰情况下的通信情形
pp = floor(num_slots/once_slot) -1;
for p = 0:pp
    bias = once_slot * p;
    disp(bias);
        for j = 1:N     
            %第一个数组 
            data_array1(6 *(j-1)+1 + 1 + bias) = 1;  % poll  0 resp 00 final  6  slots
            data_array1(6 *(j-1)+3 + 1 + bias) = 1;
            data_array1(6 *(j-1)+6 + 1 + bias) = 1; 
            data_array11(6 *(j-1)+1 + 1 + bias) = 1;  % poll  0 resp 00 final  6  slots
            data_array11(6 *(j-1)+3 + 1 + bias) = 1;
            data_array11(6 *(j-1)+6 + 1 + bias) = 1; 

            %第二个数组 
            m = floor((j-1)/3); %第几组
            n = mod(j-1, 3);    %第几个 
            data_array2(9*m + n +1+1 + bias) = 1;  %这里不表示1和0，而是去表示持续时间？
            data_array2(9*m + n +1+3+1 + bias) = 1; % 不太行，因为实际数据包的传输时间很短很短， poll只有0.1ms,最大的final也才只有0.35ms,
            %所以为了画图，我现在考虑最大数据包长度下的持续时间 127B，也就是1.2ms
            data_array2(9*m + n +1+6+1 + bias) = 1;

            data_array22(9*m + n +1+1 + bias) = 1;  %这里不表示1和0，而是去表示持续时间？
            data_array22(9*m + n +1+3+1 + bias) = 1; % 不太行，因为实际数据包的传输时间很短很短， poll只有0.1ms,最大的final也才只有0.35ms,
            %所以为了画图，我现在考虑最大数据包长度下的持续时间 127B，也就是1.2ms
            data_array22(9*m + n +1+6+1 + bias) = 1;
        end
end

% num_slots = length(data_array1);
slot_duration = 2; % 每个时隙的持续时间为2ms  
packet_duration = 1.2; % 数据包传输持续时间为1.2ms  
no_packet_duration = slot_duration - packet_duration; % 无数据包持续时间为0.8ms  



interference_intervals = exprnd(1/lambda, 1, num_interferences);  % 生成干扰时间间隔  以s为单位
interference_times = cumsum(interference_intervals) * 1000;  % 计算绝对干扰时间    以ms为单位
% 将干扰时间转换为对应的时隙索引
interference_indices = ceil(interference_times / slot_duration);    

interference_times_effective = []; 
interference_times_pos = [];

retry_num = 0;
for i = 1:num_interferences  
    index = interference_indices(i);    
    intertime = interference_times(i);  
    if index >= 1 && index <= num_slots        %这边应该是可以限制的啊？
        interference_times_effective(i) = interference_times(i);   
        intNum = floor(interference_times_effective(i));  
        % 如果 intNum 是偶数，减去1以得到最大奇数  
        if mod(intNum, 2) == 0  
            maxOdd = intNum - 1;  
        else  
            maxOdd = intNum;  
        end  
        interference_times_pos(i) = maxOdd;
        % 如果干扰时间影响到数据包传输，设置对应位置为0  同时由于DS-TWR的性质，后面的也需要改
        if data_array22(index) == 1  && intertime < (index-1)* slot_duration + 2.0   
            m = floor(index/once_slot);  %第m个超帧，从0开始
            index1 = mod((index-1), once_slot) +1;  %在超帧当中的序号，从1开始
            k = floor((index1 -1-1)/9);   %三个为一组的第几组，从0开始
            j = mod((index1 -1-1), 3) +1 ; %节点在一组当中的需要，从1开始
            num = 3 * k + j ; %节点在其中的序号  在一次超帧所有节点当中的序号，从1开始
            ds_twr2(num + m * N) = 0;
            positioning(m+1, num) = 0; %暂时：节点测距失败
            data_array22(index) = 0; 
            if k*9+j+1+m*once_slot == index     %第一个数据包发生错误，后面的两个数据包也不能再有了
                data_array22(index + 3) = 0; 
                data_array22(index + 6) = 0;    
                %会进行重传
                retry_num = retry_num +1;
                ID = IDs(num);  %节点ID 
                disp("需要重传 "+(m+1)+", "+ID+"选择:"+ mod(ID, NN));
                retrys(retry_num, 1) = m*N + num; 
                %选择一个CAP
                select_cap1 = mod(ID, NN) * 6 + m *once_slot + cap_start; 
                retrys(retry_num, 2) = select_cap1;
                retrys(retry_num, 3) = select_cap1 + 2; 
                retrys(retry_num, 4) = select_cap1 + 5; 
                disp("ds-twr2中的"+retrys(retry_num, 1)+"选择的CAP时隙是"+ retrys(retry_num, 2) +"，"+retrys(retry_num, 3)+"，"+retrys(retry_num, 4));
            elseif k*9+j+4+m*once_slot == index
                data_array22(index + 3) = 0; 
                %重传
                retry_num = retry_num +1;
                ID = IDs(num);  %节点ID
                retrys(retry_num, 1) = m*N + num; 
                disp("需要重传 "+(m+1)+", "+ID+"选择:"+ mod(ID, NN));
                %选择一个CAP
                select_cap1 = mod(ID, NN) * 6 + m * once_slot + cap_start; 
                retrys(retry_num, 2) = select_cap1;
                retrys(retry_num, 3) = select_cap1 + 2; 
                retrys(retry_num, 4) = select_cap1 + 5; 
                disp("ds-twr2中的"+retrys(retry_num, 1)+"选择的CAP时隙是"+ retrys(retry_num, 2) +"，"+retrys(retry_num, 3)+"，"+retrys(retry_num, 4));
            end  
        end
        
        %传统超帧受干扰影响
        if data_array11(index) == 1 && intertime <= (index-1)* slot_duration + 1.2 
             m = floor(index/once_slot);  %第m个超帧，从0开始
             index1 = mod((index-1), once_slot) +1;  %时隙在超帧当中的序号，从1开始
             k = floor((index1-1-1)/6) +1; %节点在一组超帧的所有节点当中的序号，从1开始
             ds_twr1(m*N + k) = 0;
             data_array11(index) = 0;  
             if m*once_slot + 6*(k-1) + 1 + 1 == index
                data_array11(index+2) = 0;  
                data_array11(index+5) = 0;  
             elseif m*once_slot + 6*(k-1) + 3 + 1 == index
                data_array11(index+3) = 0;  
             end
        end
    end
end

%不考虑干扰影响地前提下，但是还是需要考虑两两之间的冲突
retry_array = zeros(1, num_slots);  % 初始化为0（表示没有被占用，N*T + 1表示前面已经产生冲突） 元素的值对应在ds_twr2当中的索引  
for  i = 1:retry_num
    if retry_array(retrys(i,2)) == 0
        %未被占用
        disp("未被占用的"+i+", "+ retry_array(retrys(i,2)));
        retry_array(retrys(i, 2)) = i;   %设置为在retrys当中的索引
        retry_array(retrys(i, 3)) = i;
        retry_array(retrys(i, 4)) = i;
        ds_twr2(retrys(i, 1)) = 1;  
    elseif (retry_array(retrys(i,2)) ~= 0) && (retry_array(retrys(i,2)) ~= N*T + 1)
        %被占用   看起来第一个就不对了？
        disp("被占用的" +i+", " + retry_array(retrys(i,2)));
        node_index = retry_array(retrys(i,2));
        disp("node index in retrys" + node_index);
        ds_twr2(retrys(node_index, 1)) = 0;  %上一个要失败
        ds_twr2(retrys(i, 1)) = 0;  
        retry_array(retrys(i, 2)) = N*T + 1;
        retry_array(retrys(i, 3)) = N*T + 1;
        retry_array(retrys(i, 4)) = N*T + 1;    %说明发生冲突
    else
        %已冲突，还是要把这个设置为0的哈
        ds_twr2(retrys(i, 1)) = 0;
    end
end

%现在继续考虑干扰时间
retry_array1 = retry_array;
for i = 1:num_interferences  
    index = interference_indices(i);    
    intertime = interference_times(i);  
    if index >= 1 && index <= num_slots    
        if ((retry_array(index) ~= 0) && (retry_array(index) ~= N*T + 1)) && intertime < (index-1)* slot_duration + 2.0 
            ds_twr2(retrys(retry_array(index),1)) = 0;
            retry_array1(index) = 0;
            if retrys(retry_array(index),2) == index     %第一个数据包发生错误，后面的两个数据包也不能再有了
                retry_array1(index + 2) = 0;     %又是无效了
                retry_array1(index + 5) = 0;    
            elseif retrys(retry_array(index),3) == index
                retry_array1(index + 3) = 0;     %又是无效了
            end  
        end
    end
end



% 生成时间序列  
time_series1 = []; % 初始化时间序列  
data_series1 = []; % 初始化数据序列  
time_series2 = []; % 初始化时间序列  
data_series2 = []; % 初始化数据序列  

time_series11 = []; % 初始化时间序列  
data_series11 = []; % 初始化数据序列  
time_series22 = []; % 初始化时间序列  
data_series22 = []; % 初始化数据序列 

%随机数据包失败
time_series111 = []; % 初始化时间序列     
data_series111 = []; % 初始化数据序列   在没有干扰情况  后面画成虚线
time_series222 = []; % 初始化时间序列  
data_series222 = []; % 初始化数据序列   


% 遍历每个时隙，生成时间序列和数据序列  
for i = 1:num_slots  
    if data_array2(i) == 1  
        % 数据包传输的时间段  
        time_series2 = [time_series2, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series2 = [data_series2, 1, 1]; % 数据包传输状态  
        
        % 无数据包的时间段  
        time_series2 = [time_series2, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series2 = [data_series2, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series2 = [time_series2, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series2 = [data_series2, 0, 0]; % 无数据包状态  
    end  
    if data_array1(i) == 1  
        % 数据包传输的时间段  
        time_series1 = [time_series1, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series1 = [data_series1, 1, 1]; % 数据包传输状态  
        
        % 无数据包的时间段  
        time_series1 = [time_series1, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series1 = [data_series1, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series1 = [time_series1, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series1 = [data_series1, 0, 0]; % 无数据包状态  
    end  

    if data_array11(i) == 1  
        % 数据包传输的时间段  
        time_series11 = [time_series11, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series11 = [data_series11, -1, -1]; % 数据包传输状态  
        
        % 无数据包的时间段  
        time_series11 = [time_series11, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series11 = [data_series11, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series11 = [time_series11, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series11 = [data_series11, 0, 0]; % 无数据包状态  
    end  

    if data_array22(i) == 1  
        % 数据包传输的时间段  
        time_series22 = [time_series22, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series22 = [data_series22, -1, -1]; % 数据包传输状态  
        
        % 无数据包的时间段  
        time_series22 = [time_series22, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series22 = [data_series22, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series22 = [time_series22, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series22 = [data_series22, 0, 0]; % 无数据包状态  
    end  
    if (retry_array(i) ~= 0) && (retry_array(i) ~= N*T + 1)
        % 数据包传输的时间段  
        time_series111 = [time_series111, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series111 = [data_series111, 1, 1]; % 数据包传输状态  

        % 无数据包的时间段  
        time_series111 = [time_series111, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series111 = [data_series111, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series111 = [time_series111, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series111 = [data_series111, 0, 0]; % 无数据包状态  
    end  

    if (retry_array1(i) ~=0) && (retry_array1(i) ~= N*T + 1)
        % 数据包传输的时间段  
        time_series222 = [time_series222, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        data_series222 = [data_series222, -1, -1]; % 数据包传输状态  

        % 无数据包的时间段  
        time_series222 = [time_series222, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        data_series222 = [data_series222, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        time_series222 = [time_series222, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        data_series222 = [data_series222, 0, 0]; % 无数据包状态  
    end  

end  

% 绘图  
figure;  

% 绘制第一个子图  
subplot(3, 1, 1); % 将图形窗口分为2行1列，当前绘制第1个子图  
hold on; % 保持当前图  
plot(time_series1, data_series1, 'g-', 'LineWidth', 2); % 绘制第三个数组  
plot(time_series11, data_series11, 'm-', 'LineWidth', 2); % 绘制第四个数组  
stem(interference_times_pos, ones(size(interference_times_pos))+0.2, 'filled', 'MarkerSize', 10, 'LineWidth', 2);  
title('standard time slot'); % 设置标题  
xlabel('time (ms)'); % x轴标签  
ylabel('data'); % y轴标签  
yticks([0 1]); % 设置y轴刻度 
legend('without interference', 'with interference'); % 图例  
% grid on; % 添加网格  

% 绘制第二个子图  
subplot(3, 1, 2); % 当前绘制第2个子图  
hold on; % 保持当前图  
plot(time_series2, data_series2, 'g-', 'LineWidth', 2); % 绘制第三个数组  
plot(time_series22, data_series22, 'm-', 'LineWidth', 2); % 绘制第四个数组  
plot(time_series111, data_series111, 'b-', 'LineWidth', 2); % 绘制第三个数组  
plot(time_series222, data_series222, 'r-', 'LineWidth', 2); % 绘制第四个数组  
stem(interference_times_pos, ones(size(interference_times_pos))+0.2, 'filled', 'MarkerSize', 6, 'LineWidth', 2);  
title('Layered time slot'); % 设置标题  
xlabel('time (ms)'); % x轴标签  
yticks([0 1]); % 设置y轴刻度  
ylabel('data'); % y轴标签  
legend('without interference', 'with interference'); % 图例  
% grid on; % 添加网格  

subplot(3, 1, 3); % 将图形窗口分为2行1列，当前绘制第1个子图  
hold on; % 保持当前图  
bar(ds_twr1);
bar(ds_twr2*-1);
title('successfule positioning'); % 设置标题  
xlabel('time (ms)'); % x轴标签  
ylabel('data'); % y轴标签  
yticks([0 1]); % 设置y轴刻度 
legend('standard', 'layered'); % 图例  

% 设置整体标题（可选）  
sgtitle('DS-TWR in two MAC with interference'); % 设置整体标题

%比较完美地避过去了
