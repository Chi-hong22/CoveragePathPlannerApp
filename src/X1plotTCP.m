%% X1plotTCP - TCP路径规划轨迹绘制与仿真工具
%
% 功能描述：
%   读取CSV格式的路径点数据，进行轨迹规划仿真并绘制三维运动轨迹图
%   支持自定义起始位置、姿态角、运动参数等
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：陶奥飞
%   单位：哈尔滨工程大学
%
% 版本信息：
%   当前版本：v1.0
%   创建日期：250110
%   最后修改：250227
%
% 版本历史：
%   v1.0 (250110) - 首次发布
%       + 实现基础的轨迹规划与绘制功能
%       + 支持CSV路径点导入
%       + 支持自定义运动参数配置
%       + 添加三维可视化显示
%   v1.1 (250227) - 首次发布
%       + 实现部署后的simulink模型调用
%       + 优化标签显示和错误处理
%
% 输入参数：
%   app - [object] GUI应用程序对象，包含以下主要属性：
%       Kdelta(1-4)     - [double] 控制参数
%       Delta(1-4)      - [double] 位移参数
%       ud              - [double] 期望速度
%       Td              - [double] 掉深时间
%       Tj              - [double] 急停时间
%       P0(X,Y,Z)       - [double] 初始位置坐标
%       A0(X,Y,Z)       - [double] 初始姿态角
%       Z               - [double] 基准深度值
%       up/down         - [int] 上升/下降点索引
%       Dup/Ddown       - [double] 上升/下降深度值
%
% 输出参数：
%   无直接返回值，生成轨迹图窗口显示结果
%
% 注意事项：
%   1. 需要确保'result_no_duplicates'变量存在且格式正确
%   2. result_no_duplicates格式要求：2列或4列数据格式
%   3. 需要Simulink模型'X1PFjicheng'支持
%
% 调用示例：
%   % 通过GUI界面调用，不需要直接调用该函数
%
% 依赖工具箱：
%   - Simulink
%   - MATLAB基础工具箱
%
% 参见函数：
%   readmatrix, sim, plot3, scatter3

function X1plotTCP(app)
    try
        result_no_duplicates = evalin('base', 'result_no_duplicates');
    catch
        app.TotalLengthLabelandTCP.Text = '获取result_no_duplicates路径数据失败';
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
        return;
    end
    
    Kdelta=[app.Kdelta1EditField.Value,app.Kdelta2EditField.Value,app.Kdelta3EditField.Value,app.Kdelta4EditField.Value];
    Delta=[app.Delta1EditField.Value,app.Delta2EditField.Value,app.Delta3EditField.Value,app.Delta4EditField.Value];
    %获取期望速度，掉深时间和急停时间
    ud=app.udEditField.Value;
    Td=app.TdEditField.Value;
    Tj=app.TjEditField.Value;
    % 获取初始位置和姿态角
    P0 = [app.P0XEditField.Value, app.P0YEditField.Value, app.P0ZEditField.Value];
    A0 = [app.A0XEditField.Value, app.A0YEditField.Value, app.A0ZEditField.Value];
    
    % 获取路径点数量和处理Z坐标
    WPNum = size(result_no_duplicates, 1);
    numColumns = size(result_no_duplicates, 2);
    
    % 根据列数进行不同的操作
    if numColumns == 4
        result_no_duplicates(:, 3:4) = [];
        column_of_z = app.ZEditField.Value * ones(size(result_no_duplicates, 1), 1);
        Waypoints = [result_no_duplicates, column_of_z];
    elseif numColumns == 2
        column_of_z = app.ZEditField.Value * ones(size(result_no_duplicates, 1), 1);
        Waypoints = [result_no_duplicates, column_of_z];
    else
        error('路径数据的列数必须是2或4');
    end
    
    Waypoints(app.upEditField.Value,3)=app.DupEditField.Value;
    Waypoints(app.downEditField.Value,3)=app.DdownEditField.Value;
    up=app.upEditField.Value;
    down=app.downEditField.Value;
    z=app.ZEditField.Value;
    
    % 保持所有assignin语句
    assignin('base','z',z);
    assignin('base',"Waypoints",Waypoints);
    assignin('base','WPNum',WPNum);
    assignin('base','P0',P0);
    assignin('base','A0',A0);
    assignin('base','Kdelta',Kdelta);
    assignin('base','Delta',Delta);
    assignin('base','ud',ud);
    assignin('base',"Td",Td);
    assignin('base',"Tj",Tj);
    assignin('base','up',up);
    assignin('base',"down",down);
    
    % 使用app.currentProjectRoot设置模型位置
    if isfield(app, 'currentProjectRoot') && ~isempty(app.currentProjectRoot)
        modelPath = fullfile(app.currentProjectRoot, 'src', 'utils', 'main', 'X1PFjicheng.slx');
    else
        % 如果app没有currentProjectRoot属性，尝试从当前文件位置推断
        appRootPath = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
        modelPath = fullfile(appRootPath, 'src', 'utils', 'main', 'X1PFjicheng.slx');
    end
    
    % 检查模型文件是否存在
    if ~exist(modelPath, 'file')
        % 尝试其他可能的位置
        alternativePaths = {
            fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'main', 'X1PFjicheng.slx'),
            fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'src', 'X1PFjicheng.slx')
        };
        
        for i = 1:length(alternativePaths)
            if exist(alternativePaths{i}, 'file')
                modelPath = alternativePaths{i};
                break;
            end
        end
        
        % 如果仍然找不到模型文件
        if ~exist(modelPath, 'file')
            app.StatusLabel.Text = '无法找到Simulink模型文件';
            app.StatusLabel.FontColor = [0.8 0 0];
            app.SendTCPButton.Enable = true;
            return;
        end
    end
    
    app.StatusLabel.Text = '正在运行仿真系统，请稍后... ' ;

    % 在加载模型前，先关闭所有打开的同名模型
    if bdIsLoaded('X1PFjicheng')
        try
            close_system('X1PFjicheng', 0); % 尝试关闭模型而不保存
        catch
            % 如果模型已修改且无法关闭，可能会抛出异常
            app.StatusLabel.Text = '无法关闭已打开的模型，请手动关闭后重试';
            app.StatusLabel.FontColor = [0.8 0 0];
            app.SendTCPButton.Enable = true;
            return;
        end
    end
    
    try
        % 使用加载的模型路径运行仿真
        sim(modelPath);
        app.StatusLabel.Text = '正在绘制结果，请稍后... ' ;
        
        X = logsout{26}.Values.Data;
        Y = logsout{27}.Values.Data;
        Z = logsout{28}.Values.Data;
        WaypointsPlot = [P0;Waypoints];
        
        figure
        plot3(X,Y,Z,'-b',WaypointsPlot(:,1),WaypointsPlot(:,2),WaypointsPlot(:,3),'--r','LineWidth',1.5);
        hold on;grid on;
        scatter3(X(1),Y(1),Z(1),40,'p','filled','MarkerFaceColor','red');
        scatter3(X(end),Y(end),Z(end),40,'h','filled','MarkerFaceColor','black');
        scatter3(WaypointsPlot(:,1),WaypointsPlot(:,2),WaypointsPlot(:,3),40,'o','MarkerEdgeColor','red');
        set(gca,'DataAspectRatio' ,[1 1 0.06]);
        legend({'Track','Task Path','Start','End','WPs'},'Location','best');legend('boxoff');
        zlabel('Depth[m]');
        set(gca,'ZDir','reverse');
        
        app.StatusLabel.Text = '绘制成功' ;
    catch ME
        app.StatusLabel.Text = ['仿真出错: ' ME.message];
        app.StatusLabel.FontColor = [0.8 0 0];
        app.SendTCPButton.Enable = true;
    end
end