function generatePath(app)
    % 生成路径
    %
    % 功能描述：
    %   此函数用于从GUI中收集参数，并调用路径生成函数生成AUV的梳状覆盖路径。
    %   生成的路径将在UI界面中显示，并计算总路径长度。
    %
    % 输入参数：
    %   app - AUVCoveragePathPlannerApp的实例
    %
    % 输出参数：
    %   无直接输出，结果通过UI界面显示
    %
    % 注意事项：
    %   1. 确保所有输入参数有效且格式正确。
    %   2. 该函数会更新UI界面中的按钮状态和标签。
    %
    % 版本信息：
    %   版本：v1.1
    %   创建日期：241101
    %   最后修改：250110
    %
    % 作者信息：
    %   作者：游子昂
    %   邮箱：you.ziang@hrbeu.edu.cn
    %   单位：哈尔滨工程大学
    startPoint = [app.XEditField.Value, app.YEditField.Value];
    lineSpacing = app.LineSpacingEditField.Value;
    pathWidth = app.PathWidthEditField.Value;
    numLines = app.NumLinesEditField.Value;
    radius= app.dubinsradiusEditField.Value;
    direction = lower(app.DirectionDropDown.Value);
    
    % 调用路径生成函数
    try
        % 清除当前axes
        cla(app.UIAxes1);
        
        % 生成路径
        app.Waypoints = generateCombPath(app, startPoint, lineSpacing, pathWidth, numLines, direction,radius);
        
        % 将路径点保存到基础工作区
        assignin('base', 'Waypoints', app.Waypoints);
        
        % 手动绘制路径
        plot(app.UIAxes1, app.Waypoints(:,1), app.Waypoints(:,2), 'b-', 'LineWidth', 2);
        hold(app.UIAxes1, 'on');
        
        % 绘制路径点
        plot(app.UIAxes1, app.Waypoints(:,1), app.Waypoints(:,2), 'bo', 'MarkerSize', 6);
        
        % 绘制起点（绿色方块）
        plot(app.UIAxes1, app.Waypoints(1,1), app.Waypoints(1,2), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % 绘制终点（红色方块）
        plot(app.UIAxes1, app.Waypoints(end,1), app.Waypoints(end,2), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
        
        % 计算总长度
        totalLength = 0;
        for i = 1:size(app.Waypoints,1)-1
            totalLength = totalLength + norm(app.Waypoints(i+1,:) - app.Waypoints(i,:));
        end
        
        % 更新总长度标签
        app.TotalLengthLabelandTCP.Text = sprintf('总路径长度: %.1f 米', totalLength);
        
        % 设置图形属性
        grid(app.UIAxes1, 'on');
        xlabel(app.UIAxes1, 'X轴 (米)');
        ylabel(app.UIAxes1, 'Y轴 (米)');
        title(app.UIAxes1, sprintf('AUV梳状覆盖路径规划图 (%s方向)', upper(direction)));
        legend(app.UIAxes1, '路径', '路径点', '起点', '终点');
        axis(app.UIAxes1, 'equal');
        hold(app.UIAxes1, 'off');
        
        % 启用按钮
        app.ExportGlobalWaypointsButton.Enable = 'on';
        app.SendGlobalPathsButton.Enable = 'on';
        
    catch ME
        % 错误处理
        errordlg(['路径生成错误: ' ME.message], '错误');
    end
    % app.PlanLocalPathsButton.Enable = 'off';  
    % app.SendLocalPathsButton.Enable = 'off';
    % app.GenerateButton.Enable = 'off';
end