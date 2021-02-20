package com.example.quick_usb

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val ACTION_USB_PERMISSION = "com.example.quick_usb.USB_PERMISSION"

private fun pendingPermissionIntent(context: Context) = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)

/** QuickUsbPlugin */
class QuickUsbPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private var applicationContext: Context? = null
  private var usbManager: UsbManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "quick_usb")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
    usbManager = applicationContext?.getSystemService(Context.USB_SERVICE) as UsbManager
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    usbManager = null
    applicationContext = null
  }

  private var usbDevice: UsbDevice? = null
  private var usbDeviceConnection: UsbDeviceConnection? = null

  private val receiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      context.unregisterReceiver(this)
      val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
      val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
      if (!granted) {
        println("Permission denied: ${device?.deviceName}")
      }
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getDeviceList" -> {
        val manager = usbManager ?: return result.error("IllegalState", "usbManager null", null)
        val usbDeviceList = manager.deviceList.entries.map {
          mapOf(
                  "identifier" to it.key,
                  "vendorId" to it.value.vendorId,
                  "productId" to it.value.productId,
                  "configurationCount" to it.value.configurationCount
          )
        }
        result.success(usbDeviceList)
      }
      "hasPermission" -> {
        val manager = usbManager ?: return result.error("IllegalState", "usbManager null", null)
        val identifier = call.argument<String>("identifier")
        val device = manager.deviceList[identifier]
        result.success(manager.hasPermission(device))
      }
      "requestPermission" -> {
        val context = applicationContext ?: return result.error("IllegalState", "applicationContext null", null)
        val manager = usbManager ?: return result.error("IllegalState", "usbManager null", null)
        val identifier = call.argument<String>("identifier")
        val device = manager.deviceList[identifier]
        if (!manager.hasPermission(device)) {
          context.registerReceiver(receiver, IntentFilter(ACTION_USB_PERMISSION))
          manager.requestPermission(device, pendingPermissionIntent(context))
        }
        result.success(null)
      }
      "openDevice" -> {
        val manager = usbManager ?: return result.error("IllegalState", "usbManager null", null)
        val identifier = call.argument<String>("identifier")
        usbDevice = manager.deviceList[identifier]
        usbDeviceConnection = manager.openDevice(usbDevice)
        result.success(true)
      }
      "closeDevice" -> {
        usbDeviceConnection?.close()
        usbDeviceConnection = null
        usbDevice = null
        result.success(null)
      }
      "getConfiguration" -> {
        val device = usbDevice ?: return result.error("IllegalState", "usbDevice null", null)
        val index = call.argument<Int>("index")!!
        val configuration = device.getConfiguration(index)
        val map = configuration.toMap() + ("index" to index)
        result.success(map)
      }
      "setConfiguration" -> {
        val device = usbDevice ?: return result.error("IllegalState", "usbDevice null", null)
        val connection = usbDeviceConnection ?: return result.error("IllegalState", "usbDeviceConnection null", null)
        val index = call.argument<Int>("index")!!
        val configuration = device.getConfiguration(index)
        result.success(connection.setConfiguration(configuration))
      }
      "claimInterface" -> {
        val device = usbDevice ?: return result.error("IllegalState", "usbDevice null", null)
        val connection = usbDeviceConnection ?: return result.error("IllegalState", "usbDeviceConnection null", null)
        val id = call.argument<Int>("id")!!
        val alternateSetting = call.argument<Int>("alternateSetting")!!
        val usbInterface = device.findInterface(id, alternateSetting)
        result.success(connection.claimInterface(usbInterface, true))
      }
      "releaseInterface" -> {
        val device = usbDevice ?: return result.error("IllegalState", "usbDevice null", null)
        val connection = usbDeviceConnection ?: return result.error("IllegalState", "usbDeviceConnection null", null)
        val id = call.argument<Int>("id")!!
        val alternateSetting = call.argument<Int>("alternateSetting")!!
        val usbInterface = device.findInterface(id, alternateSetting)
        result.success(connection.releaseInterface(usbInterface))
      }
      "bulkTransfer" -> {
        val device = usbDevice ?: return result.error("IllegalState", "usbDevice null", null)
        val connection = usbDeviceConnection ?: return result.error("IllegalState", "usbDeviceConnection null", null)
        val endpointMap = call.argument<Map<String, Any>>("endpoint")!!
        val data = call.argument<ByteArray>("data")!!
        val endpoint = device.findEndpoint(endpointMap["endpointNumber"] as Int)
        val actualLength = connection.bulkTransfer(endpoint, data, data.count(), 1000)
        result.success(actualLength)
      }
      else -> result.notImplemented()
    }
  }
}

fun UsbDevice.findInterface(id: Int, alternateSetting: Int): UsbInterface? {
  for (i in 0..interfaceCount) {
    val usbInterface = getInterface(i)
    if (usbInterface.id == id && usbInterface.alternateSetting == alternateSetting) {
      return usbInterface
    }
  }
  return null
}

fun UsbDevice.findEndpoint(endpointNumber: Int): UsbEndpoint? {
  for (i in 0..interfaceCount) {
    val usbInterface = getInterface(i)
    for (j in 0..usbInterface.endpointCount) {
      if (usbInterface.getEndpoint(j).endpointNumber == endpointNumber) {
        return usbInterface.getEndpoint(j)
      }
    }
  }
  return null
}

fun UsbConfiguration.toMap() = mapOf(
        "id" to id,
        "interfaces" to List(interfaceCount) { getInterface(it).toMap() }
)

fun UsbInterface.toMap() = mapOf(
        "id" to id,
        "alternateSetting" to alternateSetting,
        "endpoints" to List(endpointCount) { getEndpoint(it).toMap() }
)

fun UsbEndpoint.toMap() = mapOf(
        "endpointNumber" to endpointNumber,
        "direction" to direction
)