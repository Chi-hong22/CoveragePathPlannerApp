%% sendLocalData - 发送局部路径规划数据到AUV
%
% 功能描述：
%   根据设置的服务器IP和端口，将局部路径规划数据发送到AUV设备。
%   本函数通过调用sendPathDataViaTCP函数实现核心功能，优化了代码结构。
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
%   当前版本：v1.2
%   创建日期：20241101
%   最后修改：250328
%
% 作者信息：
%   作者：游子昂
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function sendLocalData(app)
    % 获取工作区中的路径数据
    try
        result_no_duplicates = evalin('base', 'result_no_duplicates');
    catch
        app.TotalLengthLabelandTCP.Text = '获取result_no_duplicates路径数据失败';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        return;
    end

    % 调用统一函数发送数据
    sendPathDataViaTCP(app, result_no_duplicates, 'SendLocalPathsButton');
end