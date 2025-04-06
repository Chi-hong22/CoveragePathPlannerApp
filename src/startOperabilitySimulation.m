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

    % ����ͳһ������������
    sendPathDataViaTCP(app, pathData, 'StartOperabilitySimulationButton');

    % �������ݴ����TCP���ͷֿ�����
    app.StartOperabilitySimulationButton.Enable = false;

    [jsonData, statusData, ~] = processPathData(app, pathData);
    if ~statusData
        app.StartOperabilitySimulationButton.Enable = true;
        return;
    end
    [statusTCP, ~] = processTCP(app, jsonData);
    if ~statusTCP
        app.StartOperabilitySimulationButton.Enable = true;
        return;
    end


end