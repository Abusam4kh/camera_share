import 'package:flutter/material.dart';

import '../widgets/role_card.dart';
import 'history_screen.dart';
import 'receiver_screen.dart';
import 'sender_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'شارك الكاميرا',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'السجل',
            onPressed: () =>
                Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const HistoryScreen(),
              ),
            ),
            icon: const Icon(
              Icons.history_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          children: [
            Container(
              padding:
                  const EdgeInsets.all(22),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  26,
                ),
                gradient:
                    LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .wifi_tethering_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'كاميرا محلية بدون إنترنت',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'حوّل هاتفًا إلى مرسل للكاميرا وهاتفًا آخر إلى شاشة مشاهدة عبر نقطة اتصال Wi-Fi.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر وضع الجهاز',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            RoleCard(
              icon:
                  Icons.videocam_rounded,
              title:
                  'الهاتف المرسل',
              subtitle:
                  'يشغّل الكاميرا ويشارك الصورة عبر الشبكة المحلية.',
              onTap: () =>
                  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SenderScreen(),
                ),
              ),
            ),
            RoleCard(
              icon:
                  Icons.monitor_rounded,
              title:
                  'الهاتف المشاهد',
              subtitle:
                  'يتصل بعنوان الهاتف المرسل ويعرض البث مباشرة.',
              onTap: () =>
                  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ReceiverScreen(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,
                      color:
                          Theme.of(context)
                              .colorScheme
                              .primary,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    const Expanded(
                      child: Text(
                        'ملاحظة: فعّل نقطة الاتصال يدويًا من إعدادات Android في الهاتف المرسل، ثم صِل الهاتف المشاهد بها. لا يحتاج الاتصال إلى إنترنت.',
                        style:
                            TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
