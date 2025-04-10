%% CoveragePathPlannerApp - AUV 海底探测梳状全覆盖路径拐点生成工具
%
% 功能描述：
%   生成 AUV 海底探测梳状全覆盖路径拐点，并支持导出为.csv/.mat格式文件。
%   同时，新增了 dubins 路径规划避障算法相关设置，以及 TCP 设置和数据发送功能。
%   新增了 AUV 操纵性分析功能，支持仿真 AUV 在不同操作条件下的运动行为。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：dongxingan（董星犴）
%   邮箱：1443123118@qq.com
%   作者：陶奥飞
%   邮箱：taoaofei@gmail.com
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.5
%   创建日期：250110
%   最后修改：250328
%
% 版本历史：
%   v1.0 (241001) - 初始版本，实现基本的路径拐点生成功能
%   v1.1 (241101) - TCP 设置和数据发送功能
%   v1.2 (250110) - 新增 Dubins 路径规划避障算法设置，相应的TCP 设置和数据发送功能
%   v1.3 (250317) - 新增 AUV 多项路径规划路径点设置
%   v1.4 (250326) - 重构主体UI,将容错相关工况参数单独展示
%   v1.5 (250328) - 新增 AUV 操纵性分析功能
%
%   无直接输入参数，通过 GUI 界面设置相关参数
%
% 输出参数：
%   无直接返回值，生成的路径拐点数据可导出为.csv/.mat格式文件
%
% 注意事项：
%   1. 在使用 Dubins 路径规划避障算法前，请确保相关参数设置正确。
%   2. TCP 发送功能需要确保服务器 IP 和端口设置正确，且 AUV 设备已连接。
%   3. 导出路径点文件时，请选择合适的保存路径和文件格式。
%
% 调用示例：
%   无直接调用示例，通过运行 GUI 界面进行操作
%
% 依赖工具箱：
%   - MATLAB 自带的 GUI 组件和绘图工具箱
%
% 参见函数：
%   planUAVPaths, drawPaths, obstacleMarking, exportDubinsWaypoints, sendDubinsTCPData, importMapData, generatePath, exportWaypoints, sendTCPData



classdef CoveragePathPlannerApp < matlab.apps.AppBase

    properties (Access = public)
        %% 主窗口组件
        UIFigure                 matlab.ui.Figure        % 主应用窗口
        
        %% 面板容器组件
        InitPanel                matlab.ui.container.Panel  % AUV参数初始化面板
        PathParametersPanel      matlab.ui.container.Panel  % 路径参数面板
        FaultTolerantPanel       matlab.ui.container.Panel  % 容错参数设置面板
        TCPPanel                 matlab.ui.container.Panel  % TCP设置面板
        dubinsPanel              matlab.ui.container.Panel  % Dubins路径规划参数面板
        OperabilityPanel         matlab.ui.container.Panel  % UUV操作性设置面板       

        %% AUV初始参数组件
        % 速度和时间设置
        udEditField              matlab.ui.control.NumericEditField  % 最大速度设置
        udLabel                  matlab.ui.control.Label             % 最大速度标签
        TjEditField              matlab.ui.control.NumericEditField  % 急停时间设置
        TjLabel                  matlab.ui.control.Label             % 急停时间标签
        
        % 规划路径起点
        XEditField               matlab.ui.control.NumericEditField  % X坐标输入框
        XEditFieldLabel          matlab.ui.control.Label             % X坐标标签
        YEditField               matlab.ui.control.NumericEditField  % Y坐标输入框
        YEditFieldLabel          matlab.ui.control.Label             % Y坐标标签
        ZEditField               matlab.ui.control.NumericEditField  % Z坐标输入框
        ZEditFieldLabel          matlab.ui.control.Label             % Z坐标标签
        
        % AUV初始位置设置
        P0XEditField             matlab.ui.control.NumericEditField  % 初始X坐标
        P0XLabel                 matlab.ui.control.Label             % 初始X坐标标签
        P0YEditField             matlab.ui.control.NumericEditField  % 初始Y坐标
        P0YLabel                 matlab.ui.control.Label             % 初始Y坐标标签
        P0ZEditField             matlab.ui.control.NumericEditField  % 初始Z坐标
        P0ZLabel                 matlab.ui.control.Label             % 初始Z坐标标签
        
        % AUV初始姿态角设置
        A0XEditField             matlab.ui.control.NumericEditField  % Roll角
        A0XLabel                 matlab.ui.control.Label             % Roll角标签
        A0YEditField             matlab.ui.control.NumericEditField  % Pitch角
        A0YLabel                 matlab.ui.control.Label             % Pitch角标签
        A0ZEditField             matlab.ui.control.NumericEditField  % Yaw角
        A0ZLabel                 matlab.ui.control.Label             % Yaw角标签
        
        %% 梳状路径参数设置组件
        % 路径方向设置
        DirectionDropDown        matlab.ui.control.DropDown          % 路径方向下拉框
        DirectionDropDownLabel   matlab.ui.control.Label             % 路径方向标签
        
        % 路径参数设置
        LineSpacingEditField     matlab.ui.control.NumericEditField  % 梳状齿间距输入框
        LineSpacingEditFieldLabel matlab.ui.control.Label            % 梳状齿间距标签
        PathWidthEditField       matlab.ui.control.NumericEditField  % 路径总宽输入框
        PathWidthEditFieldLabel  matlab.ui.control.Label             % 路径总宽标签
        NumLinesEditField        matlab.ui.control.NumericEditField  % 路径条数输入框
        NumLinesEditFieldLabel   matlab.ui.control.Label             % 路径条数标签
        
        % 锚定和上下浮设置
        anchorEditField          matlab.ui.control.EditField         % 锚定点索引设置
        anchorEditFieldLabel     matlab.ui.control.Label             % 锚定点索引标签
        TanchorEditField         matlab.ui.control.NumericEditField  % 锚定时长设置
        TanchorEditFieldLabel    matlab.ui.control.Label             % 锚定时长标签
        downEditField            matlab.ui.control.EditField         % 下潜点索引设置
        downEditFieldLabel       matlab.ui.control.Label             % 下潜点索引标签
        DdownEditField           matlab.ui.control.NumericEditField  % 下潜深度设置
        DdownEditFieldLabel      matlab.ui.control.Label             % 下潜深度标签
        upEditField              matlab.ui.control.EditField         % 上浮点索引设置
        upEditFieldLabel         matlab.ui.control.Label             % 上浮点索引标签
        DupEditField             matlab.ui.control.NumericEditField  % 上浮深度设置
        DupEditFieldLabel        matlab.ui.control.Label             % 上浮深度标签

        %% 容错参数设置组件
        % 掉深时间设置

        TdEditField              matlab.ui.control.NumericEditField  % 掉深时间设置
        TdLabel                  matlab.ui.control.Label             % 掉深时间标签
        
        % 卡舵时间设置
        Kdelta1EditField         matlab.ui.control.NumericEditField  % 舵1卡舵时间
        Kdelta1Label             matlab.ui.control.Label             % 舵1卡舵时间标签
        Kdelta2EditField         matlab.ui.control.NumericEditField  % 舵2卡舵时间
        Kdelta2Label             matlab.ui.control.Label             % 舵2卡舵时间标签
        Kdelta3EditField         matlab.ui.control.NumericEditField  % 舵3卡舵时间
        Kdelta3Label             matlab.ui.control.Label             % 舵3卡舵时间标签
        Kdelta4EditField         matlab.ui.control.NumericEditField  % 舵4卡舵时间
        Kdelta4Label             matlab.ui.control.Label             % 舵4卡舵时间标签
        
        % 卡舵角度设置
        Delta1EditField          matlab.ui.control.NumericEditField  % 舵1卡舵角度
        Delta1Label              matlab.ui.control.Label             % 舵1卡舵角度标签
        Delta2EditField          matlab.ui.control.NumericEditField  % 舵2卡舵角度
        Delta2Label              matlab.ui.control.Label             % 舵2卡舵角度标签
        Delta3EditField          matlab.ui.control.NumericEditField  % 舵3卡舵角度
        Delta3Label              matlab.ui.control.Label             % 舵3卡舵角度标签
        Delta4EditField          matlab.ui.control.NumericEditField  % 舵4卡舵角度
        Delta4Label              matlab.ui.control.Label             % 舵4卡舵角度标签

        %% TCP通信设置组件
        ServerIPEditField        matlab.ui.control.EditField         % 服务器IP地址
        ServerIPLabel            matlab.ui.control.Label             % 服务器IP标签
        PortEditField            matlab.ui.control.NumericEditField  % 服务器端口
        PortLabel                matlab.ui.control.Label             % 服务器端口标签
        hostIPEditField          matlab.ui.control.EditField         % 本机IP地址
        hostIPLabel              matlab.ui.control.Label             % 本机IP标签
        hPortEditField           matlab.ui.control.NumericEditField  % 本机端口
        hPortLabel               matlab.ui.control.Label             % 本机端口标签
        
        %% Dubins路径规划参数组件
        dubinsnsLabel            matlab.ui.control.Label             % 前段路径点个数标签
        dubinsnsEditField        matlab.ui.control.NumericEditField  % 前段路径点个数输入框
        dubinsnlLabel            matlab.ui.control.Label             % 中段路径点个数标签
        dubinsnlEditField        matlab.ui.control.NumericEditField  % 中段路径点个数输入框
        dubinsnfLabel            matlab.ui.control.Label             % 后段路径点个数标签
        dubinsnfEditField        matlab.ui.control.NumericEditField  % 后段路径点个数输入框
        dubinsradiusLabel        matlab.ui.control.Label             % Dubins转弯半径标签
        dubinsradiusEditField    matlab.ui.control.NumericEditField  % Dubins转弯半径输入框

        %% UUV操作性设置组件
        DesiredSpeedEditField    matlab.ui.control.NumericEditField  % 期望速度
        SimulationTimeEditField  matlab.ui.control.NumericEditField  % 仿真时间
        Rudder1EditField         matlab.ui.control.NumericEditField  % 舵角1
        Rudder2EditField         matlab.ui.control.NumericEditField  % 舵角2
        Rudder3EditField         matlab.ui.control.NumericEditField  % 舵角3
        Rudder4EditField         matlab.ui.control.NumericEditField  % 舵角4
        StartOperabilitySimulationButton matlab.ui.control.Button    % 开始操作性仿真按钮

        %% 操作按钮组件
        GenerateButton           matlab.ui.control.Button            % 生成全局梳状路径按钮
        ExportGlobalWaypointsButton matlab.ui.control.Button         % 导出全局路径数据按钮
        SendGlobalPathsButton    matlab.ui.control.Button            % 发送全局路径数据按钮
        ImportButton             matlab.ui.control.Button            % 导入地图数据按钮
        ObstacleMarkingButton    matlab.ui.control.Button            % 障碍物标注按钮
        PlanLocalPathsButton     matlab.ui.control.Button            % 生成局部Dubins路径按钮
        ExportLocalWaypointsButton matlab.ui.control.Button          % 导出Dubins路径按钮
        SendLocalPathsButton     matlab.ui.control.Button            % 发送Dubins路径数据按钮
        % X1plotTCPButton          matlab.ui.control.Button            % AUV运行仿真图按钮
        % drawPathsButton          matlab.ui.control.Button            % 绘制路径按钮

        %% 显示区域组件
        UIAxes1                  matlab.ui.control.UIAxes            % 全局梳状路径显示区域
        UIAxes2                  matlab.ui.control.UIAxes            % 局部Dubins路径显示区域
        UIAxes3                  matlab.ui.control.UIAxes            % 地形及障碍物显示区域
        TotalLengthLabelandTCP   matlab.ui.control.Label             % 总路径长度及TCP状态显示
        StatusLabel              matlab.ui.control.Label             % 状态信息显示标签
        
        %% 数据存储变量
        Waypoints                                                    % 存储路径点数据

    end

    properties (SetAccess = immutable, GetAccess = public)
        currentProjectRoot string                                    % 项目根目录
    end

    methods (Access = private)
        function createComponents(app)
            %% 主窗口设置
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1300 830]; ...[100 100 1300 830]
            app.UIFigure.Name = 'UUV路径点上位机 (单位:m)';

            %% 1. 坐标初始化面板
            app.InitPanel = uipanel(app.UIFigure);
            app.InitPanel.Title = ' UUV参数(inf-无选择)';
            app.InitPanel.Position = [30 610 370 200]; % 增加面板高度

            % 设置期望速度
            uilabel(app.InitPanel, 'Text', '最大速度:', 'Position', [20 155 60 22]);
            app.udEditField = uieditfield(app.InitPanel, 'numeric');
            app.udEditField.Position = [75 155 40 22];
            app.udEditField.Value = 7.0;
            app.udEditField.HorizontalAlignment = 'center';

            % 设置急停时间
            uilabel(app.InitPanel, 'Text', '急停时间:', 'Position', [150 155 60 22]);
            app.TjEditField = uieditfield(app.InitPanel, 'numeric');
            app.TjEditField.Position = [205 155 40 22];
            app.TjEditField.Value = inf;
            app.TjEditField.HorizontalAlignment = 'center';

            % 规划路径起始点坐标
            uilabel(app.InitPanel, 'Text', '规划路径起点:', 'Position', [20 130 120 22]);

            % X 坐标
            app.XEditFieldLabel = uilabel(app.InitPanel);
            app.XEditFieldLabel.Position = [25 105 35 22];
            app.XEditFieldLabel.Text = 'X:';
            app.XEditFieldLabel.HorizontalAlignment = 'center';
            app.XEditField = uieditfield(app.InitPanel, 'numeric');
            app.XEditField.Position = [65 105 50 22];
            app.XEditField.Value = 160;
            app.XEditField.HorizontalAlignment = 'center';

            % Y 坐标
            app.YEditFieldLabel = uilabel(app.InitPanel);
            app.YEditFieldLabel.Position = [125 105 35 22];
            app.YEditFieldLabel.Text = 'Y:';
            app.YEditFieldLabel.HorizontalAlignment = 'center';
            app.YEditField = uieditfield(app.InitPanel, 'numeric');
            app.YEditField.Position = [165 105 50 22];
            app.YEditField.Value = 90;
            app.YEditField.HorizontalAlignment = 'center';

            % Z 坐标
            app.ZEditFieldLabel = uilabel(app.InitPanel);
            app.ZEditFieldLabel.Position = [225 105 35 22];
            app.ZEditFieldLabel.Text = 'Z:';
            app.ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.ZEditField.Position = [265 105 50 22];
            app.ZEditField.Value = 20;
            app.ZEditField.HorizontalAlignment = 'center';

            % AUV 初始位置
            uilabel(app.InitPanel, 'Text', 'AUV 初始位置:', 'Position', [20 80 100 22]);

            % X 坐标
            app.P0XLabel = uilabel(app.InitPanel);
            app.P0XLabel.Position = [25 55 35 22];
            app.P0XLabel.Text = 'X:';
            app.P0XLabel.HorizontalAlignment = 'center';
            app.P0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0XEditField.Position = [65 55 50 22];
            app.P0XEditField.Value = 100;
            app.P0XEditField.HorizontalAlignment = 'center';

            % Y 坐标
            app.P0YLabel = uilabel(app.InitPanel);
            app.P0YLabel.Position = [125 55 35 22];
            app.P0YLabel.Text = 'Y:';
            app.P0YLabel.HorizontalAlignment = 'center';
            app.P0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0YEditField.Position = [165 55 50 22];
            app.P0YEditField.Value = 0;
            app.P0YEditField.HorizontalAlignment = 'center';

            % Z 坐标
            app.P0ZLabel = uilabel(app.InitPanel);
            app.P0ZLabel.Position = [225 55 35 22];
            app.P0ZLabel.Text = 'Z:';
            app.P0ZLabel.HorizontalAlignment = 'center';
            app.P0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0ZEditField.Position = [265 55 50 22];
            app.P0ZEditField.Value = 20;
            app.P0ZEditField.HorizontalAlignment = 'center';

            % AUV 初始姿态角
            uilabel(app.InitPanel, 'Text', 'UUV 初始姿态角(角度制):', 'Position', [20 30 150 22]);

            % Roll
            app.A0XLabel = uilabel(app.InitPanel);
            app.A0XLabel.Position = [25 5 35 22];
            app.A0XLabel.Text = 'Roll:';
            app.A0XLabel.HorizontalAlignment = 'center';
            app.A0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0XEditField.Position = [65 5 50 22];
            app.A0XEditField.Value = 0;
            app.A0XEditField.HorizontalAlignment = 'center';

            % Pitch
            app.A0YLabel = uilabel(app.InitPanel);
            app.A0YLabel.Position = [125 5 35 22];
            app.A0YLabel.Text = 'Pitch:';
            app.A0YLabel.HorizontalAlignment = 'center';
            app.A0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0YEditField.Position = [165 5 50 22];
            app.A0YEditField.Value = 0;
            app.A0YEditField.HorizontalAlignment = 'center';

            % Yaw
            app.A0ZLabel = uilabel(app.InitPanel);
            app.A0ZLabel.Position = [225 5 35 22];
            app.A0ZLabel.Text = 'Yaw:';
            app.A0ZLabel.HorizontalAlignment = 'center';
            app.A0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0ZEditField.Position = [265 5 50 22];
            app.A0ZEditField.Value = 0;
            app.A0ZEditField.HorizontalAlignment = 'center';

            %% 2. 路径参数面板
            app.PathParametersPanel = uipanel(app.UIFigure);
            app.PathParametersPanel.Title = ' 路径参数';
            app.PathParametersPanel.Position = [30 465 370 140];

            % 方向选择
            app.DirectionDropDownLabel = uilabel(app.PathParametersPanel);
            app.DirectionDropDownLabel.Position = [10 95 80 22];
            app.DirectionDropDownLabel.Text = '路径方向:';

            app.DirectionDropDown = uidropdown(app.PathParametersPanel);
            app.DirectionDropDown.Items = {'   X ', '   Y '};  % 通过添加空格实现视觉居中
            app.DirectionDropDown.Position = [70 95 80 22];
            app.DirectionDropDown.Value = '   Y ';  % 需要匹配Items中的完整字符串
            
            % 梳状齿间距
            app.LineSpacingEditFieldLabel = uilabel(app.PathParametersPanel);
            app.LineSpacingEditFieldLabel.Position = [200 95 80 22];
            app.LineSpacingEditFieldLabel.Text = '梳状齿间距:';
            
            app.LineSpacingEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.LineSpacingEditField.Position = [270 95 80 22];
            app.LineSpacingEditField.Value = 200;
            app.LineSpacingEditField.HorizontalAlignment = 'center';   
            
            % 路径宽度
            app.PathWidthEditFieldLabel = uilabel(app.PathParametersPanel);
            app.PathWidthEditFieldLabel.Position = [10 65 80 22];
            app.PathWidthEditFieldLabel.Text = '路径总宽:';
            
            app.PathWidthEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.PathWidthEditField.Position = [70 65 80 22];
            app.PathWidthEditField.Value = 1730;
            app.PathWidthEditField.HorizontalAlignment = 'center';
            
            % 梳状路径数量
            app.NumLinesEditFieldLabel = uilabel(app.PathParametersPanel);
            app.NumLinesEditFieldLabel.Position = [200 65 80 22];
            app.NumLinesEditFieldLabel.Text = '路径条数:';
            
            app.NumLinesEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.NumLinesEditField.Position = [270 65 80 22];
            app.NumLinesEditField.Value = 10;
            app.NumLinesEditField.HorizontalAlignment = 'center';

            % 梳状路径锚定点
            app.anchorEditFieldLabel = uilabel(app.PathParametersPanel);
            app.anchorEditFieldLabel.Position = [10 35 80 22];
            app.anchorEditFieldLabel.Text = '锚定点索引:';
            
            app.anchorEditField = uieditfield(app.PathParametersPanel);
            app.anchorEditField.Position = [80 35 40 22];
            app.anchorEditField.Value = '1';
            app.anchorEditField.HorizontalAlignment = 'center';

            % 梳状路径锚定点时间
            app.TanchorEditFieldLabel = uilabel(app.PathParametersPanel);
            app.TanchorEditFieldLabel.Position = [10 5 80 22];
            app.TanchorEditFieldLabel.Text = '锚定时长:';
            
            app.TanchorEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.TanchorEditField.Position = [80 5 40 22];
            app.TanchorEditField.Value = 0;
            app.TanchorEditField.HorizontalAlignment = 'center';

            % 梳状路径下潜路径点
            app.downEditFieldLabel = uilabel(app.PathParametersPanel);
            app.downEditFieldLabel.Position = [125 35 80 22];
            app.downEditFieldLabel.Text = '下潜点索引:';
            
            app.downEditField = uieditfield(app.PathParametersPanel);
            app.downEditField.Position = [195 35 50 22];
            app.downEditField.Value = '21,22';
            app.downEditField.HorizontalAlignment = 'center';

            % 梳状路径下潜深度
            app.DdownEditFieldLabel = uilabel(app.PathParametersPanel);
            app.DdownEditFieldLabel.Position = [250 35 80 22];
            app.DdownEditFieldLabel.Text = '下潜深度:';
            
            app.DdownEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.DdownEditField.Position = [310 35 40 22];
            app.DdownEditField.Value = 30;
            app.DdownEditField.HorizontalAlignment = 'center';

            % 梳状路径上浮路径点
            app.upEditFieldLabel = uilabel(app.PathParametersPanel);
            app.upEditFieldLabel.Position = [125 5 80 22];
            app.upEditFieldLabel.Text = '上浮点索引:';
            
            app.upEditField = uieditfield(app.PathParametersPanel);
            app.upEditField.Position = [195 5 50 22];
            app.upEditField.Value = '25,26';
            app.upEditField.HorizontalAlignment = 'center';

            % 梳状路径上浮深度
            app.DupEditFieldLabel = uilabel(app.PathParametersPanel);
            app.DupEditFieldLabel.Position = [250 5 80 22];
            app.DupEditFieldLabel.Text = '上浮深度:';
            
            app.DupEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.DupEditField.Position = [310 5 40 22];
            app.DupEditField.Value = 10;
            app.DupEditField.HorizontalAlignment = 'center';

            %% 3. 容错参数面板

            app.FaultTolerantPanel = uipanel(app.UIFigure);
            app.FaultTolerantPanel.Title = ' 容错参数设置';
            app.FaultTolerantPanel.Position = [30 295 370 165]; 

            % 设置掉深时间
            uilabel(app.FaultTolerantPanel, 'Text', '掉深时间:', 'Position', [10 115 60 22]);
            app.TdEditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.TdEditField.Position = [70 115 40 22];
            app.TdEditField.Value = inf;
            app.TdEditField.HorizontalAlignment = 'center';

            uilabel(app.FaultTolerantPanel, 'Text', '设置卡舵时间(s):', 'Position', [10 95 120 14]);

            % 舵1
            app.Kdelta1Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta1Label.Position = [10 65 25 22];
            app.Kdelta1Label.Text = '舵1:';
            app.Kdelta1Label.HorizontalAlignment = 'center';
            app.Kdelta1EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta1EditField.Position = [35 65 50 22];
            app.Kdelta1EditField.Value = inf;
            app.Kdelta1EditField.HorizontalAlignment = 'center';

            % 舵2
            app.Kdelta2Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta2Label.Position = [100 65 25 22];
            app.Kdelta2Label.Text = '舵2:';
            app.Kdelta2Label.HorizontalAlignment = 'center';
            app.Kdelta2EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta2EditField.Position = [125 65 50 22];
            app.Kdelta2EditField.Value = inf;
            app.Kdelta2EditField.HorizontalAlignment = 'center';

            % 舵3
            app.Kdelta3Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta3Label.Position = [190 65 25 22];
            app.Kdelta3Label.Text = '舵3:';
            app.Kdelta3Label.HorizontalAlignment = 'center';
            app.Kdelta3EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta3EditField.Position = [215 65 50 22];
            app.Kdelta3EditField.Value = inf;
            app.Kdelta3EditField.HorizontalAlignment = 'center';

            % 舵4
            app.Kdelta4Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta4Label.Position = [280 65 25 22];
            app.Kdelta4Label.Text = '舵4:';
            app.Kdelta4Label.HorizontalAlignment = 'center';
            app.Kdelta4EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta4EditField.Position = [305 65 50 22];
            app.Kdelta4EditField.Value = inf;
            app.Kdelta4EditField.HorizontalAlignment = 'center';

            % 容错控制卡舵舵角设置
            uilabel(app.FaultTolerantPanel, 'Text', '设置卡舵舵角(°):', 'Position', [10 35 120 22]);

            % 舵1
            app.Delta1Label = uilabel(app.FaultTolerantPanel);
            app.Delta1Label.Position = [10 5 25 22];
            app.Delta1Label.Text = '舵1:';
            app.Delta1Label.HorizontalAlignment = 'center';
            app.Delta1EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta1EditField.Position = [35 5 50 22];
            app.Delta1EditField.Value = 0;
            app.Delta1EditField.HorizontalAlignment = 'center';

            % 舵2
            app.Delta2Label = uilabel(app.FaultTolerantPanel);
            app.Delta2Label.Position = [100 5 25 22];
            app.Delta2Label.Text = '舵2:';
            app.Delta2Label.HorizontalAlignment = 'center';
            app.Delta2EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta2EditField.Position = [125 5 50 22];
            app.Delta2EditField.Value = 0;
            app.Delta2EditField.HorizontalAlignment = 'center';

            % 舵3
            app.Delta3Label = uilabel(app.FaultTolerantPanel);
            app.Delta3Label.Position = [190 5 25 22];
            app.Delta3Label.Text = '舵3:';
            app.Delta3Label.HorizontalAlignment = 'center';
            app.Delta3EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta3EditField.Position = [215 5 50 22];
            app.Delta3EditField.Value = 0;
            app.Delta3EditField.HorizontalAlignment = 'center';

            % 舵4
            app.Delta4Label = uilabel(app.FaultTolerantPanel);
            app.Delta4Label.Position = [280 5 25 22];
            app.Delta4Label.Text = '舵4:';
            app.Delta4Label.HorizontalAlignment = 'center';
            app.Delta4EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta4EditField.Position = [305 5 50 22];
            app.Delta4EditField.Value = 0;
            app.Delta4EditField.HorizontalAlignment = 'center';

            %% 4. TCP设置面板
            app.TCPPanel = uipanel(app.UIFigure);
            app.TCPPanel.Title = ' TCP设置';
            app.TCPPanel.Position = [30 195 370 90]; 
            
            % TCP控件布局
            app.ServerIPLabel = uilabel(app.TCPPanel);
            app.ServerIPLabel.Position = [10 40 60 22];
            app.ServerIPLabel.Text = '服务器IP:'; 
            app.ServerIPEditField = uieditfield(app.TCPPanel);
            app.ServerIPEditField.Position = [65 40 100 22];
            app.ServerIPEditField.Value = '192.168.1.115';
            app.ServerIPEditField.HorizontalAlignment = 'center';

            app.PortLabel = uilabel(app.TCPPanel);
            app.PortLabel.Position = [200 40 80 22];
            app.PortLabel.Text = '服务器端口:';

            app.PortEditField = uieditfield(app.TCPPanel, 'numeric');
            app.PortEditField.Position = [280 40 60 22];
            app.PortEditField.Value = 5001;
            app.PortEditField.HorizontalAlignment = 'center';

            app.hostIPLabel = uilabel(app.TCPPanel);
            app.hostIPLabel.Position = [10 10 60 22];
            app.hostIPLabel.Text = '本机IP:'; 
            app.hostIPEditField = uieditfield(app.TCPPanel);
            app.hostIPEditField.Position = [65 10 100 22];
            app.hostIPEditField.Value = '192.168.1.100';
            app.hostIPEditField.HorizontalAlignment = 'center';

            app.hPortLabel = uilabel(app.TCPPanel);
            app.hPortLabel.Position = [200 10 80 22];
            app.hPortLabel.Text = '本机端口:';
            app.hPortEditField = uieditfield(app.TCPPanel, 'numeric');
            app.hPortEditField.Position = [280 10 60 22];
            app.hPortEditField.Value = 8888;
            app.hPortEditField.HorizontalAlignment = 'center';

            %% 5. Dubins 面板
            app.dubinsPanel = uipanel(app.UIFigure);
            app.dubinsPanel.Title = ' Dubins 路径规划设置(周期:圆弧-直线-圆弧)';
            app.dubinsPanel.Position = [30 100 370 90]; % 调整位置
            
            app.dubinsnsLabel = uilabel(app.dubinsPanel);
            app.dubinsnsLabel.Position = [10 40 120 22];
            app.dubinsnsLabel.Text = '前段路径点个数(圆弧):';
            
            app.dubinsnsEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnsEditField.Position = [140 40 40 22];
            app.dubinsnsEditField.Value = 1;
            app.dubinsnsEditField.HorizontalAlignment = 'center';
            
            app.dubinsnlLabel = uilabel(app.dubinsPanel);
            app.dubinsnlLabel.Position = [190 40 120 22];
            app.dubinsnlLabel.Text = '中段路径点个数(直线):';
            
            app.dubinsnlEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnlEditField.Position = [320 40 40 22];
            app.dubinsnlEditField.Value = 50;
            app.dubinsnlEditField.HorizontalAlignment = 'center';

            app.dubinsnfLabel = uilabel(app.dubinsPanel);
            app.dubinsnfLabel.Position = [10 10 120 22];
            app.dubinsnfLabel.Text = '后段路径点个数(圆弧):';

            app.dubinsnfEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnfEditField.Position = [140 10 40 22];
            app.dubinsnfEditField.Value = 1;
            app.dubinsnfEditField.HorizontalAlignment = 'center';

            app.dubinsradiusLabel = uilabel(app.dubinsPanel);
            app.dubinsradiusLabel.Position = [190 10 120 22];
            app.dubinsradiusLabel.Text = 'Dubins 转弯半径:';

            app.dubinsradiusEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsradiusEditField.Position = [320 10 40 22];
            app.dubinsradiusEditField.Value = 0;
            app.dubinsradiusEditField.HorizontalAlignment = 'center';

            %% 6. UUV操作性设置面板
            app.OperabilityPanel = uipanel(app.UIFigure);
            app.OperabilityPanel.Title = ' UUV操作性设置';
            app.OperabilityPanel.Position = [480 720 340 90]; % 位于按钮组上方

            % 舵角1
            uilabel(app.OperabilityPanel, 'Text', '舵角1:', 'Position', [10 40 40 22]); % 标签
            app.Rudder1EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder1EditField.Position = [50 40 30 22]; % 输入框
            app.Rudder1EditField.Value = 0;
            app.Rudder1EditField.HorizontalAlignment = 'center';

            % 舵角2
            uilabel(app.OperabilityPanel, 'Text', '舵角2:', 'Position', [85 40 40 22]); % 标签
            app.Rudder2EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder2EditField.Position = [125 40 30 22]; % 输入框
            app.Rudder2EditField.Value = 0;
            app.Rudder2EditField.HorizontalAlignment = 'center';

            % 舵角3
            uilabel(app.OperabilityPanel, 'Text', '舵角3:', 'Position', [165 40 40 22]); % 标签
            app.Rudder3EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder3EditField.Position = [205 40 30 22]; % 输入框
            app.Rudder3EditField.Value = 0;
            app.Rudder3EditField.HorizontalAlignment = 'center';

            % 舵角4
            uilabel(app.OperabilityPanel, 'Text', '舵角4:', 'Position', [245 40 40 22]); % 标签
            app.Rudder4EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder4EditField.Position = [285 40 30 22]; % 输入框
            app.Rudder4EditField.Value = 0;
            app.Rudder4EditField.HorizontalAlignment = 'center';

            % 期望速度
            uilabel(app.OperabilityPanel, 'Text', '期望速度:', 'Position', [10 5 55 22]);
            app.DesiredSpeedEditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.DesiredSpeedEditField.Position = [70 5 40 22];
            app.DesiredSpeedEditField.Value = 0;
            app.DesiredSpeedEditField.HorizontalAlignment = 'center';

            % 仿真时间
            uilabel(app.OperabilityPanel, 'Text', '仿真时间:', 'Position', [120 5 55 22]);
            app.SimulationTimeEditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.SimulationTimeEditField.Position = [180 5 40 22];
            app.SimulationTimeEditField.Value = 0;
            app.SimulationTimeEditField.HorizontalAlignment = 'center';

            % 开始操作性仿真按钮
            app.StartOperabilitySimulationButton = uibutton(app.OperabilityPanel, 'push');
            app.StartOperabilitySimulationButton.ButtonPushedFcn = @(~,~) startOperabilitySimulation(app);
            app.StartOperabilitySimulationButton.Position = [230 5 80 22];
            app.StartOperabilitySimulationButton.Text = '操纵性仿真';

            %% 7. 按钮组
            
            % 创建梳状路径生成按钮 - 根据区域边界自动计算梳状覆盖路径
            app.GenerateButton = uibutton(app.UIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = @(~,~) generatePath(app);
            app.GenerateButton.Position = [480 680 340 30]; % 新位置
            app.GenerateButton.Text = '生成全局梳状路径';

            % 创建梳状路径点导出按钮 - 将生成的梳状路径点以CSV格式保存到本地
            app.ExportGlobalWaypointsButton = uibutton(app.UIFigure, 'push');
            app.ExportGlobalWaypointsButton.ButtonPushedFcn = @(~,~) exportGlobalWaypoints(app);
            app.ExportGlobalWaypointsButton.Position = [480 645 340 30]; % 新位置
            app.ExportGlobalWaypointsButton.Text = '导出全局梳状路径数据(csv)';
            app.ExportGlobalWaypointsButton.Enable = 'off';

            % 创建梳状路径点发送按钮 - 通过TCP协议将梳状路径点数据发送至AUV
            app.SendGlobalPathsButton = uibutton(app.UIFigure, 'push');
            app.SendGlobalPathsButton.ButtonPushedFcn = @(~,~) sendGlobalData(app);
            app.SendGlobalPathsButton.Position = [480 610 340 30]; % 新位置
            app.SendGlobalPathsButton.Text = '发送全局梳状路径数据至 AUV ';
            app.SendGlobalPathsButton.Enable = 'off';

            % 创建地图数据导入按钮 - 从MAT文件中加载预设的地图数据
            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.ButtonPushedFcn = @(~,~) importMapData(app);
            app.ImportButton.Position = [480 575 340 30]; % 新位置
            app.ImportButton.Text = '导入地图数据';

            % 创建地形图及障碍物标注按钮 - 显示地形并允许用户标注障碍物
            app.ObstacleMarkingButton = uibutton(app.UIFigure, 'push');
            app.ObstacleMarkingButton.ButtonPushedFcn = @(~,~)obstacleMarking(app);
            app.ObstacleMarkingButton.Position = [480 540 340 30]; % 新位置
            app.ObstacleMarkingButton.Text = '地形图及障碍物标注';
            app.ObstacleMarkingButton.Enable = 'off';

            % 创建Dubins路径规划按钮
            app.PlanLocalPathsButton = uibutton(app.UIFigure, 'push');
            app.PlanLocalPathsButton.ButtonPushedFcn = @(~,~) planUAVPaths(app);
            app.PlanLocalPathsButton.Position =[480 505 340 30]; % 新位置
            app.PlanLocalPathsButton.Text = '生成局部 Dubins 路径规划';
            app.PlanLocalPathsButton.Enable = 'off';

            % 创建Dubins路径点导出按钮 - 将计算的路径点以CSV格式保存到本地文件
            app.ExportLocalWaypointsButton = uibutton(app.UIFigure, 'push');
            app.ExportLocalWaypointsButton.ButtonPushedFcn = @(~,~) exportLocalWaypoints(app);
            app.ExportLocalWaypointsButton.Position = [480 470 340 30]; % 新位置
            app.ExportLocalWaypointsButton.Text = '导出 Dubins 路径规划数据(csv)';
            app.ExportLocalWaypointsButton.Enable = 'off';

            % 创建Dubins路径点发送按钮 - 通过TCP协议将路径点数据发送至AUV
            app.SendLocalPathsButton = uibutton(app.UIFigure, 'push');
            app.SendLocalPathsButton.ButtonPushedFcn = @(~,~) sendLocalData(app);
            app.SendLocalPathsButton.Position = [480 435 340 30]; % 最下方按钮位置保持不变
            app.SendLocalPathsButton.Text = '发送 Dubins 路径规划数据至 AUV ';
            app.SendLocalPathsButton.Enable = 'off';

            % % 创建仿真图绘制按钮 - 可视化显示当前路径规划及环境的仿真效果
            % app.X1plotTCPButton = uibutton(app.UIFigure, 'push');
            % app.X1plotTCPButton.ButtonPushedFcn = @(~,~) X1plotTCP(app);
            % app.X1plotTCPButton.Position = [480 390 340 30];
            % app.X1plotTCPButton.Text = '绘制 AUV 运行仿真图';
            % app.X1plotTCPButton.Enable = 'off';

            %% 8. 状态标签
            % 总路径长度及TCP状态版本展示
            app.TotalLengthLabelandTCP = uilabel(app.UIFigure);
            app.TotalLengthLabelandTCP.Position = [30 60 320 40];
            app.TotalLengthLabelandTCP.Text = '总路径长度: 0.0 米';
            app.TotalLengthLabelandTCP.HorizontalAlignment = 'center';
            
            % 总体状态标签
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [30 30 320 30];
            app.StatusLabel.Text = '还未生成规划路径数据！';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontColor = [0.8 0 0];
            
            %% 9. 绘图区域
            
            % 创建AUV全局路径规划显示区域 - 用于展示覆盖路径规划的整体效果
            % 位于界面右上方，显示AUV在整个区域的梳状覆盖路径
            app.UIAxes1 = uiaxes(app.UIFigure);
            app.UIAxes1.Position = [860 430 390 390];
            title(app.UIAxes1, ' 全局梳状路径规划效果图');
            xlabel(app.UIAxes1, 'X轴 (米)');
            ylabel(app.UIAxes1, 'Y轴 (米)');
            grid(app.UIAxes1, 'on');

            % 创建Dubins局部路径规划显示区域 - 用于展示基于Dubins曲线的局部路径规划结果
            % 位于界面右下方，显示AUV在障碍物环境中的局部路径规划轨迹
            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.Position = [860 40 390 390];
            title(app.UIAxes2, '局部 Dubins 路径规划效果图');
            xlabel(app.UIAxes2, 'X轴 (米)');
            ylabel(app.UIAxes2, 'Y轴 (米)');
            grid(app.UIAxes2, 'on');

            % 创建地形与障碍物显示区域 - 用于显示环境地形和用户标注的障碍物
            % 位于界面中下方，允许用户交互式地标注和查看地形障碍物信息
            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.Position = [440 40 390 390];
            title(app.UIAxes3, '地形及障碍物标注图');
            xlabel(app.UIAxes3, 'X轴 (米)');
            ylabel(app.UIAxes3, 'Y轴 (米)');
            grid(app.UIAxes3, 'on');

        end

        %% 项目路径设置脚本
        function [projectRoot,currentDir]= setupAppPaths(app)
            % 获取当前脚本所在的目录
            currentDir = fileparts(mfilename('fullpath'));
            
            % 根据是否已部署设置项目根目录
            if isdeployed
                % 在已部署环境中，使用系统临时目录作为基础
                [status, tempPath] = system('echo %TEMP%');
                if status == 0
                    basePath = strtrim(tempPath);
                    appFolder = fullfile(basePath, 'CoveragePathPlannerApp');
                    
                    % 确保应用程序文件夹存在
                    if ~exist(appFolder, 'dir')
                        mkdir(appFolder);
                        fprintf('已创建应用程序文件夹: %s\n', appFolder);
                    end
                    projectRoot = appFolder;
                else
                    % 如果无法获取系统临时目录，使用当前目录
                    projectRoot = pwd;
                    fprintf('无法获取系统临时目录，使用当前目录: %s\n', projectRoot);
                end
            else
                % 开发环境，使用相对路径
                projectRoot = fullfile(currentDir, '..');
            end
            
            % 定义需要添加的核心文件夹路径
            pathsToAdd = {
%                 fullfile(currentDir, 'utils'),            ... 工具函数主目录
%                 fullfile(currentDir, 'utils', 'dubins'),  ... Dubins路径规划
%                 fullfile(currentDir, 'utils', 'main'),    ... 主要功能函数
%                 fullfile(currentDir, 'utils', 'plot'),    ... 绘图相关函数
%                 fullfile(currentDir, 'utils', 'trajectory'), ... 轨迹生成函数
                fullfile(projectRoot, 'data'),            ... 数据文件夹
                fullfile(projectRoot, 'picture')          ... 图片文件夹
            };
            
            % 确保文件夹存在
            if isdeployed
                % 已编译环境，只创建数据和输出文件夹
                dataPaths = {
                    fullfile(projectRoot, 'data'),
                    fullfile(projectRoot, 'picture')
                };
                
                for i = 1:length(dataPaths)
                    if ~exist(dataPaths{i}, 'dir')
                        try
                            mkdir(dataPaths{i});
                            fprintf('已部署环境: 创建文件夹 %s\n', dataPaths{i});
                        catch ME
                            warning('无法创建文件夹 %s: %s', dataPaths{i}, ME.message);
                        end
                    end
                end
            else
                % 开发环境，创建所有文件夹并添加到搜索路径
                for i = 1:length(pathsToAdd)
                    if ~exist(pathsToAdd{i}, 'dir')
                        try
                            mkdir(pathsToAdd{i});
                            fprintf('开发环境: 创建文件夹 %s\n', pathsToAdd{i});
                        catch ME
                            warning('无法创建文件夹 %s: %s', pathsToAdd{i}, ME.message);
                        end
                    end
                    
                    % 添加到搜索路径
                    addpath(pathsToAdd{i});
                    fprintf('已添加路径: %s\n', pathsToAdd{i});
                end
            end
            
            % 验证环境设置
            app.checkEnvironment();
            
            fprintf('路径设置完成！项目根目录: %s\n', projectRoot);
        end

        %% 检查必要的工具箱是否安装
        function checkEnvironment(~)
            requiredToolboxes = {'MATLAB', 'Simulink'};
            installedToolboxes = ver;
            installedToolboxNames = {installedToolboxes.Name};
            
            fprintf('\n环境检查:\n');
            for i = 1:length(requiredToolboxes)
                if any(contains(installedToolboxNames, requiredToolboxes{i}))
                    fprintf('? %s 已安装\n', requiredToolboxes{i});
                else
                    warning('? %s 未安装\n', requiredToolboxes{i});
                end
            end
            
            % 检查MATLAB版本
            matlabVersion = version;
            fprintf('当前MATLAB版本: %s\n', matlabVersion);
        end

        %% 添加启动和关闭时的清理代码
        function startup(app)
            try
                % 设置默认工作目录
                if ~isdeployed % 如果不是已编译的版本
                    cd(fileparts(mfilename('fullpath')));
                else
                    [status, result] = system('echo %TEMP%');
                    if status == 0
                        tempDir = strtrim(result);
                        cd(tempDir);
                    end
                end
                
                % 初始化状态
                app.StatusLabel.Text = '还未生成规划路径数据！';
                app.StatusLabel.FontColor = [0.8 0 0];
                
            catch ME
                warning(ME.identifier, '启动初始化失败: %s', ME.message);
            end
        end
        
        function cleanup(app)
            try
                % 清理任何打开的TCP连接
                if isfield(app, 'tcpClient') && isvalid(app.tcpClient)
                    clear app.tcpClient;
                end
            catch
                % 忽略清理错误
            end
        end
    end 

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CoveragePathPlannerApp()

            % 设置路径
            [projectRoot,~]=setupAppPaths(app);
            
            % 获取当前文件夹路径
            % app.currentProjectRoot = pwd;
            % app.currentProjectRoot = fullfile(fileparts(mfilename('fullpath')), '..');
            % app.currentProjectRoot = fullfile(pwd, '..');
            app.currentProjectRoot = projectRoot;
            % 注意：删除了以下使用 genpath 和 addpath 修改搜索路径的代码
            
            % 创建组件
            createComponents(app)
            
            % 初始化属性
            app.Waypoints = [];
            
            % 运行启动代码
            startup(app)
            
            % 显示界面
            app.UIFigure.Visible = 'on';
        end

        % 修改删除函数，添加清理代码
        function delete(app)
            % 运行清理代码
            cleanup(app)
            
            % 删除界面
            delete(app.UIFigure)
        end
    end
end