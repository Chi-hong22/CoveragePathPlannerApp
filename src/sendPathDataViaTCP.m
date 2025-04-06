%% sendPathDataViaTCP - ͨ��TCPЭ�鷢��·������
%
% ����������
%   �ú������ڽ�·������ͨ��TCPЭ�鷢�͵�ָ���ķ�������
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.0
%   �������ڣ�250328
%   ����޸ģ�250329
%
% �汾��ʷ��
%   v1.0 (250329) - �״η���
%       + ʵ�ֻ�����TCP���ݷ��͹���
%       + ��ӻ����Ĵ������״̬����
%
% ���������
%   app         - [object] MATLAB App���󣬰���UI�ؼ���״̬��Ϣ
%   pathData    - [double array] ·�����ݾ�������Ϊ·��������������Ϊ2��4
%   buttonName  - [string] �������Ͳ����İ�ť����
%
% ���������
%   ��ֱ�ӷ���ֵ��������ͨ��TCP���ӷ��͵�Ŀ�������������UI����ʾ״̬��Ϣ
%
% ע�����
%   1. ȷ��Ŀ�������IP��ַ�Ͷ˿���ȷ�ҷ��������ڿ���״̬
%   2. ·�����ݵ���������Ϊ2��4��������׳�����
%   3. �ϸ������Ǳ�������������·����������Χ��
%   4. ��������÷��Ͱ�ť��ֱ��������ɻ�ʧ��
%
% ����ʾ����
%   % ʾ��1����������
%   sendPathDataViaTCP(app, pathData, 'SendButton');
%
% ���������䣺
%   - MATLAB App Designer
%   - Instrument Control Toolbox (tcpclient����)
%
% �μ�������
%   processPathData,processTCP

function sendPathDataViaTCP(app, pathData, buttonName)
    % ���ð�ť
    app.(buttonName).Enable = false;

    % ���ݴ���
    [jsonData, statusTCP, ~] = processPathData(app, pathData);
    if ~statusTCP
        app.(buttonName).Enable = true;
        return;
    end

    % TCP����
    [statusData, ~] = processTCP(app, jsonData);
    if ~statusData
        app.(buttonName).Enable = true;
        return;
    end

end