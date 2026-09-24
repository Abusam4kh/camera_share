import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/mjpeg_client.dart';
import '../services/database_service.dart';
import '../models/session.dart';
import '../widgets/status_card.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final hostController = TextEditingController();
  final client = MjpegClient();
  Uint8List? frame;
  bool connected = false;
  String? error;

  Future<void> connect() async {
    final host = hostController.text.trim();

    if (host.isEmpty) {
      setState(() {
        error = 'اكتب عنوان IP للهاتف المرسل.';
      });
      return;
    }

    setState(() {
      error = null;
      frame = null;
    });

    try {
      await client.connect(host, 8080);

      client.frames.listen(
        (data) {
          if (mounted) {
            setState(() {
              frame = data;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              connected = false;
              error = e.toString();
            });
          }
        },
      );

      await DatabaseService.instance.insertSession(
        CameraSession(
          role: 'receiver',
          address: host,
          port: 8080,
          startedAt: DateTime.now(),
        ),
      );

      if (mounted) {
        setState(() {
          connected = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'تعذر الاتصال: $e';
        });
      }
    }
  }

  Future<void> disconnect() async {
    await client.disconnect();

    if (mounted) {
      setState(() {
        connected = false;
        frame = null;
      });
    }
  }

  @override
  void dispose() {
    hostController.dispose();
    client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الهاتف المشاهد'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: hostController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'عنوان IP للهاتف المرسل',
              hintText: 'مثال: 192.168.43.1',
              prefixIcon: Icon(Icons.lan_rounded),
            ),
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'حالة الاتصال',
            value: connected ? 'متصل بالبث' : 'غير متصل',
            icon: connected ? Icons.wifi : Icons.wifi_off,
            active: connected,
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: frame == null
                  ? const Center(
                      child: Text(
                        'لا يوجد بث',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Image.memory(
                      frame!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: connected ? disconnect : connect,
            icon: Icon(
              connected ? Icons.link_off : Icons.link,
            ),
            label: Text(
              connected ? 'قطع الاتصال' : 'اتصال بالبث',
            ),
          ),
        ],
      ),
    );
  }
}
