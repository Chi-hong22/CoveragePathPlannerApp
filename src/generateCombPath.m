    %% generateCombPath - 生成梳状路径
    %
    % 功能描述：
    %   此函数用于生成AUV的梳状覆盖路径。根据给定的起始点、线间距、路径宽度、线条数量、方向和转弯半径，
    %   生成路径点并计算总路径长度。
    %
    % 输入参数：
    %   app - AUVCoveragePathPlannerApp的实例
    %   start_point - 起始点坐标 [x, y]
    %   line_spacing - 梳状齿间距
    %   path_width - 路径宽度
    %   num_lines - 梳状路径数量
    %   direction - 路径方向 ('x' 或 'y')
    %   radius - 转弯半径
    %
    % 输出参数：
    %   waypoints - 生成的路径点数组
    %
    % 注意事项：
    %   1. 确保所有输入参数有效且格式正确。
    %   2. 该函数会更新UI界面中的标签。
    %
    % 版本信息：
    %   版本：v1.2
    %   创建日期：241101
    %   最后修改：250316
    % 版本历史：
    %   v1.0 (241101) - 初始版本
    %   v1.1 (250110) - 优化代码
    %   v1.2 (250316) - 修改direction参数无效的情况
    %
    % 作者信息：
    %   作者：游子昂
    %   邮箱：you.ziang@hrbeu.edu.cn
    %   单位：哈尔滨工程大学

function waypoints = generateCombPath(app, startPoint, lineSpacing, pathWidth, numLines, direction,radius)
    % 删除方向参数中的所有空格
    direction = strrep(direction, ' ', '');
    
    % 初始化waypoints数组
    totalPoints = numLines * 2;  % 每条线有起点和终点
    waypoints = zeros(totalPoints, 4);

    % 根据方向生成梳状路径
    if strcmp(direction, 'x')
        % X方向梳状路径（垂直于Y轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从左到右
                % 左端点
                waypoints(2*i-1,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,0,radius];
                % 右端点
                waypoints(2*i,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,0,radius];
            else  % 偶数线，从右到左
                % 右端点
                waypoints(2*i-1,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,pi,radius];
                % 左端点
                waypoints(2*i,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,pi,radius];
            end
        end
    else
        % Y方向梳状路径（垂直于X轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从下到上
                % 下端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),pi/2,radius];
                % 上端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,pi/2,radius];
            else  % 偶数线，从上到下
                % 上端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,-pi/2,radius];
                % 下端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),-pi/2,radius];
            end
        end
    end
    
    % 计算路径总长度
    totalLength = 0;
    for i = 1:size(waypoints,1)-1
        totalLength = totalLength + norm(waypoints(i+1,:) - waypoints(i,:));
    end
    
    % 更新状态（修改这里，使用正确的属性名）
    app.TotalLengthLabelandTCP.Text = sprintf('总路径长度: %.1f 米', totalLength);
    app.StatusLabel.Text = '已生成规划路径数据！';
    app.StatusLabel.FontColor = [0 0.5 0];
end
