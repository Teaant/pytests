
%由于干扰出现的时间所引发的失败 → 计算信道利用率
%由于数据包传输所引发的失败  → 信道利用率          数据包传输失败概率如何随机产生？ 

%持续时间以2s暂时
clear;

Test = 2;

T = 2;
once_slot = 250;
num_slots = once_slot * T;          % 时隙数量  
slot_length = 2;       % 每个时隙的长度（ms）  
standard_slots = 6;

%泊松分布，产生随机数量失败的数据包   
% 模型 2：泊松分布  

% 125 / 6 = 20
CAP = 10; %假设必须要保留10个CAP时间段
N = floor((once_slot-CAP)/standard_slots) ;  %每一轮节点数

lambdap = floor(N/3); % 参数，泊松分布的平均失败数   lambda/N*3 也就是一次所有节点的数据包   20 * 3 = 60

maxID = 2000;
minID = 1;
IDs = randperm(maxID - minID + 1, N) + minID - 1;  
% IDs = 1:N*T;
%计算cap的开始时隙号  
k1 = floor(N/3);
if mod(N, 3) > 0 
    k1 = k1 +1;
end
cap_start = 9* k1 + 1 + 1; 
rest_cap = once_slot - cap_start  + 1;
%可以有多少个 ~
NN = floor(rest_cap / 2);  
collision_flag = 0xFFFF;

ds_twr = ones(1, N * T); %几轮啊  
ds_twr2 = ones(1, N * T); %几轮啊  

data_array1 = zeros(1, num_slots);  % 初始化为0 
data_array2 = zeros(1, num_slots);  % 初始化为0  
data_array11 = zeros(1, num_slots);  % 初始化为0  
data_array22 = zeros(1, num_slots);  % 初始化为0  

%有效DS-TWR时隙
data_array111 = zeros(1, num_slots);  % 初始化为0  
data_array222 = zeros(1, num_slots);  % 初始化为0  

pp = floor(num_slots/once_slot) -1;
for p = 0:pp
    bias = once_slot * p;
        for j = 1:N     
            %第一个数组 
            data_array1(6 *(j-1)+1 + 1 + bias) = 1;  % poll  0 resp 00 final  6  slots
            data_array1(6 *(j-1)+3 + 1 + bias) = 1;
            data_array1(6 *(j-1)+6 + 1 + bias) = 1; 
            data_array11(6 *(j-1)+1 + 1 + bias) = 1;  % poll  0 resp 00 final  6  slots
            data_array11(6 *(j-1)+3 + 1 + bias) = 1;
            data_array11(6 *(j-1)+6 + 1 + bias) = 1; 

            data_array111(6 *(j-1)+1 + 1 + bias) = 1;  % poll  0 resp 00 final  6  slots
            data_array111(6 *(j-1)+3 + 1 + bias) = 1;
            data_array111(6 *(j-1)+6 + 1 + bias) = 1; 
            
            %第二个数组 
            m = floor((j-1)/3); %第几组
            n = mod(j-1, 3);    %第几个 
            data_array2(9*m + n +1+1 + bias) = 1;  %这里不表示1和0，而是去表示持续时间？
            data_array2(9*m + n +1+3+1 + bias) = 1; % 不太行，因为实际数据包的传输时间很短很短， poll只有0.1ms,最大的final也才只有0.35ms,
            %所以为了画图，我现在考虑最大数据包长度下的持续时间 127B，也就是1.2ms
            data_array2(9*m + n +1+6+1 + bias) = 1;

            data_array22(9*m + n +1+1 + bias) = 1;  %这里不表示1和0，而是去表示持续时间？
            data_array22(9*m + n +1+3+1 + bias) = 1; 
            data_array22(9*m + n +1+6+1 + bias) = 1;  

            data_array222(9*m + n +1+1 + bias) = 1;  %这里不表示1和0，而是去表示持续时间？
            data_array222(9*m + n +1+3+1 + bias) = 1; 
            data_array222(9*m + n +1+6+1 + bias) = 1; 
        end
end


fail_slots1 = zeros(1, num_slots); 
fail_slots2 = zeros(1, num_slots); 

%产生随机失败的次数
failedCount1 = poissrnd(lambdap * T, 1, 1); % 生成一个随机失败数 
disp("随机选择"+failedCount1+"个数据包发生失败 ~");
datas = ones(1, N * 3*T);   %所有数据包
if failedCount1 > 0  
    failingdatas1 = randperm(N * 3 * T, failedCount1); % 随机选择失败的数据包，一共是60个
    datas(failingdatas1) = 0; %这些位置等于0
end


retrys = zeros(N*T, 4);    %在ds_twr2当中的索引 + slot 1 + slot 2 + slot 3
positioning = ones(T, N); % 0 测距失败   1 测距一次   2 测距两次   
retry_num = 0;

for i = 1:length(datas)  
    is_fail = datas(i);
    if is_fail == 0 
        %失败   
        m = floor((i-1)/(3*N));   %第m次超帧  从0开始
        j = mod(i-1, 3*N)+1;  %一次所有数据包当中的数据包序号，从1开始

        k = floor((j-1)/3) + 1; %一次超帧中的第k个节点，从1开始
        n = mod(j-1, 3) +1; %DS-TWR当中的第几个数据包，从1开始
        %更新数据包发送
        disp("第"+m+"个超帧的第"+k+"个节点的第"+n+"个数据包发生失败");
        ds_twr(k + N*m) = 0; 
        ds_twr2(k + N*m) = 0; 
        positioning(m+1, k) = 0;
        %找到两个协议的DS-TWR第一个数据包对应的时隙
        %标准MAC
        slot1 = m * once_slot + 6 * (k-1) + 1 +1 ; %poll帧数据包
        %分层时隙MAC
        %第二个数组 
        mm = floor((k-1)/3); %第几组 从0开始
        nn = mod(k-1, 3);    %第几个 从0开始
        slot2 = m * once_slot + mm * 9 + nn + 1 + 1;  % poll帧 
        if n == 1
            %全部失败
            fail_slots1(slot1) = 0;
            fail_slots2(slot2) = 0;
            %第一个 
            data_array11(slot1) = 0;
            data_array11(slot1+2) = 0;
            data_array11(slot1+5) = 0;

            data_array22(slot2) = 0;
            data_array22(slot2+3) = 0;
            data_array22(slot2+6) = 0;
            
            %重传  @Todo 可能有不同的选择策略 ~  连续，标准，等间隔  （也许也可以讨论，不过这个是out of scope）
            retry_num = retry_num +1;
            ID = IDs(k);  %节点ID 
            % disp("需要重传 "+(m+1)+", "+ID+"选择:"+ mod(ID, NN));
            retrys(retry_num, 1) = k + N*m; 
            %选择一个CAP
            select_cap1 = mod(ID, NN) * 2 + m *once_slot + cap_start; 
            retrys(retry_num, 2) = select_cap1;
            retrys(retry_num, 3) = select_cap1 + 2; 
            retrys(retry_num, 4) = select_cap1 + 5; 
            % disp("ds-twr2中的"+retrys(retry_num, 1)+"选择的CAP时隙是"+ retrys(retry_num, 2) +"，"+retrys(retry_num, 3)+"，"+retrys(retry_num, 4));
        elseif n == 2
            fail_slots1(slot1+2) = 0;
            fail_slots2(slot2+3) = 0;
            data_array11(slot1+2) = 0;
            data_array11(slot1+5) = 0;

            data_array22(slot2+3) = 0;
            data_array22(slot2+6) = 0;
            if (data_array22(slot2) == 1)
                retry_num = retry_num +1;
                ID = IDs(k);  %节点ID 
                % disp("需要重传 "+(m+1)+", "+ID+"选择:"+ mod(ID, NN));
                retrys(retry_num, 1) = k + N*m; 
                %选择一个CAP 
                select_cap1 = (mod(ID, NN) * 2 - 6) + m *once_slot + cap_start; 
                retrys(retry_num, 2) = select_cap1;
                retrys(retry_num, 3) = select_cap1 + 2; 
                retrys(retry_num, 4) = select_cap1 + 5; 
                % disp("ds-twr2中的"+retrys(retry_num, 1)+"选择的CAP时隙是"+ retrys(retry_num, 2) +"，"+retrys(retry_num, 3)+"，"+retrys(retry_num, 4));
            end
        else
            %如果是第三个数据包失败，不会重传
            fail_slots1(slot1+5) = 0;
            fail_slots2(slot2+6) = 0;

            data_array11(slot1+5) = 0;
            data_array22(slot2+6) = 0;          
        end
    end
end    



%不考虑干扰影响地前提下，但是还是需要考虑两两之间的冲突
retry_array = zeros(1, num_slots);  % 初始化为0（表示没有被占用，N*T + 1表示前面已经产生冲突） 元素的值对应在ds_twr2当中的索引  

% function [uniqueElements , da_twr2] = after_retry(retry_num, retrys, retry_array, ds_twr2) 
[retry_array, ds_twr2] = after_retry(retry_num, retrys, retry_array, ds_twr2);

%还是随机产生一些ID吧，也不管新加入了，就假设他们是要随机发送数据，然后随机地占用连续两个时隙
maxID = 3000;
minID = 2001; 
others = 5;
cap_data = zeros(T*others, 3);  %可能到最后还是没有用
selects = floor(rest_cap/2);
cap_node_num = 0;
for superframe = 0:T-1
    %每一次随机产生一定数量的节点产生请求
    otherIDs = randperm(maxID - minID + 1, others) + minID - 1;  
    otherIDs = test(mod(otherIDs, selects)); 
    for ii = 1:length(otherIDs)
        node = otherIDs(ii);
        cap_node_num = cap_node_num +1;
        select1 = superframe*once_slot + mod(node, selects)*2 + cap_start;
        cap_data(cap_node_num,1) = node;
        cap_data(cap_node_num,2) = select1;
        cap_data(cap_node_num,3) = select1+1;
    end
end

%未占用 0， 节点占用，   冲突 0xFFFF
%已经考虑过竞争访问了
%现在考虑外节点与测距节点的干扰

cap_array = zeros(1, num_slots);
%外节点的时隙占用（不考虑DS-TWR的）
for i = 1:cap_node_num
    cap_array(cap_data(i, 2)) = 1;   %？？
    cap_array(cap_data(i, 3)) = 1;
end

%考虑CAP阶段的DS-TWR的通信情况
cap_array1 = cap_array;
retry_array1 = retry_array;    %被干扰之后
for i = 1:cap_node_num
    comp_id = cap_data(i,1);
    %还有可能需要考虑你比方说第一个冲突了，那第二个也不可用了，因为要考虑这个前后的是吧
    index = cap_data(i,2); 
    if index >= 1 && index <= num_slots    
        if ((retry_array(index) ~= 0) && (retry_array(index) ~= collision_flag))    %所以和DS-TWR冲突了
            ds_twr2(retrys(retry_array(index),1)) = 0;
            retry_array1(index) = 0;
            if retrys(retry_array(index),2) == index   
                retry_array1(index + 2) = 0;    
                retry_array1(index + 5) = 0;    
            elseif retrys(retry_array(index),3) == index
                retry_array1(index + 3) = 0;  
            end
            cap_array1(index) = 0;  
            cap_array1(index+1) = 0;
        elseif (retry_array(index) == 0)
            %无冲突 不需要做什么 ~
        elseif (retry_array(index) ==  collision_flag)
            %已经冲突，外节点的全部冲突
            cap_array1(index) = 0; 
            cap_array1(index+1) = 0;
        end
    end
    index = cap_data(i,3); 
    if index >= 1 && index <= num_slots    
        if ((retry_array(index) ~= 0) && (retry_array(index) ~= collision_flag))    %所以和DS-TWR冲突了
            ds_twr2(retrys(retry_array(index),1)) = 0;
            retry_array1(index) = 0;
            if retrys(retry_array(index),2) == index   
                retry_array1(index + 2) = 0;    
                retry_array1(index + 5) = 0;    
            elseif retrys(retry_array(index),3) == index
                retry_array1(index + 3) = 0;  
            end
            cap_array1(index) = 0;  
        elseif (retry_array(index) == 0)
            %无冲突 不需要做什么 ~
        elseif (retry_array(index) ==  collision_flag)
            %已经冲突，外节点的全部冲突
            cap_array1(index) = 0; 
        end
    end
end

% num_slots = length(data_array1);
slot_duration = 2; % 每个时隙的持续时间为2ms  
packet_duration = 1.2; % 数据包传输持续时间为1.2ms  
no_packet_duration = slot_duration - packet_duration; % 无数据包持续时间为0.8ms 

% 生成时间序列  
time_series1 = []; % 初始化时间序列  
data_series1 = []; % 初始化数据序列  
time_series2 = []; % 初始化时间序列  
data_series2 = []; % 初始化数据序列  

time_series11 = []; % 初始化时间序列  
data_series11 = []; % 初始化数据序列  
time_series22 = []; % 初始化时间序列  
data_series22 = []; % 初始化数据序列 

time_series111 = []; % 初始化时间序列  
data_series111 = []; % 初始化数据序列  
time_series222 = []; % 初始化时间序列  
data_series222 = []; % 初始化数据序列 

cap_time11=[];
cap_data11=[];
cap_time22=[];
cap_data22=[];


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
    if (retry_array(i) ~= 0) && (retry_array(i) ~= collision_flag)
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

    if (retry_array1(i) ~=0) && (retry_array1(i) ~= collision_flag )
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


    if (cap_array(i) == 1)
        % 数据包传输的时间段  
        cap_time11 = [cap_time11, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        cap_data11 = [cap_data11, 1, 1]; % 数据包传输状态  

        % 无数据包的时间段  
        cap_time11 = [cap_time11, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        cap_data11 = [cap_data11, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        cap_time11 = [cap_time11, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        cap_data11 = [cap_data11, 0, 0]; % 无数据包状态  
    end 

    if (cap_array1(i) == 1)
        % 数据包传输的时间段  
        cap_time22 = [cap_time22, (i-1)*slot_duration, (i-1)*slot_duration + packet_duration]; % 开始和结束时间  
        cap_data22 = [cap_data22, -1, -1]; % 数据包传输状态  

        % 无数据包的时间段  
        cap_time22 = [cap_time22, (i-1)*slot_duration + packet_duration, i*slot_duration]; % 功率逐渐衰减至0  
        cap_data22 = [cap_data22, 0, 0]; % 无数据包状态  
    else  
        % 无数据包时段（保持为0）  
        cap_time22 = [cap_time22, (i-1)*slot_duration, i*slot_duration]; % 开始和结束时间  
        cap_data22 = [cap_data22, 0, 0]; % 无数据包状态  
    end  
end  

% 绘图  
figure;  

% 绘制第一个子图  
subplot(3, 1, 1); % 将图形窗口分为2行1列，当前绘制第1个子图  
hold on; % 保持当前图  
plot(time_series1, data_series1, 'g-', 'LineWidth', 2); % 绘制第三个数组  
plot(time_series11, data_series11, 'm-', 'LineWidth', 2); % 绘制第四个数组  

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
plot(time_series111, data_series111, 'b-', 'LineWidth', 2); % 绘制第四个数组  
plot(time_series222, data_series222, 'b-', 'LineWidth', 2); % 绘制第四个数组  
%cap_data22
plot(cap_time22, cap_data22, 'r-'); % 绘制第四个数组  
plot(cap_time11, cap_data11, 'r-'); % 绘制第四个数组  
% stem((fail_slots2-1)*slot_duration, ones(size(fail_slots2))+0.2, 'filled', 'MarkerSize', 6, 'LineWidth', 1);   
title('Layered time slot'); % 设置标题  
xlabel('time (ms)'); % x轴标签  
yticks([0 1]); % 设置y轴刻度  
ylabel('data'); % y轴标签  
legend('without interference', 'with interference'); % 图例  
% grid on; % 添加网格  

subplot(3, 1, 3); % 将图形窗口分为2行1列，当前绘制第1个子图  
hold on; % 保持当前图  
bar(ds_twr);
bar(ds_twr2*-1);
title('successfule positioning'); % 设置标题  
xlabel('time (ms)'); % x轴标签  
ylabel('data'); % y轴标签  
yticks([0 1]); % 设置y轴刻度 
legend('standard', 'layered'); % 图例  


% 设置整体标题（可选）  
sgtitle('DS-TWR in two MAC with interference'); % 设置整体标题

% 然后我如何评价啊，还是不知

%比较完美地避过去了
