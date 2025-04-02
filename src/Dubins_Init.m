%% dubinsInit - 基于起始和结束信息初始化基本Dubins路径结构
%
% 功能描述：
%   根据起始点和终点信息初始化基本Dubins路径结构。
%
% 输入参数：
%   start_info  - 起始点信息
%   finish_info - 终点信息
%
% 输出参数：
%   dubins_info - 基本Dubins路径信息
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

function dubins_info = Dubins_Init(start_info,finish_info)

dubins_info.traj.type=0;                                    % Type of Dubins path
dubins_info.traj.erro=0;                                    % Error marker
dubins_info.traj.length=0;                                  % Path length
dubins_info.traj.flag=0;                                    % 0: Dubins path
                                                            % 1: Tangent parh
%% Starting information
dubins_info.start.x=start_info(1);                          % Starting point x coordinate
dubins_info.start.y=start_info(2);                          % Starting point y coordinate
dubins_info.start.phi=start_info(3);                        % Starting heading angle
dubins_info.start.R=start_info(4);                          % Starting arc radius
dubins_info.start.phi_c=0;                                  % Starting point azimuth angle
dubins_info.start.xc=0;                                     % Sarting arc center x coordinate
dubins_info.start.yc=0;                                     % Sarting arc center y coordinate
dubins_info.start.phi_ex=0;                                 % Cutting out azimuth angle
dubins_info.start.x_ex=0;                                   % Cutting out point x coordinate
dubins_info.start.y_ex=0;                                   % Cutting out point y coordinate
dubins_info.start.psi=0;                                    % Travel angles on the starting arc

%% Ending information
dubins_info.finish.x=finish_info(1);                        % Ending point x coordinate
dubins_info.finish.y=finish_info(2);                        % Ending point y coordinate
dubins_info.finish.phi=finish_info(3);                      % Ending heading angle
dubins_info.finish.R=finish_info(4);                        % Ending arc radius
dubins_info.finish.phi_c=0;                                 % Ending point azimuth angle
dubins_info.finish.xc=0;                                    % Ending arc center x coordinate
dubins_info.finish.yc=0;                                    % Ending arc center y coordinate
dubins_info.finish.phi_en=0;                                % Cutting in azimuth angle
dubins_info.finish.phi_en1=0;                               % Cutting in heading angle
dubins_info.finish.x_en=0;                                  % Cutting in point x coordinate
dubins_info.finish.y_en=0;                                  % Cutting in point y coordinate
dubins_info.finish.psi=0;                                   % Travel angles on the Ending arc
end

