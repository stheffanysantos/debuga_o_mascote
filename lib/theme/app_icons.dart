import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícones do design — reproduzidos a partir dos `<path>` SVG originais do
/// canvas do Claude Design, para fidelidade visual exata. Todos usam
/// viewBox 24x24.
abstract final class AppIcons {
  static Widget play({double size = 24, required Color color}) {
    return _svg(size, '<path d="M7 4.5v15a1 1 0 0 0 1.5.87l12-7.5a1 1 0 0 0 0-1.74l-12-7.5A1 1 0 0 0 7 4.5z" fill="${_hex(color)}"/>');
  }

  static Widget chevronLeft({double size = 24, required Color color}) {
    return _svg(size, '<path d="M15 18l-6-6 6-6" stroke="${_hex(color)}" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>');
  }

  static Widget star({double size = 24, required Color color}) {
    return _svg(size, '<path d="M12 2l2.9 6.6 7.1.7-5.4 4.8 1.6 7L12 17.4 5.8 21l1.6-7L2 9.3l7.1-.7z" fill="${_hex(color)}"/>');
  }

  static Widget lock({double size = 24, required Color color}) {
    return _svg(size, '''
      <rect x="4" y="11" width="16" height="10" rx="3" fill="none" stroke="${_hex(color)}" stroke-width="2.6"/>
      <path d="M8 11V7a4 4 0 0 1 8 0v4" fill="none" stroke="${_hex(color)}" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget walk({double size = 24, required Color color}) {
    return _svg(size, '<path d="M12 19V5M5 12l7-7 7 7" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>');
  }

  static Widget turnLeft({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M9 14L4 9l5-5" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M4 9h11a5 5 0 0 1 0 10h-3" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget turnRight({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M15 14l5-5-5-5" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M20 9H9a5 5 0 0 0 0 10h3" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget repeat({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M17 2l4 4-4 4" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M3 11V9a4 4 0 0 1 4-4h14" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M7 22l-4-4 4-4" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M21 13v2a4 4 0 0 1-4 4H3" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget refresh({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M3 12a9 9 0 1 0 3-6.7" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M3 4v5h5" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget arrowRight({double size = 24, required Color color}) {
    return _svg(size, '<path d="M5 12h14M13 6l6 6-6 6" fill="none" stroke="${_hex(color)}" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/>');
  }

  static Widget volumeOn({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M4 9v6h4l5 4V5L8 9H4z" fill="${_hex(color)}"/>
      <path d="M16.5 9a4.5 4.5 0 0 1 0 6" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <path d="M19 6.5a8.5 8.5 0 0 1 0 11" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
    ''');
  }

  static Widget volumeOff({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M4 9v6h4l5 4V5L8 9H4z" fill="${_hex(color)}"/>
      <path d="M16 9l6 6M22 9l-6 6" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
    ''');
  }

  static Widget settings({double size = 24, required Color color}) {
    return _svg(size, '''
      <line x1="4" y1="6" x2="20" y2="6" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <circle cx="9" cy="6" r="2.4" fill="${_hex(color)}"/>
      <line x1="4" y1="12" x2="20" y2="12" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <circle cx="16" cy="12" r="2.4" fill="${_hex(color)}"/>
      <line x1="4" y1="18" x2="20" y2="18" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <circle cx="11" cy="18" r="2.4" fill="${_hex(color)}"/>
    ''');
  }

  static Widget help({double size = 24, required Color color}) {
    return _svg(size, '''
      <circle cx="12" cy="12" r="9" fill="none" stroke="${_hex(color)}" stroke-width="2.4"/>
      <path d="M9.3 9.3a2.7 2.7 0 1 1 3.9 2.4c-.9.5-1.2.9-1.2 1.8" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
      <circle cx="12" cy="17.2" r="0.3" fill="${_hex(color)}" stroke="${_hex(color)}" stroke-width="1.8"/>
    ''');
  }

  static Widget home({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M3 12l9-8 9 8" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M5 10v10h14V10" fill="none" stroke="${_hex(color)}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ''');
  }

  static Widget trophy({double size = 24, required Color color}) {
    return _svg(size, '''
      <path d="M7 4h10v4a5 5 0 0 1-10 0V4z" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linejoin="round"/>
      <path d="M7 5H4a3 3 0 0 0 3 5" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M17 5h3a3 3 0 0 1-3 5" fill="none" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
      <line x1="12" y1="13" x2="12" y2="17" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <line x1="8" y1="20" x2="16" y2="20" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
      <line x1="12" y1="17" x2="12" y2="20" stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round"/>
    ''');
  }

  static Widget _svg(double size, String innerPaths) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 24 24">$innerPaths</svg>',
      width: size,
      height: size,
    );
  }

  static String _hex(Color color) {
    String channel(double v) => (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}';
  }
}
