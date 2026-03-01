# Tasks

- [x] Task 1: 创建 OPDS 数据模型
  - [x] SubTask 1.1: 创建 `OpdsCatalog` 模型类（目录信息）
  - [x] SubTask 1.2: 创建 `OpdsEntry` 模型类（书籍条目）
  - [x] SubTask 1.3: 创建 `OpdsLink` 模型类（链接关系）
  - [x] SubTask 1.4: 创建 `OpdsAuthor` 和 `OpdsPublisher` 等辅助模型

- [x] Task 2: 实现 OPDS 解析服务
  - [x] SubTask 2.1: 创建 `OpdsService` 服务类
  - [x] SubTask 2.2: 实现 HTTP 客户端和 URL 验证
  - [x] SubTask 2.3: 实现 Atom/XML 解析器（使用 `xml` 包）
  - [x] SubTask 2.4: 实现导航链接和获取链接识别
  - [x] SubTask 2.5: 实现分页和搜索支持

- [x] Task 3: 实现书籍下载服务
  - [x] SubTask 3.1: 扩展 `FileService` 支持网络下载
  - [x] SubTask 3.2: 实现下载进度监听
  - [x] SubTask 3.3: 实现取消下载功能
  - [x] SubTask 3.4: 实现临时文件管理和清理

- [x] Task 4: 创建 OPDS 目录管理界面
  - [x] SubTask 4.1: 创建 `OpdsScreen` 主界面
  - [x] SubTask 4.2: 实现 OPDS 目录添加/编辑对话框
  - [x] SubTask 4.3: 实现目录列表展示和管理
  - [x] SubTask 4.4: 实现目录浏览界面（层级导航）

- [x] Task 5: 实现书籍详情和下载界面
  - [x] SubTask 5.1: 创建书籍详情展示组件
  - [x] SubTask 5.2: 实现下载进度对话框
  - [x] SubTask 5.3: 实现错误提示和重试逻辑
  - [x] SubTask 5.4: 实现下载完成后的导入确认

- [x] Task 6: 修改书架界面空状态逻辑
  - [x] SubTask 6.1: 修改 `ShelfScreen` 根据书籍数量控制按钮显示
  - [x] SubTask 6.2: 优化空状态 UI 提示
  - [x] SubTask 6.3: 测试空状态和非空状态切换

- [x] Task 7: 扩展"加入书籍"按钮功能
  - [x] SubTask 7.1: 修改 `BookOptionsSheet` 添加长按菜单
  - [x] SubTask 7.2: 添加"从 OPDS 导入"选项
  - [x] SubTask 7.3: 实现选项点击导航到 OPDS 界面

- [x] Task 8: 集成和状态管理
  - [x] SubTask 8.1: 在 `BookProvider` 中添加 OPDS 相关方法
  - [x] SubTask 8.2: 实现 OPDS 下载任务的状态管理
  - [x] SubTask 8.3: 添加下载任务列表和状态跟踪

- [x] Task 9: 依赖配置和国际化
  - [x] SubTask 9.1: 在 `pubspec.yaml` 中添加 `xml` 和 `http` 依赖
  - [x] SubTask 9.2: 添加国际化文本（中英文）
  - [x] SubTask 9.3: 配置网络权限（移动端）

- [ ] Task 10: 测试和验证
  - [ ] SubTask 10.1: 测试空状态按钮隐藏功能
  - [ ] SubTask 10.2: 测试 OPDS 目录添加和浏览
  - [ ] SubTask 10.3: 测试书籍下载和导入流程
  - [ ] SubTask 10.4: 测试错误处理和边界情况

# Task Dependencies
- Task 2 依赖于 Task 1
- Task 3 依赖于 Task 2
- Task 4 依赖于 Task 2
- Task 5 依赖于 Task 3 和 Task 4
- Task 7 依赖于 Task 4
- Task 8 依赖于 Task 2 和 Task 3
- Task 10 依赖于所有其他任务
