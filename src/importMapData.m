% �����ͼ����
    %
    % ����������
    %   �˺������ڴ��û�ѡ���.mat�ļ��е����ͼ���ݣ������临�Ƶ�Ӧ�ó����Ŀ¼�С�
    %   �û�ͨ���ļ�ѡ��Ի���ѡ���ļ����ļ��������Ƶ�Ӧ�ó����Ŀ¼�С�
    %
    % ���������
    %   app - AUVCoveragePathPlannerApp��ʵ��
    %
    % ���������
    %   ��ֱ����������ͨ��UI������ʾ
    %
    % ע�����
    %   1. ȷ���û�ѡ����ļ������Ҹ�ʽ��ȷ��
    %   2. �ú��������UI�����еİ�ť״̬��
    %
    % �汾��Ϣ��
    %   �汾��v1.1
    %   �������ڣ�241101
    %   ����޸ģ�250110
    %
    % ������Ϣ��
    %   ���ߣ�������
    %   ���䣺1443123118@qq.com
    %   ��λ�����������̴�ѧ
    
function importMapData(app)
    % ʹ��Ӧ�ó��򱣴��·��
    defaultPath = fullfile(app.currentProjectRoot, 'data');
    
    % ���data�ļ��в����ڣ��򴴽���
    if ~exist(defaultPath, 'dir')
        mkdir(defaultPath);
    end
    
    % ��ȡ�ļ���������Ĭ��·��Ϊdata�ļ���
    [filename, pathname] = uigetfile('*.mat', 'ѡ���ͼ�����ļ�', defaultPath);
    
    if isequal(filename, 0) || isequal(pathname, 0)
        % �û�ȡ������
        app.StatusLabel.Text = '���������ȡ��';
        app.StatusLabel.FontColor = [0.8 0 0];
        return;
    end
    disp('��ͼ���ݵ���ɹ�');

    app.StatusLabel.Text = ['��ѡ���ļ�: ' filename];
    app.StatusLabel.FontColor = [0 0 0.8];

    app.ObstacleMarkingButton.Enable = 'on';
    
end