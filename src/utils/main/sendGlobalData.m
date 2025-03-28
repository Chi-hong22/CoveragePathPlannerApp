%% sendGlobalData - 发送全局路径规划数据到AUV设备
%
% 功能描述：
%   此函数用于将全局路径规划数据通过TCP连接发送到AUV设备。
%   通过调用sendPathDataViaTCP函数实现核心功能，优化了代码结构。
%
% 输入参数：
%   app - AUVCoveragePathPlannerApp的实例，包含UI组件和路径数据
%
% 输出参数：
%   无直接输出，发送结果会在UI界面中显示
%
% 注意事项：
%   1. 确保服务器IP和端口正确，且AUV设备已开启并准备好接收数据。
%   2. 发送过程中，相关按钮将被禁用，发送完成后恢复可用状态。
%
% 版本信息：
%   版本：v1.2
%   创建日期：241101
%   最后修改：250328
%
% 作者信息：
%   作者：游子昂
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学

function sendGlobalData(app)
    % 调用统一函数发送数据
    sendPathDataViaTCP(app, app.Waypoints, 'SendGlobalPathsButton');
end