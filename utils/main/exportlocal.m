%% exportlocal - 局部路径规划数据导出工具
%
% 功能描述：
%   将局部路径规划数据从CSV文件中读取并导出到用户指定位置。通过图形界面
%   交互，支持用户自定义导出文件名和路径。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241115
%   最后修改：250110
%
% 版本历史：
%   v1.1 (250110)
%       + 优化错误处理机制
%       + 改进用户界面交互
%   v1.0 (241115)
%       + 首次发布
%       + 实现基础CSV文件导出功能
%       + 添加用户交互界面
%
% 输入参数：
%   app - [object] AUVCoveragePathPlannerApp的实例
%         必选参数，包含应用程序的UI组件和数据
%
% 输出参数：
%   无直接返回值，结果通过文件导出和UI提示反馈
%
% 注意事项：
%   1. 数据源：确保'result_no_duplicates.csv'文件存在且格式正确
%   2. 权限要求：需要目标文件夹的写入权限
%   3. 数据格式：输出为CSV格式，保持原始数据结构
%
% 调用示例：
%   % 在APP中调用
%   app = AUVCoveragePathPlannerApp;
%   exportlocal(app);
%
% 依赖函数：
%   - readmatrix
%   - writetable
%   - array2table
%
% 参见函数：
%   importlocal, processData

% 函数实现部分
function exportlocal(app)
    % 读取 CSV 文件内容
    data = readmatrix('result_no_duplicates.csv');

    % 获取保存文件名
    [filename, pathname] = uiputfile({'*.csv', 'CSV文件 (*.csv)'}, '保存 CSV 文件', 'exported_data.csv');
    
    if isequal(filename, 0) || isequal(pathname, 0)
        % 用户取消操作
        return;
    end

    % 完整路径
    fullPath = fullfile(pathname, filename);

    % 保存数据到 CSV 文件
    try
        writetable(array2table(data), fullPath);
        msgbox(['数据已成功导出到: ' fullPath], '导出成功');
    catch ME
        errordlg(['导出失败: ' ME.message], '导出错误');
    end
end