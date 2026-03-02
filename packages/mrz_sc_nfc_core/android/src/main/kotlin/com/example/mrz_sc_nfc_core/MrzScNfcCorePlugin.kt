package com.example.mrz_sc_nfc_core

import android.app.Activity
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

class MrzScNfcCorePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, NfcAdapter.ReaderCallback {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private var nfcAdapter: NfcAdapter? = null
  private var isoDep: IsoDep? = null
  private val executor = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mrz_sc_nfc_core")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "startSession" -> {
        startNfcSession(result)
      }
      "transceive" -> {
        val command = call.arguments as? ByteArray
        if (command != null) {
          transceiveCommand(command, result)
        } else {
          result.error("INVALID_ARGUMENT", "Command bytes are null", null)
        }
      }
      "stopSession" -> {
        val errorMessage = call.arguments as? String
        stopNfcSession(errorMessage, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun startNfcSession(result: Result) {
    val currentActivity = activity
    if (currentActivity == null) {
      result.error("NO_ACTIVITY", "Plugin requires an activity to start NFC", null)
      return
    }

    nfcAdapter = NfcAdapter.getDefaultAdapter(currentActivity)
    if (nfcAdapter == null) {
      result.error("NFC_UNAVAILABLE", "NFC is not available on this device", null)
      return
    }

    val flags = NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B or NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK
    nfcAdapter?.enableReaderMode(currentActivity, this, flags, null)
    result.success(null)
  }

  private fun stopNfcSession(errorMessage: String?, result: Result?) {
    activity?.let { act ->
      nfcAdapter?.disableReaderMode(act)
    }
    isoDep?.close()
    isoDep = null
    result?.success(null)
  }

  override fun onTagDiscovered(tag: Tag?) {
    if (tag == null) return
    isoDep = IsoDep.get(tag)
    try {
      isoDep?.connect()
      isoDep?.timeout = 5000 // Passports can take several seconds to generate cryptographic keys
      
      mainHandler.post {
        channel.invokeMethod("onTagDiscovered", null)
      }
    } catch (e: Exception) {
      mainHandler.post {
        channel.invokeMethod("onError", e.message)
      }
    }
  }

  private fun transceiveCommand(command: ByteArray, result: Result) {
    if (isoDep == null || !isoDep!!.isConnected) {
      result.error("NO_CONNECTION", "No NFC tag is connected", null)
      return
    }

    executor.execute {
      try {
        val response = isoDep?.transceive(command)
        mainHandler.post {
          result.success(response)
        }
      } catch (e: Exception) {
        mainHandler.post {
          result.error("TRANSCEIVE_ERROR", e.message, null)
        }
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    stopNfcSession(null, null)
    activity = null
  }
}
