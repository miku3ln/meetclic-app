package com.meetclic.meetclic

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 🔥 Forzar el fondo blanco ANTES de iniciar Flutter
        window.decorView.setBackgroundColor(android.graphics.Color.WHITE)

        // 🔥 Asegura que las flags de transparencia no existan:
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = android.graphics.Color.WHITE
            window.navigationBarColor = android.graphics.Color.WHITE
        }

        super.onCreate(savedInstanceState)
    }
}
