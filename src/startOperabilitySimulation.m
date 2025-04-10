%% startOperabilitySimulation - AUV �����Է�����������
%
% ����������
%   �ú����������� AUV �Ĳ����Է��棬�����û�����Ķ�ǡ������ٶȺͷ���ʱ�䣬
%   ģ�� AUV �ڲ�ͬ���������µ��˶���Ϊ������������������ AUV �Ĳ������ܺ�
%   ����ϵͳ����Ӧ���ԡ�
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ
%   ���ߣ��հ·�
%   ���䣺taoaofei@gmail.com
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.0
%   �������ڣ�250328
%
% �汾��ʷ��
%   v1.0 (250328) - ��ʼ�汾��ʵ�ֻ������湦��
%
% ���������
%   app - [object] Ӧ�ö���
%       ͨ��GUI���洫�ݣ��������¿ɵ��ýӿڣ�
%       1. �ĸ���ǵ�ֵ
%          app.Rudder1EditField.Value
%          app.Rudder2EditField.Value
%          app.Rudder3EditField.Value
%          app.Rudder4EditField.Value
%       2. �����ٶ�
%          app.DesiredSpeedEditField.Value
%       3. ����ʱ��
%          app.SimulationTimeEditField.Value
%
% ���������
%   ��ֱ�ӷ���ֵ����������ͨ��ͼ�ν�����ʾ�򱣴浽ָ���ļ��С�
%
% ע�����
%   1. ���ݴ�����TCP���͵ĵ��÷�ʽ�ڴ�����������˵����
%   2. ע��pathData�ĸ�ʽ�����ݣ�����Ϊһ����ά��������Ϊ·��������������Ϊ2��4��
%   3. 
%
% ���÷�����
%   app.StartOperabilitySimulationButton.ButtonPushedFcn = @(~,~) startOperabilitySimulation(app);
%
% ���������䣺
%   - MATLAB ����������
%   - Simulink ���湤���䣨��ѡ��
%
% �μ�������
%   sendPathDataViaTCP,processPathData,processTCP

function startOperabilitySimulation(app)

    % �������ݴ����TCP���ͷֿ�����
    app.StartOperabilitySimulationButton.Enable = false;
    
    
    
    hostIP = app.hostIPEditField.Value;
    hPort = app.hPortEditField.Value;
    Rudder=[app.Rudder1EditField.Value,app.Rudder2EditField.Value,app.Rudder3EditField.Value,app.Rudder4EditField.Value];
    Time=app.SimulationTimeEditField.Value;
    ue=app.DesiredSpeedEditField.Value;
    P0 = [app.P0XEditField.Value, app.P0YEditField.Value, app.P0ZEditField.Value];
    A0 = [app.A0XEditField.Value, app.A0YEditField.Value, app.A0ZEditField.Value];
    
    assignin('base','Rudder',Rudder);
    assignin('base','Time',Time);
    assignin('base',"ue",ue);
    assignin('base', 'P0', P0);
            assignin('base', 'A0', A0);
    
    
    dataStruct = struct( 'hostIP', hostIP, ...
        'hPort', hPort, ...
        'Rudder',Rudder, ...
        'Time',Time, ...
        'ue',ue, ...
        'P0', P0, ...
        'A0', A0);
       
    manoeuvreData = jsonencode(dataStruct);
    
    
    [statusTCP, ~] = processTCP(app, manoeuvreData);
    % if ~statusTCP
        app.StartOperabilitySimulationButton.Enable = true;
        % return;
    % end
    
    
    end