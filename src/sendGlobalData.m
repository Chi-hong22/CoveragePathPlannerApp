%% sendGlobalData - ����ȫ��·���滮���ݵ�AUV�豸
%
% ����������
%   �˺������ڽ�ȫ��·���滮����ͨ��TCP���ӷ��͵�AUV�豸��
%   ͨ������sendPathDataViaTCP����ʵ�ֺ��Ĺ��ܣ��Ż��˴���ṹ��
%
% ���������
%   app - AUVCoveragePathPlannerApp��ʵ��������UI�����·������
%
% ���������
%   ��ֱ����������ͽ������UI��������ʾ
%
% ע�����
%   1. ȷ��������IP�Ͷ˿���ȷ����AUV�豸�ѿ�����׼���ý������ݡ�
%   2. ���͹����У���ذ�ť�������ã�������ɺ�ָ�����״̬��
%
% �汾��Ϣ��
%   �汾��v1.2
%   �������ڣ�241101
%   ����޸ģ�250328
%
% ������Ϣ��
%   ���ߣ����Ӱ�
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ

function sendGlobalData(app)
    % ����ͳһ������������
    sendPathDataViaTCP(app, app.Waypoints, 'SendGlobalPathsButton');
end