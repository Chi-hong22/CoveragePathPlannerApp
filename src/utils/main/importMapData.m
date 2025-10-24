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
        app.StatusLabel.FontColor = [0.8 0 0];
        return;
    end
    
    % 构建完整文件路径
    fullFilePath = fullfile(pathname, filename);
    
    % 尝试加载地图数据
    try
        % 加载.mat文件
        loadedData = load(fullFilePath);
        
        % 验证文件中是否包含terrainHeightMap变量
        if isfield(loadedData, 'terrainHeightMap')
            % 提取地形高度数据
            app.terrainHeightMap = loadedData.terrainHeightMap;
            app.importedMapFile = fullFilePath;
            
            % 在UIAxes3上显示地形图预览
            imagesc(app.UIAxes3, app.terrainHeightMap);
            title(app.UIAxes3, '地形图预览');
            xlabel(app.UIAxes3, 'X轴 (米)');
            ylabel(app.UIAxes3, 'Y轴 (米)');
            colorbar(app.UIAxes3);
            colormap(app.UIAxes3, 'jet');
            caxis(app.UIAxes3, [-30 30]);
            axis(app.UIAxes3, 'equal');
            grid(app.UIAxes3, 'on');
            
            % 更新状态标签
            app.StatusLabel.Text = sprintf('已导入地图数据: %s', filename);
            app.StatusLabel.FontColor = [0 0.6 0];
            
            % 启用障碍物标注按钮
            app.obstacleMarkingButton.Enable = 'on';
            
            disp(['地图数据导入成功: ' fullFilePath]);
            disp(['地形图尺寸: ' num2str(size(app.terrainHeightMap))]);
            
        else
            % 文件中没有terrainHeightMap变量
            errordlg('所选文件中未找到terrainHeightMap变量，请确认文件格式正确！', '数据格式错误');
            app.StatusLabel.Text = '导入失败: 文件格式不正确';
            app.StatusLabel.FontColor = [0.8 0 0];
        end
        
    catch ME
        % 加载失败
        errordlg(['无法加载地图数据: ' ME.message], '加载错误');
        app.StatusLabel.Text = '导入失败: 文件加载错误';
        app.StatusLabel.FontColor = [0.8 0 0];
        disp(['错误信息: ' ME.message]);
    end
    
end