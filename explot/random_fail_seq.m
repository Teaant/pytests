% 定义参数  
numSlots = 100; % 总的时隙数量  
dataPacketsCount = 10; % 数据包数量  
successProbability = 0.9; % - 数据包成功的概率  

% 生成数据包状态数组  
dataPacketsArray = zeros(1, numSlots);  
dataPacketPositions = randperm(numSlots, dataPacketsCount);  
dataPacketsArray(dataPacketPositions) = 1; % 假设随机位置有数据包  

% 初始化结果数组  
outputDataPackets = zeros(1, numSlots);  

% 模拟过程  
canSend = true; % 当前是否可以发送数据包  
for i = 1:numSlots  
    if dataPacketsArray(i) == 1   
        % 仅在当前有数据包时进行处理  
        if canSend  
            if rand < successProbability  
                outputDataPackets(i) = 1; % 发送成功  
            else  
                outputDataPackets(i) = 0; % 发送失败  
                canSend = false; % 失败后不再发送  
            end  
        else  
            outputDataPackets(i) = 0; % 由于前一个失败，后续不发送  
        end  
    else  
        outputDataPackets(i) = 0; % 当前时隙没有数据包  
    end  
end  

% 绘制结果  
figure;  
plot(dataPacketsArray, 'b-', 'LineWidth', 2); hold on;  
plot(outputDataPackets, 'r--', 'LineWidth', 2);  
title('模拟连续相关性数据包传输');  
xlabel('时隙');  
ylabel('数据包状态');  
legend('原始数据包', '模拟发送结果');  
grid on;