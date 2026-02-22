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
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

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
  String get description => '一款支持PDF和EPUB格式的跨平台阅读器';

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
    return '清除数据失败: $error';
  }
}
