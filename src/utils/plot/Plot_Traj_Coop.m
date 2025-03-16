%% plotTrajCoop - 绘制所有AUV的备选路径和合作路径
%
% 功能描述：
%   绘制所有AUV的备选路径和合作路径。
%
% 输入参数：
%   Coop_State - AUV路径信息的单元数组
%   ObsInfo    - 障碍物信息矩阵
%   Property   - 路径规划参数结构体
%   flag       - 绘制备选路径的选项，0: 不绘制；1: 绘制
%   demo       - 示例索引
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250316
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function simplified_result_no_duplicates = Plot_Traj_Coop(Coop_State,ObsInfo,Property,flag)
    %% 初始化信息 
    [~,n]=size(Coop_State);
    scale=Property.scale;                                               % 设置绘图比例
    px=zeros(1,2*n);
    py=zeros(1,2*n);
    clf;                                                               % 清除当前图窗
    figure;
    hold on;

    %% 绘制障碍物
    theta=0:0.05:2*pi;
    [obs_num,~]=size(ObsInfo);
    for i=1:obs_num
        xo_temp=ObsInfo(i,1)+ObsInfo(i,3)*cos(theta);
        yo_temp=ObsInfo(i,2)+ObsInfo(i,3)*sin(theta);
        o1=plot(xo_temp*scale,yo_temp*scale,'r');
        o1.LineWidth=1.5;
        s=sprintf('%d',i);
        text(ObsInfo(i,1)*scale,ObsInfo(i,2)*scale,s);
    end

    %% 绘制路径及其起始点和终点
    for i=1:n
        if flag==1                                                      % 绘制备选路径
            [~,m]=size(Coop_State(i).TrajSeqCell);                      % 获取TrajSeqCell中的路径数量
            for j=1:m                                                   % 遍历每条路径
                [Traj_x,Traj_y]=Traj_Discrete...                        % 获取离散化的航点序列
                    (Coop_State(i).TrajSeqCell{j},Property);
                hold on;
                l2=plot(Traj_x*scale,Traj_y*scale,'b');                 % 绘制备选路径
                l2.LineWidth=1;                                         % 设置路径宽度
                %l2.Color=[1 1 1]*0.7;                                  % 灰色不透明模式，透明度不重叠
                l2.Color(4)=0.3;                                        % 灰色透明模式，透明度会叠加
            end
        end
        [~,c]=size(Traj_x);                                             % 获取离散航点数量
        px(i)=Traj_x(1);                                                % 获取起点x坐标
        py(i)=Traj_y(1);                                                % 获取起点y坐标
        px(n+i)=Traj_x(c);                                              % 获取终点x坐标
        py(n+i)=Traj_y(c);                                              % 获取终点y坐标
    end
    pt=scatter(px*scale,py*scale,80);                                   % 绘制起点和终点
    pt.MarkerFaceColor='r';
    pt.MarkerEdgeColor='k';

    for i=1:n                                                           % 绘制每个AUV的协作路径
        [Traj_x,Traj_y]=Traj_Discrete...
            (Coop_State(i).TrajSeq_Coop,Property);                      % 获取离散航点序列
        hold on;
        l1=plot(Traj_x*scale,Traj_y*scale,'k');                         % 绘制协作路径
        l1.LineWidth=1.5;                                               % 设置路径宽度
    end

    % 收集所有路径点
    max_points = max(cellfun(@length, {Coop_State.TrajSeq_Coop}));
    all_x = NaN(max_points, length(Coop_State));
    all_y = NaN(max_points, length(Coop_State));

    for i = 1:length(Coop_State)
        [Traj_x, Traj_y] = Traj_Discrete(Coop_State(i).TrajSeq_Coop, Property);
        all_x(1:length(Traj_x), i) = Traj_x;
        all_y(1:length(Traj_y), i) = Traj_y;
    end

    % 合并并清理数据
    temp_data = [all_x(:), all_y(:)];
    valid_idx = all(temp_data ~= 0, 2) & ~any(isnan(temp_data), 2);
    valid_data = temp_data(valid_idx, :);

    % 删除重复的行并保持顺序
    result_no_duplicates = unique(valid_data, 'rows', 'stable');

    %% 简化路径
    % 初始化路径数据矩阵,先放入起点
    simplified_result_no_duplicates = [result_no_duplicates(1, :)];


    % 遍历路径点
    for i = 2 : size(result_no_duplicates, 1) - 1
        % 当前点
        current_point = result_no_duplicates(i, :);
        % 前一个点
        prev_point = result_no_duplicates(i-1, :);
        % 后一个点
        next_point = result_no_duplicates(i+1, :);
        
        % 计算前一条线段的斜率
        if prev_point(1) ~= current_point(1)
            prev_slope = (current_point(2) - prev_point(2)) / (current_point(1) - prev_point(1));
        else
            prev_slope = Inf;
        end
        
        % 计算后一条线段的斜率
        if current_point(1) ~= next_point(1)
            next_slope = (next_point(2) - current_point(2)) / (next_point(1) - current_point(1));
        else
            next_slope = Inf;
        end
        
        % 判断斜率是否相同（考虑浮点数比较）
        slope_condition = abs(prev_slope - next_slope) > 1e-10;
        
        % 如果斜率不同，保留当前点
        if slope_condition
            simplified_result_no_duplicates = [simplified_result_no_duplicates; current_point];
        end
    end
    
    % 添加终止点
    simplified_result_no_duplicates = [simplified_result_no_duplicates; result_no_duplicates(end, :)];

    %% 设置图形参数
    % set(gca,'FontName','Times New Roman','FontSize',12);
    % xlabel('$X/m$','Interpreter','latex');
    % ylabel('$Y/m$','Interpreter','latex');
    % zlabel('$Y/m$','Interpreter','latex');
    % grid on;
    % box on;
    % L=legend([l1,l2,o1],{'协作路径',...
    %     '备选路径','威胁区域'});
    % L.Location='northeast';
    % L.FontSize=12;
end

