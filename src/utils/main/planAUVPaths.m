%% planAUVPaths - 生成AUV的避障路径规划
%
% 功能描述：
%   基于 Dubins 曲线理论,为 AUV 生成避障路径。结合已标注的障碍物信息,
%   在保证安全的前提下生成平滑的路径。
%
% 输入参数：
%   app        - AUVCoveragePathPlannerApp的实例
%   numLines   - 路径线条数量
%   dubinsns   - Dubins路径起始段的离散点数
%   dubinsnl   - Dubins路径直线段的离散点数
%   dubinsnf   - Dubins路径结束段的离散点数
%
% 版本信息：
%   当前版本：v1.2
%   创建日期：241101
%   最后修改：250316
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function planAUVPaths(app,numLines,dubinsns,dubinsnl,dubinsnf)
    
    % 从工作区获取Waypoints变量
    try
        Waypoints = evalin('base', 'Waypoints');
    catch
        errordlg('工作区中未找到Waypoints变量', '错误');
        return;
    end

    % 加载圆的信息
    try
        load('circlesInformation.mat');
    catch
        errordlg('无法找到障碍物信息文件 circlesInformation.mat', '错误');
        return;
    end

    % 初始化数据
    Property.obs_last=0;                        % 记录当前轨迹规划期间避开的障碍物
    Property.invasion=0;                        % 记录轨迹规划期间是否有任何侵入障碍物(威胁区域)
    Property.mode=1;                           % 设置轨迹生成模式 1:最短路径; 2:常规路径
    Property.ns=dubinsns;                      % 设置起始弧段的离散点数
    Property.nl=dubinsnl;                      % 设置直线段的离散点数
    Property.nf=dubinsnf;                      % 设置弧段末端的离散点数
    Property.max_obs_num=5;                    % 设置每次路径规划要检测的最大障碍物数量
    Property.max_info_num=20;                  % 设置每个规划步骤存储的最大路径段数
    Property.max_step_num=4;                   % 设置路径的最大规划步数
    Property.Info_length=33;                   % 设置每个路径信息的长度
    Property.radius=100*1e3;                   % 设置AUV的转弯半径(mm)
    Property.scale=1;
    Property.increment=20*1e3;                 % 设置路径长度增量的调整范围
    Property.selection1=3;                     % 设置路径过滤模式1
    Property.selection2=1;                     % 设置路径过滤模式2
                                                % =1: 路径不与障碍物相交
                                                % =2: 路径的转弯角度不超过3*pi/2
                                                % =3: 同时满足1和2

    % 设置起点信息
    StartInfo=Waypoints(1:2*numLines-1,:);     % 单位(mm)

    % 设置终点信息
    FinishInfo=Waypoints(2:2*numLines,:);      % 单位(mm)

    % 设置障碍物(威胁圆)信息
    ObsInfo=circlesInfo;
    ObsInfo(:,3)=ObsInfo(:,3)+2;
    [AUV_num,~]=size(StartInfo);              % 获取AUV数量
    [obs_num,~]=size(ObsInfo);                % 获取障碍物数量

    Coop_State(1:AUV_num)=struct(...          % AUV航行路径信息的结构
        'trajLength',[],...                  % 所有路径长度数组
        'trajLength_max',0,...               % 最大路径长度
        'trajLength_min',0,...               % 最小路径长度
        'TrajSeqCell',[],...                  % 路径序列单元数组
        'ideal_length',0,...                  % 期望路径长度
        'optim_length',0,...                  % 优化后的路径长度
        'traj_index_top',0,...                % 大于且最接近期望路径长度的路径索引
        'traj_index_bottom',0,...             % 小于且最接近期望路径长度的路径索引
        'TrajSeq_Coop',[]);                   % 协作路径序列矩阵

    % 按顺序规划每个AUV从起点到终点的路径
    for AUV_index=1:2*numLines-1              % 遍历每个AUV
        start_info=StartInfo(AUV_index,:);    % 获取AUV的起点信息
        finish_info=FinishInfo(AUV_index,:);  % 获取AUV的终点信息
        Property.radius=start_info(4);        % 根据初始信息设置AUV的转弯半径
        TrajSeqCell=trajCollection...        % 计算AUV的所有可用航行路径
            (start_info,finish_info,ObsInfo,Property);                  
        Coop_State(AUV_index)=coopStateUpdate...  % 从可用航行路径中选择基本路径
            (TrajSeqCell,Coop_State(AUV_index),ObsInfo,Property); % 并优化基本路径以生成协作路径

        plotTrajMultiModification(TrajSeqCell,ObsInfo,Property);
        hold on;
    end

    result_no_duplicates = plotTrajCoop(Coop_State,ObsInfo,Property,1);            
    assignin('base','result_no_duplicates',result_no_duplicates);

    app.SendLocalTCPButton.Enable = 'on';
    app.GenerateButton.Enable = 'on';

    % 假设数据是多列，每两列代表一条路径的x和y坐标
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

    % 读取障碍物信息
    load('circlesInformation.mat', 'circlesInfo');

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
    legend(app.UIAxes2, '路径',  '起点', '终点', '障碍物');
    % 保持图形
    hold(app.UIAxes2, 'off');
end