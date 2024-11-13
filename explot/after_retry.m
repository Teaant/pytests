function [uniqueElements , da_twr2] = after_retry(retry_num, retrys, retry_array, ds_twr2)  
    % retry_array = zeros(1, num_slots);  
    % ds_twr2 = zeros(1, 4)
    for i= 1:retry_num
        for j = 2:4  %索引
            slot = retrys(i, j);
            if retry_array(slot) == 0
                retry_array(slot) = i;
                if j == 4
                    %三个数据包都没有碰撞
                    ds_twr2(retrys(i, 1)) = 1;
                end
            elseif retry_array(slot) == 0xFFFF
                %已经冲突，不再考虑了
                break;
            else
                %标记冲突
                last = retry_array(slot); %上一个在retrys当中的索引
                %上一个要失败
                disp("上一个冲突了的节点在"+last);
                ds_twr2(retrys(last, 1)) = 0;
                if retrys(last, 2) == slot
                    retry_array(retrys(last, 3)) = 0;
                    retry_array(retrys(last, 4)) = 0;
                elseif retrys(last, 3) == slot
                    retry_array(retrys(last, 4)) = 0; 
                end
                retry_array(slot) = 0xFFFF;
                break;
            end
        end
    end
    uniqueElements = retry_array;
    da_twr2 = ds_twr2;
end