# Tasks - 全平台Flutter阅读器开发任务

## Task 1: 项目基础配置
更新pubspec.yaml，添加所有必要的依赖库
- [ ] 1.1 更新项目基本信息（名称、描述、版本约束）
- [ ] 1.2 添加UI相关依赖（cupertino_icons, material_design_icons_flutter）
- [ ] 1.3 添加状态管理依赖（provider）
- [ ] 1.4 添加路由管理依赖（go_router）
- [ ] 1.5 添加PDF/EPUB阅读器依赖（pdfrx, katbook_epub_reader）
- [ ] 1.6 添加文件处理依赖（file_picker, permission_handler）
- [ ] 1.7 添加本地存储依赖（shared_preferences, hive, hive_flutter, path_provider）
- [ ] 1.8 添加工具类依赖（intl, url_launcher, device_info_plus, package_info_plus）
- [ ] 1.9 添加开发依赖（flutter_lints, build_runner, hive_generator）

## Task 2: 项目结构搭建
创建完整的项目目录结构
- [ ] 2.1 创建routes/目录和app_router.dart
- [ ] 2.2 创建models/目录（book.dart, reading_progress.dart）
- [ ] 2.3 创建providers/目录（book_provider.dart, settings_provider.dart, reading_provider.dart）
- [ ] 2.4 创建services/目录（file_service.dart, storage_service.dart, platform_service.dart）
- [ ] 2.5 创建screens/目录（shelf_screen.dart, pdf_reader_screen.dart, epub_reader_screen.dart, settings_screen.dart）
- [ ] 2.6 创建widgets/目录（book_card.dart, file_import_button.dart, reading_progress_bar.dart）
- [ ] 2.7 创建utils/目录（constants.dart, extensions.dart, platform_helper.dart）
- [ ] 2.8 创建l10n/目录用于国际化

## Task 3: 数据模型实现
实现Hive支持的数据模型
- [ ] 3.1 实现Book模型（含Hive适配器）
- [ ] 3.2 实现ReadingProgress模型（含Hive适配器）
- [ ] 3.3 实现AppSettings模型（含Hive适配器）
- [ ] 3.4 生成Hive适配器代码（build_runner）

## Task 4: 服务层实现
实现核心服务类
- [ ] 4.1 实现StorageService（Hive数据库操作封装）
- [ ] 4.2 实现FileService（文件选择、元数据提取）
- [ ] 4.3 实现PlatformService（平台判断、窗口管理）

## Task 5: 状态管理实现
实现Provider状态管理
- [ ] 5.1 实现BookProvider（书架状态管理）
- [ ] 5.2 实现SettingsProvider（设置状态管理）
- [ ] 5.3 实现ReadingProvider（阅读状态管理）

## Task 6: 路由配置
配置go_router路由系统
- [ ] 6.1 配置应用路由（书架、PDF阅读、EPUB阅读、设置）
- [ ] 6.2 实现路由过渡动画
- [ ] 6.3 配置深度链接支持

## Task 7: 书架首页实现
实现书架首页界面
- [ ] 7.1 实现ShelfScreen页面框架
- [ ] 7.2 实现BookCard组件（网格/列表视图）
- [ ] 7.3 实现书籍操作菜单（长按/右键）
- [ ] 7.4 实现顶部工具栏（搜索、导入、设置）
- [ ] 7.5 实现空书架提示界面

## Task 8: 文件导入功能
实现文件导入功能
- [ ] 8.1 实现FileImportButton组件
- [ ] 8.2 实现文件选择功能（file_picker）
- [ ] 8.3 实现PDF元数据提取
- [ ] 8.4 实现EPUB元数据提取
- [ ] 8.5 实现批量导入功能
- [ ] 8.6 实现桌面端拖拽导入
- [ ] 8.7 实现Web端文件上传

## Task 9: PDF阅读器实现
实现PDF阅读功能
- [ ] 9.1 实现PdfReaderScreen页面框架
- [ ] 9.2 集成pdfrx渲染引擎
- [ ] 9.3 实现目录导航功能
- [ ] 9.4 实现页面跳转和缩略图预览
- [ ] 9.5 实现缩放和文本选择
- [ ] 9.6 实现搜索功能
- [ ] 9.7 实现阅读工具栏
- [ ] 9.8 实现移动端手势支持
- [ ] 9.9 实现桌面端快捷键支持

## Task 10: EPUB阅读器实现
实现EPUB阅读功能
- [ ] 10.1 实现EpubReaderScreen页面框架
- [ ] 10.2 集成katbook_epub_reader
- [ ] 10.3 实现目录导航功能
- [ ] 10.4 实现阅读设置面板（字体、行距等）
- [ ] 10.5 实现主题切换（白天/夜晚/Sepia）
- [ ] 10.6 实现书签功能
- [ ] 10.7 实现笔记功能
- [ ] 10.8 实现阅读进度保存

## Task 11: 设置页面实现
实现设置管理功能
- [ ] 11.1 实现SettingsScreen页面框架
- [ ] 11.2 实现阅读设置选项
- [ ] 11.3 实现主题设置选项
- [ ] 11.4 实现语言切换功能
- [ ] 11.5 实现数据导出/导入功能
- [ ] 11.6 实现关于页面

## Task 12: 国际化实现
实现多语言支持
- [ ] 12.1 配置Flutter国际化支持
- [ ] 12.2 创建中文翻译文件
- [ ] 12.3 创建英文翻译文件
- [ ] 12.4 替换所有硬编码文本为国际化字符串

## Task 13: 平台适配
实现各平台特定功能
- [ ] 13.1 实现移动端适配（刘海屏、深色模式）
- [ ] 13.2 实现桌面端菜单栏（Windows/macOS/Linux）
- [ ] 13.3 实现桌面端快捷键支持
- [ ] 13.4 实现桌面端右键菜单
- [ ] 13.5 配置Web端PWA支持
- [ ] 13.6 实现Web端响应式布局

## Task 14: 应用入口和初始化
实现应用入口和初始化逻辑
- [ ] 14.1 重构main.dart（初始化Hive、Provider等）
- [ ] 14.2 实现App根组件（主题、路由配置）
- [ ] 14.3 实现启动加载页面
- [ ] 14.4 实现错误处理边界

## Task 15: 测试实现
添加测试代码
- [ ] 15.1 添加单元测试（模型、服务）
- [ ] 15.2 添加Widget测试（组件）
- [ ] 15.3 添加集成测试（核心流程）

## Task 16: 平台配置完善
完善各平台配置文件
- [ ] 16.1 完善Android配置（权限、最低版本）
- [ ] 16.2 完善iOS配置（权限、最低版本）
- [ ] 16.3 完善Windows配置
- [ ] 16.4 完善macOS配置
- [ ] 16.5 完善Linux配置
- [ ] 16.6 完善Web配置（PWA manifest）

# Task Dependencies
- Task 3 依赖 Task 2
- Task 4 依赖 Task 3
- Task 5 依赖 Task 4
- Task 6 依赖 Task 5
- Task 7 依赖 Task 5, Task 6
- Task 8 依赖 Task 4, Task 7
- Task 9 依赖 Task 5, Task 6, Task 8
- Task 10 依赖 Task 5, Task 6, Task 8
- Task 11 依赖 Task 5, Task 6
- Task 12 依赖 Task 7, Task 9, Task 10, Task 11
- Task 13 依赖 Task 7, Task 9, Task 10, Task 11
- Task 14 依赖 Task 1-6
- Task 15 依赖 Task 14
- Task 16 依赖 Task 1
