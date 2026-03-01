# 书籍导入增强功能规范

## Why
当前应用仅支持从本地文件导入书籍，缺乏在线书籍资源获取能力。需要实现 OPDS 导入功能以扩展书籍来源，同时优化空状态下的 UI 显示逻辑，提升用户体验。

## What Changes
- **新增空状态按钮隐藏逻辑**：当书籍列表为空时，隐藏右下角的"导入书籍"和"搜索"按钮
- **新增 OPDS 导入功能**：在"加入书籍"按钮的操作选项中添加"从 OPDS 导入"选项
- **实现完整的 OPDS 客户端**：支持 OPDS 目录发现、解析、书籍下载和导入
- **新增 OPDS 配置界面**：允许用户添加和管理 OPDS 目录源
- **新增导入进度显示**：实时显示书籍下载和导入进度

**BREAKING**: 无破坏性变更

## Impact
- **Affected specs**: 
  - 书籍管理功能增强
  - 新增 OPDS 目录订阅能力
  - 新增网络下载和文件管理能力
- **Affected code**:
  - `lib/screens/shelf_screen.dart` - 修改按钮显示逻辑
  - `lib/widgets/book_options_sheet.dart` - 添加 OPDS 导入选项
  - 新增 `lib/screens/opds_screen.dart` - OPDS 目录浏览界面
  - 新增 `lib/services/opds_service.dart` - OPDS 解析和下载服务
  - 新增 `lib/models/opds_catalog.dart` - OPDS 目录数据模型
  - `lib/providers/book_provider.dart` - 扩展书籍导入方法

## ADDED Requirements

### Requirement: 空状态按钮隐藏
The system SHALL 隐藏右下角的操作按钮（导入书籍、搜索）当书籍列表为空时，仅显示空状态提示信息。

#### Scenario: 书籍列表为空
- **WHEN** 用户打开应用且系统中没有任何书籍
- **THEN** 右下角的"导入书籍"按钮和"搜索"按钮完全不可见
- **THEN** 仅显示"暂无书籍"提示和"导入书籍"的引导文字

#### Scenario: 书籍列表非空
- **WHEN** 系统中存在至少一本书籍
- **THEN** 右下角的"导入书籍"按钮和"搜索"按钮正常显示
- **THEN** 用户可以正常使用所有操作功能

### Requirement: OPDS 导入入口
The system SHALL 在"加入书籍"按钮的长按菜单中提供"从 OPDS 导入"选项。

#### Scenario: 访问 OPDS 导入
- **WHEN** 用户长按"加入书籍"按钮
- **THEN** 显示操作菜单，包含"从文件导入"和"从 OPDS 导入"两个选项
- **THEN** 用户可以选择"从 OPDS 导入"进入 OPDS 目录浏览界面

### Requirement: OPDS 目录管理
The system SHALL 提供 OPDS 目录源的添加、编辑、删除和浏览功能。

#### Scenario: 添加 OPDS 目录
- **WHEN** 用户首次使用 OPDS 功能
- **THEN** 显示引导界面，提示添加 OPDS 目录 URL
- **THEN** 用户可以输入 OPDS 目录的 Atom feed URL
- **THEN** 系统验证 URL 有效性并保存

#### Scenario: 浏览 OPDS 目录
- **WHEN** 用户选择已配置的 OPDS 目录
- **THEN** 解析并显示目录的层级结构
- **THEN** 支持导航到子分类和书籍列表
- **THEN** 显示书籍封面、标题、作者等元数据

### Requirement: OPDS 书籍下载与导入
The system SHALL 支持从 OPDS 目录下载书籍文件并导入到本地书架。

#### Scenario: 下载并导入书籍
- **WHEN** 用户在 OPDS 目录中选择一本书籍
- **THEN** 显示书籍详情和下载选项
- **THEN** 用户确认下载后，开始下载书籍文件
- **THEN** 下载完成后自动解析元数据并添加到书架
- **THEN** 显示下载和导入进度

#### Scenario: 下载进度显示
- **WHEN** 书籍正在下载
- **THEN** 显示实时进度条（百分比、已下载/总大小）
- **THEN** 显示下载速度估计
- **THEN** 支持取消下载操作

#### Scenario: 错误处理
- **WHEN** 下载失败（网络错误、URL 无效等）
- **THEN** 显示明确的错误信息
- **THEN** 提供重试选项
- **THEN** 清理未完成的临时文件

### Requirement: OPDS 解析能力
The system SHALL 支持解析标准 OPDS 1.2 规范的 Atom feed。

#### Scenario: 解析 OPDS Feed
- **WHEN** 接收到 OPDS 目录响应
- **THEN** 解析 Atom 命名空间的 feed 结构
- **THEN** 提取导航链接（navigation links）和 acquisition links
- **THEN** 支持分页（pagination links）
- **THEN** 支持搜索接口（OpenSearch）

#### Scenario: 提取书籍元数据
- **WHEN** 解析书籍条目
- **THEN** 提取标题、作者、出版商、语言等信息
- **THEN** 提取封面图片 URL
- **THEN** 识别可获取的格式（EPUB、PDF 等）
- **THEN** 提取摘要和分类信息

## MODIFIED Requirements

### Requirement: 书籍导入流程
**原功能**：仅支持从本地文件系统导入书籍

**修改后**：
- 支持从本地文件导入
- 支持从 OPDS 目录下载并导入
- 统一的书籍元数据提取和存储流程
- 支持批量导入（多本书籍）

## REMOVED Requirements

### Requirement: 无
**Reason**: 本次增强为功能扩展，不移除任何现有功能
**Migration**: 不适用
