% 发送局部路径规划数据到AUV
%
% 功能描述：
%   根据设置的服务器IP和端口，将局部路径规划数据发送到AUV设备。
%
% 输入参数：
%   app - AUVCoveragePathPlannerApp实例
%
% 输出参数：
%   无直接返回值，发送结果通过UI界面显示
%
% 注意事项：
%   1. 请确保服务器IP和端口设置正确，且AUV设备已连接。
%   2. 发送过程中，按钮将被禁用，发送完成后恢复可用状态。
%   3. 本函数读取本地CSV文件，文件名固定为'result_no_duplicates.csv'。
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：20241101
%   最后修改：20241101
%
% 作者信息：
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function sendDubinsTCPData(app)
    % 获取TCP设置
    serverIP = app.ServerIPEditField.Value;
    port = app.PortEditField.Value;
    app.SendTCPButton.Enable = false;

    if isempty(serverIP) || isempty(port)
        app.TotalLengthLabelandTCP.Text = '请输入有效的IP地址和端口';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end

    % 显示连接中状态
    app.TotalLengthLabelandTCP.Text = '正在尝试连接...';
    app.TotalLengthLabelandTCP.FontColor = [0.8 0.8 0];
    drawnow; % 立即更新UI

    % 设置10秒超时
    try
        client = tcpclient(serverIP, port, 'Timeout', 10, 'ConnectTimeout', 10);
        
        % 连接成功
        app.TotalLengthLabelandTCP.Text = 'TCP连接成功';
        app.TotalLengthLabelandTCP.FontColor = [0 0.5 0];
    catch tcpErr
        % 区分超时和其他错误
        if contains(tcpErr.message, 'Timeout') || contains(tcpErr.message, 'timed out')
            app.TotalLengthLabelandTCP.Text = '连接超时，请检查目标设备是否开启';
        else
            app.TotalLengthLabelandTCP.Text = sprintf('TCP连接失败: %s\n请检查IP地址和端口设置', tcpErr.message);
        end
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end

    % 获取工作区中的路径数据
    try
        result_no_duplicates = evalin('base', 'result_no_duplicates');
    catch
        app.TotalLengthLabelandTCP.Text = '获取result_no_duplicates路径数据失败';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end

    % 获取初始位置和姿态角
    try
        %获取卡舵序号和卡舵状态
        Kdelta=[app.Kdelta1EditField.Value,app.Kdelta2EditField.Value,app.Kdelta3EditField.Value,app.Kdelta4EditField.Value];
        Delta=[app.Delta1EditField.Value,app.Delta2EditField.Value,app.Delta3EditField.Value,app.Delta4EditField.Value];
        %获取期望速度，掉深时间和急停时间
        ud=app.udEditField.Value;
        Td=app.TdEditField.Value;
        Tj=app.TjEditField.Value;
        % 获取初始位置和姿态角
        P0 = [app.P0XEditField.Value, app.P0YEditField.Value, app.P0ZEditField.Value];
        A0 = [app.A0XEditField.Value, app.A0YEditField.Value, app.A0ZEditField.Value];

        %获取IP
        hostIP=app.hostIPEditField.Value;
        hPort=app.hPortEditField.Value;

        % 获取路径点数量和处理Z坐标
        WPNum = size(result_no_duplicates, 1);
        numColumns = size(result_no_duplicates, 2);

        % 根据列数进行不同的操作
        if numColumns == 4
            result_no_duplicates(:, 3:4) = [];
            column_of_z = app.ZEditField.Value * ones(size(result_no_duplicates, 1), 1);
            result_no_duplicates = [result_no_duplicates, column_of_z];
        elseif numColumns == 2
            column_of_z = app.ZEditField.Value * ones(size(result_no_duplicates, 1), 1);
            result_no_duplicates = [result_no_duplicates, column_of_z];
        else
            error('路径数据的列数必须是2或4');
        end


        %%上浮索引
        upinputStr = app.upEditField.Value;
        % 将字符串转换为数值向量
        try
            upvector = str2num(upinputStr); % 使用 str2num 将字符串转换为数值
        catch
            uialert(app.UIFigure, '输入格式错误，请输入逗号或空格分隔的数字。', '错误');

        end
        
        for i = 1:length(upvector)
            rowIdx = upvector(i); % 获取行索引
            if rowIdx <= size(result_no_duplicates, 1) % 检查行索引是否有效
                result_no_duplicates(rowIdx, 3) = app.DupEditField.Value; % 更新第三列
            else
                app.TotalLengthLabelandTCP.Text = '上浮点/下潜点索引超出总航程';
            end
        end
        up=upvector(1);%初始上浮点索引

        %%下潜索引
        downinputStr = app.downEditField.Value;
        try
            downvector = str2num(downinputStr); % 使用 str2num 将字符串转换为数值
        catch
            uialert(app.UIFigure, '输入格式错误，请输入逗号或空格分隔的数字。', '错误');
        end
        
        for i = 1:length(downvector)
            rowIdx = downvector(i); % 获取行索引
            if rowIdx <= size(result_no_duplicates, 1) % 检查行索引是否有效
                result_no_duplicates(rowIdx, 3) = app.DdownEditField.Value; % 更新第三列
            else
                app.TotalLengthLabelandTCP.Text = '上浮点/下潜点索引超出总航程';
            end
        end
        down=downvector(1);%初始下潜点索引

        z=app.ZEditField.Value;%设置深度


        % 保持原有的assignin语句
        assignin('base','z',z);
        assignin('base',"Waypoints",result_no_duplicates);
        assignin('base','WPNum',WPNum);
        assignin('base','P0',P0);
        assignin('base','A0',A0);
        assignin('base','Kdelta',Kdelta);
        assignin('base','Delta',Delta);
        assignin('base','ud',ud);
        assignin('base',"Td",Td);
        assignin('base',"Tj",Tj);
        assignin('base','up',up);
        assignin('base',"down",down);

        % 创建数据结构
        dataStruct = struct('Waypoints', result_no_duplicates, ...
            'WPNum', WPNum, ...
            'P0', P0, ...
            'A0', A0, ...
            'Kdelta',Kdelta, ...
            'Delta',Delta, ...
            'ud',ud, ...
            'Td',Td, ...
            'Tj',Tj, ...
            'up',up, ...
            'down',down, ...
            'z',z, ...
            'hostIP',hostIP, ...
            'hPort',hPort);
        % 转换为JSON
        jsonData = jsonencode(dataStruct);
    catch dataErr
        app.TotalLengthLabelandTCP.Text = ['数据准备失败: ', dataErr.message];   
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end
    
    % 发送数据
    try
        flush(client);
        write(client, jsonData, 'string');
        % 更新状态
        app.StatusLabel.Text = '规划路径数据发送成功！';
        app.StatusLabel.FontColor = [0 0.5 0];
    catch writeErr
        app.StatusLabel.Text = ['数据发送失败: %s', writeErr.message];
        app.StatusLabel.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end
    app.SendTCPButton.Enable = true;
    
end