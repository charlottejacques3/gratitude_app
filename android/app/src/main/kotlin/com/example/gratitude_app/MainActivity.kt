package com.example.gratitude_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.embedding.android.FlutterActivity
import dev.fluttercommunity.plus.androidalarmmanager.AndroidAlarmManagerPlugin

class MainActivity: FlutterActivity() {
    // override fun onCreate(savedInstanceState: Bundle?) {
    //     super.onCreate(savedInstanceState)
    //     AndroidAlarmManagerPlugin.registerWith(flutterEngine!!)
    // }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)  // Registers plugins automatically
    }
}

