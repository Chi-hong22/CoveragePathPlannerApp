%% obstacleMarking - 地形障碍物检测与标记工具
%
% 功能描述：
%   从地形高度图中检测障碍物，并计算每个障碍物的最小外接圆。包括数据加载、
%   障碍物检测、外接圆计算和可视化展示等功能。适用于AUV避障路径规划。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 版本历史：
%   v1.1 (250110)
%       + 优化障碍物检测算法
%       + 改进可视化显示效果
%       + 添加数据存储功能
%   v1.0 (241101)
%       + 首次发布
%       + 实现基础障碍物检测
%       + 添加最小外接圆计算
%
% 输入参数：
%   app - [object] AUVCoveragePathPlannerApp实例
%         必选参数，包含UI组件和数据
%
% 输出参数：
%   无直接返回值，结果保存至circlesInformation.mat文件
%   文件包含结构：
%   - circlesInfo: [nx3 double] 障碍物圆形信息
%     [centerX, centerY, radius]
%
% 注意事项：
%   1. 数据要求：需要terrainHeightMap_feed8_2000.mat文件
%   2. 内存消耗：与地形图大小和障碍物数量成正比
%   3. 阈值设置：默认阈值3.2米，可根据实际需求调整
%   4. 存储路径：结果保存在项目data目录下
%
% 调用示例：
%   % 在APP中调用
%   app = AUVCoveragePathPlannerApp;
%   obstacleMarking(app);
%
% 依赖函数：
%   - bwlabel
%   - regionprops
%   - imagesc
%
% 参见函数：
%   generateCombPath, plotObstacles

function obstacleMarking(app)

    % 加载.mat文件中的数据
    try
        loadedData = load('terrainHeightMap_feed8_2000.mat');
        % 从结构体中提取 terrainHeightMap
        heightData = loadedData.terrainHeightMap;
        % 将提取的数据保存到工作区
        assignin('base', 'terrainHeightMap', heightData);
    catch ME
        errordlg(['无法加载或处理数据: ' ME.message], '错误');
        return;
    end

    % 定义障碍物阈值（根据你的具体需求设定）
    threshold = 3.2; % 你可以调整这个值

    % 创建障碍物地图
    obstacleMap = heightData > threshold;

    % 将障碍物地图转换为二值图像
    obstacleBW = double(obstacleMap);

    % 标记连通区域（每个障碍物）
    [L, numObstacles] = bwlabel(obstacleBW);

    % 初始化用于存储所有圆心坐标和半径的数组
    centers = zeros(numObstacles, 2);
    radii = zeros(numObstacles, 1);

    % 清除当前图窗
    cla(app.UIAxes3);
    
    % 绘制高度数据
    imagesc(app.UIAxes3, heightData);

    % 保持当前图形，以便在上面添加其他元素
    hold(app.UIAxes3, 'on');

    % 添加标题
    title(app.UIAxes3, '地形图及障碍物标注');

    % 添加颜色条
    colorbar(app.UIAxes3);
    colormap(app.UIAxes3, 'jet'); % 使用 'jet' 色彩映射
    caxis(app.UIAxes3, [-30 30]);
    % 设置坐标轴比例为相等
    axis(app.UIAxes3, 'equal');


    for i = 1:numObstacles
        % 提取当前障碍物区域的所有点
        [rows, cols] = find(L == i);
        
        % 计算最小外接圆 (初始估算)
        stats = regionprops(L == i, 'Centroid', 'MajorAxisLength');
        center = stats.Centroid;
        radius = stats.MajorAxisLength / 2; % 使用主轴长度的一半作为半径估计
        
        % 检查并调整半径，确保所有点都在圆内
        for j = 1:length(rows)
            distance = sqrt((cols(j) - center(1))^2 + (rows(j) - center(2))^2);
            if distance > radius
                radius = distance;
            end
        end
        
        % 存储当前圆的信息
        centers(i, :) = center;
        radii(i) = radius;
        
        % 绘制当前圆
        th = linspace(0, 2*pi, 100);
        x_circle = center(1) + radius * cos(th);
        y_circle = center(2) + radius * sin(th);
        plot(app.UIAxes3,x_circle, y_circle, 'r-', 'LineWidth', 2); % 绘制圆周
        plot(app.UIAxes3,center(1), center(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2); % 绘制圆心
    end

    hold(app.UIAxes3,'on');
    for i = 1:numObstacles
        % 再次绘制所有圆
        th = linspace(0, 2*pi, 100);
        x_circle = centers(i, 1) + radii(i) * cos(th);
        y_circle = centers(i, 2) + radii(i) * sin(th);
        plot(app.UIAxes3,x_circle, y_circle, 'r-', 'LineWidth', 2); % 绘制圆周
        plot(app.UIAxes3,centers(i, 1), centers(i, 2), 'r+', 'MarkerSize', 10, 'LineWidth', 2); % 绘制圆心
    end


    % 创建一个矩阵用于保存每个圆的信息
    % 每一行表示一个圆：[CenterX, CenterY, Radius]
    circlesInfo = zeros(numObstacles, 3);

    for i = 1:numObstacles
        % 将当前圆的信息添加到矩阵中
        circlesInfo(i, :) = [centers(i, 1), centers(i, 2), radii(i)];
    end

    % 将circlesInfo变量保存到工作区，供其他函数直接调用
    assignin('base', 'circlesInfo', circlesInfo);

    app.PlanPathsButton.Enable = 'on';  

end
