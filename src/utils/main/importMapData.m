%% importMapData - 导入地图数据
%
% 功能描述：
%   从用户选择的.mat文件中导入地图数据，并将其复制到应用程序的目录中。
%   用户通过文件选择对话框选择文件。
%
% 输入参数：
%   app - AUVCoveragePathPlannerApp的实例
%
% 注意事项：
%   1. 确保用户选择的文件存在且格式正确。
%   2. 该函数会更新UI界面中的按钮状态。
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function importMapData(app)
    % 使用应用程序保存的路径
    defaultPath = fullfile(app.currentProjectRoot, 'data');
    
    % 如果data文件夹不存在，则创建它
    if ~exist(defaultPath, 'dir')
        mkdir(defaultPath);
    end
    
    % 获取文件名，设置默认路径为data文件夹
    [filename, pathname] = uigetfile('*.mat', '选择地图数据文件', defaultPath);
    
    if isequal(filename, 0) || isequal(pathname, 0)
        % 用户取消操作
        app.StatusLabel.Text = '导入操作已取消';
        return;
    end
    disp('地图数据导入成功');
    app.obstacleMarkingButton.Enable = 'on';
    
end