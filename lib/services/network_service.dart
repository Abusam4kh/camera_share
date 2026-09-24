import 'dart:io';

class NetworkService {
  static Future<String?> localIpv4() async {
    try {
      final interfaces =
          await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      final candidates = <String>[];

      for (final interface in interfaces) {
        for (final address
            in interface.addresses) {
          if (!address.isLoopback &&
              address.type ==
                  InternetAddressType.IPv4) {
            candidates.add(
              address.address,
            );
          }
        }
      }

      candidates.sort(
        (a, b) {
          final ap =
              a.startsWith('192.168.') ? 0 : 1;
          final bp =
              b.startsWith('192.168.') ? 0 : 1;

          return ap.compareTo(bp);
        },
      );

      return candidates.isEmpty
          ? null
          : candidates.first;
    } catch (_) {
      return null;
    }
  }

  static bool isValidIpv4(
    String value,
  ) {
    final parts =
        value.trim().split('.');

    if (parts.length != 4) {
      return false;
    }

    for (final part in parts) {
      final n = int.tryParse(part);

      if (n == null ||
          n < 0 ||
          n > 255) {
        return false;
      }
    }

    return true;
  }
}
