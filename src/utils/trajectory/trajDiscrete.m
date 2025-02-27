%% trajDiscrete - 将路径序列离散化为航点序列
%
% 功能描述：
%   将Dubins路径序列离散化为航点序列。
%
% 输入参数：
%   TrajSeq  - 主路径序列矩阵
%   Property - 路径规划参数结构体
%
% 输出参数：
%   Traj_x   - 航点x坐标数组
%   Traj_y   - 航点y坐标数组
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
function [Traj_x,Traj_y] = trajDiscrete(TrajSeq,Property)
    [r,~]=size(TrajSeq);                                            % Obtain the number of Dubins path segments
    start_info=zeros(1,4);                                          % Initialize starting info
    finish_info=zeros(1,4);                                         % Initialize ending info
    ns=Property.ns;                                                 % Obtain number of discrete points in the starting arc
    nl=Property.nl;                                                 % Obtain number of discrete points in the straight line
    nf=Property.nf;                                                 % Obtain number of discrete points in the ending arc
    x_temp=zeros(1,10000);                                          % Initialize waypoints x coordinate sequence
    y_temp=zeros(1,10000);                                          % Initialize waypoints y coordinate sequence
    count=1;                                                        % Initialize waypoints conunter
    for i=1:r                                                       % Traverse every path segment in sequence
        type=TrajSeq(i,1);                                          % Obtain current path segment type
        if type==0                                                  % If the path type is 0
            break;                                                  % terminate loop
        end    
        start_info(1)=TrajSeq(i,2);                                 % Starting point x coordinate
        start_info(2)=TrajSeq(i,3);                                 % Starting point y coordinate
        start_info(3)=TrajSeq(i,4);                                 % Starting heading angle
        start_info(4)=TrajSeq(i,5);                                 % Starting arc radius
        finish_info(1)=TrajSeq(i,13);                               % Ending point x coordinate
        finish_info(2)=TrajSeq(i,14);                               % Ending point y coordinate
        finish_info(3)=TrajSeq(i,15);                               % Ending heading angle
        finish_info(4)=TrajSeq(i,16);                               % Ending arc radius

        dubins_info=dubinsInit(start_info,finish_info);            % Initialize basic Dubins path structure
        dubins_info=dubinsGenerate(dubins_info,type);              % Generate complete path information based on basic path information and path type
        [dubins_x,dubins_y]=dubinsDiscret(dubins_info,ns,nl,nf);   % Discretize Dubins path into waypoints sequence

        [~,n]=size(dubins_x);                                       % Obtain the number of waypoints for the current Dubins path segment
        for j=1:n                                                   % Sequentially store the waypoints of the current path segment
            x_temp(count)=dubins_x(j);                              
            y_temp(count)=dubins_y(j);                              
            count=count+1;                                          % Update waypoint counter
        end
    end
    Traj_x=zeros(1,count-1);
    Traj_y=zeros(1,count-1);
    Traj_x(:)=x_temp(1:count-1);                                    % Output waypoints x coordinate
    Traj_y(:)=y_temp(1:count-1);                                    % Output waypoints y coordinate
end

