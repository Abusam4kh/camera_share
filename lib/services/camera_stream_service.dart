import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';

class CameraStreamService {
  CameraController? controller;

  HttpServer? _server;

  final Set<HttpResponse> _clients =
      <HttpResponse>{};

  Uint8List? _latestFrame;

  DateTime _lastFrameAt =
      DateTime.fromMillisecondsSinceEpoch(0);

  static const int port = 8080;

  bool get isRunning =>
      _server != null;

  Future<void> start() async {
    if (isRunning) {
      return;
    }

    final cameras =
        await availableCameras();

    if (cameras.isEmpty) {
      throw StateError(
        'لا توجد كاميرا متاحة على الجهاز.',
      );
    }

    final selected =
        cameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          ImageFormatGroup.jpeg,
    );

    await controller!.initialize();

    await controller!
        .startImageStream(
      _onImage,
    );

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _server!.listen(
      _handleRequest,
    );
  }

  void _onImage(CameraImage image) {
    final now = DateTime.now();

    if (now
            .difference(_lastFrameAt)
            .inMilliseconds <
        100) {
      return;
    }

    if (image.planes.isEmpty) {
      return;
    }

    final bytes =
        Uint8List.fromList(
      image.planes.first.bytes,
    );

    if (bytes.length < 100) {
      return;
    }

    _latestFrame = bytes;

    _lastFrameAt = now;

    _broadcast(bytes);
  }

  void _broadcast(
    Uint8List jpeg,
  ) {
    final dead =
        <HttpResponse>[];

    for (final client in _clients) {
      try {
        client.add(
          _multipartFrame(jpeg),
        );
      } catch (_) {
        dead.add(client);
      }
    }

    for (final client in dead) {
      _clients.remove(client);
      client.close();
    }
  }

  List<int> _multipartFrame(
    Uint8List jpeg,
  ) {
    final header = <int>[
      ...'--frame\r\n'.codeUnits,
      ...'Content-Type: image/jpeg\r\n'
          .codeUnits,
      ...'Content-Length: ${jpeg.length}\r\n\r\n'
          .codeUnits,
    ];

    return <int>[
      ...header,
      ...jpeg,
      ...'\r\n'.codeUnits,
    ];
  }

  Future<void> _handleRequest(
    HttpRequest request,
  ) async {
    if (request.uri.path ==
        '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            ContentType(
          'application',
          'json',
          charset: 'utf-8',
        )
        ..write(
          '{"ok":true,"service":"camera_share"}',
        );

      await request.response.close();

      return;
    }

    if (request.uri.path !=
        '/stream') {
      request.response
        ..statusCode =
            HttpStatus.notFound
        ..write('Not found');

      await request.response.close();

      return;
    }

    final response =
        request.response;

    response.headers
      ..set(
        'Cache-Control',
        'no-cache, no-store, must-revalidate',
      )
      ..set(
        'Pragma',
        'no-cache',
      )
      ..set(
        'Connection',
        'close',
      )
      ..set(
        'Content-Type',
        'multipart/x-mixed-replace; boundary=frame',
      );

    _clients.add(response);

    response.done.whenComplete(
      () => _clients.remove(response),
    );

    final frame =
        _latestFrame;

    if (frame != null) {
      response.add(
        _multipartFrame(frame),
      );
    }
  }

  Future<void> stop() async {
    try {
      await controller
          ?.stopImageStream();
    } catch (_) {}

    await controller?.dispose();

    controller = null;

    final clients =
        List<HttpResponse>.from(
      _clients,
    );

    _clients.clear();

    for (final client in clients) {
      try {
        await client.close();
      } catch (_) {}
    }

    await _server?.close(
      force: true,
    );

    _server = null;

    _latestFrame = null;
  }

  Future<void> dispose() =>
      stop();
}
