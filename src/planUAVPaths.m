% �ƻ�AUV·��
    %
    % ����������
    %   �˺�����������AUV��·���滮������ȡCSV�ļ��еĺ�����Ϣ��
    %   �����ϰ�����Ϣ�������ݸ����Ĳ�������·����
    %   �˺������ڴ�CSV�ļ��ж�ȡ·�����ݣ�����UI�����л���·����
    %   ͬʱ���������ȡ�ϰ�����Ϣ�������ϰ��
    %
    % ���������
    %   app - AUVCoveragePathPlannerApp��ʵ��
    %
    % ��������� 
    %   pathPlanning - ���ɵ�·���滮���
    %
    % ע�����
    %   1. ȷ��CSV�ļ����ϰ�����Ϣ�ļ������Ҹ�ʽ��ȷ��
    %   2. �ú��������UI�����еİ�ť״̬��
    %
    % �汾��Ϣ��
    %   �汾��v1.1
    %   �������ڣ�241101
    %   ����޸ģ�250328
    %
    % ������Ϣ��
    %   ���ߣ�Chihong�����Ӱ���
    %   ���䣺you.ziang@hrbeu.edu.cn
    %   ���ߣ�������
    %   ���䣺1443123118@qq.com
    %   ��λ�����������̴�ѧ

function planUAVPaths(app)
    % �ӹ�������ȡWaypoints����
    try
        Waypoints = evalin('base', 'Waypoints');
    catch
        errordlg('��������δ�ҵ�Waypoints����', '����');
        return;
    end
    % �ӹ�������ȡcirclesInfo����
    try
        circlesInfo = evalin('base', 'circlesInfo');
    catch
        errordlg('��������δ�ҵ�circlesInfo����', '����');
        return;
    end

    %% ��ʼ������
    Property.obs_last=0;                                                % ��¼��ǰ�켣�滮�ڼ�ܿ����ϰ���
    Property.invasion=0;                                                % ��¼�켣�滮�ڼ��Ƿ����κ������ϰ����в����
    Property.mode=1;                                                    % ���ù켣����ģʽ 1: ���·��; 2: ����·��
    Property.ns=app.dubinsnsEditField.Value;                            % ������ʼ���ε���ɢ����
    Property.nl=app.dubinsnlEditField.Value;                            % ����ֱ�߶ε���ɢ����
    Property.nf=app.dubinsnfEditField.Value;                            % ���ý������ε���ɢ����
    Property.max_obs_num=5;                                             % ����ÿ��·���滮Ҫ��������ϰ�������
    Property.max_info_num=20;                                           % ����ÿ���滮����洢�����·������
    Property.max_step_num=4;                                            % ����·�������滮������
    Property.Info_length=33;                                            % ����ÿ��·����Ϣ�ĳ���
    Property.radius=100*1e3;                                            % ����AUV��ת��뾶�����ף�
    Property.scale=1;
    Property.increment=20*1e3;                                          % ����·�����������ĵ�����Χ
    Property.selection1=3;                                              % ����·������ģʽ1
    Property.selection2=1;                                              % ����·������ģʽ2
                                                                    % =1: ·�������ϰ����ཻ
                                                                    % =2: ·����ת��ǲ�����3 * pi/2
                                                                    % =3: ͬʱ����1��2
                                                                
    % ���������Ϣ
    StartInfo=Waypoints(1:2* app.NumLinesEditField.Value-1,:);            % ��λ�����ף�

    % �����յ���Ϣ
    FinishInfo=Waypoints(2:2* app.NumLinesEditField.Value,:);               % ��λ�����ף�

    % �����ϰ����вԲ����Ϣ
    ObsInfo=circlesInfo;
    ObsInfo(:,3)=ObsInfo(:,3)+2;
    [uav_num,~]=size(StartInfo);                                        % ��ȡAUV����
    [obs_num,~]=size(ObsInfo);                                          % ��ȡ�ϰ�������

    Coop_State(1:uav_num)=struct(...                                    % AUV����·����Ϣ�Ľṹ
        'traj_length',[],...                                            % ����·�����ȵ�����
        'traj_length_max',0,...                                         % ���·������
        'traj_length_min',0,...                                         % ��С·������
        'TrajSeqCell',[],...                                            % ·�����е�Ԫ����
        'ideal_length',0,...                                            % ����·������
        'optim_length',0,...                                            % �Ż����·������
        'traj_index_top',0,...                                          % ���ȴ�������ӽ�����·�����ȵ�·������
        'traj_index_bottom',0,...                                       % ����С������ӽ�����·�����ȵ�·������
        'TrajSeq_Coop',[]);                                             % Э��·�����о���

    %% ��˳��滮ÿ��AUV����㵽�յ��·��
    for uav_index=1:2*app.NumLinesEditField.Value-1                                        % ����ÿ��AUV
        start_info=StartInfo(uav_index,:);                              % ��ȡAUV�������Ϣ
        finish_info=FinishInfo(uav_index,:);                            % ��ȡAUV���յ���Ϣ
        Property.radius=start_info(4);                                  % ���ݳ�ʼ��Ϣ����AUV��ת��뾶
        TrajSeqCell=Traj_Collection...                                  % ����AUV�����п�������·��
            (start_info,finish_info,ObsInfo,Property);                  
        Coop_State(uav_index)=Coop_State_Update...                      % �ӿ�������·����ѡ�����·��
            (TrajSeqCell,Coop_State(uav_index),ObsInfo,Property);       % ���Ż�����·��������Э��·��

        Plot_Traj_Multi_Modification(TrajSeqCell,ObsInfo,Property);
        hold on;
    end


    result_no_duplicates = Plot_Traj_Coop(Coop_State,ObsInfo,Property,1);                    % ����Э��·���滮���
    assignin('base','result_no_duplicates',result_no_duplicates);

    % app.drawPathsButton.Enable = 'on';
    app.ExportLocalWaypointsButton.Enable = 'on';
    app.SendLocalPathsButton.Enable = 'on';

    % ���UIAxes2�ϵ�����ͼ��Ԫ��
    cla(app.UIAxes2);

    % ����CSV�ļ��е������Ƕ��У�ÿ���д���һ��·����x��y����
    numPaths = size(result_no_duplicates, 2) / 2; % ����·������
    hold(app.UIAxes2, 'on'); % ���ֵ�ǰͼ�Σ��Ա���ͬһͼ���ϻ��ƶ���·��

    % ����·��
    for i = 1:numPaths
        % ѡ���i��·��������
        x = result_no_duplicates(:, 2*i-1);
        y = result_no_duplicates(:, 2*i);
        
        % ����·��
        plot(app.UIAxes2, x, y, 'b-', 'LineWidth', 2);
        
        % ����·����
        plot(app.UIAxes2, x, y, 'bo', 'MarkerSize', 6);
        
        % ������㣨��ɫ���飩
        plot(app.UIAxes2, x(1), y(1), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % �����յ㣨��ɫ���飩
        plot(app.UIAxes2, x(end), y(end), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
    end


    % �����ϰ���
    for i = 1:size(circlesInfo, 1)
        % ��ȡԲ�����ĺͰ뾶
        centerX = circlesInfo(i, 1);
        centerY = circlesInfo(i, 2);
        radius = circlesInfo(i, 3);
        
        % ����Բ
        rectangle(app.UIAxes2, 'Position', [centerX - radius, centerY - radius, 2*radius, 2*radius], ...
                    'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2);
    end

    % Ϊ����ͼ������ʾ�ϰ������һ����ɫԲȦ
    plot(app.UIAxes2, NaN, NaN, 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Obstacles');

    % �����������ǩ������
    xlabel(app.UIAxes2, 'X/m');
    ylabel(app.UIAxes2, 'Y/m');
    grid(app.UIAxes2, 'on');

    % ���ͼ��
    legend(app.UIAxes2, '·��',  '���', '�յ�', '�ϰ���');
    % ����ͼ��
    hold(app.UIAxes2, 'off');

    % app.X1plotTCPButton.Enable = 'on';
    
end