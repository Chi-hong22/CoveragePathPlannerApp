%% dubinsObsCheck - 检测当前Dubins路径上的障碍物数量
%
% 功能描述：
%   检测当前Dubins路径上存在的障碍物数量。
%
% 输入参数：
%   dubins_info - 完整的Dubins路径信息
%   ObsInfo     - 障碍物信息矩阵
%   Property    - 路径规划参数结构体
%
% 输出参数：
%   Obs_Series  - 障碍物编号数组
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function Obs_Series = dubinsObsCheck(dubins_info, ObsInfo, Property)
%% Initialize information
[obs_num,~]=size(ObsInfo);                                      % Obtain the number of obstacles
ns=Property.ns;                                                 % Number of discrete points on the starting arc
nl=Property.nl;                                                 % Number of discrete points on the straight line
nf=Property.nf;                                                 % Number of discrete points on the ending arc
[dubins_x,dubins_y]=dubinsDiscret(dubins_info,ns,nl,nf);       % Generate waypoints
[~,pt_num]=size(dubins_x);                                      % Obtain the number of waypoints
Obs_Temp=zeros(1,Property.max_obs_num);                         % Initialize temporary obstacle number sequence
Obs_Series=zeros(1,Property.max_obs_num);                       % Initialize obstacle number sequence
c1=0;                                                           % Initialize counter 1
c2=0;                                                           % Initialize counter 2
%% Detect obstacles on the path in sequence 
for i=1:obs_num                                                 % Traverse every obstacle
    if Property.invasion==1&&...                                % If the obstacle was intruded during the last path planning
            i==Property.obs_last
        continue;                                               % Do not record the obstacle
    end
    for j=1:pt_num                                              % Traverse each waypoint sequentially
        x=dubins_x(j);                                          % Obtain the waypoint x coordinate
        y=dubins_y(j);                                          % Obtain the waypoint y coordinate
        xo=ObsInfo(i,1);                                        % Obtain the obstacle center x coordinate
        yo=ObsInfo(i,2);                                        % Obtain the obstacle center y coordinate
        Ro=ObsInfo(i,3);                                        % Obtain the obstacle radius
        if sqrt((x-xo)^2+(y-yo)^2)<0.99*Ro                      % If the distance from the waypoint to the center of the obstacle is less than the radius of the obstacle
            c1=c1+1;                                            % Update counter
            Obs_Temp(1,c1)=i;                                   % Record the obstacle number in temporary obstacle number sequence
            break;                                              % Stop traversing subsequent waypoints
        end
    end
end
%% Reorder obstacles on the path according to the direction of the path
for i=1:pt_num                                                  % Traverse each waypoint sequentially
    for j=1:c1                                                  % Traverse every obstacle intersect with the path
        x=dubins_x(i);                                          % Obtain the waypoint x coordinate
        y=dubins_y(i);                                          % Obtain the waypoint y coordinate
        xo=ObsInfo(Obs_Temp(j),1);                              % Obtain the obstacle center x coordinate
        yo=ObsInfo(Obs_Temp(j),2);                              % Obtain the obstacle center y coordinate
        Ro=ObsInfo(Obs_Temp(j),3);                              % Obtain the obstacle radius
        if sqrt((x-xo)^2+(y-yo)^2)<Ro                           % If the distance from the waypoint to the center of the obstacle is less than the radius of the obstacle
            if c2==0||Obs_Series(1,c2)~=Obs_Temp(j)
                c2=c2+1;                                        % Update counter
                Obs_Series(1,c2)=Obs_Temp(j);                   % Record the obstacle number in obstacle number sequence
            end
            break;                                              % Stop traversing subsequent waypoints
        end
    end
end

end

