package dev.kishanr.adaptrise

import dev.kishanr.adaptrise.bridge.AdaptRisePigeonBridge
import dev.kishanr.adaptrise.bridge.NativeAlarmHostApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeAlarmHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, AdaptRisePigeonBridge(this))
    }
}
