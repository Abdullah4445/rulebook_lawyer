import 'package:lawyer/utils/DarkThemePreference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  int _darkTheme = 0;

  int get darkTheme => _darkTheme;

  set darkTheme(int value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  /// Returns true when the app should render in dark mode.
  ///
  /// Convention used for the persisted [_darkTheme] int:
  ///   * 0  = follow the OS / system theme (default, what new users see)
  ///   * 1  = forced light
  ///   * 2  = forced dark
  ///
  /// Previously this always returned the stored toggle and ignored the OS
  /// brightness, which left widgets that read `getThem()` rendering in
  /// light-mode colors even when the system (and scaffold) were dark — so
  /// text-fields and section labels looked invisible.
  bool getThem() {
    switch (_darkTheme) {
      case 1:
        return false;
      case 2:
        return true;
      case 0:
      default:
        return getSystemThem();
    }
  }

  bool getSystemThem() {
    var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }
}
