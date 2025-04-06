function generatePath(app)
    % ����·��
    %
    % ����������
    %   �˺������ڴ�GUI���ռ�������������·�����ɺ�������AUV����״����·����
    %   ���ɵ�·������UI��������ʾ����������·�����ȡ�
    %
    % ���������
    %   app - AUVCoveragePathPlannerApp��ʵ��
    %
    % ���������
    %   ��ֱ����������ͨ��UI������ʾ
    %
    % ע�����
    %   1. ȷ���������������Ч�Ҹ�ʽ��ȷ��
    %   2. �ú��������UI�����еİ�ť״̬�ͱ�ǩ��
    %
    % �汾��Ϣ��
    %   �汾��v1.1
    %   �������ڣ�241101
    %   ����޸ģ�250110
    %
    % ������Ϣ��
    %   ���ߣ����Ӱ�
    %   ���䣺you.ziang@hrbeu.edu.cn
    %   ��λ�����������̴�ѧ
    startPoint = [app.XEditField.Value, app.YEditField.Value];
    lineSpacing = app.LineSpacingEditField.Value;
    pathWidth = app.PathWidthEditField.Value;
    numLines = app.NumLinesEditField.Value;
    radius= app.dubinsradiusEditField.Value;
    direction = lower(app.DirectionDropDown.Value);
    
    % ����·�����ɺ���
    try
        % �����ǰaxes
        cla(app.UIAxes1);
        
        % ����·��
        app.Waypoints = generateCombPath(app, startPoint, lineSpacing, pathWidth, numLines, direction,radius);
        
        % ��·���㱣�浽����������
        assignin('base', 'Waypoints', app.Waypoints);
        
        % �ֶ�����·��
        plot(app.UIAxes1, app.Waypoints(:,1), app.Waypoints(:,2), 'b-', 'LineWidth', 2);
        hold(app.UIAxes1, 'on');
        
        % ����·����
        plot(app.UIAxes1, app.Waypoints(:,1), app.Waypoints(:,2), 'bo', 'MarkerSize', 6);
        
        % ������㣨��ɫ���飩
        plot(app.UIAxes1, app.Waypoints(1,1), app.Waypoints(1,2), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % �����յ㣨��ɫ���飩
        plot(app.UIAxes1, app.Waypoints(end,1), app.Waypoints(end,2), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % �����ܳ���
        totalLength = 0;
        for i = 1:size(app.Waypoints,1)-1
            totalLength = totalLength + norm(app.Waypoints(i+1,:) - app.Waypoints(i,:));
        end
        
        % �����ܳ��ȱ�ǩ
        app.TotalLengthLabelandTCP.Text = sprintf('��·������: %.1f ��', totalLength);
        
        % ����ͼ������
        grid(app.UIAxes1, 'on');
        xlabel(app.UIAxes1, 'X�� (��)');
        ylabel(app.UIAxes1, 'Y�� (��)');
        title(app.UIAxes1, sprintf('AUV��״����·���滮ͼ (%s����)', upper(direction)));
        legend(app.UIAxes1, '·��', '·����', '���', '�յ�');
        axis(app.UIAxes1, 'equal');
        hold(app.UIAxes1, 'off');
        
        % ���ð�ť
        app.ExportGlobalWaypointsButton.Enable = 'on';
        app.SendGlobalPathsButton.Enable = 'on';
        
    catch ME
        % ������
        errordlg(['·�����ɴ���: ' ME.message], '����');
    end
    % app.PlanLocalPathsButton.Enable = 'off';  
    % app.SendLocalPathsButton.Enable = 'off';
    % app.GenerateButton.Enable = 'off';
end