%% dubinsSelectionThreat - 选择威胁最小的路径
%
% 功能描述：
%   从给定的UAV路径信息矩阵中选择威胁最小的路径。
%
% 输入参数：
%   TrajCollect - UAV路径信息矩阵
%   ObsInfo     - 障碍物信息矩阵
%   i           - TrajCollect的行号
%   threat_min  - 最小威胁（输入/输出）
%   length_min  - 最小长度（输入/输出）
%   index       - 选中的路径索引（输入/输出）
%
% 版本信息：
%   当前版本：v1.1
%   创建日期：241101
%   最后修改：250110
%
% 作者信息：
%   作者：董星犴
%   邮箱：1443123118@qq.com
%   单位：哈尔滨工程大学

function [threat_min,length_min,index] = Dubins_Selection_Threat...
    (TrajCollect,ObsInfo,threat_min,length_min,index,i)

xc=TrajCollect(i,7);
yc=TrajCollect(i,8);
R=TrajCollect(i,5);
length=TrajCollect(i,24);
obs_index(1:5)=TrajCollect(i,27:31);

if length==0
    return;
end

if obs_index(1)~=0
    x_obs=ObsInfo(obs_index(1),1);
    y_obs=ObsInfo(obs_index(1),2);
    R_obs=ObsInfo(obs_index(1),3);
    threat=R+R_obs-sqrt((xc-x_obs)^2+(yc-y_obs)^2);
    if threat<0
        threat=0;
    end
    if threat_min==0&&i==1
        threat_min=threat;
        index=i;
    end
    if threat_min>threat
        threat_min=threat;
        index=i;
    end
else
    threat_min=0;
    if length_min==0
        length_min=length;
        index=i;
    end
    if length_min>length
        length_min=length;
        index=i;
    end
end

end

