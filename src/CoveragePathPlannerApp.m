%% CoveragePathPlannerApp - AUV 海底探测梳状全覆盖路径拐点生成工具
%
% 功能描述：
%   生成 AUV 海底探测梳状全覆盖路径拐点，并支持导出为.csv/.mat格式文件。
%   同时，新增了 dubins 路径规划避障算法相关设置，以及 TCP 设置和数据发送功能。
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
%   当前版本：v1.3
%   创建日期：250110
%   最后修改：250317
%
% 版本历史：
%   v1.0 (241001) - 初始版本，实现基本的路径拐点生成功能
%   v1.1 (241101) - TCP 设置和数据发送功能
%   v1.2 (250110) - 新增 dubins 路径规划避障算法设置，相应的TCP 设置和数据发送功能
%   v1.3 (250317) - 新增 AUV 多项路径规划路径点设置
%
% 输入参数：
%   无直接输入参数，通过 GUI 界面设置相关参数
%
% 输出参数：
%   无直接返回值，生成的路径拐点数据可导出为.csv/.mat格式文件
%
% 注意事项：
%   1. 在使用 dubins 路径规划避障算法前，请确保相关参数设置正确。
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
        UIFigure                 matlab.ui.Figure
        StartPointPanel          matlab.ui.container.Panel
        XEditField               matlab.ui.control.NumericEditField
        XEditFieldLabel          matlab.ui.control.Label
        YEditField               matlab.ui.control.NumericEditField
        YEditFieldLabel          matlab.ui.control.Label
        PathParametersPanel      matlab.ui.container.Panel
        LineSpacingEditField     matlab.ui.control.NumericEditField
        LineSpacingEditFieldLabel  matlab.ui.control.Label
        PathWidthEditField       matlab.ui.control.NumericEditField
        PathWidthEditFieldLabel  matlab.ui.control.Label
        NumLinesEditField        matlab.ui.control.NumericEditField
        NumLinesEditFieldLabel   matlab.ui.control.Label
        DirectionDropDown        matlab.ui.control.DropDown
        DirectionDropDownLabel   matlab.ui.control.Label
        
        
        % 新增的初始化面板
        InitPanel          matlab.ui.container.Panel

        % 新增卡舵序号和卡舵角度
        Kdelta1EditField             matlab.ui.control.NumericEditField
        Kdelta1Label                 matlab.ui.control.Label
        Kdelta2EditField             matlab.ui.control.NumericEditField
        Kdelta2Label                 matlab.ui.control.Label
        Kdelta3EditField             matlab.ui.control.NumericEditField
        Kdelta3Label                 matlab.ui.control.Label
        Kdelta4EditField             matlab.ui.control.NumericEditField
        Kdelta4Label                 matlab.ui.control.Label

        Delta1EditField             matlab.ui.control.NumericEditField
        Delta1Label                 matlab.ui.control.Label
        Delta2EditField             matlab.ui.control.NumericEditField
        Delta2Label                 matlab.ui.control.Label
        Delta3EditField             matlab.ui.control.NumericEditField
        Delta3Label                 matlab.ui.control.Label
        Delta4EditField             matlab.ui.control.NumericEditField
        Delta4Label                 matlab.ui.control.Label

        %新增期望速度设置
        udEditField             matlab.ui.control.NumericEditField
        udLabel                 matlab.ui.control.Label

        %新增掉深时间设置
        TdEditField             matlab.ui.control.NumericEditField
        TdLabel                 matlab.ui.control.Label

        %新增急停时间设置
        TjEditField             matlab.ui.control.NumericEditField
        TjLabel                 matlab.ui.control.Label
        %新增路径Z坐标设置
        ZEditField             matlab.ui.control.NumericEditField
        ZLabel                 matlab.ui.control.Label
        ZEditFieldLabel  matlab.ui.control.Label
        %新增上浮/下潜设置
        upEditField             matlab.ui.control.EditField
        upEditFieldLabel  matlab.ui.control.Label
        downEditField             matlab.ui.control.EditField
        downEditFieldLabel  matlab.ui.control.Label
        DupEditField             matlab.ui.control.NumericEditField
        DupEditFieldLabel  matlab.ui.control.Label
        DdownEditField             matlab.ui.control.NumericEditField
        DdownEditFieldLabel  matlab.ui.control.Label
        
        % 新增初始位置和姿态角面板
        P0XEditField             matlab.ui.control.NumericEditField
        P0XLabel                 matlab.ui.control.Label
        P0YEditField             matlab.ui.control.NumericEditField
        P0YLabel                 matlab.ui.control.Label
        P0ZEditField             matlab.ui.control.NumericEditField
        P0ZLabel                 matlab.ui.control.Label
        
        A0XEditField            matlab.ui.control.NumericEditField
        A0XLabel                matlab.ui.control.Label
        A0YEditField            matlab.ui.control.NumericEditField
        A0YLabel                matlab.ui.control.Label
        A0ZEditField            matlab.ui.control.NumericEditField
        A0ZLabel                matlab.ui.control.Label
        
        % 新增TCP设置面板
        TCPPanel                matlab.ui.container.Panel
        ServerIPEditField       matlab.ui.control.EditField
        ServerIPLabel           matlab.ui.control.Label
        PortEditField           matlab.ui.control.NumericEditField
        PortLabel               matlab.ui.control.Label

        hostIPEditField       matlab.ui.control.EditField
        hostIPLabel           matlab.ui.control.Label
        hPortEditField           matlab.ui.control.NumericEditField
        hPortLabel               matlab.ui.control.Label
        
        GenerateButton          matlab.ui.control.Button
        SendTCPButton          matlab.ui.control.Button % 新增TCP发送按钮
        X1plotTCPButton          matlab.ui.control.Button
        UIAxes1                  matlab.ui.control.UIAxes
        UIAxes2                  matlab.ui.control.UIAxes
        UIAxes3                  matlab.ui.control.UIAxes
        TotalLengthLabelandTCP  matlab.ui.control.Label
        StatusLabel            matlab.ui.control.Label % 新增状态显示标签
        ExportButton           matlab.ui.control.Button
        Waypoints
        
        %新增dubins路径规划避障算法
        dubinsPanel           matlab.ui.container.Panel
        dubinsnsLabel         matlab.ui.control.Label
        dubinsnsEditField      matlab.ui.control.NumericEditField
        dubinsnlLabel         matlab.ui.control.Label
        dubinsnlEditField      matlab.ui.control.NumericEditField
        dubinsnfLabel         matlab.ui.control.Label
        dubinsnfEditField      matlab.ui.control.NumericEditField
        dubinsradiusLabel     matlab.ui.control.Label
        dubinsradiusEditField       matlab.ui.control.NumericEditField
        
        PlanPathsButton          matlab.ui.control.Button
%         drawPathsButton             matlab.ui.control.Button
        obstacleMarkingButton             matlab.ui.control.Button
        exportDubinsWaypointsButton          matlab.ui.control.Button
        SendLocalTCPButton       matlab.ui.control.Button
        ImportButton       matlab.ui.control.Button
    end

    properties (SetAccess = immutable, GetAccess = public)
        currentProjectRoot string    % 将属性移到这个新的属性块中
    end

    methods (Access = private)
        function createComponents(app)
            %% 主窗口设置
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1300 900]; ...[100 100 1300 830]
            app.UIFigure.Name = 'AUV路径点上位机 (单位:m)';

            %% 1. 坐标初始化面板
            app.InitPanel = uipanel(app.UIFigure);
            app.InitPanel.Title = ' 相关参数初始化(inf-无选择)';
            app.InitPanel.Position = [30 460 370 350]; % 增加面板高度

            % 容错控制卡舵序号设置
            uilabel(app.InitPanel, 'Text', '设置卡舵时间(s):', 'Position', [10 310 120 14]);

            % 舵1
            app.Kdelta1Label = uilabel(app.InitPanel);
            app.Kdelta1Label.Position = [10 280 25 22];
            app.Kdelta1Label.Text = '舵1:';
            app.Kdelta1Label.HorizontalAlignment = 'center';
            app.Kdelta1EditField = uieditfield(app.InitPanel, 'numeric');
            app.Kdelta1EditField.Position = [35 280 50 22];
            app.Kdelta1EditField.Value = inf;
            app.Kdelta1EditField.HorizontalAlignment = 'center';

            % 舵2
            app.Kdelta2Label = uilabel(app.InitPanel);
            app.Kdelta2Label.Position = [100 280 25 22];
            app.Kdelta2Label.Text = '舵2:';
            app.Kdelta2Label.HorizontalAlignment = 'center';
            app.Kdelta2EditField = uieditfield(app.InitPanel, 'numeric');
            app.Kdelta2EditField.Position = [125 280 50 22];
            app.Kdelta2EditField.Value = inf;
            app.Kdelta2EditField.HorizontalAlignment = 'center';

            % 舵3
            app.Kdelta3Label = uilabel(app.InitPanel);
            app.Kdelta3Label.Position = [190 280 25 22];
            app.Kdelta3Label.Text = '舵3:';
            app.Kdelta3Label.HorizontalAlignment = 'center';
            app.Kdelta3EditField = uieditfield(app.InitPanel, 'numeric');
            app.Kdelta3EditField.Position = [215 280 50 22];
            app.Kdelta3EditField.Value = inf;
            app.Kdelta3EditField.HorizontalAlignment = 'center';

            % 舵4
            app.Kdelta4Label = uilabel(app.InitPanel);
            app.Kdelta4Label.Position = [280 280 25 22];
            app.Kdelta4Label.Text = '舵4:';
            app.Kdelta4Label.HorizontalAlignment = 'center';
            app.Kdelta4EditField = uieditfield(app.InitPanel, 'numeric');
            app.Kdelta4EditField.Position = [305 280 50 22];
            app.Kdelta4EditField.Value = inf;
            app.Kdelta4EditField.HorizontalAlignment = 'center';

            % 容错控制卡舵舵角设置
            uilabel(app.InitPanel, 'Text', '设置卡舵舵角(°):', 'Position', [10 250 120 22]);

            % 舵1
            app.Delta1Label = uilabel(app.InitPanel);
            app.Delta1Label.Position = [10 220 25 22];
            app.Delta1Label.Text = '舵1:';
            app.Delta1Label.HorizontalAlignment = 'center';
            app.Delta1EditField = uieditfield(app.InitPanel, 'numeric');
            app.Delta1EditField.Position = [35 220 50 22];
            app.Delta1EditField.Value = 0;
            app.Delta1EditField.HorizontalAlignment = 'center';

            % 舵2
            app.Delta2Label = uilabel(app.InitPanel);
            app.Delta2Label.Position = [100 220 25 22];
            app.Delta2Label.Text = '舵2:';
            app.Delta2Label.HorizontalAlignment = 'center';
            app.Delta2EditField = uieditfield(app.InitPanel, 'numeric');
            app.Delta2EditField.Position = [125 220 50 22];
            app.Delta2EditField.Value = 0;
            app.Delta2EditField.HorizontalAlignment = 'center';

            % 舵3
            app.Delta3Label = uilabel(app.InitPanel);
            app.Delta3Label.Position = [190 220 25 22];
            app.Delta3Label.Text = '舵3:';
            app.Delta3Label.HorizontalAlignment = 'center';
            app.Delta3EditField = uieditfield(app.InitPanel, 'numeric');
            app.Delta3EditField.Position = [215 220 50 22];
            app.Delta3EditField.Value = 0;
            app.Delta3EditField.HorizontalAlignment = 'center';

            % 舵4
            app.Delta4Label = uilabel(app.InitPanel);
            app.Delta4Label.Position = [280 220 25 22];
            app.Delta4Label.Text = '舵4:';
            app.Delta4Label     .HorizontalAlignment = 'center';
            app.Delta4EditField = uieditfield(app.InitPanel, 'numeric');
            app.Delta4EditField.Position = [305 220 50 22];
            app.Delta4EditField.Value = 0;
            app.Delta4EditField.HorizontalAlignment = 'center';

            % 设置期望速度
            uilabel(app.InitPanel, 'Text', '最大速度:', 'Position', [20 175 60 22]);
            app.udEditField = uieditfield(app.InitPanel, 'numeric');
            app.udEditField.Position = [75 175 40 22];
            app.udEditField.Value = 3.0;
            app.udEditField.HorizontalAlignment = 'center';


            % 设置掉深时间
            uilabel(app.InitPanel, 'Text', '掉深时间:', 'Position', [130 175 60 22]);
            app.TdEditField = uieditfield(app.InitPanel, 'numeric');
            app.TdEditField.Position = [185 175 40 22];
            app.TdEditField.Value = inf;
            app.TdEditField.HorizontalAlignment = 'center';

            % 设置急停时间
            uilabel(app.InitPanel, 'Text', '急停时间:', 'Position', [240 175 60 22]);
            app.TjEditField = uieditfield(app.InitPanel, 'numeric');
            app.TjEditField.Position = [295 175 40 22];
            app.TjEditField.Value = inf;
            app.TjEditField.HorizontalAlignment = 'center';

            % 规划路径起始点坐标
            uilabel(app.InitPanel, 'Text', '规划路径起点:', 'Position', [20 130 120 22]);

            % X 坐标
            app.XEditFieldLabel = uilabel(app.InitPanel);
            app.XEditFieldLabel.Position = [130 130 25 22];
            app.XEditFieldLabel.Text = 'X:';
            app.XEditFieldLabel.HorizontalAlignment = 'center';
            app.XEditField = uieditfield(app.InitPanel, 'numeric');
            app.XEditField.Position = [155 130 50 22];
            app.XEditField.Value = 160;
            app.XEditField.HorizontalAlignment = 'center';

            % Y 坐标
            app.YEditFieldLabel = uilabel(app.InitPanel);
            app.YEditFieldLabel.Position = [220 130 25 22];
            app.YEditFieldLabel.Text = 'Y:';
            app.YEditFieldLabel.HorizontalAlignment = 'center';
            app.YEditField = uieditfield(app.InitPanel, 'numeric');
            app.YEditField.Position = [245 130 50 22];
            app.YEditField.Value = 90;
            app.YEditField.HorizontalAlignment = 'center';

            % AUV 初始位置
            uilabel(app.InitPanel, 'Text', 'AUV 初始位置:', 'Position', [20 100 100 22]);

            % X 坐标
            app.P0XLabel = uilabel(app.InitPanel);
            app.P0XLabel.Position = [25 70 35 22];
            app.P0XLabel.Text = 'X:';
            app.P0XLabel.HorizontalAlignment = 'center';
            app.P0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0XEditField.Position = [65 70 50 22];
            app.P0XEditField.Value = 100;
            app.P0XEditField.HorizontalAlignment = 'center';

            % Y 坐标
            app.P0YLabel = uilabel(app.InitPanel);
            app.P0YLabel.Position = [125 70 35 22];
            app.P0YLabel.Text = 'Y:';
            app.P0YLabel.HorizontalAlignment = 'center';
            app.P0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0YEditField.Position = [165 70 50 22];
            app.P0YEditField.Value = 0;
            app.P0YEditField.HorizontalAlignment = 'center';

            % Z 坐标
            app.P0ZLabel = uilabel(app.InitPanel);
            app.P0ZLabel.Position = [225 70 35 22];
            app.P0ZLabel.Text = 'Z:';
            app.P0ZLabel.HorizontalAlignment = 'center';
            app.P0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0ZEditField.Position = [265 70 50 22];
            app.P0ZEditField.Value = 20;
            app.P0ZEditField.HorizontalAlignment = 'center';

            % AUV 初始姿态角
            uilabel(app.InitPanel, 'Text', 'AUV 初始姿态角(角度制):', 'Position', [20 40 150 22]);

            % Roll
            app.A0XLabel = uilabel(app.InitPanel);
            app.A0XLabel.Position = [25 10 35 22];
            app.A0XLabel.Text = 'Roll:';
            app.A0XLabel.HorizontalAlignment = 'center';
            app.A0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0XEditField.Position = [65 10 50 22];
            app.A0XEditField.Value = 0;
            app.A0XEditField.HorizontalAlignment = 'center';

            % Pitch
            app.A0YLabel = uilabel(app.InitPanel);
            app.A0YLabel.Position = [125 10 35 22];
            app.A0YLabel.Text = 'Pitch:';
            app.A0YLabel.HorizontalAlignment = 'center';
            app.A0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0YEditField.Position = [165 10 50 22];
            app.A0YEditField.Value = 0;
            app.A0YEditField.HorizontalAlignment = 'center';

            % Yaw
            app.A0ZLabel = uilabel(app.InitPanel);
            app.A0ZLabel.Position = [225 10 35 22];
            app.A0ZLabel.Text = 'Yaw:';
            app.A0ZLabel.HorizontalAlignment = 'center';
            app.A0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0ZEditField.Position = [265 10 50 22];
            app.A0ZEditField.Value = 0;
            app.A0ZEditField.HorizontalAlignment = 'center';

            %% 2. 路径参数面板
            app.PathParametersPanel = uipanel(app.UIFigure);
            app.PathParametersPanel.Title = ' 路径参数';
            app.PathParametersPanel.Position = [30 310 370 140];

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

            % 梳状路径Z坐标
            app.ZEditFieldLabel = uilabel(app.PathParametersPanel);
            app.ZEditFieldLabel.Position = [10 35 80 22];
            app.ZEditFieldLabel.Text = 'AUV深度:';
            
            app.ZEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.ZEditField.Position = [70 35 40 22];
            app.ZEditField.Value = 20;
            app.ZEditField.HorizontalAlignment = 'center';

            % 梳状路径下潜路径点
            app.downEditFieldLabel = uilabel(app.PathParametersPanel);
            app.downEditFieldLabel.Position = [120 35 80 22];
            app.downEditFieldLabel.Text = '下潜点索引:';
            
            app.downEditField = uieditfield(app.PathParametersPanel);
            app.downEditField.Position = [190 35 50 22];
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
            app.upEditFieldLabel.Position = [120 5 80 22];
            app.upEditFieldLabel.Text = '上浮点索引:';
            
            app.upEditField = uieditfield(app.PathParametersPanel);
            app.upEditField.Position = [190 5 50 22];
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
            
            %% 3. TCP设置面板
            app.TCPPanel = uipanel(app.UIFigure);
            app.TCPPanel.Title = ' TCP设置';
            app.TCPPanel.Position = [30 210 370 90];
            
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

            %% 4. Dubins 面板
            app.dubinsPanel = uipanel(app.UIFigure);
            app.dubinsPanel.Title = ' Dubins 路径规划设置(周期:圆弧-直线-圆弧)';
            app.dubinsPanel.Position = [30 110 370 90];
            
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

            %% 5. 按钮组
            
            % 创建梳状路径生成按钮 - 根据区域边界自动计算梳状覆盖路径
            app.exportDubinsWaypointsButton = uibutton(app.UIFigure, 'push');
            app.exportDubinsWaypointsButton.ButtonPushedFcn = @(~,~) generatePath(app);
            app.exportDubinsWaypointsButton.Position = [440 780 320 30];
            app.exportDubinsWaypointsButton.Text = '生成全局梳状路径';
            
            % 创建梳状路径点导出按钮 - 将生成的梳状路径点以CSV格式保存到本地
            app.ExportButton = uibutton(app.UIFigure, 'push');
            app.ExportButton.ButtonPushedFcn = @(~,~) exportWaypoints(app);
            app.ExportButton.Position = [440 740 320 30];
            app.ExportButton.Text = '导出全局梳状路径数据(csv)';
            app.ExportButton.Enable = 'off';

            % 创建梳状路径点发送按钮 - 通过TCP协议将梳状路径点数据发送至AUV
            app.SendTCPButton = uibutton(app.UIFigure, 'push');
            app.SendTCPButton.ButtonPushedFcn = @(~,~) sendTCPData(app);
            app.SendTCPButton.Position = [440 700 320 30];
            app.SendTCPButton.Text = '发送全局梳状路径数据至 AUV ';
            app.SendTCPButton.Enable = 'off';

            % 创建地图数据导入按钮 - 从MAT文件中加载预设的地图数据
            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.ButtonPushedFcn = @(~,~) importMapData(app);
            app.ImportButton.Position = [440 660 320 30];
            app.ImportButton.Text = '导入地图数据';
            
            % 创建地形图及障碍物标注按钮 - 显示地形并允许用户标注障碍物
            app.obstacleMarkingButton = uibutton(app.UIFigure, 'push');
            app.obstacleMarkingButton.ButtonPushedFcn = @(~,~)obstacleMarking(app);
            app.obstacleMarkingButton.Position = [440 620 320 30];
            app.obstacleMarkingButton.Text = '地形图及障碍物标注';
            app.obstacleMarkingButton.Enable = 'off';

            % 创建Dubins路径规划按钮
            app.PlanPathsButton = uibutton(app.UIFigure, 'push');
            app.PlanPathsButton.ButtonPushedFcn = @(~,~) planUAVPaths(app, app.NumLinesEditField.Value,app.dubinsnsEditField.Value,app.dubinsnlEditField.Value,app.dubinsnfEditField.Value);
            app.PlanPathsButton.Position =[440 580 320 30];
            app.PlanPathsButton.Text = '生成局部 Dubins 路径规划';
            app.PlanPathsButton.Enable = 'off';
            
            % 创建Dubins路径点导出按钮 - 将计算的路径点以CSV格式保存到本地文件
            app.GenerateButton = uibutton(app.UIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = @(~,~) exportDubinsWaypoints(app);
            app.GenerateButton.Position = [440 540 320 30];
            app.GenerateButton.Text = '导出 Dubins 路径规划数据(csv)';
            app.GenerateButton.Enable = 'off';
            
            % 创建Dubins路径点发送按钮 - 通过TCP协议将路径点数据发送至AUV
            app.SendLocalTCPButton = uibutton(app.UIFigure, 'push');
            app.SendLocalTCPButton.ButtonPushedFcn = @(~,~) sendDubinsTCPData(app);
            app.SendLocalTCPButton.Position = [440 500 320 30];
            app.SendLocalTCPButton.Text = '发送 Dubins 路径规划数据至 AUV ';
            app.SendLocalTCPButton.Enable = 'off';

            % % 创建仿真图绘制按钮 - 可视化显示当前路径规划及环境的仿真效果
            % app.X1plotTCPButton = uibutton(app.UIFigure, 'push');
            % app.X1plotTCPButton.ButtonPushedFcn = @(~,~) X1plotTCP(app);
            % app.X1plotTCPButton.Position = [440 460 320 30];
            % app.X1plotTCPButton.Text = '绘制 AUV 运行仿真图';
            % app.X1plotTCPButton.Enable = 'off';

            %% 6. 状态标签
            % 总路径长度及TCP状态版本展示
            app.TotalLengthLabelandTCP = uilabel(app.UIFigure);
            app.TotalLengthLabelandTCP.Position = [30 70 320 40];
            app.TotalLengthLabelandTCP.Text = '总路径长度: 0.0 米';
            app.TotalLengthLabelandTCP.HorizontalAlignment = 'center';
            
            % 总体状态标签
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [30 30 320 30];
            app.StatusLabel.Text = '还未生成规划路径数据！';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontColor = [0.8 0 0];
            
            %% 7. 绘图区域
            
            % 创建AUV全局路径规划显示区域 - 用于展示覆盖路径规划的整体效果
            % 位于界面右上方，显示AUV在整个区域的梳状覆盖路径
            app.UIAxes1 = uiaxes(app.UIFigure);
            app.UIAxes1.Position = [880 490 390 390];
            title(app.UIAxes1, ' 全局梳状路径规划效果图');
            xlabel(app.UIAxes1, 'X轴 (米)');
            ylabel(app.UIAxes1, 'Y轴 (米)');
            grid(app.UIAxes1, 'on');

            % 创建Dubins局部路径规划显示区域 - 用于展示基于Dubins曲线的局部路径规划结果
            % 位于界面右下方，显示AUV在障碍物环境中的局部路径规划轨迹
            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.Position = [880 70 390 390];
            title(app.UIAxes2, '局部 Dubins 路径规划效果图');
            xlabel(app.UIAxes2, 'X轴 (米)');
            ylabel(app.UIAxes2, 'Y轴 (米)');
            grid(app.UIAxes2, 'on');

            % 创建地形与障碍物显示区域 - 用于显示环境地形和用户标注的障碍物
            % 位于界面中下方，允许用户交互式地标注和查看地形障碍物信息
            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.Position = [450 70 390 390];
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
                fullfile(currentDir, 'utils'),            ... 工具函数主目录
                fullfile(currentDir, 'utils', 'dubins'),  ... Dubins路径规划
                fullfile(currentDir, 'utils', 'main'),    ... 主要功能函数
                fullfile(currentDir, 'utils', 'plot'),    ... 绘图相关函数
                fullfile(currentDir, 'utils', 'trajectory'), ... 轨迹生成函数
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
                    fprintf('✓ %s 已安装\n', requiredToolboxes{i});
                else
                    warning('⨯ %s 未安装\n', requiredToolboxes{i});
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