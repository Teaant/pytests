% 定义输入矩阵A和B  
A = rand(3, 3);  % 随机生成3x3矩阵A  
B = rand(3, 3);  % 随机生成3x3矩阵B  

% 确保输入矩阵A和B都是3x3的  
assert(all(size(A) == [3, 3]), 'Matrix A must be 3x3.');  
assert(all(size(B) == [3, 3]), 'Matrix B must be 3x3.');  

% 初始化参数  
num_iterations = 200;  % 迭代次数  
num_candidates = 1000; % 候选数  
num_seeds = round(0.25 * num_candidates); % 选择前25%  

% 初始C矩阵为零  
C = zeros(3, 3);  

for iter = 1:num_iterations  
    % 生成随机候选矩阵  
    candidates = zeros(3, 3, num_candidates);  
    for i = 1:num_candidates  
        candidates(:, :, i) = C + (rand(3, 3) * 0.4 - 0.2); % 在[-0.2, 0.2]范围内  
    end  

    % 计算每个候选的范数  
    norms = zeros(num_candidates, 1);  
    for i = 1:num_candidates  
        norms(i) = norm(A - (B + candidates(:, :, i)), 'fro'); % Frobenius范数  
    end  

    % 排序并选择前25%  
    [~, sorted_indices] = sort(norms);  
    best_candidates = candidates(:, :, sorted_indices(1:num_seeds));  

    % 使用最佳候选生成新的候选矩阵  
    % 在每个最佳候选上添加微小摄动  
    perturbations = rand(3, 3, num_seeds) * 0.4 - 0.2; % 新的摄动范围  
    for i = 1:num_seeds  
        candidates(:, :, i) = best_candidates(:, :, i) + perturbations(:, :, i);  
    end  
    
    % 选择新的C  
    C = best_candidates(:, :, randi(num_seeds)); % 从最优候选中随机选择一个作为C  
end  

% 输出最终得到的矩阵C  
disp('Optimized Matrix C:');  
disp(C);