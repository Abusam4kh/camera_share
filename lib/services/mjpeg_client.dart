import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class MjpegClient {
  HttpClient? _client;

  StreamSubscription<List<int>>?
      _subscription;

  final StreamController<
      Uint8List> _frames =
      StreamController<
          Uint8List>.broadcast();

  Stream<Uint8List> get frames =>
      _frames.stream;

  bool _stopped = false;

  Future<void> connect(
    String host,
    int port,
  ) async {
    await disconnect();

    _stopped = false;

    _client = HttpClient()
      ..connectionTimeout =
          const Duration(seconds: 5);

    final request =
        await _client!.getUrl(
      Uri.parse(
        'http://$host:$port/stream',
      ),
    );

    request.headers.set(
      HttpHeaders.acceptHeader,
      'multipart/x-mixed-replace',
    );

    final response =
        await request.close();

    if (response.statusCode !=
        HttpStatus.ok) {
      throw HttpException(
        'HTTP ${response.statusCode}',
      );
    }

    final buffer = <int>[];

    _subscription =
        response.listen(
      (chunk) {
        if (_stopped) {
          return;
        }

        buffer.addAll(chunk);

        _parse(buffer);
      },
      onError:
          (Object error, StackTrace stack) {
        if (!_frames.isClosed) {
          _frames.addError(
            error,
            stack,
          );
        }
      },
      onDone: () {
        if (!_stopped &&
            !_frames.isClosed) {
          _frames.addError(
            StateError(
              'انقطع الاتصال بالبث.',
            ),
          );
        }
      },
    );
  }

  void _parse(
    List<int> buffer,
  ) {
    while (true) {
      final headerEnd =
          _indexOf(
        buffer,
        const [
          13,
          10,
          13,
          10,
        ],
      );

      if (headerEnd < 0) {
        return;
      }

      final headerText =
          String.fromCharCodes(
        buffer.sublist(
          0,
          headerEnd,
        ),
      );

      final match = RegExp(
        r'Content-Length:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(
        headerText,
      );

      if (match == null) {
        buffer.removeRange(
          0,
          headerEnd + 4,
        );

        continue;
      }

      final length =
          int.parse(
        match.group(1)!,
      );

      final start =
          headerEnd + 4;

      if (buffer.length <
          start + length + 2) {
        return;
      }

      final jpeg =
          Uint8List.fromList(
        buffer.sublist(
          start,
          start + length,
        ),
      );

      buffer.removeRange(
        0,
        start + length + 2,
      );

      if (!_frames.isClosed) {
        _frames.add(jpeg);
      }
    }
  }

  int _indexOf(
    List<int> data,
    List<int> pattern,
  ) {
    if (data.length <
        pattern.length) {
      return -1;
    }

    for (
      var i = 0;
      i <=
          data.length -
              pattern.length;
      i++
    ) {
      var ok = true;

      for (
        var j = 0;
        j < pattern.length;
        j++
      ) {
        if (data[i + j] !=
            pattern[j]) {
          ok = false;
          break;
        }
      }

      if (ok) {
        return i;
      }
    }

    return -1;
  }

  Future<void> disconnect() async {
    _stopped = true;

    await _subscription
        ?.cancel();

    _subscription = null;

    _client?.close(
      force: true,
    );

    _client = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _frames.close();
  }
}
