# Universal Reader - 全平台Flutter阅读器 Spec

## Why
开发一款支持PDF和EPUB格式的跨平台阅读器，覆盖手机、平板、桌面和网页，提供统一的阅读体验和本地数据管理能力。

## What Changes
- **BREAKING**: 重构现有项目结构，从默认Flutter模板迁移到完整阅读器架构
- 添加全平台支持的依赖库（PDF/EPUB阅读器、文件选择、本地存储等）
- 实现书架首页、PDF阅读器、EPUB阅读器、设置页面等核心功能
- 添加桌面端菜单栏、快捷键、右键菜单支持
- 实现PWA配置支持Web端离线访问
- 添加国际化支持（中英文）
- 实现数据持久化（Hive数据库）

## Impact
- Affected specs: 书架管理、文件导入、PDF阅读、EPUB阅读、设置管理、数据持久化
- Affected code: pubspec.yaml, lib/ 目录下所有文件, 各平台配置文件

## ADDED Requirements

### Requirement: 项目基础配置
The system SHALL 配置完整的Flutter项目依赖和基础结构

#### Scenario: 依赖配置
- **GIVEN** 现有的Flutter项目
- **WHEN** 更新pubspec.yaml
- **THEN** 添加所有必要的依赖库（UI、状态管理、PDF/EPUB阅读器、文件处理、存储等）

#### Scenario: 项目结构
- **GIVEN** 现有的lib/目录
- **WHEN** 创建项目结构
- **THEN** 按照规范创建routes/, models/, providers/, services/, screens/, widgets/, utils/目录

### Requirement: 数据模型
The system SHALL 定义书籍和阅读进度的数据模型

#### Scenario: Book模型
- **GIVEN** 需要存储书籍信息
- **WHEN** 创建Book模型
- **THEN** 包含id, title, author, coverPath, filePath, fileType, addedAt, lastReadAt, readingProgress等字段
- **AND** 支持Hive序列化

#### Scenario: ReadingProgress模型
- **GIVEN** 需要记录阅读进度
- **WHEN** 创建ReadingProgress模型
- **THEN** 包含bookId, currentPage/totalPages（PDF）或 currentChapter/cfi（EPUB）, lastReadPosition, updatedAt等字段
- **AND** 支持Hive序列化

### Requirement: 状态管理
The system SHALL 使用Provider管理应用状态

#### Scenario: BookProvider
- **GIVEN** 书架需要状态管理
- **WHEN** 创建BookProvider
- **THEN** 管理书籍列表、加载状态、添加/删除/更新书籍操作

#### Scenario: SettingsProvider
- **GIVEN** 应用需要持久化设置
- **WHEN** 创建SettingsProvider
- **THEN** 管理主题模式、字体大小、阅读设置等

#### Scenario: ReadingProvider
- **GIVEN** 阅读器需要状态管理
- **WHEN** 创建ReadingProvider
- **THEN** 管理当前阅读状态、进度、书签等

### Requirement: 服务层
The system SHALL 封装文件、存储和平台相关操作

#### Scenario: FileService
- **GIVEN** 需要处理文件导入
- **WHEN** 创建FileService
- **THEN** 支持文件选择、元数据提取（PDF/EPUB）、批量导入、拖拽导入

#### Scenario: StorageService
- **GIVEN** 需要本地数据存储
- **WHEN** 创建StorageService
- **THEN** 封装Hive操作，管理书籍、进度、设置的CRUD

#### Scenario: PlatformService
- **GIVEN** 需要平台适配
- **WHEN** 创建PlatformService
- **THEN** 提供平台判断、窗口管理、菜单栏控制等方法

### Requirement: 书架首页
The system SHALL 提供书籍管理和浏览界面

#### Scenario: 书籍展示
- **GIVEN** 用户打开应用
- **WHEN** 显示书架首页
- **THEN** 以网格/列表形式展示书籍卡片（封面、标题、作者、进度）
- **AND** 桌面端默认网格，移动端自适应

#### Scenario: 书籍操作
- **GIVEN** 用户查看书籍
- **WHEN** 长按/右键书籍
- **THEN** 显示操作菜单（打开、删除、收藏、标记已读）

#### Scenario: 顶部工具栏
- **GIVEN** 用户在书架页面
- **WHEN** 查看顶部栏
- **THEN** 包含标题、搜索框、导入按钮、设置入口

### Requirement: 文件导入
The system SHALL 支持多方式文件导入

#### Scenario: 本地文件导入
- **GIVEN** 用户点击导入按钮
- **WHEN** 选择本地文件
- **THEN** 使用file_picker选择PDF/EPUB文件
- **AND** 自动提取元数据并添加到书架

#### Scenario: 批量导入
- **GIVEN** 用户选择多个文件
- **WHEN** 确认导入
- **THEN** 批量处理并显示进度

#### Scenario: 拖拽导入（桌面端）
- **GIVEN** 用户在桌面端
- **WHEN** 拖拽文件到应用窗口
- **THEN** 接收文件并导入

#### Scenario: Web端上传
- **GIVEN** 用户在Web端
- **WHEN** 点击上传或拖拽文件
- **THEN** 支持文件上传并导入

### Requirement: PDF阅读器
The system SHALL 提供完整的PDF阅读功能

#### Scenario: PDF渲染
- **GIVEN** 用户打开PDF文件
- **WHEN** 进入PDF阅读器
- **THEN** 使用pdfrx渲染PDF内容

#### Scenario: 导航功能
- **GIVEN** 用户阅读PDF
- **WHEN** 需要导航
- **THEN** 支持目录导航、页面跳转、缩略图预览

#### Scenario: 阅读操作
- **GIVEN** 用户阅读PDF
- **WHEN** 进行操作
- **THEN** 支持缩放、文本选择、搜索、页面旋转

#### Scenario: 手势支持
- **GIVEN** 用户在移动端
- **WHEN** 使用手势
- **THEN** 支持单指滑动翻页、双指缩放

#### Scenario: 桌面端操作
- **GIVEN** 用户在桌面端
- **WHEN** 使用鼠标/键盘
- **THEN** 支持鼠标滚轮翻页、Ctrl+F搜索

### Requirement: EPUB阅读器
The system SHALL 提供完整的EPUB阅读功能

#### Scenario: EPUB渲染
- **GIVEN** 用户打开EPUB文件
- **WHEN** 进入EPUB阅读器
- **THEN** 使用katbook_epub_reader渲染内容

#### Scenario: 阅读设置
- **GIVEN** 用户阅读EPUB
- **WHEN** 调整设置
- **THEN** 支持字体大小、行距、字距、对齐方式调整

#### Scenario: 主题切换
- **GIVEN** 用户阅读EPUB
- **WHEN** 切换主题
- **THEN** 支持白天/夜晚/护眼（Sepia）模式

#### Scenario: 书签和笔记
- **GIVEN** 用户阅读EPUB
- **WHEN** 添加书签或笔记
- **THEN** 保存书签位置和笔记内容

### Requirement: 设置页面
The system SHALL 提供应用设置管理

#### Scenario: 阅读设置
- **GIVEN** 用户进入设置
- **WHEN** 查看阅读设置
- **THEN** 可调整默认字体、主题、翻页方式等

#### Scenario: 数据管理
- **GIVEN** 用户进入设置
- **WHEN** 查看数据管理
- **THEN** 支持导出/导入数据库（备份功能）

#### Scenario: 关于页面
- **GIVEN** 用户进入设置
- **WHEN** 查看关于
- **THEN** 显示应用版本、开源许可等信息

### Requirement: 平台适配
The system SHALL 针对不同平台进行适配

#### Scenario: 移动端适配
- **GIVEN** 应用在Android/iOS运行
- **WHEN** 用户使用应用
- **THEN** 使用Cupertino风格导航手势、适配刘海屏、跟随系统深色模式

#### Scenario: 桌面端适配
- **GIVEN** 应用在Windows/macOS/Linux运行
- **WHEN** 用户使用应用
- **THEN** 显示菜单栏（File->Open, Edit->Settings等）
- **AND** 支持窗口大小记忆、右键菜单
- **AND** 支持快捷键（Ctrl+O打开、Ctrl+F搜索、Ctrl++/-缩放、F11全屏）

#### Scenario: Web端适配
- **GIVEN** 应用在浏览器运行
- **WHEN** 用户使用应用
- **THEN** 支持PWA离线访问、响应式布局、浏览器前进后退

### Requirement: 国际化
The system SHALL 支持多语言

#### Scenario: 语言切换
- **GIVEN** 用户使用应用
- **WHEN** 切换语言
- **THEN** 支持中文和英文切换
- **AND** 所有UI文本支持国际化

### Requirement: 数据持久化
The system SHALL 使用Hive进行本地数据存储

#### Scenario: 数据库初始化
- **GIVEN** 应用启动
- **WHEN** 初始化数据库
- **THEN** 使用Hive初始化并注册适配器

#### Scenario: 数据CRUD
- **GIVEN** 应用运行中
- **WHEN** 进行数据操作
- **THEN** 支持书籍、进度、设置的增删改查

## MODIFIED Requirements
无

## REMOVED Requirements
无
