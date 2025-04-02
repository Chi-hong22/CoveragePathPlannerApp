%   TrajCollect - UAV路径信息矩阵
%   i           - TrajCollect的行号
%   length_min  - 最小长度（输入/输出）
%   index       - 选中的路径索引（输入/输出）
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 作者信息：
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function [length_min,index] = Dubins_Selection_Length(TrajCollect,length_min,index,i)
    length=TrajCollect(i,24);

    if length==0
        return;
    end

    if length_min==0
        length_min=length;
        index=i;
    end

    if length_min>length
        length_min=length;
        index=i;
    end
end

