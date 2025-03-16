%% CoveragePathPlannerApp - AUV 海底探测梳状全覆盖路径拐点生成工具
%
% 功能描述：
%   1. 生成 AUV 海底探测梳状全覆盖路径拐点
%   2. 基于 Dubins 曲线的避障路径规划
%   3. 支持导入海底地形数据并进行障碍物标注
%   4. 提供路径数据导出功能（CSV格式）
%   5. 支持 TCP 数据传输
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%   作者：dongxingan（董星犴）
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.2
%   创建日期：20241001
%   最后修改：20250110
%
% 版本历史：
%   v1.0 (20241001) - 初始版本，实现基本的路径拐点生成功能
%   v1.1 (20241101) - 新增 TCP 设置和数据发送功能
%   v1.2 (20250110) - 新增 Dubins 路径规划避障算法功能
%
% 输入参数：
%   无直接输入参数，通过 GUI 界面设置相关参数
%
% 输出参数：
%   无直接返回值，通过以下方式输出：
%   1. CSV文件：保存路径点数据
%   2. TCP数据：发送至AUV设备
%   3. 图形显示：实时路径可视化
%
% 注意事项：
%   1. 在使用 Dubins 路径规划避障算法前，请确保相关参数设置正确
%   2. TCP 发送功能需要确保服务器 IP 和端口设置正确
%   3. 导出路径点文件时，请选择合适的保存路径和文件格式
%
% 依赖工具箱：
%   - MATLAB 自带的 GUI 组件
%   - MATLAB 绘图工具箱
%
% 参见函数：
%   planAUVPaths, obstacleMarking, exportDubinsWaypoints, sendDubinsTCPData, 
%   importMapData, generatePath, exportWaypoints, sendTCPData


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
        
        GenerateButton          matlab.ui.control.Button
        SendTCPButton          matlab.ui.control.Button % 新增TCP发送按钮
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
        obstacleMarkingButton     matlab.ui.control.Button
        exportDubinsWaypointsButton        matlab.ui.control.Button
        SendLocalTCPButton       matlab.ui.control.Button
        ImportButton       matlab.ui.control.Button
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        currentProjectRoot string    
    end

    methods (Access = private)
        function createComponents(app)
            % 主窗口设置
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1300 900];
            app.UIFigure.Name = 'AUV全覆盖梳状路径拐点生成器 v1.2(单位:m)';
 
            %% 1. 坐标初始化面板
            app.InitPanel = uipanel(app.UIFigure);
            app.InitPanel.Title = '相关坐标初始化';
            app.InitPanel.Position = [30 560 320 240];
            
            % 起始点坐标
            uilabel(app.InitPanel, 'Text', '规划路径起始点坐标:', 'Position', [10 190 120 22]);
            
            app.XEditFieldLabel = uilabel(app.InitPanel);
            app.XEditFieldLabel.Position = [10 160 25 22];
            app.XEditFieldLabel.Text = ' X:';
            app.XEditFieldLabel.HorizontalAlignment = 'center';
            
            app.XEditField = uieditfield(app.InitPanel, 'numeric');
            app.XEditField.Position = [50 160 80 22];
            app.XEditField.Value = 160;
            app.XEditField.HorizontalAlignment = 'center';
            
            app.YEditFieldLabel = uilabel(app.InitPanel);
            app.YEditFieldLabel.Position = [150 160 25 22];
            app.YEditFieldLabel.Text = ' Y:';
            app.YEditFieldLabel.HorizontalAlignment = 'center';
            
            app.YEditField = uieditfield(app.InitPanel, 'numeric');
            app.YEditField.Position = [190 160 80 22];
            app.YEditField.Value = 90;
            app.YEditField.HorizontalAlignment = 'center';
            
            % 初始位置
            uilabel(app.InitPanel, 'Text', 'AUV初始位置:', 'Position', [10 115 100 22]);
            
            app.P0XLabel = uilabel(app.InitPanel);
            app.P0XLabel.Position = [10 85 35 22];
            app.P0XLabel.Text = ' X:';
            app.P0XLabel.HorizontalAlignment = 'center';
            
            app.P0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0XEditField.Position = [50 85 50 22];
            app.P0XEditField.Value = 0;
            app.P0XEditField.HorizontalAlignment = 'center';
            
            app.P0YLabel = uilabel(app.InitPanel);
            app.P0YLabel.Position = [110 85 35 22];
            app.P0YLabel.Text = ' Y:';
            app.P0YLabel.HorizontalAlignment = 'center';
            
            app.P0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0YEditField.Position = [150 85 50 22];
            app.P0YEditField.Value = 0;
            app.P0YEditField.HorizontalAlignment = 'center';
            
            app.P0ZLabel = uilabel(app.InitPanel);
            app.P0ZLabel.Position = [210 85 35 22];
            app.P0ZLabel.Text = ' Z:';
            app.P0ZLabel.HorizontalAlignment = 'center';
            
            app.P0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0ZEditField.Position = [250 85 50 22];
            app.P0ZEditField.Value = 0;
            app.P0ZEditField.HorizontalAlignment = 'center';
            
            % 初始姿态角
            uilabel(app.InitPanel, 'Text', 'AUV初始姿态角:', 'Position', [10 40 100 22]);
            
            app.A0XLabel = uilabel(app.InitPanel);
            app.A0XLabel.Position = [10 10 35 22];
            app.A0XLabel.Text = ' Roll:';
            app.A0XLabel.HorizontalAlignment = 'center';
            
            app.A0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0XEditField.Position = [50 10 50 22];
            app.A0XEditField.Value = 0;
            app.A0XEditField.HorizontalAlignment = 'center';
            
            app.A0YLabel = uilabel(app.InitPanel);
            app.A0YLabel.Position = [110 10 35 22];
            app.A0YLabel.Text = ' Pitch:';
            app.A0YLabel.HorizontalAlignment = 'center';
            
            app.A0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0YEditField.Position = [150 10 50 22];
            app.A0YEditField.Value = 0;
            app.A0YEditField.HorizontalAlignment = 'center';
            
            app.A0ZLabel = uilabel(app.InitPanel);
            app.A0ZLabel.Position = [210 10 35 22];
            app.A0ZLabel.Text = ' Yaw:';
            app.A0ZLabel.HorizontalAlignment = 'center';
            
            app.A0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.A0ZEditField.Position = [250 10 50 22];
            app.A0ZEditField.Value = 0;
            app.A0ZEditField.HorizontalAlignment = 'center';
            
            %% 2. 路径参数面板
            app.PathParametersPanel = uipanel(app.UIFigure);
            app.PathParametersPanel.Title = '路径参数';
            app.PathParametersPanel.Position = [30 410 320 140];
            
            % 方向选择
            app.DirectionDropDownLabel = uilabel(app.PathParametersPanel);
            app.DirectionDropDownLabel.Position = [35 95 80 22];
            app.DirectionDropDownLabel.Text = '路径方向:';
            
            app.DirectionDropDown = uidropdown(app.PathParametersPanel);
            app.DirectionDropDown.Items = {'  X  ', '  Y  '};  % 通过添加空格实现视觉居中
            app.DirectionDropDown.Position = [115 95 75 22];
            app.DirectionDropDown.Value = '  Y  ';  % 需要匹配Items中的完整字符串
            
            % 梳状齿间距
            app.LineSpacingEditFieldLabel = uilabel(app.PathParametersPanel);
            app.LineSpacingEditFieldLabel.Position = [35 65 80 22];
            app.LineSpacingEditFieldLabel.Text = '梳状齿间距:';
            
            app.LineSpacingEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.LineSpacingEditField.Position = [115 65 150 22];
            app.LineSpacingEditField.Value = 200;
            app.LineSpacingEditField.HorizontalAlignment = 'center';
            
            % 路径宽度
            app.PathWidthEditFieldLabel = uilabel(app.PathParametersPanel);
            app.PathWidthEditFieldLabel.Position = [35 35 80 22];
            app.PathWidthEditFieldLabel.Text = '路径总宽:';
            
            app.PathWidthEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.PathWidthEditField.Position = [115 35 150 22];
            app.PathWidthEditField.Value = 1730;
            app.PathWidthEditField.HorizontalAlignment = 'center';
            
            % 梳状路径数量
            app.NumLinesEditFieldLabel = uilabel(app.PathParametersPanel);
            app.NumLinesEditFieldLabel.Position = [35 5 80 22];
            app.NumLinesEditFieldLabel.Text = '路径条数:';
            
            app.NumLinesEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.NumLinesEditField.Position = [115 5 150 22];
            app.NumLinesEditField.Value = 10;
            app.NumLinesEditField.HorizontalAlignment = 'center';
            
            %% 3. TCP设置面板
            app.TCPPanel = uipanel(app.UIFigure);
            app.TCPPanel.Title = 'TCP设置';
            app.TCPPanel.Position = [30 310 320 90];
            
            app.ServerIPLabel = uilabel(app.TCPPanel);
            app.ServerIPLabel.Position = [35 40 60 22];
            app.ServerIPLabel.Text = '服务器IP:';
            
            app.ServerIPEditField = uieditfield(app.TCPPanel);
            app.ServerIPEditField.Position = [95 40 170 22];
            app.ServerIPEditField.Value = '192.168.1.108';
            app.ServerIPEditField.HorizontalAlignment = 'center';
            
            app.PortLabel = uilabel(app.TCPPanel);
            app.PortLabel.Position = [35 10 60 22];
            app.PortLabel.Text = '端口:';
            
            app.PortEditField = uieditfield(app.TCPPanel, 'numeric');
            app.PortEditField.Position = [95 10 170 22];
            app.PortEditField.Value = 5000;
            app.PortEditField.HorizontalAlignment = 'center';

            %% 4. Dubins 设置面板
            app.dubinsPanel = uipanel(app.UIFigure);
            app.dubinsPanel.Title = ' Dubins 路径规划设置(周期:圆弧-直线-圆弧)';
            app.dubinsPanel.Position = [30 150 320 150];
            
            app.dubinsnsLabel = uilabel(app.dubinsPanel);
            app.dubinsnsLabel.Position = [35 100 120 22];
            app.dubinsnsLabel.Text = '前段路径点个数(圆弧):';
            
            app.dubinsnsEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnsEditField.Position = [165 100 110 22];
            app.dubinsnsEditField.Value = 1;
            app.dubinsnsEditField.HorizontalAlignment = 'center';
            
            app.dubinsnlLabel = uilabel(app.dubinsPanel);
            app.dubinsnlLabel.Position = [35 70 120 22];
            app.dubinsnlLabel.Text = '中段路径点个数(直线):';
            
            app.dubinsnlEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnlEditField.Position = [165 70 110 22];
            app.dubinsnlEditField.Value = 50;
            app.dubinsnlEditField.HorizontalAlignment = 'center';
            
            app.dubinsnfLabel = uilabel(app.dubinsPanel);
            app.dubinsnfLabel.Position = [35 40 120 22];
            app.dubinsnfLabel.Text = '后段路径点个数(圆弧):';
            
            app.dubinsnfEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnfEditField.Position = [165 40 110 22];            app.dubinsnfEditField.Value = 1;
            app.dubinsnfEditField.HorizontalAlignment = 'center';
            
            app.dubinsradiusLabel = uilabel(app.dubinsPanel);
            app.dubinsradiusLabel.Position = [35 10 120 22];
            app.dubinsradiusLabel.Text = 'Dubins 转弯半径:';
            
            app.dubinsradiusEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsradiusEditField.Position = [165 10 110 22];
            app.dubinsradiusEditField.Value = 0;
            app.dubinsradiusEditField.HorizontalAlignment = 'center';
            
            %% 5. 按钮组和状态标签
            app.exportDubinsWaypointsButton = uibutton(app.UIFigure, 'push');
            app.exportDubinsWaypointsButton.ButtonPushedFcn = @(~,~) generatePath(app);
            app.exportDubinsWaypointsButton.Position = [400 770 320 30];
            app.exportDubinsWaypointsButton.Text = '生成全局梳状路径';
            
            app.ExportButton = uibutton(app.UIFigure, 'push');
            app.ExportButton.ButtonPushedFcn = @(~,~) exportWaypoints(app);
            app.ExportButton.Position = [400 730 320 30];
            app.ExportButton.Text = '导出全局梳状路径数据(csv)';
            app.ExportButton.Enable = 'off';
            
            app.SendTCPButton = uibutton(app.UIFigure, 'push');
            app.SendTCPButton.ButtonPushedFcn = @(~,~) sendTCPData(app);
            app.SendTCPButton.Position = [400 690 320 30];
            app.SendTCPButton.Text = '发送全局梳状路径数据至 AUV ';
            app.SendTCPButton.Enable = 'off';

            % 导入.mat的地图数据按钮
            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.ButtonPushedFcn = @(~,~) importMapData(app);
            app.ImportButton.Position = [400 650 320 30];
            app.ImportButton.Text = '导入地图数据';

            % 地形图及障碍物标注按钮
            app.obstacleMarkingButton = uibutton(app.UIFigure, 'push');
            app.obstacleMarkingButton.ButtonPushedFcn = @(~,~) obstacleMarking(app);
            app.obstacleMarkingButton.Position = [400 610 320 30];
            app.obstacleMarkingButton.Text = '地形图及障碍物标注';
            app.obstacleMarkingButton.Enable = 'off';
            
            % Dubins 路径规划按钮
            app.PlanPathsButton = uibutton(app.UIFigure, 'push');
            app.PlanPathsButton.ButtonPushedFcn = @(~,~) planAUVPaths(app, app.NumLinesEditField.Value,app.dubinsnsEditField.Value,app.dubinsnlEditField.Value,app.dubinsnfEditField.Value);
            app.PlanPathsButton.Position = [400 570 320 30];
            app.PlanPathsButton.Text = '生成局部 Dubins 路径规划';
            app.PlanPathsButton.Enable = 'off';

            % 导出 Dubins 路径点按钮来
            app.GenerateButton = uibutton(app.UIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = @(~,~) exportDubinsWaypoints(app);
            app.GenerateButton.Position = [400 530 320 30];
            app.GenerateButton.Text = '导出 Dubins 路径规划数据(csv)';
            app.GenerateButton.Enable = 'off';
            
            % 发送 Dubins 路径数据至AUV按钮
            app.SendLocalTCPButton = uibutton(app.UIFigure, 'push');
            app.SendLocalTCPButton.ButtonPushedFcn = @(~,~) sendDubinsTCPData(app);
            app.SendLocalTCPButton.Position = [400 490 320 30];
            app.SendLocalTCPButton.Text = '发送 Dubins 路径规划数据至 AUV ';
            app.SendLocalTCPButton.Enable = 'off';
            
            %% 6. 状态标签
            % 总路径长度及TCP状态版本展示
            app.TotalLengthLabelandTCP = uilabel(app.UIFigure);
            app.TotalLengthLabelandTCP.Position = [30 100 320 30];
            app.TotalLengthLabelandTCP.Text = '总路径长度: 0.0 米';
            app.TotalLengthLabelandTCP.HorizontalAlignment = 'center';
            
            % 总体状态标签
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [30 60 320 20];
            app.StatusLabel.Text = '还未生成规划路径数据！';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontColor = [0.8 0 0];
            
            %% 7. 绘图区域

            app.UIAxes1 = uiaxes(app.UIFigure);
            app.UIAxes1.Position = [800 490 390 390];
            title(app.UIAxes1, 'AUV全局路径规划效果图');
            xlabel(app.UIAxes1, 'X轴 (米)');
            ylabel(app.UIAxes1, 'Y轴 (米)');
            grid(app.UIAxes1, 'on');

            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.Position = [800 90 390 390];
            title(app.UIAxes2, 'Dubins 路径规划效果图');
            xlabel(app.UIAxes2, 'X轴 (米)');
            ylabel(app.UIAxes2, 'Y轴 (米)');
            grid(app.UIAxes2, 'on');

            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.Position = [400 90 390 390];
            title(app.UIAxes3, '地形图及障碍物标注');
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
            % 检查必要的工具箱是否安装
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
        % 添加启动和关闭时的清理代码
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
        function app = CoveragePathPlannerApp
            
            % 设置路径
            [projectRoot,~]=setupAppPaths(app);

            % 获取当前文件夹路径
            app.currentProjectRoot = projectRoot;
            
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