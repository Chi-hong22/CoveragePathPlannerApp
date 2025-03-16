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
%
% 输出参数：
%   result_no_duplicates - 包含所有路径点的无重复矩阵，每行为[x,y]坐标
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

function result_no_duplicates = plotTrajCoop(Coop_State,ObsInfo,Property,flag)
    %% 初始化信息 
    [~,n]=size(Coop_State);
    scale=Property.scale;                                               % 设置绘图比例
    px=zeros(1,2*n);
    py=zeros(1,2*n);
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
                [Traj_x,Traj_y]=trajDiscrete...                        % 获取离散化的航点序列
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
        [Traj_x,Traj_y]=trajDiscrete...
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
        [Traj_x, Traj_y] = trajDiscrete(Coop_State(i).TrajSeq_Coop, Property);
        all_x(1:length(Traj_x), i) = Traj_x;
        all_y(1:length(Traj_y), i) = Traj_y;
    end

    % 合并并清理数据
    temp_data = [all_x(:), all_y(:)];
    valid_idx = all(temp_data ~= 0, 2) & ~any(isnan(temp_data), 2);
    valid_data = temp_data(valid_idx, :);

    % 删除重复的行并保持顺序
    result_no_duplicates = unique(valid_data, 'rows', 'stable');

    %% 设置图形参数
    set(gca,'FontName','Times New Roman','FontSize',12);
    xlabel('$X/m$','Interpreter','latex');
    ylabel('$Y/m$','Interpreter','latex');
    zlabel('$Y/m$','Interpreter','latex');
    grid on;
    box on;
    L=legend([l1,l2,o1],{'协作路径',...
        '备选路径','威胁区域'});
    L.Location='northeast';
    L.FontSize=12;

end

