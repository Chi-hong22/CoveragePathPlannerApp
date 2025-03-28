% 导出局部路径规划数据
%
% 功能描述：
%   此函数用于将局部路径规划数据从CSV文件中读取并导出到用户指定的CSV文件中。
%   用户通过文件选择对话框选择保存路径和文件名。
%
% 输入参数：
%   app - AUVCoveragePathPlannerApp的实例
%
% 输出参数：
%   无直接输出，结果通过UI界面显示
%
% 注意事项：
%   1. 确保CSV文件存在且格式正确。
%   2. 该函数会更新UI界面中的状态标签。
%
% 版本信息：
%   版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 作者信息：
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学


function exportLocalWaypoints(app)

    try
        % 从工作区读取数据
        result_no_duplicates = evalin('base', 'result_no_duplicates');
        
        % 设置默认保存路径为 app.currentProjectRoot/data
        defaultPath = fullfile(app.currentProjectRoot, 'data');
        
        % 如果目录不存在则创建
        if ~exist(defaultPath, 'dir')
            mkdir(defaultPath);
        end
        
        % 设置默认文件名
        defaultFileName = fullfile(defaultPath, 'CSV_Dubins_waypoints.csv');
        
        % 获取保存文件名
        [filename, pathname] = uiputfile({'*.csv', 'CSV文件 (*.csv)'}, ...
            '保存 CSV 文件', defaultFileName);
        
        if isequal(filename, 0) || isequal(pathname, 0)
            % 用户取消操作
            app.StatusLabel.Text = '导出操作已取消';
            return;
        end

        % 完整路径
        fullPath = fullfile(pathname, filename);

        % 创建表头
        columnNames = {'X', 'Y'};
        
        % 转换为表格并设置表头
        resultTable = array2table(result_no_duplicates, 'VariableNames', columnNames);

        % 保存数据到 CSV 文件
        writetable(resultTable, fullPath);
        app.StatusLabel.Text = '数据导出成功！';
        app.StatusLabel.FontColor = [0 0.5 0];

        
    catch ME
        app.StatusLabel.Text = ['导出失败: ' ME.message];
        app.StatusLabel.FontColor = [0.8 0 0];
        errordlg(['导出失败: ' ME.message], '导出错误');
    end


end