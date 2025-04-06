    %% generateCombPath - ������״·��
    %
    % ����������
    %   �˺�����������AUV����״����·�������ݸ�������ʼ�㡢�߼�ࡢ·����ȡ����������������ת��뾶��
    %   ����·���㲢������·�����ȡ�
    %
    % ���������
    %   app - AUVCoveragePathPlannerApp��ʵ��
    %   start_point - ��ʼ������ [x, y]
    %   line_spacing - ��״�ݼ��
    %   path_width - ·�����
    %   num_lines - ��״·������
    %   direction - ·������ ('x' �� 'y')
    %   radius - ת��뾶
    %
    % ���������
    %   waypoints - ���ɵ�·��������
    %
    % ע�����
    %   1. ȷ���������������Ч�Ҹ�ʽ��ȷ��
    %   2. �ú��������UI�����еı�ǩ��
    %
    % �汾��Ϣ��
    %   �汾��v1.2
    %   �������ڣ�241101
    %   ����޸ģ�250316
    % �汾��ʷ��
    %   v1.0 (241101) - ��ʼ�汾
    %   v1.1 (250110) - �Ż�����
    %   v1.2 (250316) - �޸�direction������Ч�����
    %
    % ������Ϣ��
    %   ���ߣ����Ӱ�
    %   ���䣺you.ziang@hrbeu.edu.cn
    %   ��λ�����������̴�ѧ

function waypoints = generateCombPath(app, startPoint, lineSpacing, pathWidth, numLines, direction,radius)
    % ɾ����������е����пո�
    direction = strrep(direction, ' ', '');
    
    % ��ʼ��waypoints����
    totalPoints = numLines * 2;  % ÿ�����������յ�
    waypoints = zeros(totalPoints, 4);

    % ���ݷ���������״·��
    if strcmp(direction, 'x')
        % X������״·������ֱ��Y�ᣩ
        for i = 1:numLines
            if mod(i,2) == 1  % �����ߣ�������
                % ��˵�
                waypoints(2*i-1,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,0,radius];
                % �Ҷ˵�
                waypoints(2*i,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,0,radius];
            else  % ż���ߣ����ҵ���
                % �Ҷ˵�
                waypoints(2*i-1,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,pi,radius];
                % ��˵�
                waypoints(2*i,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,pi,radius];
            end
        end
    else
        % Y������״·������ֱ��X�ᣩ
        for i = 1:numLines
            if mod(i,2) == 1  % �����ߣ����µ���
                % �¶˵�
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),pi/2,radius];
                % �϶˵�
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,pi/2,radius];
            else  % ż���ߣ����ϵ���
                % �϶˵�
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,-pi/2,radius];
                % �¶˵�
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),-pi/2,radius];
            end
        end
    end
    
    % ����·���ܳ���
    totalLength = 0;
    for i = 1:size(waypoints,1)-1
        totalLength = totalLength + norm(waypoints(i+1,:) - waypoints(i,:));
    end
    
    % ����״̬���޸����ʹ����ȷ����������
    app.TotalLengthLabelandTCP.Text = sprintf('��·������: %.1f ��', totalLength);
    app.StatusLabel.Text = '�����ɹ滮·�����ݣ�';
    app.StatusLabel.FontColor = [0 0.5 0];
end
