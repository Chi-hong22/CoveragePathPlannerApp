%% processTCP - ͨ��TCPЭ�鷢��JSON����
%
% ����������
%   �ú�������ͨ��TCPЭ�鷢�ʹ�����JSON���ݵ�ָ���ķ�������
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.0
%   �������ڣ�250329
%   ����޸ģ�250329
%
% �汾��ʷ��
%   v1.0 (250329) - �״η���
%       + ʵ�ֻ�����TCP���ݷ��͹���
%       + ��ӻ����Ĵ������״̬����
%
% ���������
%   app         - [object] MATLAB App���󣬰���UI�ؼ���״̬��Ϣ
%   jsonData    - [string] ������·�����ݣ�JSON��ʽ
%
% ���������
%   statusTCP   - [logical] ���ݷ��͵�״̬��true��ʾ�ɹ���false��ʾʧ�ܣ�
%   errorMessage - [string] ������ݷ���ʧ�ܣ����ش�����Ϣ
%
% ע�����
%   1. ȷ��Ŀ�������IP��ַ�Ͷ˿���ȷ�ҷ��������ڿ���״̬
%   2. ��������÷��Ͱ�ť��ֱ��������ɻ�ʧ��
%
% ����ʾ����
%   % ʾ��1����������
%   [statusTCP, errorMessage] = processTCP(app, jsonData);
%
% ���������䣺
%   - MATLAB App Designer
%   - Instrument Control Toolbox (tcpclient����)
%
% �μ�������
%   tcpclient, flush, write

function [statusTCP, errorMessage] = processTCP(app, jsonData)

    % ��ȡTCP����
    serverIP = app.ServerIPEditField.Value;
    port = app.PortEditField.Value;

    if isempty(serverIP) || isempty(port)
        app.TotalLengthLabelandTCP.Text = '��������Ч��IP��ַ�Ͷ˿�';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        statusTCP = false;
        return;
    end

    try
        % ��ʾ������״̬
        app.TotalLengthLabelandTCP.Text = '���ڳ�������...';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0.8 0];
        drawnow; % ��������UI

        % ����10�볬ʱ
        client = tcpclient(serverIP, port, 'Timeout', 10, 'ConnectTimeout', 10);
        % ���ӳɹ�
        app.TotalLengthLabelandTCP.Text = 'TCP���ӳɹ�';
        app.TotalLengthLabelandTCP.FontColor = [0 0.5 0];

        % ��������
        flush(client);
        write(client, jsonData, 'string');
        % ����״̬
        app.statusTCPLabel.Text = '�滮·�����ݷ��ͳɹ���';
        app.statusTCPLabel.FontColor = [0 0.5 0];
        statusTCP = true;
        errorMessage = '';
    catch tcpErr
        % ���ֳ�ʱ����������
        if contains(tcpErr.message, 'Timeout') || contains(tcpErr.message, 'timed out')
            errorMessage = '���ӳ�ʱ������Ŀ���豸�Ƿ���';
        else
            errorMessage = sprintf('TCP����ʧ��: %s\n����IP��ַ�Ͷ˿�����', tcpErr.message);
        end
        app.TotalLengthLabelandTCP.Text = errorMessage;
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        statusTCP = false;
    end
end