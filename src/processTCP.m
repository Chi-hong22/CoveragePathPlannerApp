%% processTCP - 通过TCP协议发送JSON数据
%
% 功能描述：
%   该函数用于通过TCP协议发送处理后的JSON数据到指定的服务器。
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
%       + 实现基础的TCP数据发送功能
%       + 添加基本的错误处理和状态反馈
%
% 输入参数：
%   app         - [object] MATLAB App对象，包含UI控件和状态信息
%   jsonData    - [string] 处理后的路径数据，JSON格式
%
% 输出参数：
%   statusTCP   - [logical] 数据发送的状态（true表示成功，false表示失败）
%   errorMessage - [string] 如果数据发送失败，返回错误信息
%
% 注意事项：
%   1. 确保目标服务器IP地址和端口正确且服务器处于开启状态
%   2. 函数会禁用发送按钮，直到操作完成或失败
%
% 调用示例：
%   % 示例1：基础调用
%   [statusTCP, errorMessage] = processTCP(app, jsonData);
%
% 依赖工具箱：
%   - MATLAB App Designer
%   - Instrument Control Toolbox (tcpclient函数)
%
% 参见函数：
%   tcpclient, flush, write

function [statusTCP, errorMessage] = processTCP(app, jsonData)

    % 获取TCP设置
    serverIP = app.ServerIPEditField.Value;
    port = app.PortEditField.Value;

    if isempty(serverIP) || isempty(port)
        app.TotalLengthLabelandTCP.Text = '请输入有效的IP地址和端口';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        statusTCP = false;
        return;
    end

    try
        % 显示连接中状态
        app.TotalLengthLabelandTCP.Text = '正在尝试连接...';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0.8 0];
        drawnow; % 立即更新UI

        % 设置10秒超时
        client = tcpclient(serverIP, port, 'Timeout', 10, 'ConnectTimeout', 10);
        % 连接成功
        app.TotalLengthLabelandTCP.Text = 'TCP连接成功';
        app.TotalLengthLabelandTCP.FontColor = [0 0.5 0];

        % 发送数据
        flush(client);
        write(client, jsonData, 'string');
        % 更新状态
        app.statusTCPLabel.Text = '规划路径数据发送成功！';
        app.statusTCPLabel.FontColor = [0 0.5 0];
        statusTCP = true;
        errorMessage = '';
    catch tcpErr
        % 区分超时和其他错误
        if contains(tcpErr.message, 'Timeout') || contains(tcpErr.message, 'timed out')
            errorMessage = '连接超时，请检查目标设备是否开启';
        else
            errorMessage = sprintf('TCP连接失败: %s\n请检查IP地址和端口设置', tcpErr.message);
        end
        app.TotalLengthLabelandTCP.Text = errorMessage;
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        statusTCP = false;
    end
end