%% trajLength - 计算路径长度
%
% 功能描述：
%   计算UAV路径序列的总长度。
%
% 输入参数：
%   TrajSeq - UAV路径序列矩阵
%
% 输出参数：
%   length - 路径总长度
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

function length = Traj_Length(TrajSeq)
[dubins_num,~]=size(TrajSeq);                                   % Obtain the number of segments in the path
length=0;                                                       % Initializa path length
for i=1:dubins_num                                              % Traverse all segments of the path
    length=length+TrajSeq(i,24);                                % Accumulate the length of each segment
end
end

