package com.example.quick_usb

import android.content.Context
import android.hardware.usb.UsbManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** QuickUsbPlugin */
class QuickUsbPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private var usbManager: UsbManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "quick_usb")
    channel.setMethodCallHandler(this)
    usbManager = flutterPluginBinding.applicationContext.getSystemService(Context.USB_SERVICE) as UsbManager
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    usbManager = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getDeviceList" -> {
        val manager = usbManager ?: return result.error("IllegalState", null, null)
        val usbDeviceList = manager.deviceList.entries.map {
          mapOf(
                  "identifier" to it.key,
                  "vendorId" to it.value.vendorId,
                  "productId" to it.value.productId
          )
        }
        result.success(usbDeviceList)
      }
      else -> result.notImplemented()
    }
  }
}
