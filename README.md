# 🌊 AUV 全覆盖路径规划器

🚀 基于 MATLAB GUI 的自主水下航行器(AUV)海底探测路径规划应用程序。
集成了智能路径生成、Dubins曲线优化、障碍物避障等功能，支持实时数据可视化和AUV控制系统对接。

## ✨ 功能特点

- 🎯 智能路径规划：基于直观的图形界面实现参数配置和路径生成
- ↔️ 双向规划能力：支持 X/Y 两个方向的梳状探测路径生成
- 📊 实时数据反馈：动态显示规划路径和关键航点坐标
- 💾 数据互操作：支持路径点数据的导入导出，兼容 CSV 格式
- 🔄 通信集成：内置 TCP 通信模块，实现与 AUV 控制系统的无缝对接
- 🔄 Dubins 路径优化：提供转弯半径和路径点密度的精确控制
- 🗺️ 地形感知：支持 .mat 格式地形数据导入和障碍物智能标注
- 🔄 模式自适应：支持从精确的 Dubins 曲线到简单直线路径的平滑过渡
- 📈 可视化增强：多视图展示，包含地形图、障碍物分布和路径规划效果

## 🛠️ 安装与使用

### 👨‍💻 开发工作流

> 请确保已安装 Git 和 MATLAB
> 
> 请确保已配置好 Git 的用户名和邮箱
> 
> 详细工作流请参考组内的Git教程

1. Fork 本仓库至自己的github账号仓库中
2. 克隆到本地进行开发

    ```bash
    git clone https://github.com/yourusername/auv-coverage-planner.git
    cd CoveragePathPlannerApp
    ```

3. 创建新分支进行开发

    ```bash
    git checkout -b feature/your-feature-name
    ```

4. 提交更改

    ```bash
    git add .
    git commit -m "描述你的更改"
    ```

5. 推送到远程仓库（自己的）

    ```bash
    git push origin feature/your-feature-name
    ```

6. 创建 Pull Request 到主仓库
7. 等待审核

#### 版本发布

```bash
# 标记新版本
git tag -a v1.1 -m "版本1.1发布"

# 推送标签
git push origin v1.1
```

#### 请确保提交前：

运行所有测试用例
更新相关文档
遵循代码规范

### 🚦 运行方式

1. 启动应用程序
   - 在MATLAB中打开`CoveragePathPlannerApp.m`文件
   - 点击"运行"按钮或在命令行输入: `CoveragePathPlannerApp`

2. 全局路径规划
   - 在"相关坐标初始化"面板中设置起始点坐标
   - 在"路径参数"面板中配置间距、宽度等参数
   - 点击【生成梳状路径】生成全局探测路径，可在UIAxes1中查看效果图
   - 点击【导出梳状路径点】将路径数据保存为CSV格式
   - 点击【发送梳状路径数据至AUV】通过TCP传输至AUV控制系统

3. 地形分析与避障规划
   - 点击【导入地图数据】加载.mat格式的海底地形数据
   - 点击【地形图及障碍物标注】在UIAxes3中查看地形可视化结果
   - 在"Dubins路径规划设置"面板中调整路径参数
   - 点击【Dubins路径规划】生成避障路径，可在UIAxes2中查看效果
   - 点击【导出Dubins路径点】保存优化后的路径数据
   - 点击【发送Dubins路径数据至AUV】将优化路径发送至AUV

界面会实时显示：
- 路径规划总长度
- 操作状态信息（红色提示）
- 三个视图窗口的规划结果

### ❓ 常见问题

1. 如遇到TCP连接失败：

   - 检查目标IP地址和端口是否正确
   - 确认防火墙设置
  
2. 路径生成失败：

   - 确保输入参数在有效范围内
   - 检查MATLAB版本兼容性

## 📋 界面参数介绍

### 📍 相关坐标初始化

- 规划路径起始点坐标 (X, Y)
- AUV 初始位置 (X, Y, Z)
- AUV 初始姿态角 (Roll, Pitch, Yaw)

### 🛣️ 路径参数

- 路径方向：X/Y 方向选择
- 梳状齿间距：默认 200m
- 路径宽度：默认 1000m
- 路径数量：默认 6 条

### 🔌 TCP 通信设置

- 服务器 IP：默认 192.168.1.108
- 端口：默认 5000

### ⚙️ Dubins路径规划设置

- 前端路径点个数：前端Dubins路径设置的个数，默认是1
- 中端路径点个数：中端Dubins路径设置的个数，默认是2
- 后端路径点个数：后端Dubins路径设置的个数，默认是1
- 转弯半径：Dubins路径规划的转弯半径设置，默认是0

## 🎮 功能按钮

- 【生成梳状路径】根据设定的起始点、间距、宽度等参数，生成全局探测路径
- 【导出梳状路径点】将生成的全局路径点数据以标准 CSV 格式保存，便于后续分析和使用
- 【发送梳状路径数据至AUV】通过配置的 TCP 连接（默认 192.168.1.108:5000）将路径数据传输至 AUV 控制系统
- 【导入地图数据】支持导入 .mat 格式的海底地形高程数据，用于后续的障碍物分析
- 【地形图及障碍物标注】在 UIAxes3 绘图区域中可视化地形数据，并自动标注潜在障碍物位置
- 【Dubins路径规划】基于预设的路径点密度（前端/中端/后端）和转弯半径，生成平滑的避障路径
- 【发送Dubins路径数据至AUV】将优化后的 Dubins 路径数据通过 TCP 协议发送至 AUV
- 【导出Dubins路径点】将优化后的路径点数据以 CSV 格式保存，包含所有关键航点坐标

界面实时状态通过以下方式反馈：

- 总路径长度标签显示当前规划路径的完整长度
- 状态标签（红色字体）提示当前操作结果和系统状态
- 三个图形显示区域（UIAxes1/2/3）分别展示：
  - 全局路径规划效果图
  - Dubins 路径规划效果图
  - 地形标注可视化结果

## ⚖️ 所有权声明

版权所有 © 哈尔滨工程大学智能海洋机器人实验室张强老师团队

未经允许，不得用于商业用途

维护者：Chi-hong22/游子昂,董星犴

## 📝 版本信息

版本：1.2 🏷️

发布日期：2025-01-10 📅

### 🔜 预计更新内容

- 优化梳状路径点与Dubins模块的数据衔接
- 解耦地形图障碍物与Dubins路径规划

## 💻 系统要求

MATLAB R2024a 或更高版本

建议屏幕分辨率：1200x800 或更高

## 📬 联系方式

`you.ziang@hrbeu.edu.cn`

如有优化需求，请联系项目负责人`游子昂`进行统一安排迭代升级。