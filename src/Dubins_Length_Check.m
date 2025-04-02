%% dubinsLengthCheck - 检测UAV是否可以生成符合长度要求的路径
%
% 功能描述：
%   检测UAV是否可以生成符合指定长度要求的路径。
%
% 输入参数：
%   length       - 预期路径长度
%   dubins_info  - 基本Dubins路径信息
%
% 输出参数：
%   result       - 路径是否可以生成的结果，1 表示可以，0 表示不可以
%   dubins_best  - 最接近预期长度的Dubins路径
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

function [result,dubins_best] = Dubins_Length_Check(length,dubins_info)
result=0;
for type=1:4
    dubins_info=Dubins_Generate(dubins_info,type);              % Calculate complete Dubins path information
    %If the current trajectory is shorter than the expected trajectory, there is room for PSO optimization
    if dubins_info.traj.length<=length
        [fit_gro_history,dubins_best]=...                       % Adjust the radius of the starting and ending arcs of the current path 
            Dubins_PSO(length,dubins_info);                     % using particle swarm optimization algorithm
        if min(fit_gro_history)<0.2*length                      % If the minimum length error is within the allowable range
            result=1;                                           % Indicating that the UAV can generate a path that satisfies the length constraint
            return;                                             % Terminate the function, and the following types will no longer be calculated
        end        
    end
end
end

