# AI Study Helper

一个基于Flutter开发的AI学习助手应用，提供智能对话、思维导图等功能。

## 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Windows 10/11（或其他支持Flutter的操作系统）

## 项目启动说明

### 1. 环境准备

#### 安装Flutter SDK
如果尚未安装Flutter，请访问 [Flutter官网](https://flutter.dev/docs/get-started/install) 下载并安装Flutter SDK。

#### 验证Flutter环境
打开终端，运行以下命令验证Flutter是否正确安装：
```bash
flutter --version
```

#### 启用Windows开发者模式（仅Windows）
在Windows上运行Flutter应用需要启用开发者模式：
1. 打开"设置" > "更新和安全" > "开发者选项"
2. 打开"开发人员模式"开关
3. 或者在终端运行：`start ms-settings:developers`

### 2. 安装项目依赖

进入项目目录，运行以下命令安装依赖包：
```bash
flutter pub get
```

### 3. 启动应用

#### Windows平台
```bash
flutter run -d windows
```

#### Web平台
```bash
flutter run -d chrome
```

#### Android平台
```bash
flutter run -d android
```

#### iOS平台
```bash
flutter run -d ios
```

### 4. 其他常用命令

#### 查看可用设备
```bash
flutter devices
```

#### 构建Windows发布版本
```bash
flutter build windows --release
```

#### 运行测试
```bash
flutter test
```

#### 代码分析
```bash
flutter analyze
```

## 项目结构

```
lib/
├── core/           # 核心配置和错误处理
├── models/         # 数据模型
├── providers/      # 状态管理
├── routes/         # 路由配置
├── screens/        # 页面
├── services/       # 服务层
├── theme/          # 主题配置
└── widgets/        # 通用组件
```

## 技术栈

- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [Riverpod](https://riverpod.dev/) - 状态管理
- [Dio](https://pub.dev/packages/dio) - 网络请求
- [GoRouter](https://pub.dev/packages/go_router) - 路由管理
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - 本地存储

## 开发说明

### 代码规范
- 遵循Flutter官方代码规范
- 使用 `flutter analyze` 检查代码问题
- 使用 `flutter format .` 格式化代码

### API配置
API相关配置位于 `lib/core/config/api_config.dart`，根据实际环境修改API地址。

## 文档

- [技术栈与界面风格说明](./docx/技术栈与界面风格说明.md)
- [接口文档](./docx/接口文档_AI学习助手.md)
- [架构分析](./ARCHITECTURE_ANALYSIS.md)
- [架构评审总结](./ARCHITECTURE_REVIEW_SUMMARY.md)

## 许可证

Copyright © 2025 AI Study Helper
