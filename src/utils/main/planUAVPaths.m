    % 计划AUV路径
    %
    % 功能描述：
    %   此函数用于生成AUV的路径规划。它读取CSV文件中的航点信息，
    %   加载障碍物信息，并根据给定的参数生成路径。
    %   此函数用于从CSV文件中读取路径数据，并在UI界面中绘制路径。
    %   同时，它还会读取障碍物信息并绘制障碍物。
    %
    % 输入参数：
    %   app - AUVCoveragePathPlannerApp的实例
    %   numLines - 路径线条数量
    %   dubinsNs - Dubins路径起始段的离散点数
    %   dubinsNl - Dubins路径直线段的离散点数
    %   dubinsNf - Dubins路径结束段的离散点数
    %
    % 输出参数：
    %   pathPlanning - 生成的路径规划结果
    %
    % 注意事项：
    %   1. 确保CSV文件和障碍物信息文件存在且格式正确。
    %   2. 该函数会更新UI界面中的按钮状态。
    %
    % 版本信息：
    %   版本：v1.1
    %   创建日期：241101
    %   最后修改：250316
    %
    % 作者信息：
    %   作者：董星犴
    %   邮箱：1443123118@qq.com
    %   单位：哈尔滨工程大学
function planUAVPaths(app,numLines,dubinsns,dubinsnl,dubinsnf)
    % clear all;
    % close all;
    % clc;
%     addpath('Function_Plot');
%     addpath('Function_Dubins');
%     addpath('Function_Trajectory');
    % addpath('dubins_obstacle_avoidance');

    % 从工作区获取Waypoints变量
    try
        Waypoints = evalin('base', 'Waypoints');
    catch
        errordlg('工作区中未找到Waypoints变量', '错误');
        return;
    end
    % 从工作区获取circlesInfo变量
    try
        circlesInfo = evalin('base', 'circlesInfo');
    catch
        errordlg('工作区中未找到circlesInfo变量', '错误');
        return;
    end
    % % 加载圆的信息
    % try
    %     load('circlesInformation.mat');
    % catch
    %     errordlg('无法找到障碍物信息文件 circlesInformation.mat', '错误');
    %     return;
    % end

    % Initialize Data
    Property.obs_last=0;                                                % Record the obstacles avoided during current trajectory planning
    Property.invasion=0;                                                % Record whether there is any intrusion into obstacles (threat areas) during trajectory planning
    Property.mode=1;                                                    % Set trajectory generation mode 1: shortest path; 2: Conventional path
    Property.ns=dubinsns;                                                     % Set the number of discrete points in the starting arc segment
    Property.nl=dubinsnl;                                                     % Set the number of discrete points in the straight line segment
    Property.nf=dubinsnf;                                                     % Set the number of discrete points at the end of the arc segment
    Property.max_obs_num=5;                                             % Set the maximum number of obstacles to be detected for each path planning
    Property.max_info_num=20;                                           % Set the maximum number of stored path segments for each planning step
    Property.max_step_num=4;                                            % Set the maximum number of planned steps for the path
    Property.Info_length=33;                                            % Set the length of each path information
    Property.radius=100*1e3;                                            % Set the turning radius of the UAV（mm）
    Property.scale=1;
    Property.increment=20*1e3;                                          % Set the adjustment range of path lenth increment
    Property.selection1=3;                                              % Set path filtering mode 1
    Property.selection2=1;                                              % Set path filtering mode 2
                                                                    % =1: The path does not intersect with obstacles
                                                                    % =2: The turning angle of the path shall not exceed 3 * pi/2
                                                                    % =3: Simultaneously satisfying 1 and 2
                                                                
    % Set starting point infomation
    StartInfo=Waypoints(1:2*numLines-1,:);            % unit (mm)

    % Set ending point information
    FinishInfo=Waypoints(2:2*numLines,:);               % unit (mm)

    % Set obastacles (threat circle) information
    ObsInfo=circlesInfo;
    ObsInfo(:,3)=ObsInfo(:,3)+2;
    [uav_num,~]=size(StartInfo);                                        % Obtain UAVs number
    [obs_num,~]=size(ObsInfo);                                          % Obtain obstacles number

    Coop_State(1:uav_num)=struct(...                                    % The structure of flight paths information for UAVs
        'traj_length',[],...                                            % Array of all path length 
        'traj_length_max',0,...                                         % Maximum path length
        'traj_length_min',0,...                                         % Minimum path length
        'TrajSeqCell',[],...                                            % Path sequence cell array
        'ideal_length',0,...                                       % Expected path length
        'optim_length',0,...                                            % Optimized path length
        'traj_index_top',0,...                                          % Index of path that lenth is greater than and closest to the expected path length
        'traj_index_bottom',0,...                                       % Index of path that lenth is shorter than and closest to the expected path length
        'TrajSeq_Coop',[]);                                             % Matrix of cooperative path sequence

%% Plan the path of each UAV from the starting point to the endpoint in sequence
    for uav_index=1:2*numLines-1                                                   % Traverse each UAV
        start_info=StartInfo(uav_index,:);                              % Obtain the starting point information of the UAV
        finish_info=FinishInfo(uav_index,:);                            % Obtain the ending point information of the UAV
        Property.radius=start_info(4);                                  % Set the turning radius of the UAV based on initial information
        TrajSeqCell=Traj_Collection...                                  % Calculate all available flight paths for the UAV
            (start_info,finish_info,ObsInfo,Property);                  
        Coop_State(uav_index)=Coop_State_Update...                      % Select the basic path from the available flight paths
            (TrajSeqCell,Coop_State(uav_index),ObsInfo,Property);       % and optimize the basic path to generate a cooperative path

        Plot_Traj_Multi_Modification(TrajSeqCell,ObsInfo,Property);
        hold on;
    end


    Plot_Traj_Coop(Coop_State,ObsInfo,Property,1,1);                    % Plot cooperative path planning results
    % app.drawPathsButton.Enable = 'on';
    app.SendLocalTCPButton.Enable = 'on';
    app.GenerateButton.Enable = 'on';

    % 路径点简化脚本
    % 从工作区读取路径点数据
    path = evalin('base', 'result_no_duplicates');

    % 转换为数值矩阵（如果是表格）
    if istable(path)
        path = table2array(path);
    end

    % 检查输入数据的有效性
    if isempty(path) || size(path, 1) < 2
        warning('路径点数据不足，无法简化');
        return;
    end

    % 初始化简化后的路径
    simplified_path = [path(1, :)];

    % 遍历路径点
    for i = 2 : size(path, 1) - 1
        % 当前点
        current_point = path(i, :);
        % 下一个点
        next_point = path(i+1, :);
        % 上一个保留点
        last_simplified_point = simplified_path(end, :);
        
        % 条件1：横坐标相同，纵坐标不同，与上一个点纵坐标相同，横坐标不同
        condition1 = (current_point(1) == next_point(1)) && ...
                    (current_point(2) ~= next_point(2)) && ...
                    (last_simplified_point(2) == current_point(2)) && ...
                    (last_simplified_point(1) ~= current_point(1));
        
        % 条件2：横坐标不同，纵坐标相同，与上一个点纵坐标不同，横坐标相同
        condition2 = (current_point(1) ~= next_point(1)) && ...
                    (current_point(2) == next_point(2)) && ...
                    (last_simplified_point(2) ~= current_point(2)) && ...
                    (last_simplified_point(1) == current_point(1));
        
        % 条件3：横坐标和纵坐标都不同，与上一个点纵坐标不同，横坐标不同
        condition3 = (current_point(1) ~= next_point(1)) && ...
                    (current_point(2) ~= next_point(2)) && ...
                    (last_simplified_point(2) ~= current_point(2)) && ...
                    (last_simplified_point(1) ~= current_point(1));
        
        % 条件4：横坐标相同，纵坐标不同，与上一个点纵坐标不同，横坐标不同
        condition4 = (current_point(1) == next_point(1)) && ...
                    (current_point(2) ~= next_point(2)) && ...
                    (last_simplified_point(2) ~= current_point(2)) && ...
                    (last_simplified_point(1) ~= current_point(1));
        
        % 条件5：横坐标不同，纵坐标相同，与上一个点纵坐标不同，横坐标不同
        condition5 = (current_point(1) ~= next_point(1)) && ...
                    (current_point(2) == next_point(2)) && ...
                    (last_simplified_point(2) ~= current_point(2)) && ...
                    (last_simplified_point(1) ~= current_point(1));
        
        % 条件6：横坐标不同，纵坐标不同，与上一个点纵坐标相同，横坐标不同
        condition6 = (current_point(1) ~= next_point(1)) && ...
                    (current_point(2) ~= next_point(2)) && ...
                    (last_simplified_point(2) == current_point(2)) && ...
                    (last_simplified_point(1) ~= current_point(1));
        
        % 条件7：横坐标不同，纵坐标不同，与上一个点纵坐标不同，横坐标相同
        condition7 = (current_point(1) ~= next_point(1)) && ...
                    (current_point(2) ~= next_point(2)) && ...
                    (last_simplified_point(2) ~= current_point(2)) && ...
                    (last_simplified_point(1) == current_point(1));
        
        % 如果满足任一条件，保留当前点
        if condition1 || condition2 || condition3 || condition4 || condition5 || condition6 || condition7
            simplified_path = [simplified_path; current_point];
        end
    end

    % 添加终止点
    simplified_path = [simplified_path; path(end, :)];

    % 将简化后的路径存回工作区
    assignin('base', 'result_no_duplicates', simplified_path);

    % 从工作区获取路径数据
    try
        result_no_duplicates = evalin('base', 'result_no_duplicates');
    catch
        errordlg('工作区中未找到路径数据', '错误');
        return;
    end

    % 假设CSV文件中的数据是多列，每两列代表一条路径的x和y坐标
    numPaths = size(result_no_duplicates, 2) / 2; % 计算路径数量
    hold(app.UIAxes2, 'on'); % 保持当前图形，以便在同一图形上绘制多条路径

    % 绘制路径
    for i = 1:numPaths
        % 选择第i条路径的数据
        x = result_no_duplicates(:, 2*i-1);
        y = result_no_duplicates(:, 2*i);
        
        % 绘制路径
        plot(app.UIAxes2, x, y, 'b-', 'LineWidth', 2);
        
        % 绘制路径点
        plot(app.UIAxes2, x, y, 'bo', 'MarkerSize', 6);
        
        % 绘制起点（绿色方块）
        plot(app.UIAxes2, x(1), y(1), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % 绘制终点（红色方块）
        plot(app.UIAxes2, x(end), y(end), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
    end


    % 绘制障碍物
    for i = 1:size(circlesInfo, 1)
        % 获取圆的中心和半径
        centerX = circlesInfo(i, 1);
        centerY = circlesInfo(i, 2);
        radius = circlesInfo(i, 3);
        
        % 绘制圆
        rectangle(app.UIAxes2, 'Position', [centerX - radius, centerY - radius, 2*radius, 2*radius], ...
                    'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2);
    end

    % 为了在图例中显示障碍物，绘制一个红色圆圈
    plot(app.UIAxes2, NaN, NaN, 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Obstacles');

    % 设置坐标轴标签和网格
    xlabel(app.UIAxes2, 'X/m');
    ylabel(app.UIAxes2, 'Y/m');
    grid(app.UIAxes2, 'on');

    % 添加图例
%     legend(app.UIAxes2, '路径', '路径点', '起点', '终点', '障碍物');
    legend(app.UIAxes2, '路径',  '起点', '终点', '障碍物');
    % 保持图形
    hold(app.UIAxes2, 'off');

    % app.X1plotTCPButton.Enable = 'on';
    
end