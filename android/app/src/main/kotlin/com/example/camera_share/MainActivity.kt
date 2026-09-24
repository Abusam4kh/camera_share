package com.example.camera_share

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "camera_share/system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openHotspotSettings" -> {
                        try {
                            startActivity(
                                Intent("android.settings.TETHER_SETTINGS")
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("HOTSPOT", e.message, null)
                        }
                    }
                    "openWirelessSettings" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_WIRELESS_SETTINGS)
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("WIRELESS", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
