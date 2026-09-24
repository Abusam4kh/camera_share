import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/camera_stream_service.dart';
import '../services/database_service.dart';
import '../services/hotspot_service.dart';
import '../services/network_service.dart';
import '../widgets/status_card.dart';

class SenderScreen extends StatefulWidget {
  const SenderScreen({super.key});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final service = CameraStreamService();
  bool running = false;
  String? ip;
  String? error;

  Future<void> start() async {
    setState(() => error = null);
    try {
      await service.start();
      final address = await NetworkService.localIpv4();
      if (address == null) {
        throw StateError('تعذر معرفة عنوان IP المحلي.');
      }
      await DatabaseService.instance.insertSession(
        CameraSession(
          role: 'sender',
          address: address,
          port: CameraStreamService.port,
          startedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        ip = address;
        running = true;
      });
    } catch (e) {
      await service.stop();
      if (!mounted) return;
      setState(() => error = e.toString());
    }
  }

  Future<void> stop() async {
    await service.stop();
    if (!mounted) return;
    setState(() => running = false);
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = ip == null ? '' : 'http://$ip:${CameraStreamService.port}/stream';
    return Scaffold(
      appBar: AppBar(title: const Text('الهاتف المرسل')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.wifi_tethering_rounded, size: 54),
                  const SizedBox(height: 14),
                  const Text(
                    'أولاً فعّل نقطة الاتصال',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يجب أن يتصل الهاتف الآخر بهذه الشبكة. لا تحتاج إلى إنترنت.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: HotspotService.openHotspotSettings,
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('فتح إعدادات نقطة الاتصال'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'حالة المشاركة',
            value: running ? 'تعمل الآن' : 'متوقفة',
            icon: running ? Icons.videocam : Icons.videocam_off,
            active: running,
          ),
          if (ip != null) ...[
            const SizedBox(height: 12),
            StatusCard(
              title: 'عنوان الهاتف',
              value: '$ip:${CameraStreamService.port}',
              icon: Icons.lan_rounded,
              active: true,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SelectableText(
                  url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: running ? stop : start,
            icon: Icon(running ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(running ? 'إيقاف المشاركة' : 'بدء مشاركة الكاميرا'),
          ),
        ],
      ),
    );
  }
}
