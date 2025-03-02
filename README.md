# 学习助手

学习助手是一款基于Flutter开发的对话应用，支持多种大语言模型API的接入，包括OpenAI、Anthropic Claude和国内的Kimi等，旨在为学习和工作提供便捷的AI对话能力。

## 功能特性

- **多API支持**: 支持接入OpenAI (GPT-3.5/GPT-4)、Claude、Kimi等多种API服务
- **角色预设**: 内置多种角色预设，可自定义角色和系统提示词
- **预设文本**: 支持保存常用问题和提示语，减少重复输入
- **深色模式**: 支持浅色/深色主题切换，保护眼睛
- **主题自定义**: 可自由选择主题色，打造个性化体验
- **头像设置**: 允许设置个人头像，增强个性化
- **数据本地存储**: 所有数据都保存在本地，确保隐私安全

## 项目架构

本项目采用**领域驱动设计(DDD)**和**干净架构**原则构建，主要分为以下几层:

- **表示层(Presentation)**: UI界面和Bloc状态管理
- **领域层(Domain)**: 业务模型、仓库接口和用例
- **数据层(Data)**: 数据源和仓库实现
- **核心层(Core)**: 工具类、常量和服务定位器

### 技术栈

- **Flutter**: UI框架
- **Bloc**: 状态管理
- **Get_It**: 依赖注入
- **SharedPreferences**: 本地数据存储
- **HTTP**: 网络请求

## 开始使用

### 前提条件

- Flutter 3.0.0 或更高版本
- Dart 3.0.0 或更高版本

### 安装步骤

1. 克隆此仓库
```bash
git clone https://github.com/xiaonengya/learning_assistant_demo.git
```

2. 安装依赖
```bash
cd learning_assistant_demo
flutter pub get
```

3. 运行应用
```bash
flutter run
```

### 首次使用

1. 打开应用后，先前往"设置"页面
2. 点击"API配置"，添加一个新的API配置（需要您自己的API密钥）
3. 返回主界面开始对话

## 项目结构

```
lib/
├── core/                  # 核心工具和常量
│   ├── constants/         # 应用常量
│   ├── di/                # 依赖注入
│   └── utils/             # 工具类
├── data/                  # 数据层
│   ├── datasources/       # 数据源
│   │   ├── local/         # 本地数据源
│   │   └── remote/        # 远程数据源
│   └── repositories/      # 仓库实现
├── domain/                # 领域层
│   ├── models/            # 业务模型
│   ├── repositories/      # 仓库接口
│   └── usecases/          # 用例
└── presentation/          # 表示层
    ├── blocs/             # BLoC状态管理
    ├── pages/             # 页面
    └── widgets/           # 可复用组件
```

## 许可证

本项目基于GPL-3.0许可证开源 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

如有问题或建议，可以通过以下方式联系：

- GitHub Issue
- 邮箱：ckl1234512345@outlook.com

## 贡献指南

欢迎提交问题报告、功能需求或代码贡献。请先创建Issue讨论您的想法，再提交Pull Request。

## 致谢

- 感谢所有开源项目的贡献者
- 特别感谢Flutter社区提供的宝贵资源
