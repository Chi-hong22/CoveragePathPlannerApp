%% startOperabilitySimulation - AUV 操作性仿真启动函数
%
% 功能描述：
%   该函数用于启动 AUV 的操作性仿真，根据用户输入的舵角、期望速度和仿真时间，
%   模拟 AUV 在不同操作条件下的运动行为。仿真结果可用于评估 AUV 的操纵性能和
%   控制系统的响应特性。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%   作者：陶奥飞
%   邮箱：taoaofei@gmail.com
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.0
%   创建日期：250328
%
% 版本历史：
%   v1.0 (250328) - 初始版本，实现基本仿真功能
%
% 输入参数：
%   app - [object] 应用对象
%       通过GUI界面传递，包含以下可调用接口：
%       1. 四个舵角的值
%          app.Rudder1EditField.Value
%          app.Rudder2EditField.Value
%          app.Rudder3EditField.Value
%          app.Rudder4EditField.Value
%       2. 期望速度
%          app.DesiredSpeedEditField.Value
%       3. 仿真时间
%          app.SimulationTimeEditField.Value
%
% 输出参数：
%   无直接返回值，仿真结果将通过图形界面显示或保存到指定文件中。
%
% 注意事项：
%   1. 数据处理与TCP发送的调用方式在代码正文中有说明。
%   2. 注意pathData的格式与内容，必须为一个二维矩阵，行数为路径点数量，列数为2或4。
%   3. 
%
% 调用方法：
%   app.StartOperabilitySimulationButton.ButtonPushedFcn = @(~,~) startOperabilitySimulation(app);
%
% 依赖工具箱：
%   - MATLAB 基础工具箱
%   - Simulink 仿真工具箱（可选）
%
% 参见函数：
%   sendPathDataViaTCP,processPathData,processTCP

function startOperabilitySimulation(app)

    % 调用统一函数发送数据
    sendPathDataViaTCP(app, pathData, 'StartOperabilitySimulationButton');

    % 或者数据处理和TCP发送分开调用
    app.StartOperabilitySimulationButton.Enable = false;

    [jsonData, statusData, ~] = processPathData(app, pathData);
    if ~statusData
        app.StartOperabilitySimulationButton.Enable = true;
        return;
    end
    [statusTCP, ~] = processTCP(app, jsonData);
    if ~statusTCP
        app.StartOperabilitySimulationButton.Enable = true;
        return;
    end


end