%% processPathData - 处理路径数据并转换为JSON格式
%
% 功能描述：
%   该函数用于处理路径数据，并将处理后的数据转换为JSON格式。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.0
%   创建日期：250329
%   最后修改：250329
%
% 版本历史：
%   v1.0 (250329) - 首次发布
%       + 实现路径数据的处理功能
%       + 添加基本的错误处理和状态反馈
%
% 输入参数：
%   app         - [object] MATLAB App对象，包含UI控件和状态信息
%   pathData    - [double array] 路径数据矩阵，行数为路径点数量，列数为2或4
%
% 输出参数：
%   jsonData    - [string] 处理后的路径数据，JSON格式
%   statusData  - [logical] 数据处理的状态（true表示成功，false表示失败）
%   errorMessage - [string] 如果数据处理失败，返回错误信息
%
% 注意事项：
%   1. 路径数据的列数必须为2或4，否则会抛出错误
%   2. 上浮点和下潜点的索引必须在路径点数量范围内
%   3. 函数会禁用发送按钮，直到操作完成或失败
%
% 调用示例：
%   % 示例1：基础调用
%   [jsonData, statusData, errorMessage] = processPathData(app, pathData);
%
% 依赖工具箱：
%   - MATLAB App Designer
%
% 参见函数：
%   jsonencode, assignin
function [jsonData, statusData, errorMessage] = processPathData(app, pathData)
    try
        % 获取卡舵序号和卡舵状态
        Kdelta = [app.Kdelta1EditField.Value, app.Kdelta2EditField.Value, app.Kdelta3EditField.Value, app.Kdelta4EditField.Value];
        Delta = [app.Delta1EditField.Value, app.Delta2EditField.Value, app.Delta3EditField.Value, app.Delta4EditField.Value];
        % 获取期望速度，掉深时间和急停时间
        ud = app.udEditField.Value;
        Td = app.TdEditField.Value;
        Tj = app.TjEditField.Value;

        % 获取初始位置和姿态角
        P0 = [app.P0XEditField.Value, app.P0YEditField.Value, app.P0ZEditField.Value];
        A0 = [app.A0XEditField.Value, app.A0YEditField.Value, app.A0ZEditField.Value];

        % 获取IP
        hostIP = app.hostIPEditField.Value;
        hPort = app.hPortEditField.Value;

        % 获取路径点数量和处理Z坐标
        WPNum = size(pathData, 1);
        numColumns = size(pathData, 2);

        % 根据列数进行不同的操作
        if numColumns == 4
            % 如果有 4 列，删除第 3 列和第 4 列
            pathData(:, 3:4) = [];
            % 补充一列 Z 坐标
            column_of_z = app.ZEditField.Value * ones(size(pathData, 1), 1);
            pathData = [pathData, column_of_z];
        elseif numColumns == 2
            % 如果有 2 列，补充一列 Z 坐标
            column_of_z = app.ZEditField.Value * ones(size(pathData, 1), 1);
            pathData = [pathData, column_of_z];
        else
            % 如果列数不是 2 或 4，抛出错误或提示
            error('路径数据的列数必须是2或4');
        end

        % 上浮索引
        upinputStr = app.upEditField.Value;
        try
            upvector = str2num(upinputStr); % 使用 str2num 将字符串转换为数值
        catch
            uialert(app.UIFigure, '输入格式错误，请输入逗号或空格分隔的数字。', '错误');
        end

        for i = 1:length(upvector)
            rowIdx = upvector(i); % 获取行索引
            if rowIdx <= size(pathData, 1) % 检查行索引是否有效
                pathData(rowIdx, 3) = app.DupEditField.Value; % 更新第三列
            else
                app.TotalLengthLabelandTCP.Text = '上浮点/下潜点索引超出总航程';
                app.TotalLengthLabelandTCP.FontColor = [0 0 0.8];
            end
        end
        up = upvector(1); % 初始上浮点索引

        % 下潜索引
        downinputStr = app.downEditField.Value;
        try
            downvector = str2num(downinputStr); % 使用 str2num 将字符串转换为数值
        catch
            uialert(app.UIFigure, '输入格式错误，请输入逗号或空格分隔的数字。', '错误');
        end

        for i = 1:length(downvector)
            rowIdx = downvector(i); % 获取行索引
            if rowIdx <= size(pathData, 1) % 检查行索引是否有效
                pathData(rowIdx, 3) = app.DdownEditField.Value; % 更新第三列
            else
                app.TotalLengthLabelandTCP.Text = '上浮点/下潜点索引超出总航程';
                app.TotalLengthLabelandTCP.FontColor = [0 0 0.8];
            end
        end
        down = downvector(1); % 初始下潜点索引

        % 锚定点索引
        anchor = app.anchorEditField.Value;
        anchorvector = str2num(anchor);
        z_sorted = sort(anchorvector, 'descend');
        valid_z = z_sorted(z_sorted <= size(pathData, 1));
        z_sorted = valid_z;

        for row = z_sorted
            current_row = pathData(row, :);
            pathData = [pathData(1:row, :);
                repmat(current_row, 2, 1);
                pathData(row+1:end, :)];
        end
        % 锚定时长
        tm=app.TanchorEditField.Value;

        WPNum = size(pathData, 1);
        z = app.ZEditField.Value; % 设置深度

        % 保持原有的assignin语句
        assignin('base', 'z', z);
        assignin('base', "Waypoints", pathData);
        assignin('base', 'WPNum', WPNum);
        assignin('base', 'P0', P0);
        assignin('base', 'A0', A0);
        assignin('base', 'Kdelta', Kdelta);
        assignin('base', 'Delta', Delta);
        assignin('base', 'ud', ud);
        assignin('base', "Td", Td);
        assignin('base', "Tj", Tj);
        assignin('base', 'up', up);
        assignin('base', "down", down);
        assignin('base', "tm", tm);

        % 创建数据结构
        dataStruct = struct('Waypoints', pathData, ...
                            'WPNum', WPNum, ...
                            'P0', P0, ...
                            'A0', A0, ...
                            'Kdelta', Kdelta, ...
                            'Delta', Delta, ...
                            'ud', ud, ...
                            'Td', Td, ...
                            'Tj', Tj, ...
                            'up', up, ...
                            'down', down, ...
                            'z', z, ...
                            'hostIP', hostIP, ...
                            'hPort', hPort, ...
                            'tm',tm);
        % 转换为JSON
        jsonData = jsonencode(dataStruct);
        statusData = true;
        errorMessage = '';
    catch dataErr
        jsonData = '';
        statusData = false;
        errorMessage = ['发送数据准备失败: ', dataErr.message];
        app.TotalLengthLabelandTCP.Text = errorMessage;
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
    end
end