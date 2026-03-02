// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '通用阅读器';

  @override
  String get bookshelf => '书架';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get openFile => '打开文件';

  @override
  String get pdfReader => 'PDF阅读器';

  @override
  String get epubReader => 'EPUB阅读器';

  @override
  String get noBooks => '暂无书籍';

  @override
  String get addYourFirstBook => '添加您的第一本书';

  @override
  String get darkMode => '深色模式';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '系统';

  @override
  String get readerSettings => '阅读器设置';

  @override
  String get fontSize => '字体大小';

  @override
  String get theme => '主题';

  @override
  String get autoSaveProgress => '自动保存进度';

  @override
  String get clearCache => '清除缓存';

  @override
  String get cacheCleared => '缓存清除成功';

  @override
  String get clearCookies => '清除 Cookies';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleteBookConfirm => '确定要删除这本书吗？';

  @override
  String get bookDeleted => '书籍删除成功';

  @override
  String get share => '分享';

  @override
  String get fileFormatNotSupported => '文件格式不支持';

  @override
  String get permissionDenied => '权限被拒绝';

  @override
  String get errorOpeningFile => '打开文件失败';

  @override
  String aboutApp(Object appName) {
    return '关于 $appName';
  }

  @override
  String get version => '版本';

  @override
  String get developer => '开发者';

  @override
  String get description => '描述';

  @override
  String get back => '返回';

  @override
  String get next => '下一页';

  @override
  String get search => '搜索';

  @override
  String get bookmarks => '书签';

  @override
  String get tableOfContents => '目录';

  @override
  String get readingProgress => '阅读进度';

  @override
  String get appearance => '外观';

  @override
  String get pdfSettings => 'PDF设置';

  @override
  String get epubSettings => 'EPUB设置';

  @override
  String get dataManagement => '数据管理';

  @override
  String get pdfReaderOptions => 'PDF阅读器选项';

  @override
  String get epubReaderOptions => 'EPUB阅读器选项';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '系统';

  @override
  String get dataExportComingSoon => '数据导出功能即将推出';

  @override
  String failedToExportData(Object error) {
    return '导出数据失败: $error';
  }

  @override
  String get dataImportComingSoon => '数据导入功能即将推出';

  @override
  String failedToImportData(Object error) {
    return '导入数据失败: $error';
  }

  @override
  String get clearAllDataConfirm => '这将删除所有书籍和阅读进度。此操作无法撤销。';

  @override
  String get allDataCleared => '所有数据已清除';

  @override
  String failedToClearData(Object error) {
    return '清除数据失败：$error';
  }

  @override
  String get noDescription => '无描述';

  @override
  String get unknown => '未知';

  @override
  String get open => '打开';

  @override
  String get removeFromFavorites => '从收藏夹移除';

  @override
  String get addToFavorites => '添加到收藏夹';

  @override
  String get markAsUnread => '标记为未读';

  @override
  String get markAsRead => '标记为已读';

  @override
  String get bookInfo => '书籍信息';

  @override
  String get deleteBook => '删除书籍';

  @override
  String get bookInfoTitle => '书名';

  @override
  String get bookInfoAuthor => '作者';

  @override
  String get bookInfoType => '类型';

  @override
  String get bookInfoAdded => '添加时间';

  @override
  String get bookInfoLastRead => '最后阅读';

  @override
  String get bookInfoPages => '页数';

  @override
  String get bookInfoProgress => '进度';

  @override
  String get bookInfoFile => '文件';

  @override
  String get close => '关闭';

  @override
  String get opdsCatalogs => 'OPDS 目录';

  @override
  String get noOpdsCatalogs => '暂无 OPDS 目录';

  @override
  String get noOpdsCatalogsDescription => '添加 OPDS 目录以浏览和下载在线书籍';

  @override
  String get addOpdsCatalog => '添加 OPDS 目录';

  @override
  String get editOpdsCatalog => '编辑 OPDS 目录';

  @override
  String get deleteOpdsCatalog => '删除 OPDS 目录';

  @override
  String deleteOpdsCatalogConfirm(Object title) {
    return '确定要删除目录\"$title\"吗？';
  }

  @override
  String get opdsCatalogAdded => 'OPDS 目录已添加';

  @override
  String get opdsCatalogUpdated => 'OPDS 目录已更新';

  @override
  String get opdsCatalogDeleted => 'OPDS 目录已删除';

  @override
  String get opdsUrl => 'OPDS 目录 URL';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionSuccessful => '连接成功';

  @override
  String get failedToLoadOpdsCatalog => '加载 OPDS 目录失败';

  @override
  String get noBooksFound => '未找到书籍';

  @override
  String get filters => '筛选';

  @override
  String get download => '下载';

  @override
  String get bookDownloadedSuccessfully => '书籍下载成功';

  @override
  String failedToDownloadBook(Object error) {
    return '下载书籍失败：$error';
  }

  @override
  String get summary => '简介';

  @override
  String get disabled => '已禁用';

  @override
  String get enable => '启用';

  @override
  String get disable => '禁用';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get save => '保存';

  @override
  String get fieldRequired => '此字段为必填项';

  @override
  String get invalidUrl => 'URL 格式无效';

  @override
  String get retry => '重试';

  @override
  String get noContent => '无内容';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get browseAndDownloadOnlineBooks => '浏览和下载在线书籍';

  @override
  String get authenticationRequired => '需要身份验证';

  @override
  String get authenticationRequiredMessage => '此 OPDS 目录需要身份验证。请输入您的凭据。';

  @override
  String get errorPageNotFound => '页面未找到';

  @override
  String get errorPageNotFoundSuggestion => '无法找到请求的页面。请检查 URL。';

  @override
  String errorServer(Object statusCode) {
    return '服务器错误 ($statusCode)';
  }

  @override
  String get errorServerSuggestion => '服务器遇到内部错误，请稍后重试。';

  @override
  String errorAuthFailed(Object statusCode) {
    return '认证失败 ($statusCode)';
  }

  @override
  String get errorAuthFailedSuggestion => '需要身份验证，请在设置中检查您的凭据。';

  @override
  String get errorNetwork => '网络连接失败';

  @override
  String get errorNetworkSuggestion => '请检查您的网络连接后重试。';

  @override
  String get errorLoadFailed => '加载失败';

  @override
  String get errorLoadFailedSuggestion => '发生未知错误，您可以尝试重试。';

  @override
  String get importBooks => '导入书籍';

  @override
  String get importFromFile => '从文件导入';

  @override
  String get importFromFileSubtitle => '从设备中选择文件';

  @override
  String get importFromOpds => '从 OPDS 导入';

  @override
  String get importFromOpdsSubtitle => '浏览在线书籍目录';

  @override
  String get title => '标题';

  @override
  String get catalogDescription => '描述';

  @override
  String get catalogDescriptionHint => '可选描述';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get savePassword => '保存密码';

  @override
  String get savePasswordSubtitle => '保存凭据以便下次访问';
}
