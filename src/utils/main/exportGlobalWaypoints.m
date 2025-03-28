%% exportGlobalWaypoints - 导出路径点
%
% 功能描述：
%   此函数用于将生成的路径点导出为CSV文件。如果路径点数组不为空，
%   则创建一个表格并保存到用户指定的文件中。
%
% 输入参数：
%   app - AUVCoveragePathPlannerApp的实例
%
% 输出参数：
%   无直接输出，结果通过UI界面显示
%
% 注意事项：
%   1. 确保路径点数组不为空。
%   2. 该函数会更新UI界面中的状态标签。
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

function exportGlobalWaypoints(app)
    if ~isempty(app.Waypoints)
        try
            % 创建表格
            T = array2table(app.Waypoints, 'VariableNames', {'X', 'Y','theta','r'});
            
            % 设置默认保存路径为 app.currentProjectRoot/data
            defaultPath = fullfile(app.currentProjectRoot, 'data');
            
            % 如果目录不存在则创建
            if ~(exist(defaultPath, 'dir'))
                mkdir(defaultPath);
            end
            
            % 设置默认文件名
            defaultFileName = fullfile(defaultPath, 'CSV_waypoints.csv');
            
            % 获取保存文件名
            [filename, pathname] = uiputfile({'*.csv', 'CSV文件 (*.csv)'}, ...
                '保存路径点', defaultFileName);
            
            if filename ~= 0
                % 完整路径
                fullPath = fullfile(pathname, filename);
                try
                    writetable(T, fullPath);
                    % 更新状态
                    app.StatusLabel.Text = '已成功导出规划路径数据！';
                    app.StatusLabel.FontColor = [0 0.5 0];
                    msgbox(sprintf('路径点已成功导出到:\n%s', fullPath), '导出成功');
                catch saveErr
                    app.StatusLabel.Text = '保存文件失败！';
                    app.StatusLabel.FontColor = [0.8 0 0];
                    errordlg(sprintf('保存文件失败:\n%s', saveErr.message), '保存错误');
                    return;
                end
            end
        catch ME
            errordlg(sprintf('导出错误:\n%s', ME.message), '错误');
        end
    else
        app.StatusLabel.Text = '没有可导出的路径点数据！';
        app.StatusLabel.FontColor = [0.8 0 0];
        return;
    end
end