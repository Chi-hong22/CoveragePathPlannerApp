%% obstacleMarking - �����ϰ��������ǹ���
%
% ����������
%   �ӵ��θ߶�ͼ�м���ϰ��������ÿ���ϰ������С���Բ���������ݼ��ء�
%   �ϰ����⡢���Բ����Ϳ��ӻ�չʾ�ȹ��ܡ�������AUV����·���滮��
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ���ߣ�������
%   ���䣺1443123118@qq.com
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.1
%   �������ڣ�241101
%   ����޸ģ�250110
%
% �汾��ʷ��
%   v1.1 (250110)
%       + �Ż��ϰ������㷨
%       + �Ľ����ӻ���ʾЧ��
%       + ������ݴ洢����
%   v1.0 (241101)
%       + �״η���
%       + ʵ�ֻ����ϰ�����
%       + �����С���Բ����
%
% ���������
%   app - [object] AUVCoveragePathPlannerAppʵ��
%         ��ѡ����������UI���������
%
% ���������
%   ��ֱ�ӷ���ֵ�����������circlesInformation.mat�ļ�
%   �ļ������ṹ��
%   - circlesInfo: [nx3 double] �ϰ���Բ����Ϣ
%     [centerX, centerY, radius]
%
% ע�����
%   1. ����Ҫ����ҪterrainHeightMap_feed8_2000.mat�ļ�
%   2. �ڴ����ģ������ͼ��С���ϰ�������������
%   3. ��ֵ���ã�Ĭ����ֵ3.2�ף��ɸ���ʵ���������
%   4. �洢·���������������ĿdataĿ¼��
%
% ����ʾ����
%   % ��APP�е���
%   app = AUVCoveragePathPlannerApp;
%   obstacleMarking(app);
%
% ����������
%   - bwlabel
%   - regionprops
%   - imagesc
%
% �μ�������
%   generateCombPath, plotObstacles

function obstacleMarking(app)

    % ����.mat�ļ��е�����
    try
        loadedData = load('terrainHeightMap_feed8_2000.mat');
        % �ӽṹ������ȡ terrainHeightMap
        heightData = loadedData.terrainHeightMap;
        % ����ȡ�����ݱ��浽������
        assignin('base', 'terrainHeightMap', heightData);
        
        % ����������ʾ�ĸ߶����ݣ���z���������5��
        heightData_display = heightData - 5;
    catch ME
        errordlg(['�޷����ػ�������: ' ME.message], '����');
        return;
    end

    % �����ϰ�����ֵ��������ľ��������趨��
    threshold = 3.2; % ����Ե������ֵ

    % �����ϰ����ͼ (ʹ��ԭʼheightData�����ж�)
    obstacleMap = heightData > threshold;

    % ���ϰ����ͼת��Ϊ��ֵͼ��
    obstacleBW = double(obstacleMap);

    % �����ͨ����ÿ���ϰ��
    [L, numObstacles] = bwlabel(obstacleBW);

    % ��ʼ�����ڴ洢����Բ������Ͱ뾶������
    centers = zeros(numObstacles, 2);
    radii = zeros(numObstacles, 1);

    % �����ǰͼ��
    cla(app.UIAxes3);
    
    % ���Ƹ߶����� (ʹ�ô�����heightData_display������ʾ)
    imagesc(app.UIAxes3, heightData_display);

    % ���ֵ�ǰͼ�Σ��Ա��������������Ԫ��
    hold(app.UIAxes3, 'on');

    % ��ӱ���
    title(app.UIAxes3, '����ͼ���ϰ����ע');

    % �����ɫ��������λ��
    c = colorbar(app.UIAxes3);
    c.Position(1) = c.Position(1) + 0.08;  % �����ƶ�
    c.Position(3) = 0.02;                 % ���ÿ��
    % c.Limits = [-25 0];                    % ������ɫ����ʾ��Χ
    colormap(app.UIAxes3, 'parula');
    caxis(app.UIAxes3, [-30 0]);          % ����������ʾ��Χ

    % �������������Ϊ���
    axis(app.UIAxes3, 'equal');


    for i = 1:numObstacles
        % ��ȡ��ǰ�ϰ�����������е�
        [rows, cols] = find(L == i);
        
        % ������С���Բ (��ʼ����)
        stats = regionprops(L == i, 'Centroid', 'MajorAxisLength');
        center = stats.Centroid;
        radius = stats.MajorAxisLength / 2; % ʹ�����᳤�ȵ�һ����Ϊ�뾶����
        
        % ��鲢�����뾶��ȷ�����е㶼��Բ��
        for j = 1:length(rows)
            distance = sqrt((cols(j) - center(1))^2 + (rows(j) - center(2))^2);
            if distance > radius
                radius = distance;
            end
        end
        
        % �洢��ǰԲ����Ϣ
        centers(i, :) = center;
        radii(i) = radius;
        
        % ���Ƶ�ǰԲ
        th = linspace(0, 2*pi, 100);
        x_circle = center(1) + radius * cos(th);
        y_circle = center(2) + radius * sin(th);
        plot(app.UIAxes3,x_circle, y_circle, 'r-', 'LineWidth', 2); % ����Բ��
        plot(app.UIAxes3,center(1), center(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2); % ����Բ��
    end

    hold(app.UIAxes3,'on');
    for i = 1:numObstacles
        % �ٴλ�������Բ
        th = linspace(0, 2*pi, 100);
        x_circle = centers(i, 1) + radii(i) * cos(th);
        y_circle = centers(i, 2) + radii(i) * sin(th);
        plot(app.UIAxes3,x_circle, y_circle, 'r-', 'LineWidth', 2); % ����Բ��
        plot(app.UIAxes3,centers(i, 1), centers(i, 2), 'r+', 'MarkerSize', 10, 'LineWidth', 2); % ����Բ��
    end


    % ����һ���������ڱ���ÿ��Բ����Ϣ
    % ÿһ�б�ʾһ��Բ��[CenterX, CenterY, Radius]
    circlesInfo = zeros(numObstacles, 3);

    for i = 1:numObstacles
        % ����ǰԲ����Ϣ��ӵ�������
        circlesInfo(i, :) = [centers(i, 1), centers(i, 2), radii(i)];
    end

    % ��circlesInfo�������浽������������������ֱ�ӵ���
    assignin('base', 'circlesInfo', circlesInfo);

    app.PlanLocalPathsButton.Enable = 'on';  

end
