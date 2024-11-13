% 定义参数  
numSlots = 100; % 总的时隙数量  
dataPacketsCount = 10; % 数据包数量  
successProbability = 0.7; % 随机失败概率 (模型 1)  

% 生成数据包数组 (1表示数据包传输, 0表示没有传输)  
dataPacketsArray1 = zeros(1, numSlots);  
dataPacketsArray2 = zeros(1, numSlots);  

% 在随机位置添加数据包  
dataPacketPositions1 = randperm(numSlots, dataPacketsCount);  
dataPacketPositions2 = randperm(numSlots, dataPacketsCount);  

dataPacketsArray1(dataPacketPositions1) = 1;  
dataPacketsArray2(dataPacketPositions2) = 1;  

% 模型 1：简单随机失败  
failedPackets1 = rand(1, numSlots) > successProbability; % 生成随机失败  
simulatedArray1 = dataPacketsArray1 .* ~failedPackets1; % 计算模拟结果  

failedPackets2 = rand(1, numSlots) > successProbability; % 生成随机失败  
simulatedArray2 = dataPacketsArray2 .* ~failedPackets2; % 计算模拟结果  

% 模型 2：泊松分布  
lambda = 2; % 参数，泊松分布的平均失败数  
failedCount1 = poissrnd(lambda, 1, 1); % 生成一个随机失败数  
if failedCount1 > 0  
    failingSlots1 = randperm(numSlots, failedCount1); % 随机选择失败的时隙  
    simulatedArray1_poisson = simulatedArray1; % 复制数据包状态  
    simulatedArray1_poisson(failingSlots1) = 0; % 标记失败  
else  
    simulatedArray1_poisson = simulatedArray1; % 无失败  
end  

failedCount2 = poissrnd(lambda, 1, 1);  
if failedCount2 > 0  
    failingSlots2 = randperm(numSlots, failedCount2);   
    simulatedArray2_poisson = simulatedArray2;   
    simulatedArray2_poisson(failingSlots2) = 0;  
else  
    simulatedArray2_poisson = simulatedArray2;   
end  

% 模型 3：正态分布  
failureMean = round(0.1 * numSlots); % 预计失败的数量  
failureStdDev = 5; % 标准差  
numFailures = round(normrnd(failureMean, failureStdDev)); % 从正态分布抽取失败个数  
numFailures = max(0, min(numFailures, numSlots)); % 确保失败数量在合理范围  

if numFailures > 0  
    failingSlots3 = randperm(numSlots, numFailures);   
    simulatedArray1_normal = simulatedArray1;   
    simulatedArray1_normal(failingSlots3) = 0;  
else  
    simulatedArray1_normal = simulatedArray1;   
end  

% 模型 4：自相关性失败  
correlatedFailuresProb = 0.3; % 关联性概率  
simulatedArray1_correlation = simulatedArray1;  
for i = 1:numSlots-1  
    if simulatedArray1(i) == 1 && rand < correlatedFailuresProb  
        simulatedArray1_correlation(i+1) = 0; % 连续时隙失败  
    end  
end  

% 绘制结果  
figure;  

subplot(4, 2, 1);  
plot(dataPacketsArray1, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray1, 'r--', 'LineWidth', 2);  
title('Model 1: Simple Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 2);  
plot(dataPacketsArray2, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray2, 'r--', 'LineWidth', 2);  
title('Model 1: Simple Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 3);  
plot(dataPacketsArray1, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray1_poisson, 'r--', 'LineWidth', 2);  
title('Model 2: Poisson Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 4);  
plot(dataPacketsArray2, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray2_poisson, 'r--', 'LineWidth', 2);  
title('Model 2: Poisson Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 5);  
plot(dataPacketsArray1, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray1_normal, 'r--', 'LineWidth', 2);  
title('Model 3: Normal Distribution Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 6);  
plot(dataPacketsArray2, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray2_normal, 'r--', 'LineWidth', 2);  
title('Model 3: Normal Distribution Random Failure');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

subplot(4, 2, 7);  
plot(dataPacketsArray1, 'b-', 'LineWidth', 2); hold on;  
plot(simulatedArray1_correlation, 'r--', 'LineWidth', 2);  
title('Model 4: Correlated Failures');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;  

% 画出数据包 2 的关联性失败情况  
subplot(4, 2, 8);  
plot(dataPacketsArray2, 'b-', 'LineWidth', 2); hold on;  
title('Model 4: Correlated Failures');  
xlabel('Time Slots');  
ylabel('Data Packet Status');  
legend('Actual', 'Simulated');  
grid on;