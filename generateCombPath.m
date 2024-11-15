function waypoints = generateCombPath(startPoint, lineSpacing, pathWidth, numLines, direction)
    % 初始化waypoints数组
    totalPoints = numLines * 2;  % 每条线有起点和终点
    waypoints = zeros(totalPoints, 2);

    % 根据方向生成梳状路径
    if strcmp(direction, 'x')
        % X方向梳状路径（垂直于Y轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从左到右
                % 左端点
                waypoints(2*i-1,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing];
                % 右端点
                waypoints(2*i,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing];
            else  % 偶数线，从右到左
                % 右端点
                waypoints(2*i-1,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing];
                % 左端点
                waypoints(2*i,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing];
            end
        end
    else
        % Y方向梳状路径（垂直于X轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从下到上
                % 下端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2)];
                % 上端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth];
            else  % 偶数线，从上到下
                % 上端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth];
                % 下端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2)];
            end
        end
    end
end