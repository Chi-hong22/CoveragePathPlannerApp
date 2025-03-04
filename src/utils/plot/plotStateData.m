%% plotStateData - 绘制系统状态数据的时间历程
%
% 功能描述：
%   绘制系统各状态量(位移、速度、角速度、加速度、角加速度、姿态角)随时间的变化曲线
%   以及三维路径跟踪轨迹。
%
% 输入参数：
%   logsout     - 系统状态日志数据
%   P0          - 起始位置
%   Waypoints   - 路径点序列
%
% 版本信息：
%   v1.0 (250304) - 初始版本
%     * 将原huitu.m脚本转换为函数形式
%     * 添加函数文档和参数说明
%     * 规范代码结构和注释
%   
%   v1.1 (250304) - 布局优化
%     * 重新组织为两个主要图窗
%     * 优化子图布局提高可视化效果
%     * 添加网格线增强可读性
%     * 统一标题和图例样式
%
% 作者信息：
%   修改：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%   作者：(Taoaofei)陶奥飞
%   邮箱：taoaofei@gmail.com
%   单位：哈尔滨工程大学

function plotStateData(logsout, P0, Waypoints)
    %% 数据提取
    % 位移数据
    X = logsout{26}.Values.Data;
    X_T = logsout{26}.Values.Time;
    Y = logsout{27}.Values.Data;
    Y_T = logsout{27}.Values.Time;
    Z = logsout{28}.Values.Data; 
    Z_T = logsout{28}.Values.Time; 

    % 速度数据
    u = logsout{1}.Values.Data;
    u_T = logsout{1}.Values.Time;
    v = logsout{2}.Values.Data;
    v_T = logsout{2}.Values.Time;
    w = logsout{3}.Values.Data; 
    w_T = logsout{3}.Values.Time; 

    % 角速度数据
    p = logsout{4}.Values.Data;
    p_T = logsout{4}.Values.Time;
    q = logsout{5}.Values.Data;
    q_T = logsout{5}.Values.Time;
    r = logsout{6}.Values.Data;
    r_T = logsout{6}.Values.Time;

    % 加速度数据
    dot_u = logsout{12}.Values.Data;
    dot_u_T = logsout{12}.Values.Time;
    dot_v = logsout{10}.Values.Data;
    dot_v_T = logsout{10}.Values.Time;
    dot_w = logsout{8}.Values.Data;
    dot_w_T = logsout{8}.Values.time;

    % 角加速度数据
    dot_p = logsout{9}.Values.Data;
    dot_p_T = logsout{9}.Values.Time;
    dot_q = logsout{11}.Values.Data;
    dot_q_T = logsout{11}.Values.Time;
    dot_r = logsout{7}.Values.Data;
    dot_r_T = logsout{7}.Values.Time;

    % 姿态角数据
    phi = logsout{44}.Values.Data;
    phi_T = logsout{44}.Values.Time;
    theta = logsout{45}.Values.Data;
    theta_T = logsout{45}.Values.Time;
    psi = logsout{46}.Values.Data;
    psi_T = logsout{46}.Values.Time;

    %% 创建主图窗口并设置布局
    figure('Name', '系统状态数据时间历程', 'Position', [100 50 1200 800]);
    
    %% 绘制位移时间历程
    subplot(3,7,[1,2])
    plot(X_T, X, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('X[m]');
    title('纵向位移随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[8,9])
    plot(Y_T, Y, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('Y[m]');
    title('横向位移随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[15,16])
    plot(Z_T, Z, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('Z[m]');
    title('垂向位移随时间变化', 'Color', 'r');
    grid on;

    %% 绘制速度时间历程
    subplot(3,7,[3,4])
    plot(u_T, u, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('u[m/s]');
    title('纵向速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[10,11])
    plot(v_T, v, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('v[m/s]');
    title('横向速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[17,18])
    plot(w_T, w, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('w[m/s]');
    title('垂向速度随时间变化', 'Color', 'r');
    grid on;

    %% 绘制角速度时间历程
    subplot(3,7,[5,6])
    plot(p_T, p, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('p[rad/s]');
    title('横倾角速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[12,13])
    plot(q_T, q, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('q[rad/s]');
    title('纵倾角速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,7,[19,20])
    plot(r_T, r, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('r[rad/s]');
    title('首向角速度随时间变化', 'Color', 'r');
    grid on;

    %% 绘制三维路径跟踪轨迹
    subplot(3,7,[7,14,21])
    WaypointsPlot = [P0; Waypoints];
    plot3(X, Y, Z, '-b', WaypointsPlot(:,1), WaypointsPlot(:,2), WaypointsPlot(:,3), '--r', 'LineWidth', 1.5);
    hold on; grid on;
    scatter3(X(1), Y(1), Z(1), 40, 'p', 'filled', 'MarkerFaceColor', 'red');
    scatter3(X(end), Y(end), Z(end), 40, 'h', 'filled', 'MarkerFaceColor', 'black');
    scatter3(WaypointsPlot(:,1), WaypointsPlot(:,2), WaypointsPlot(:,3), 40, 'o', 'MarkerEdgeColor', 'red');
    set(gca, 'DataAspectRatio', [1 1 0.06]);
    legend({'Track', 'Task Path', 'Start', 'End', 'WPs'}, 'Location', 'best'); 
    legend('boxoff');
    zlabel('Depth[m]');
    set(gca, 'ZDir', 'reverse');
    title('三维路径跟踪轨迹', 'Color', 'r');

    %% 创建第二个图窗口显示加速度和角度数据
    figure('Name', '加速度与姿态角数据时间历程', 'Position', [100 50 1200 800]);
    
    %% 绘制加速度时间历程
    subplot(3,3,1)
    plot(dot_u_T, dot_u, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('纵向加速度[m/s^2]');
    title('纵向加速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,2)
    plot(dot_v_T, dot_v, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('横向加速度[m/s^2]');
    title('横向加速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,3)
    plot(dot_w_T, dot_w, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('垂向加速度[m/s^2]');
    title('垂向加速度随时间变化', 'Color', 'r');
    grid on;

    %% 绘制角加速度时间历程
    subplot(3,3,4)
    plot(dot_p_T, dot_p, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('横倾角加速度[rad/s^2]');
    title('横倾角加速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,5)
    plot(dot_q_T, dot_q, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('纵倾角加速度[rad/s^2]');
    title('纵倾角加速度随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,6)
    plot(dot_r_T, dot_r, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('首向角加速度[rad/s^2]');
    title('首向角加速度随时间变化', 'Interpreter', 'latex', 'Color', 'r');
    grid on;

    %% 绘制姿态角时间历程
    subplot(3,3,7)
    plot(phi_T, phi, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('横倾角[度]');
    title('横倾角随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,8)
    plot(theta_T, theta, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('纵倾角[度]');
    title('纵倾角随时间变化', 'Color', 'r');
    grid on;
    
    subplot(3,3,9)
    plot(psi_T, psi, 'LineWidth', 1.5);
    xlabel('T[s]'); ylabel('首向角[度]');
    title('首向角随时间变化', 'Color', 'r');
    grid on;
end
