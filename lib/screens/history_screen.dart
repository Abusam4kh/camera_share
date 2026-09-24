import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<CameraSession>> sessions;

  @override
  void initState() {
    super.initState();
    sessions = DatabaseService.instance.getSessions();
  }

  Future<void> clear() async {
    await DatabaseService.instance.clearSessions();
    setState(() => sessions = DatabaseService.instance.getSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الاتصالات'),
        actions: [
          IconButton(
            onPressed: clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<CameraSession>>(
        future: sessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('لا توجد جلسات محفوظة.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = data[index];
              return Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(
                    item.role == 'sender'
                        ? Icons.videocam_rounded
                        : Icons.monitor_rounded,
                  ),
                  title: Text(
                    item.role == 'sender' ? 'مرسل' : 'مشاهد',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${item.address}:${item.port}\n${item.startedAt.toLocal()}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
