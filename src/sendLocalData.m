%% sendLocalData - ���;ֲ�·���滮���ݵ�AUV
%
% ����������
%   �������õķ�����IP�Ͷ˿ڣ����ֲ�·���滮���ݷ��͵�AUV�豸��
%   ������ͨ������sendPathDataViaTCP����ʵ�ֺ��Ĺ��ܣ��Ż��˴���ṹ��
%
% ���������
%   app - AUVCoveragePathPlannerAppʵ��
%
% ���������
%   ��ֱ�ӷ���ֵ�����ͽ��ͨ��UI������ʾ
%
% ע�����
%   1. ��ȷ��������IP�Ͷ˿�������ȷ����AUV�豸�����ӡ�
%   2. ���͹����У���ť�������ã�������ɺ�ָ�����״̬��
%   3. ��������ȡ����CSV�ļ����ļ����̶�Ϊ'result_no_duplicates.csv'��
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.2
%   �������ڣ�20241101
%   ����޸ģ�250328
%
% ������Ϣ��
%   ���ߣ����Ӱ�
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ
%   ���ߣ�������
%   ���䣺1443123118@qq.com
%   ��λ�����������̴�ѧ

function sendLocalData(app)
    % ��ȡ�������е�·������
    try
        result_no_duplicates = evalin('base', 'result_no_duplicates');
    catch
        app.TotalLengthLabelandTCP.Text = '��ȡresult_no_duplicates·������ʧ��';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        return;
    end

    % ����ͳһ������������
    sendPathDataViaTCP(app, result_no_duplicates, 'SendLocalPathsButton');
end