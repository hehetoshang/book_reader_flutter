# Checklist - 全平台Flutter阅读器验收清单

## 项目基础配置
- [ ] pubspec.yaml 包含所有指定依赖
- [ ] 项目基本信息（名称、描述）已更新
- [ ] Flutter SDK版本约束 >=3.0.0

## 项目结构
- [ ] lib/routes/ 目录存在且包含 app_router.dart
- [ ] lib/models/ 目录存在且包含 book.dart, reading_progress.dart
- [ ] lib/providers/ 目录存在且包含 book_provider.dart, settings_provider.dart, reading_provider.dart
- [ ] lib/services/ 目录存在且包含 file_service.dart, storage_service.dart, platform_service.dart
- [ ] lib/screens/ 目录存在且包含 shelf_screen.dart, pdf_reader_screen.dart, epub_reader_screen.dart, settings_screen.dart
- [ ] lib/widgets/ 目录存在且包含 book_card.dart, file_import_button.dart, reading_progress_bar.dart
- [ ] lib/utils/ 目录存在且包含 constants.dart, extensions.dart, platform_helper.dart
- [ ] lib/l10n/ 目录存在且包含国际化文件

## 数据模型
- [ ] Book 模型包含所有必需字段（id, title, author, coverPath, filePath, fileType, addedAt, lastReadAt, readingProgress）
- [ ] Book 模型支持 Hive 序列化（@HiveType, @HiveField）
- [ ] ReadingProgress 模型包含所有必需字段
- [ ] ReadingProgress 模型支持 Hive 序列化
- [ ] AppSettings 模型包含主题、语言、阅读设置字段
- [ ] Hive 适配器代码已生成

## 服务层
- [ ] StorageService 封装了所有 Hive CRUD 操作
- [ ] FileService 支持文件选择和元数据提取
- [ ] FileService 支持 PDF 元数据提取
- [ ] FileService 支持 EPUB 元数据提取
- [ ] PlatformService 提供平台判断方法
- [ ] PlatformService 支持桌面端窗口管理

## 状态管理
- [ ] BookProvider 管理书籍列表状态
- [ ] BookProvider 支持添加/删除/更新书籍
- [ ] SettingsProvider 管理应用设置状态
- [ ] SettingsProvider 支持持久化设置
- [ ] ReadingProvider 管理阅读状态
- [ ] ReadingProvider 支持阅读进度保存

## 路由配置
- [ ] go_router 路由配置正确
- [ ] 包含书架、PDF阅读、EPUB阅读、设置路由
- [ ] 路由参数传递正确
- [ ] 支持路由过渡动画

## 书架首页
- [ ] ShelfScreen 页面正常显示
- [ ] 支持网格/列表视图切换
- [ ] 桌面端默认显示网格视图
- [ ] BookCard 显示封面、标题、作者、进度
- [ ] 长按/右键显示操作菜单
- [ ] 支持删除、收藏、标记已读操作
- [ ] 顶部工具栏包含搜索框
- [ ] 顶部工具栏包含导入按钮
- [ ] 顶部工具栏包含设置入口
- [ ] 空书架时显示提示界面

## 文件导入
- [ ] FileImportButton 组件正常工作
- [ ] 支持 file_picker 选择文件
- [ ] 支持 PDF 文件导入
- [ ] 支持 EPUB 文件导入
- [ ] 自动提取并显示文件元数据
- [ ] 支持批量导入多个文件
- [ ] 桌面端支持拖拽文件导入
- [ ] Web端支持点击上传文件
- [ ] Web端支持拖拽上传文件

## PDF阅读器
- [ ] PdfReaderScreen 页面正常显示
- [ ] pdfrx 渲染引擎正常工作
- [ ] 支持目录导航
- [ ] 支持页面跳转
- [ ] 支持缩略图预览
- [ ] 支持页面缩放
- [ ] 支持文本选择
- [ ] 支持文本搜索
- [ ] 支持页面旋转
- [ ] 移动端支持滑动翻页手势
- [ ] 移动端支持双指缩放手势
- [ ] 桌面端支持鼠标滚轮翻页
- [ ] 桌面端支持 Ctrl+F 搜索
- [ ] 阅读工具栏正常显示
- [ ] 支持夜间模式切换

## EPUB阅读器
- [ ] EpubReaderScreen 页面正常显示
- [ ] katbook_epub_reader 正常工作
- [ ] 支持目录导航
- [ ] 支持字体大小调整
- [ ] 支持行距调整
- [ ] 支持字距调整
- [ ] 支持对齐方式调整
- [ ] 支持白天主题
- [ ] 支持夜晚主题
- [ ] 支持护眼（Sepia）主题
- [ ] 支持添加书签
- [ ] 支持查看书签列表
- [ ] 支持添加笔记
- [ ] 阅读进度自动保存
- [ ] 阅读设置自动保存

## 设置页面
- [ ] SettingsScreen 页面正常显示
- [ ] 支持阅读设置调整
- [ ] 支持主题模式切换
- [ ] 支持语言切换（中文/英文）
- [ ] 支持数据导出功能
- [ ] 支持数据导入功能
- [ ] 关于页面显示版本信息
- [ ] 关于页面显示开源许可

## 国际化
- [ ] Flutter 国际化已配置
- [ ] 中文翻译文件完整
- [ ] 英文翻译文件完整
- [ ] 所有 UI 文本使用国际化字符串
- [ ] 语言切换即时生效

## 移动端适配
- [ ] Android 应用正常运行
- [ ] iOS 应用正常运行
- [ ] 支持 Cupertino 风格导航手势
- [ ] 适配刘海屏/挖孔屏
- [ ] 支持跟随系统深色模式
- [ ] 支持滑动翻页手势
- [ ] 支持双指缩放手势

## 桌面端适配
- [ ] Windows 应用正常运行
- [ ] macOS 应用正常运行
- [ ] Linux 应用正常运行
- [ ] 显示菜单栏（File, Edit等）
- [ ] File->Open 菜单正常工作
- [ ] Edit->Settings 菜单正常工作
- [ ] 支持窗口大小记忆
- [ ] 支持右键菜单
- [ ] Ctrl+O 快捷键打开文件
- [ ] Ctrl+F 快捷键搜索
- [ ] Ctrl++ 快捷键放大
- [ ] Ctrl+- 快捷键缩小
- [ ] F11 快捷键全屏

## Web端适配
- [ ] Web 应用正常运行
- [ ] PWA manifest 配置正确
- [ ] 支持离线访问
- [ ] 响应式布局正常
- [ ] 支持浏览器前进/后退按钮

## 数据持久化
- [ ] Hive 数据库初始化正常
- [ ] 书籍数据持久化保存
- [ ] 阅读进度持久化保存
- [ ] 设置项持久化保存
- [ ] 应用重启后数据不丢失

## 测试
- [ ] 包含单元测试
- [ ] 包含 Widget 测试
- [ ] 测试覆盖率合理

## 代码质量
- [ ] 代码包含必要注释
- [ ] 平台相关代码有明确注释
- [ ] 错误处理完善
- [ ] 加载状态显示正常
- [ ] 遵循 Flutter 官方最佳实践
