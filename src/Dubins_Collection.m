%% dubinsCollection - 生成所有类型（LSL, RSR, LSR, RSL）的路径信息
%
% 功能描述：
%   基于基本Dubins路径信息生成所有类型（LSL, RSR, LSR, RSL）的路径信息。
%
% 输入参数：
%   dubins_info - 基本Dubins路径信息
%   ObsInfo     - 障碍物信息矩阵
%   obs_index   - 当前需要避开的障碍物编号
%   Property    - 路径规划参数结构体
%
% 输出参数：
%   TrajCollect - 所有类型路径信息的矩阵
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

function TrajCollect = Dubins_Collection(dubins_info,ObsInfo,obs_index,Property)
TrajCollect=zeros(4,Property.Info_length);                          % Initialize the matrix of all type paths information
for type=1:4                                                        % Traverse each type of Dubins path
    dubins_info=Dubins_Generate(dubins_info,type);                  % Generate complete path information based on basic path information and path type
    if dubins_info.traj.length~=0                                   % If the generated trajectory length is not 0,it indicates the existence of a trajectory
        ObsSeries=Dubins_Obs_Check(dubins_info,ObsInfo,Property);   % Perform obstacle detection on the current path
    else
        continue;
    end
    TrajInfo=Traj_Info_Array(dubins_info,ObsSeries,Property);       % Record the Dubins path information and obstacle information on the path into an array
    TrajInfo(1,25)=obs_index;                                       % Record the number of the current obstacle to be avoided
    TrajCollect(type,:)=TrajInfo(1,:);                              % Store all types of path information
end

end

