%% sendPathDataViaTCP - 通过TCP协议发送路径数据
%
% 功能描述：
%   该函数用于将路径数据通过TCP协议发送到指定的服务器。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.0
%   创建日期：250328
%   最后修改：250329
%
% 版本历史：
%   v1.0 (250329) - 首次发布
%       + 实现基础的TCP数据发送功能
%       + 添加基本的错误处理和状态反馈
%
% 输入参数：
%   app         - [object] MATLAB App对象，包含UI控件和状态信息
%   pathData    - [double array] 路径数据矩阵，行数为路径点数量，列数为2或4
%   buttonName  - [string] 触发发送操作的按钮名称
%
% 输出参数：
%   无直接返回值，处理结果通过TCP连接发送到目标服务器，并在UI中显示状态信息
%
% 注意事项：
%   1. 确保目标服务器IP地址和端口正确且服务器处于开启状态
%   2. 路径数据的列数必须为2或4，否则会抛出错误
%   3. 上浮点和下潜点的索引必须在路径点数量范围内
%   4. 函数会禁用发送按钮，直到操作完成或失败
%
% 调用示例：
%   % 示例1：基础调用
%   sendPathDataViaTCP(app, pathData, 'SendButton');
%
% 依赖工具箱：
%   - MATLAB App Designer
%   - Instrument Control Toolbox (tcpclient函数)
%
% 参见函数：
%   processPathData,processTCP

function sendPathDataViaTCP(app, pathData, buttonName)
    % 禁用按钮
    app.(buttonName).Enable = false;

    % 数据处理
    [jsonData, statusTCP, ~] = processPathData(app, pathData);
    if ~statusTCP
        app.(buttonName).Enable = true;
        return;
    end

    % TCP发送
    [statusData, ~] = processTCP(app, jsonData);
    if ~statusData
        app.(buttonName).Enable = true;
        return;
    end

end