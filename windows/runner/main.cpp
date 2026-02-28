#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// 定义应用程序的唯一标识符
#define APP_UNIQUE_ID L"book_reader_flutter_unique_mutex"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // 创建互斥量检测单实例
  HANDLE mutex = ::CreateMutexW(nullptr, TRUE, APP_UNIQUE_ID);
  if (mutex == nullptr) {
    return EXIT_FAILURE;
  }

  // 如果互斥量已存在，说明程序已在运行
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    // 程序已运行，找到已存在的窗口并聚焦
    HWND hwnd = ::FindWindowW(nullptr, L"book_reader_flutter");
    if (hwnd != nullptr) {
      // 如果窗口最小化，恢复它
      if (::IsIconic(hwnd)) {
        ::ShowWindow(hwnd, SW_RESTORE);
      }
      // 将窗口置于前台并聚焦
      ::SetForegroundWindow(hwnd);
      // 如果窗口不在前台，使用 AttachThreadInput 强制聚焦
      ::BringWindowToTop(hwnd);
    }
    ::CloseHandle(mutex);
    return EXIT_SUCCESS;
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"book_reader_flutter", origin, size)) {
    ::CloseHandle(mutex);
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CloseHandle(mutex);
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
