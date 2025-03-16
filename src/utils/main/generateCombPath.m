%% generateCombPath - AUV梳状覆盖路径生成工具
%
% 功能描述：
%   基于给定参数生成AUV的梳状覆盖路径，支持X方向和Y方向的路径生成，
%   并计算总路径长度。适用于区域覆盖任务的路径规划。
%
% 作者信息：
%   作者：Chihong（游子昂）
%   邮箱：you.ziang@hrbeu.edu.cn
%   单位：哈尔滨工程大学
%
% 版本信息：
%   版本：v1.2
%   创建日期：241101
%   最后修改：250316
%
% 版本历史：
%   v1.2 (250316)
%       + 修改direction参数无效的情况
%   v1.1 (250110)
%       + 添加转弯半径参数
%       + 优化路径生成算法
%       + 改进状态显示
%   v1.0 (241101)
%       + 首次发布
%       + 实现基础梳状路径生成
%       + 支持双向路径规划
%
% 输入参数：
%   app          - [object] AUVCoveragePathPlannerApp实例
%                  必选参数，包含UI组件和数据
%   startPoint   - [1x2 double] 起始点坐标 [x, y]
%                  必选参数，定义路径起点
%   lineSpacing  - [double] 梳状齿间距（米）
%                  必选参数，>0
%   pathWidth    - [double] 路径宽度（米）
%                  必选参数，>0
%   numLines     - [integer] 梳状路径数量
%                  必选参数，>0
%   direction    - [char] 路径方向
%                  必选参数，'x'或'y'
%   radius       - [double] 转弯半径（米）
%                  必选参数，>0
%
% 输出参数：
%   waypoints    - [nx4 double] 路径点数组
%                  [x, y, heading, radius]
%
% 注意事项：
%   1. 输入验证：所有数值参数必须为正数
%   2. 内存消耗：与路径点数量成正比
%   3. 性能考虑：路径点数量会影响计算时间
%
% 调用示例：
%   % 生成X方向梳状路径
%   waypoints = generateCombPath(app, [0,0], 10, 100, 5, 'x', 5);
%
%   % 生成Y方向梳状路径
%   waypoints = generateCombPath(app, [0,0], 10, 100, 5, 'y', 5);
%
% 依赖函数：
%   - norm
%
% 参见函数：
%   plotPath, calculateTotalLength

function waypoints = generateCombPath(app, startPoint, lineSpacing, pathWidth, numLines, direction,radius)
    % 删除方向参数中的所有空格
    direction = strrep(direction, ' ', '');
    
    % 初始化waypoints数组
    totalPoints = numLines * 2;  % 每条线有起点和终点
    waypoints = zeros(totalPoints, 4);

    % 根据方向生成梳状路径
    if strcmp(direction, 'x')
        % X方向梳状路径（垂直于Y轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从左到右
                % 左端点
                waypoints(2*i-1,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,0,radius];
                % 右端点
                waypoints(2*i,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,0,radius];
            else  % 偶数线，从右到左
                % 右端点
                waypoints(2*i-1,:) = [startPoint(1) + pathWidth, startPoint(2) + (i-1)*lineSpacing,pi,radius];
                % 左端点
                waypoints(2*i,:) = [startPoint(1), startPoint(2) + (i-1)*lineSpacing,pi,radius];
            end
        end
    else
        % Y方向梳状路径（垂直于X轴）
        for i = 1:numLines
            if mod(i,2) == 1  % 奇数线，从下到上
                % 下端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),pi/2,radius];
                % 上端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,pi/2,radius];
            else  % 偶数线，从上到下
                % 上端点
                waypoints(2*i-1,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2) + pathWidth,-pi/2,radius];
                % 下端点
                waypoints(2*i,:) = [startPoint(1) + (i-1)*lineSpacing, startPoint(2),-pi/2,radius];
            end
        end
    end
    
    % 计算路径总长度
    totalLength = 0;
    for i = 1:size(waypoints,1)-1
        totalLength = totalLength + norm(waypoints(i+1,:) - waypoints(i,:));
    end
    
    % 更新状态（修改这里，使用正确的属性名）
    app.TotalLengthLabelandTCP.Text = sprintf('总路径长度: %.1f 米', totalLength);
    app.StatusLabel.Text = '已生成规划路径数据！';
    app.StatusLabel.FontColor = [0 0.5 0];
end