%% CoveragePathPlannerApp - AUV ����̽����״ȫ����·���յ����ɹ���
%
% ����������
%   ���� AUV ����̽����״ȫ����·���յ㣬��֧�ֵ���Ϊ.csv/.mat��ʽ�ļ���
%   ͬʱ�������� dubins ·���滮�����㷨������ã��Լ� TCP ���ú����ݷ��͹��ܡ�
%   ������ AUV �����Է������ܣ�֧�ַ��� AUV �ڲ�ͬ���������µ��˶���Ϊ��
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ���ߣ�dongxingan��������
%   ���䣺1443123118@qq.com
%   ���ߣ��հ·�
%   ���䣺taoaofei@gmail.com
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.5
%   �������ڣ�250110
%   ����޸ģ�250328
%
% �汾��ʷ��
%   v1.0 (241001) - ��ʼ�汾��ʵ�ֻ�����·���յ����ɹ���
%   v1.1 (241101) - TCP ���ú����ݷ��͹���
%   v1.2 (250110) - ���� Dubins ·���滮�����㷨���ã���Ӧ��TCP ���ú����ݷ��͹���
%   v1.3 (250317) - ���� AUV ����·���滮·��������
%   v1.4 (250326) - �ع�����UI,���ݴ���ع�����������չʾ
%   v1.5 (250328) - ���� AUV �����Է�������
%
%   ��ֱ�����������ͨ�� GUI ����������ز���
%
% ���������
%   ��ֱ�ӷ���ֵ�����ɵ�·���յ����ݿɵ���Ϊ.csv/.mat��ʽ�ļ�
%
% ע�����
%   1. ��ʹ�� Dubins ·���滮�����㷨ǰ����ȷ����ز���������ȷ��
%   2. TCP ���͹�����Ҫȷ�������� IP �Ͷ˿�������ȷ���� AUV �豸�����ӡ�
%   3. ����·�����ļ�ʱ����ѡ����ʵı���·�����ļ���ʽ��
%
% ����ʾ����
%   ��ֱ�ӵ���ʾ����ͨ������ GUI ������в���
%
% ���������䣺
%   - MATLAB �Դ��� GUI ����ͻ�ͼ������
%
% �μ�������
%   planUAVPaths, drawPaths, obstacleMarking, exportDubinsWaypoints, sendDubinsTCPData, importMapData, generatePath, exportWaypoints, sendTCPData



classdef CoveragePathPlannerApp < matlab.apps.AppBase

    properties (Access = public)
        %% ���������
        UIFigure                 matlab.ui.Figure        % ��Ӧ�ô���
        
        %% ����������
        InitPanel                matlab.ui.container.Panel  % AUV������ʼ�����
        PathParametersPanel      matlab.ui.container.Panel  % ·���������
        FaultTolerantPanel       matlab.ui.container.Panel  % �ݴ�����������
        TCPPanel                 matlab.ui.container.Panel  % TCP�������
        dubinsPanel              matlab.ui.container.Panel  % Dubins·���滮�������
        OperabilityPanel         matlab.ui.container.Panel  % UUV�������������       

        %% AUV��ʼ�������
        % �ٶȺ�ʱ������
        udEditField              matlab.ui.control.NumericEditField  % ����ٶ�����
        udLabel                  matlab.ui.control.Label             % ����ٶȱ�ǩ
        TjEditField              matlab.ui.control.NumericEditField  % ��ͣʱ������
        TjLabel                  matlab.ui.control.Label             % ��ͣʱ���ǩ
        
        % �滮·�����
        XEditField               matlab.ui.control.NumericEditField  % X���������
        XEditFieldLabel          matlab.ui.control.Label             % X�����ǩ
        YEditField               matlab.ui.control.NumericEditField  % Y���������
        YEditFieldLabel          matlab.ui.control.Label             % Y�����ǩ
        ZEditField               matlab.ui.control.NumericEditField  % Z���������
        ZEditFieldLabel          matlab.ui.control.Label             % Z�����ǩ
        
        % AUV��ʼλ������
        P0XEditField             matlab.ui.control.NumericEditField  % ��ʼX����
        P0XLabel                 matlab.ui.control.Label             % ��ʼX�����ǩ
        P0YEditField             matlab.ui.control.NumericEditField  % ��ʼY����
        P0YLabel                 matlab.ui.control.Label             % ��ʼY�����ǩ
        P0ZEditField             matlab.ui.control.NumericEditField  % ��ʼZ����
        P0ZLabel                 matlab.ui.control.Label             % ��ʼZ�����ǩ
        
        % AUV��ʼ��̬������
        A0XEditField             matlab.ui.control.NumericEditField  % Roll��
        A0XLabel                 matlab.ui.control.Label             % Roll�Ǳ�ǩ
        A0YEditField             matlab.ui.control.NumericEditField  % Pitch��
        A0YLabel                 matlab.ui.control.Label             % Pitch�Ǳ�ǩ
        A0ZEditField             matlab.ui.control.NumericEditField  % Yaw��
        A0ZLabel                 matlab.ui.control.Label             % Yaw�Ǳ�ǩ
        
        %% ��״·�������������
        % ·����������
        DirectionDropDown        matlab.ui.control.DropDown          % ·������������
        DirectionDropDownLabel   matlab.ui.control.Label             % ·�������ǩ
        
        % ·����������
        LineSpacingEditField     matlab.ui.control.NumericEditField  % ��״�ݼ�������
        LineSpacingEditFieldLabel matlab.ui.control.Label            % ��״�ݼ���ǩ
        PathWidthEditField       matlab.ui.control.NumericEditField  % ·���ܿ������
        PathWidthEditFieldLabel  matlab.ui.control.Label             % ·���ܿ��ǩ
        NumLinesEditField        matlab.ui.control.NumericEditField  % ·�����������
        NumLinesEditFieldLabel   matlab.ui.control.Label             % ·��������ǩ
        
        % ê�������¸�����
        anchorEditField          matlab.ui.control.EditField         % ê������������
        anchorEditFieldLabel     matlab.ui.control.Label             % ê����������ǩ
        TanchorEditField         matlab.ui.control.NumericEditField  % ê��ʱ������
        TanchorEditFieldLabel    matlab.ui.control.Label             % ê��ʱ����ǩ
        downEditField            matlab.ui.control.EditField         % ��Ǳ����������
        downEditFieldLabel       matlab.ui.control.Label             % ��Ǳ��������ǩ
        DdownEditField           matlab.ui.control.NumericEditField  % ��Ǳ�������
        DdownEditFieldLabel      matlab.ui.control.Label             % ��Ǳ��ȱ�ǩ
        upEditField              matlab.ui.control.EditField         % �ϸ�����������
        upEditFieldLabel         matlab.ui.control.Label             % �ϸ���������ǩ
        DupEditField             matlab.ui.control.NumericEditField  % �ϸ��������
        DupEditFieldLabel        matlab.ui.control.Label             % �ϸ���ȱ�ǩ

        %% �ݴ�����������
        % ����ʱ������

        TdEditField              matlab.ui.control.NumericEditField  % ����ʱ������
        TdLabel                  matlab.ui.control.Label             % ����ʱ���ǩ
        
        % ����ʱ������
        Kdelta1EditField         matlab.ui.control.NumericEditField  % ��1����ʱ��
        Kdelta1Label             matlab.ui.control.Label             % ��1����ʱ���ǩ
        Kdelta2EditField         matlab.ui.control.NumericEditField  % ��2����ʱ��
        Kdelta2Label             matlab.ui.control.Label             % ��2����ʱ���ǩ
        Kdelta3EditField         matlab.ui.control.NumericEditField  % ��3����ʱ��
        Kdelta3Label             matlab.ui.control.Label             % ��3����ʱ���ǩ
        Kdelta4EditField         matlab.ui.control.NumericEditField  % ��4����ʱ��
        Kdelta4Label             matlab.ui.control.Label             % ��4����ʱ���ǩ
        
        % ����Ƕ�����
        Delta1EditField          matlab.ui.control.NumericEditField  % ��1����Ƕ�
        Delta1Label              matlab.ui.control.Label             % ��1����Ƕȱ�ǩ
        Delta2EditField          matlab.ui.control.NumericEditField  % ��2����Ƕ�
        Delta2Label              matlab.ui.control.Label             % ��2����Ƕȱ�ǩ
        Delta3EditField          matlab.ui.control.NumericEditField  % ��3����Ƕ�
        Delta3Label              matlab.ui.control.Label             % ��3����Ƕȱ�ǩ
        Delta4EditField          matlab.ui.control.NumericEditField  % ��4����Ƕ�
        Delta4Label              matlab.ui.control.Label             % ��4����Ƕȱ�ǩ

        %% TCPͨ���������
        ServerIPEditField        matlab.ui.control.EditField         % ������IP��ַ
        ServerIPLabel            matlab.ui.control.Label             % ������IP��ǩ
        PortEditField            matlab.ui.control.NumericEditField  % �������˿�
        PortLabel                matlab.ui.control.Label             % �������˿ڱ�ǩ
        hostIPEditField          matlab.ui.control.EditField         % ����IP��ַ
        hostIPLabel              matlab.ui.control.Label             % ����IP��ǩ
        hPortEditField           matlab.ui.control.NumericEditField  % �����˿�
        hPortLabel               matlab.ui.control.Label             % �����˿ڱ�ǩ
        
        %% Dubins·���滮�������
        dubinsnsLabel            matlab.ui.control.Label             % ǰ��·���������ǩ
        dubinsnsEditField        matlab.ui.control.NumericEditField  % ǰ��·������������
        dubinsnlLabel            matlab.ui.control.Label             % �ж�·���������ǩ
        dubinsnlEditField        matlab.ui.control.NumericEditField  % �ж�·������������
        dubinsnfLabel            matlab.ui.control.Label             % ���·���������ǩ
        dubinsnfEditField        matlab.ui.control.NumericEditField  % ���·������������
        dubinsradiusLabel        matlab.ui.control.Label             % Dubinsת��뾶��ǩ
        dubinsradiusEditField    matlab.ui.control.NumericEditField  % Dubinsת��뾶�����

        %% UUV�������������
        DesiredSpeedEditField    matlab.ui.control.NumericEditField  % �����ٶ�
        SimulationTimeEditField  matlab.ui.control.NumericEditField  % ����ʱ��
        Rudder1EditField         matlab.ui.control.NumericEditField  % ���1
        Rudder2EditField         matlab.ui.control.NumericEditField  % ���2
        Rudder3EditField         matlab.ui.control.NumericEditField  % ���3
        Rudder4EditField         matlab.ui.control.NumericEditField  % ���4
        StartOperabilitySimulationButton matlab.ui.control.Button    % ��ʼ�����Է��水ť

        %% ������ť���
        GenerateButton           matlab.ui.control.Button            % ����ȫ����״·����ť
        ExportGlobalWaypointsButton matlab.ui.control.Button         % ����ȫ��·�����ݰ�ť
        SendGlobalPathsButton    matlab.ui.control.Button            % ����ȫ��·�����ݰ�ť
        ImportButton             matlab.ui.control.Button            % �����ͼ���ݰ�ť
        ObstacleMarkingButton    matlab.ui.control.Button            % �ϰ����ע��ť
        PlanLocalPathsButton     matlab.ui.control.Button            % ���ɾֲ�Dubins·����ť
        ExportLocalWaypointsButton matlab.ui.control.Button          % ����Dubins·����ť
        SendLocalPathsButton     matlab.ui.control.Button            % ����Dubins·�����ݰ�ť
        % X1plotTCPButton          matlab.ui.control.Button            % AUV���з���ͼ��ť
        % drawPathsButton          matlab.ui.control.Button            % ����·����ť

        %% ��ʾ�������
        UIAxes1                  matlab.ui.control.UIAxes            % ȫ����״·����ʾ����
        UIAxes2                  matlab.ui.control.UIAxes            % �ֲ�Dubins·����ʾ����
        UIAxes3                  matlab.ui.control.UIAxes            % ���μ��ϰ�����ʾ����
        TotalLengthLabelandTCP   matlab.ui.control.Label             % ��·�����ȼ�TCP״̬��ʾ
        StatusLabel              matlab.ui.control.Label             % ״̬��Ϣ��ʾ��ǩ
        
        %% ���ݴ洢����
        Waypoints                                                    % �洢·��������

    end

    properties (SetAccess = immutable, GetAccess = public)
        currentProjectRoot string                                    % ��Ŀ��Ŀ¼
    end

    methods (Access = private)
        function createComponents(app)
            %% ����������
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1300 830]; ...[100 100 1300 830]
            app.UIFigure.Name = 'UUV·������λ�� (��λ:m)';

            %% 1. �����ʼ�����
            app.InitPanel = uipanel(app.UIFigure);
            app.InitPanel.Title = ' UUV����(inf-��ѡ��)';
            app.InitPanel.Position = [30 610 370 200]; % �������߶�

            % ���������ٶ�
            uilabel(app.InitPanel, 'Text', '����ٶ�:', 'Position', [20 155 60 22]);
            app.udEditField = uieditfield(app.InitPanel, 'numeric');
            app.udEditField.Position = [75 155 40 22];
            app.udEditField.Value = 7.0;
            app.udEditField.HorizontalAlignment = 'center';

            % ���ü�ͣʱ��
            uilabel(app.InitPanel, 'Text', '��ͣʱ��:', 'Position', [150 155 60 22]);
            app.TjEditField = uieditfield(app.InitPanel, 'numeric');
            app.TjEditField.Position = [205 155 40 22];
            app.TjEditField.Value = inf;
            app.TjEditField.HorizontalAlignment = 'center';

            % �滮·����ʼ������
            uilabel(app.InitPanel, 'Text', '�滮·�����:', 'Position', [20 130 120 22]);

            % X ����
            app.XEditFieldLabel = uilabel(app.InitPanel);
            app.XEditFieldLabel.Position = [25 105 35 22];
            app.XEditFieldLabel.Text = 'X:';
            app.XEditFieldLabel.HorizontalAlignment = 'center';
            app.XEditField = uieditfield(app.InitPanel, 'numeric');
            app.XEditField.Position = [65 105 50 22];
            app.XEditField.Value = 160;
            app.XEditField.HorizontalAlignment = 'center';

            % Y ����
            app.YEditFieldLabel = uilabel(app.InitPanel);
            app.YEditFieldLabel.Position = [125 105 35 22];
            app.YEditFieldLabel.Text = 'Y:';
            app.YEditFieldLabel.HorizontalAlignment = 'center';
            app.YEditField = uieditfield(app.InitPanel, 'numeric');
            app.YEditField.Position = [165 105 50 22];
            app.YEditField.Value = 90;
            app.YEditField.HorizontalAlignment = 'center';

            % Z ����
            app.ZEditFieldLabel = uilabel(app.InitPanel);
            app.ZEditFieldLabel.Position = [225 105 35 22];
            app.ZEditFieldLabel.Text = 'Z:';
            app.ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.ZEditField.Position = [265 105 50 22];
            app.ZEditField.Value = 20;
            app.ZEditField.HorizontalAlignment = 'center';

            % AUV ��ʼλ��
            uilabel(app.InitPanel, 'Text', 'AUV ��ʼλ��:', 'Position', [20 80 100 22]);

            % X ����
            app.P0XLabel = uilabel(app.InitPanel);
            app.P0XLabel.Position = [25 55 35 22];
            app.P0XLabel.Text = 'X:';
            app.P0XLabel.HorizontalAlignment = 'center';
            app.P0XEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0XEditField.Position = [65 55 50 22];
            app.P0XEditField.Value = 100;
            app.P0XEditField.HorizontalAlignment = 'center';

            % Y ����
            app.P0YLabel = uilabel(app.InitPanel);
            app.P0YLabel.Position = [125 55 35 22];
            app.P0YLabel.Text = 'Y:';
            app.P0YLabel.HorizontalAlignment = 'center';
            app.P0YEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0YEditField.Position = [165 55 50 22];
            app.P0YEditField.Value = 0;
            app.P0YEditField.HorizontalAlignment = 'center';

            % Z ����
            app.P0ZLabel = uilabel(app.InitPanel);
            app.P0ZLabel.Position = [225 55 35 22];
            app.P0ZLabel.Text = 'Z:';
            app.P0ZLabel.HorizontalAlignment = 'center';
            app.P0ZEditField = uieditfield(app.InitPanel, 'numeric');
            app.P0ZEditField.Position = [265 55 50 22];
            app.P0ZEditField.Value = 20;
            app.P0ZEditField.HorizontalAlignment = 'center';

            % AUV ��ʼ��̬��
            uilabel(app.InitPanel, 'Text', 'UUV ��ʼ��̬��(�Ƕ���):', 'Position', [20 30 150 22]);

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

            %% 2. ·���������
            app.PathParametersPanel = uipanel(app.UIFigure);
            app.PathParametersPanel.Title = ' ·������';
            app.PathParametersPanel.Position = [30 465 370 140];

            % ����ѡ��
            app.DirectionDropDownLabel = uilabel(app.PathParametersPanel);
            app.DirectionDropDownLabel.Position = [10 95 80 22];
            app.DirectionDropDownLabel.Text = '·������:';

            app.DirectionDropDown = uidropdown(app.PathParametersPanel);
            app.DirectionDropDown.Items = {'   X ', '   Y '};  % ͨ����ӿո�ʵ���Ӿ�����
            app.DirectionDropDown.Position = [70 95 80 22];
            app.DirectionDropDown.Value = '   Y ';  % ��Ҫƥ��Items�е������ַ���
            
            % ��״�ݼ��
            app.LineSpacingEditFieldLabel = uilabel(app.PathParametersPanel);
            app.LineSpacingEditFieldLabel.Position = [200 95 80 22];
            app.LineSpacingEditFieldLabel.Text = '��״�ݼ��:';
            
            app.LineSpacingEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.LineSpacingEditField.Position = [270 95 80 22];
            app.LineSpacingEditField.Value = 200;
            app.LineSpacingEditField.HorizontalAlignment = 'center';   
            
            % ·�����
            app.PathWidthEditFieldLabel = uilabel(app.PathParametersPanel);
            app.PathWidthEditFieldLabel.Position = [10 65 80 22];
            app.PathWidthEditFieldLabel.Text = '·���ܿ�:';
            
            app.PathWidthEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.PathWidthEditField.Position = [70 65 80 22];
            app.PathWidthEditField.Value = 1730;
            app.PathWidthEditField.HorizontalAlignment = 'center';
            
            % ��״·������
            app.NumLinesEditFieldLabel = uilabel(app.PathParametersPanel);
            app.NumLinesEditFieldLabel.Position = [200 65 80 22];
            app.NumLinesEditFieldLabel.Text = '·������:';
            
            app.NumLinesEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.NumLinesEditField.Position = [270 65 80 22];
            app.NumLinesEditField.Value = 10;
            app.NumLinesEditField.HorizontalAlignment = 'center';

            % ��״·��ê����
            app.anchorEditFieldLabel = uilabel(app.PathParametersPanel);
            app.anchorEditFieldLabel.Position = [10 35 80 22];
            app.anchorEditFieldLabel.Text = 'ê��������:';
            
            app.anchorEditField = uieditfield(app.PathParametersPanel);
            app.anchorEditField.Position = [80 35 40 22];
            app.anchorEditField.Value = '1';
            app.anchorEditField.HorizontalAlignment = 'center';

            % ��״·��ê����ʱ��
            app.TanchorEditFieldLabel = uilabel(app.PathParametersPanel);
            app.TanchorEditFieldLabel.Position = [10 5 80 22];
            app.TanchorEditFieldLabel.Text = 'ê��ʱ��:';
            
            app.TanchorEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.TanchorEditField.Position = [80 5 40 22];
            app.TanchorEditField.Value = 0;
            app.TanchorEditField.HorizontalAlignment = 'center';

            % ��״·����Ǳ·����
            app.downEditFieldLabel = uilabel(app.PathParametersPanel);
            app.downEditFieldLabel.Position = [125 35 80 22];
            app.downEditFieldLabel.Text = '��Ǳ������:';
            
            app.downEditField = uieditfield(app.PathParametersPanel);
            app.downEditField.Position = [195 35 50 22];
            app.downEditField.Value = '21,22';
            app.downEditField.HorizontalAlignment = 'center';

            % ��״·����Ǳ���
            app.DdownEditFieldLabel = uilabel(app.PathParametersPanel);
            app.DdownEditFieldLabel.Position = [250 35 80 22];
            app.DdownEditFieldLabel.Text = '��Ǳ���:';
            
            app.DdownEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.DdownEditField.Position = [310 35 40 22];
            app.DdownEditField.Value = 30;
            app.DdownEditField.HorizontalAlignment = 'center';

            % ��״·���ϸ�·����
            app.upEditFieldLabel = uilabel(app.PathParametersPanel);
            app.upEditFieldLabel.Position = [125 5 80 22];
            app.upEditFieldLabel.Text = '�ϸ�������:';
            
            app.upEditField = uieditfield(app.PathParametersPanel);
            app.upEditField.Position = [195 5 50 22];
            app.upEditField.Value = '25,26';
            app.upEditField.HorizontalAlignment = 'center';

            % ��״·���ϸ����
            app.DupEditFieldLabel = uilabel(app.PathParametersPanel);
            app.DupEditFieldLabel.Position = [250 5 80 22];
            app.DupEditFieldLabel.Text = '�ϸ����:';
            
            app.DupEditField = uieditfield(app.PathParametersPanel, 'numeric');
            app.DupEditField.Position = [310 5 40 22];
            app.DupEditField.Value = 10;
            app.DupEditField.HorizontalAlignment = 'center';

            %% 3. �ݴ�������

            app.FaultTolerantPanel = uipanel(app.UIFigure);
            app.FaultTolerantPanel.Title = ' �ݴ��������';
            app.FaultTolerantPanel.Position = [30 295 370 165]; 

            % ���õ���ʱ��
            uilabel(app.FaultTolerantPanel, 'Text', '����ʱ��:', 'Position', [10 115 60 22]);
            app.TdEditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.TdEditField.Position = [70 115 40 22];
            app.TdEditField.Value = inf;
            app.TdEditField.HorizontalAlignment = 'center';

            uilabel(app.FaultTolerantPanel, 'Text', '���ÿ���ʱ��(s):', 'Position', [10 95 120 14]);

            % ��1
            app.Kdelta1Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta1Label.Position = [10 65 25 22];
            app.Kdelta1Label.Text = '��1:';
            app.Kdelta1Label.HorizontalAlignment = 'center';
            app.Kdelta1EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta1EditField.Position = [35 65 50 22];
            app.Kdelta1EditField.Value = inf;
            app.Kdelta1EditField.HorizontalAlignment = 'center';

            % ��2
            app.Kdelta2Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta2Label.Position = [100 65 25 22];
            app.Kdelta2Label.Text = '��2:';
            app.Kdelta2Label.HorizontalAlignment = 'center';
            app.Kdelta2EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta2EditField.Position = [125 65 50 22];
            app.Kdelta2EditField.Value = inf;
            app.Kdelta2EditField.HorizontalAlignment = 'center';

            % ��3
            app.Kdelta3Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta3Label.Position = [190 65 25 22];
            app.Kdelta3Label.Text = '��3:';
            app.Kdelta3Label.HorizontalAlignment = 'center';
            app.Kdelta3EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta3EditField.Position = [215 65 50 22];
            app.Kdelta3EditField.Value = inf;
            app.Kdelta3EditField.HorizontalAlignment = 'center';

            % ��4
            app.Kdelta4Label = uilabel(app.FaultTolerantPanel);
            app.Kdelta4Label.Position = [280 65 25 22];
            app.Kdelta4Label.Text = '��4:';
            app.Kdelta4Label.HorizontalAlignment = 'center';
            app.Kdelta4EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Kdelta4EditField.Position = [305 65 50 22];
            app.Kdelta4EditField.Value = inf;
            app.Kdelta4EditField.HorizontalAlignment = 'center';

            % �ݴ���ƿ���������
            uilabel(app.FaultTolerantPanel, 'Text', '���ÿ�����(��):', 'Position', [10 35 120 22]);

            % ��1
            app.Delta1Label = uilabel(app.FaultTolerantPanel);
            app.Delta1Label.Position = [10 5 25 22];
            app.Delta1Label.Text = '��1:';
            app.Delta1Label.HorizontalAlignment = 'center';
            app.Delta1EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta1EditField.Position = [35 5 50 22];
            app.Delta1EditField.Value = 0;
            app.Delta1EditField.HorizontalAlignment = 'center';

            % ��2
            app.Delta2Label = uilabel(app.FaultTolerantPanel);
            app.Delta2Label.Position = [100 5 25 22];
            app.Delta2Label.Text = '��2:';
            app.Delta2Label.HorizontalAlignment = 'center';
            app.Delta2EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta2EditField.Position = [125 5 50 22];
            app.Delta2EditField.Value = 0;
            app.Delta2EditField.HorizontalAlignment = 'center';

            % ��3
            app.Delta3Label = uilabel(app.FaultTolerantPanel);
            app.Delta3Label.Position = [190 5 25 22];
            app.Delta3Label.Text = '��3:';
            app.Delta3Label.HorizontalAlignment = 'center';
            app.Delta3EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta3EditField.Position = [215 5 50 22];
            app.Delta3EditField.Value = 0;
            app.Delta3EditField.HorizontalAlignment = 'center';

            % ��4
            app.Delta4Label = uilabel(app.FaultTolerantPanel);
            app.Delta4Label.Position = [280 5 25 22];
            app.Delta4Label.Text = '��4:';
            app.Delta4Label.HorizontalAlignment = 'center';
            app.Delta4EditField = uieditfield(app.FaultTolerantPanel, 'numeric');
            app.Delta4EditField.Position = [305 5 50 22];
            app.Delta4EditField.Value = 0;
            app.Delta4EditField.HorizontalAlignment = 'center';

            %% 4. TCP�������
            app.TCPPanel = uipanel(app.UIFigure);
            app.TCPPanel.Title = ' TCP����';
            app.TCPPanel.Position = [30 195 370 90]; 
            
            % TCP�ؼ�����
            app.ServerIPLabel = uilabel(app.TCPPanel);
            app.ServerIPLabel.Position = [10 40 60 22];
            app.ServerIPLabel.Text = '������IP:'; 
            app.ServerIPEditField = uieditfield(app.TCPPanel);
            app.ServerIPEditField.Position = [65 40 100 22];
            app.ServerIPEditField.Value = '192.168.1.115';
            app.ServerIPEditField.HorizontalAlignment = 'center';

            app.PortLabel = uilabel(app.TCPPanel);
            app.PortLabel.Position = [200 40 80 22];
            app.PortLabel.Text = '�������˿�:';

            app.PortEditField = uieditfield(app.TCPPanel, 'numeric');
            app.PortEditField.Position = [280 40 60 22];
            app.PortEditField.Value = 5001;
            app.PortEditField.HorizontalAlignment = 'center';

            app.hostIPLabel = uilabel(app.TCPPanel);
            app.hostIPLabel.Position = [10 10 60 22];
            app.hostIPLabel.Text = '����IP:'; 
            app.hostIPEditField = uieditfield(app.TCPPanel);
            app.hostIPEditField.Position = [65 10 100 22];
            app.hostIPEditField.Value = '192.168.1.100';
            app.hostIPEditField.HorizontalAlignment = 'center';

            app.hPortLabel = uilabel(app.TCPPanel);
            app.hPortLabel.Position = [200 10 80 22];
            app.hPortLabel.Text = '�����˿�:';
            app.hPortEditField = uieditfield(app.TCPPanel, 'numeric');
            app.hPortEditField.Position = [280 10 60 22];
            app.hPortEditField.Value = 8888;
            app.hPortEditField.HorizontalAlignment = 'center';

            %% 5. Dubins ���
            app.dubinsPanel = uipanel(app.UIFigure);
            app.dubinsPanel.Title = ' Dubins ·���滮����(����:Բ��-ֱ��-Բ��)';
            app.dubinsPanel.Position = [30 100 370 90]; % ����λ��
            
            app.dubinsnsLabel = uilabel(app.dubinsPanel);
            app.dubinsnsLabel.Position = [10 40 120 22];
            app.dubinsnsLabel.Text = 'ǰ��·�������(Բ��):';
            
            app.dubinsnsEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnsEditField.Position = [140 40 40 22];
            app.dubinsnsEditField.Value = 1;
            app.dubinsnsEditField.HorizontalAlignment = 'center';
            
            app.dubinsnlLabel = uilabel(app.dubinsPanel);
            app.dubinsnlLabel.Position = [190 40 120 22];
            app.dubinsnlLabel.Text = '�ж�·�������(ֱ��):';
            
            app.dubinsnlEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnlEditField.Position = [320 40 40 22];
            app.dubinsnlEditField.Value = 50;
            app.dubinsnlEditField.HorizontalAlignment = 'center';

            app.dubinsnfLabel = uilabel(app.dubinsPanel);
            app.dubinsnfLabel.Position = [10 10 120 22];
            app.dubinsnfLabel.Text = '���·�������(Բ��):';

            app.dubinsnfEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsnfEditField.Position = [140 10 40 22];
            app.dubinsnfEditField.Value = 1;
            app.dubinsnfEditField.HorizontalAlignment = 'center';

            app.dubinsradiusLabel = uilabel(app.dubinsPanel);
            app.dubinsradiusLabel.Position = [190 10 120 22];
            app.dubinsradiusLabel.Text = 'Dubins ת��뾶:';

            app.dubinsradiusEditField = uieditfield(app.dubinsPanel, 'numeric');
            app.dubinsradiusEditField.Position = [320 10 40 22];
            app.dubinsradiusEditField.Value = 0;
            app.dubinsradiusEditField.HorizontalAlignment = 'center';

            %% 6. UUV�������������
            app.OperabilityPanel = uipanel(app.UIFigure);
            app.OperabilityPanel.Title = ' UUV����������';
            app.OperabilityPanel.Position = [480 720 340 90]; % λ�ڰ�ť���Ϸ�

            % ���1
            uilabel(app.OperabilityPanel, 'Text', '���1:', 'Position', [10 40 40 22]); % ��ǩ
            app.Rudder1EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder1EditField.Position = [50 40 30 22]; % �����
            app.Rudder1EditField.Value = 0;
            app.Rudder1EditField.HorizontalAlignment = 'center';

            % ���2
            uilabel(app.OperabilityPanel, 'Text', '���2:', 'Position', [85 40 40 22]); % ��ǩ
            app.Rudder2EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder2EditField.Position = [125 40 30 22]; % �����
            app.Rudder2EditField.Value = 0;
            app.Rudder2EditField.HorizontalAlignment = 'center';

            % ���3
            uilabel(app.OperabilityPanel, 'Text', '���3:', 'Position', [165 40 40 22]); % ��ǩ
            app.Rudder3EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder3EditField.Position = [205 40 30 22]; % �����
            app.Rudder3EditField.Value = 0;
            app.Rudder3EditField.HorizontalAlignment = 'center';

            % ���4
            uilabel(app.OperabilityPanel, 'Text', '���4:', 'Position', [245 40 40 22]); % ��ǩ
            app.Rudder4EditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.Rudder4EditField.Position = [285 40 30 22]; % �����
            app.Rudder4EditField.Value = 0;
            app.Rudder4EditField.HorizontalAlignment = 'center';

            % �����ٶ�
            uilabel(app.OperabilityPanel, 'Text', '�����ٶ�:', 'Position', [10 5 55 22]);
            app.DesiredSpeedEditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.DesiredSpeedEditField.Position = [70 5 40 22];
            app.DesiredSpeedEditField.Value = 0;
            app.DesiredSpeedEditField.HorizontalAlignment = 'center';

            % ����ʱ��
            uilabel(app.OperabilityPanel, 'Text', '����ʱ��:', 'Position', [120 5 55 22]);
            app.SimulationTimeEditField = uieditfield(app.OperabilityPanel, 'numeric');
            app.SimulationTimeEditField.Position = [180 5 40 22];
            app.SimulationTimeEditField.Value = 0;
            app.SimulationTimeEditField.HorizontalAlignment = 'center';

            % ��ʼ�����Է��水ť
            app.StartOperabilitySimulationButton = uibutton(app.OperabilityPanel, 'push');
            app.StartOperabilitySimulationButton.ButtonPushedFcn = @(~,~) startOperabilitySimulation(app);
            app.StartOperabilitySimulationButton.Position = [230 5 80 22];
            app.StartOperabilitySimulationButton.Text = '�����Է���';

            %% 7. ��ť��
            
            % ������״·�����ɰ�ť - ��������߽��Զ�������״����·��
            app.GenerateButton = uibutton(app.UIFigure, 'push');
            app.GenerateButton.ButtonPushedFcn = @(~,~) generatePath(app);
            app.GenerateButton.Position = [480 680 340 30]; % ��λ��
            app.GenerateButton.Text = '����ȫ����״·��';

            % ������״·���㵼����ť - �����ɵ���״·������CSV��ʽ���浽����
            app.ExportGlobalWaypointsButton = uibutton(app.UIFigure, 'push');
            app.ExportGlobalWaypointsButton.ButtonPushedFcn = @(~,~) exportGlobalWaypoints(app);
            app.ExportGlobalWaypointsButton.Position = [480 645 340 30]; % ��λ��
            app.ExportGlobalWaypointsButton.Text = '����ȫ����״·������(csv)';
            app.ExportGlobalWaypointsButton.Enable = 'off';

            % ������״·���㷢�Ͱ�ť - ͨ��TCPЭ�齫��״·�������ݷ�����AUV
            app.SendGlobalPathsButton = uibutton(app.UIFigure, 'push');
            app.SendGlobalPathsButton.ButtonPushedFcn = @(~,~) sendGlobalData(app);
            app.SendGlobalPathsButton.Position = [480 610 340 30]; % ��λ��
            app.SendGlobalPathsButton.Text = '����ȫ����״·�������� AUV ';
            app.SendGlobalPathsButton.Enable = 'off';

            % ������ͼ���ݵ��밴ť - ��MAT�ļ��м���Ԥ��ĵ�ͼ����
            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.ButtonPushedFcn = @(~,~) importMapData(app);
            app.ImportButton.Position = [480 575 340 30]; % ��λ��
            app.ImportButton.Text = '�����ͼ����';

            % ��������ͼ���ϰ����ע��ť - ��ʾ���β������û���ע�ϰ���
            app.ObstacleMarkingButton = uibutton(app.UIFigure, 'push');
            app.ObstacleMarkingButton.ButtonPushedFcn = @(~,~)obstacleMarking(app);
            app.ObstacleMarkingButton.Position = [480 540 340 30]; % ��λ��
            app.ObstacleMarkingButton.Text = '����ͼ���ϰ����ע';
            app.ObstacleMarkingButton.Enable = 'off';

            % ����Dubins·���滮��ť
            app.PlanLocalPathsButton = uibutton(app.UIFigure, 'push');
            app.PlanLocalPathsButton.ButtonPushedFcn = @(~,~) planUAVPaths(app);
            app.PlanLocalPathsButton.Position =[480 505 340 30]; % ��λ��
            app.PlanLocalPathsButton.Text = '���ɾֲ� Dubins ·���滮';
            app.PlanLocalPathsButton.Enable = 'off';

            % ����Dubins·���㵼����ť - �������·������CSV��ʽ���浽�����ļ�
            app.ExportLocalWaypointsButton = uibutton(app.UIFigure, 'push');
            app.ExportLocalWaypointsButton.ButtonPushedFcn = @(~,~) exportLocalWaypoints(app);
            app.ExportLocalWaypointsButton.Position = [480 470 340 30]; % ��λ��
            app.ExportLocalWaypointsButton.Text = '���� Dubins ·���滮����(csv)';
            app.ExportLocalWaypointsButton.Enable = 'off';

            % ����Dubins·���㷢�Ͱ�ť - ͨ��TCPЭ�齫·�������ݷ�����AUV
            app.SendLocalPathsButton = uibutton(app.UIFigure, 'push');
            app.SendLocalPathsButton.ButtonPushedFcn = @(~,~) sendLocalData(app);
            app.SendLocalPathsButton.Position = [480 435 340 30]; % ���·���ťλ�ñ��ֲ���
            app.SendLocalPathsButton.Text = '���� Dubins ·���滮������ AUV ';
            app.SendLocalPathsButton.Enable = 'off';

            % % ��������ͼ���ư�ť - ���ӻ���ʾ��ǰ·���滮�������ķ���Ч��
            % app.X1plotTCPButton = uibutton(app.UIFigure, 'push');
            % app.X1plotTCPButton.ButtonPushedFcn = @(~,~) X1plotTCP(app);
            % app.X1plotTCPButton.Position = [480 390 340 30];
            % app.X1plotTCPButton.Text = '���� AUV ���з���ͼ';
            % app.X1plotTCPButton.Enable = 'off';

            %% 8. ״̬��ǩ
            % ��·�����ȼ�TCP״̬�汾չʾ
            app.TotalLengthLabelandTCP = uilabel(app.UIFigure);
            app.TotalLengthLabelandTCP.Position = [30 60 320 40];
            app.TotalLengthLabelandTCP.Text = '��·������: 0.0 ��';
            app.TotalLengthLabelandTCP.HorizontalAlignment = 'center';
            
            % ����״̬��ǩ
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [30 30 320 30];
            app.StatusLabel.Text = '��δ���ɹ滮·�����ݣ�';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontColor = [0.8 0 0];
            
            %% 9. ��ͼ����
            
            % ����AUVȫ��·���滮��ʾ���� - ����չʾ����·���滮������Ч��
            % λ�ڽ������Ϸ�����ʾAUV�������������״����·��
            app.UIAxes1 = uiaxes(app.UIFigure);
            app.UIAxes1.Position = [860 430 390 390];
            title(app.UIAxes1, ' ȫ����״·���滮Ч��ͼ');
            xlabel(app.UIAxes1, 'X�� (��)');
            ylabel(app.UIAxes1, 'Y�� (��)');
            grid(app.UIAxes1, 'on');

            % ����Dubins�ֲ�·���滮��ʾ���� - ����չʾ����Dubins���ߵľֲ�·���滮���
            % λ�ڽ������·�����ʾAUV���ϰ��ﻷ���еľֲ�·���滮�켣
            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.Position = [860 40 390 390];
            title(app.UIAxes2, '�ֲ� Dubins ·���滮Ч��ͼ');
            xlabel(app.UIAxes2, 'X�� (��)');
            ylabel(app.UIAxes2, 'Y�� (��)');
            grid(app.UIAxes2, 'on');

            % �����������ϰ�����ʾ���� - ������ʾ�������κ��û���ע���ϰ���
            % λ�ڽ������·��������û�����ʽ�ر�ע�Ͳ鿴�����ϰ�����Ϣ
            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.Position = [440 40 390 390];
            title(app.UIAxes3, '���μ��ϰ����עͼ');
            xlabel(app.UIAxes3, 'X�� (��)');
            ylabel(app.UIAxes3, 'Y�� (��)');
            grid(app.UIAxes3, 'on');

        end

        %% ��Ŀ·�����ýű�
        function [projectRoot,currentDir]= setupAppPaths(app)
            % ��ȡ��ǰ�ű����ڵ�Ŀ¼
            currentDir = fileparts(mfilename('fullpath'));
            
            % �����Ƿ��Ѳ���������Ŀ��Ŀ¼
            if isdeployed
                % ���Ѳ��𻷾��У�ʹ��ϵͳ��ʱĿ¼��Ϊ����
                [status, tempPath] = system('echo %TEMP%');
                if status == 0
                    basePath = strtrim(tempPath);
                    appFolder = fullfile(basePath, 'CoveragePathPlannerApp');
                    
                    % ȷ��Ӧ�ó����ļ��д���
                    if ~exist(appFolder, 'dir')
                        mkdir(appFolder);
                        fprintf('�Ѵ���Ӧ�ó����ļ���: %s\n', appFolder);
                    end
                    projectRoot = appFolder;
                else
                    % ����޷���ȡϵͳ��ʱĿ¼��ʹ�õ�ǰĿ¼
                    projectRoot = pwd;
                    fprintf('�޷���ȡϵͳ��ʱĿ¼��ʹ�õ�ǰĿ¼: %s\n', projectRoot);
                end
            else
                % ����������ʹ�����·��
                projectRoot = fullfile(currentDir, '..');
            end
            
            % ������Ҫ��ӵĺ����ļ���·��
            pathsToAdd = {
%                 fullfile(currentDir, 'utils'),            ... ���ߺ�����Ŀ¼
%                 fullfile(currentDir, 'utils', 'dubins'),  ... Dubins·���滮
%                 fullfile(currentDir, 'utils', 'main'),    ... ��Ҫ���ܺ���
%                 fullfile(currentDir, 'utils', 'plot'),    ... ��ͼ��غ���
%                 fullfile(currentDir, 'utils', 'trajectory'), ... �켣���ɺ���
                fullfile(projectRoot, 'data'),            ... �����ļ���
                fullfile(projectRoot, 'picture')          ... ͼƬ�ļ���
            };
            
            % ȷ���ļ��д���
            if isdeployed
                % �ѱ��뻷����ֻ�������ݺ�����ļ���
                dataPaths = {
                    fullfile(projectRoot, 'data'),
                    fullfile(projectRoot, 'picture')
                };
                
                for i = 1:length(dataPaths)
                    if ~exist(dataPaths{i}, 'dir')
                        try
                            mkdir(dataPaths{i});
                            fprintf('�Ѳ��𻷾�: �����ļ��� %s\n', dataPaths{i});
                        catch ME
                            warning('�޷������ļ��� %s: %s', dataPaths{i}, ME.message);
                        end
                    end
                end
            else
                % �������������������ļ��в���ӵ�����·��
                for i = 1:length(pathsToAdd)
                    if ~exist(pathsToAdd{i}, 'dir')
                        try
                            mkdir(pathsToAdd{i});
                            fprintf('��������: �����ļ��� %s\n', pathsToAdd{i});
                        catch ME
                            warning('�޷������ļ��� %s: %s', pathsToAdd{i}, ME.message);
                        end
                    end
                    
                    % ��ӵ�����·��
                    addpath(pathsToAdd{i});
                    fprintf('�����·��: %s\n', pathsToAdd{i});
                end
            end
            
            % ��֤��������
            app.checkEnvironment();
            
            fprintf('·��������ɣ���Ŀ��Ŀ¼: %s\n', projectRoot);
        end

        %% ����Ҫ�Ĺ������Ƿ�װ
        function checkEnvironment(~)
            requiredToolboxes = {'MATLAB', 'Simulink'};
            installedToolboxes = ver;
            installedToolboxNames = {installedToolboxes.Name};
            
            fprintf('\n�������:\n');
            for i = 1:length(requiredToolboxes)
                if any(contains(installedToolboxNames, requiredToolboxes{i}))
                    fprintf('? %s �Ѱ�װ\n', requiredToolboxes{i});
                else
                    warning('? %s δ��װ\n', requiredToolboxes{i});
                end
            end
            
            % ���MATLAB�汾
            matlabVersion = version;
            fprintf('��ǰMATLAB�汾: %s\n', matlabVersion);
        end

        %% ��������͹ر�ʱ���������
        function startup(app)
            try
                % ����Ĭ�Ϲ���Ŀ¼
                if ~isdeployed % ��������ѱ���İ汾
                    cd(fileparts(mfilename('fullpath')));
                else
                    [status, result] = system('echo %TEMP%');
                    if status == 0
                        tempDir = strtrim(result);
                        cd(tempDir);
                    end
                end
                
                % ��ʼ��״̬
                app.StatusLabel.Text = '��δ���ɹ滮·�����ݣ�';
                app.StatusLabel.FontColor = [0.8 0 0];
                
            catch ME
                warning(ME.identifier, '������ʼ��ʧ��: %s', ME.message);
            end
        end
        
        function cleanup(app)
            try
                % �����κδ򿪵�TCP����
                if isfield(app, 'tcpClient') && isvalid(app.tcpClient)
                    clear app.tcpClient;
                end
            catch
                % �����������
            end
        end
    end 

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CoveragePathPlannerApp()

            % ����·��
            [projectRoot,~]=setupAppPaths(app);
            
            % ��ȡ��ǰ�ļ���·��
            % app.currentProjectRoot = pwd;
            % app.currentProjectRoot = fullfile(fileparts(mfilename('fullpath')), '..');
            % app.currentProjectRoot = fullfile(pwd, '..');
            app.currentProjectRoot = projectRoot;
            % ע�⣺ɾ��������ʹ�� genpath �� addpath �޸�����·���Ĵ���
            
            % �������
            createComponents(app)
            
            % ��ʼ������
            app.Waypoints = [];
            
            % ������������
            startup(app)
            
            % ��ʾ����
            app.UIFigure.Visible = 'on';
        end

        % �޸�ɾ������������������
        function delete(app)
            % �����������
            cleanup(app)
            
            % ɾ������
            delete(app.UIFigure)
        end
    end
end