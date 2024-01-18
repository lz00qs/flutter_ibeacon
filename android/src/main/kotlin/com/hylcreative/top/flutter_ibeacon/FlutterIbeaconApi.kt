package com.hylcreative.top.flutter_ibeacon

import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Context.BLUETOOTH_SERVICE
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.disposables.SerialDisposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.util.concurrent.TimeUnit

enum class ChannelName(val nameString: String) {
    ADVERTISING_STATUS("flutter.hylcreative.top/status"),
    BEACON_READY("flutter.hylcreative.top/ready"),
    METHOD("flutter.hylcreative.top/method"),
    LOG("flutter.hylcreative.top/log")
}

class FlutterIbeaconApi(context: Context, binaryMessenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {
    private val iContext = context
    private val isAdvHandler = IsAdvHandler()
    private val beaconReadyHandler = BeaconReadyHandler()
    private val bluetoothManager = iContext.getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val log = Logger()

    init {
        EventChannel(binaryMessenger, ChannelName.LOG.nameString).setStreamHandler(log)
        EventChannel(binaryMessenger, ChannelName.ADVERTISING_STATUS.nameString).setStreamHandler(
            this.isAdvHandler
        )
        EventChannel(binaryMessenger, ChannelName.BEACON_READY.nameString).setStreamHandler(
            this.beaconReadyHandler
        )
        MethodChannel(binaryMessenger, ChannelName.METHOD.nameString).setMethodCallHandler(
            this
        )
    }

    private fun getBleStatus(): List<String> {
        val status = mutableListOf("false", "")
        if (isBleSupported()) {
            if (isBluetoothEnabled()) {
                if (hasBluetoothPermissions()) {
                    status[0] = "true"
                } else {
                    status[1] = "unauthorized"
                }
            } else {
                status[1] = "disabled"
            }
        } else {
            status[1] = "unsupported"
        }
        return status
    }

    private fun isBluetoothEnabled(): Boolean {
        return bluetoothAdapter.isEnabled
    }

    private fun hasBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            ((ContextCompat.checkSelfPermission(
                iContext,
                android.Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED) &&
                    ContextCompat.checkSelfPermission(
                        iContext,
                        android.Manifest.permission.BLUETOOTH_ADMIN
                    ) == PackageManager.PERMISSION_GRANTED)
        } else {
            (ContextCompat.checkSelfPermission(
                iContext,
                android.Manifest.permission.BLUETOOTH_ADVERTISE
            ) ==
                    PackageManager.PERMISSION_GRANTED)
        }
    }

    private fun isBleSupported(): Boolean {
        return iContext.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
            }
            "stop" -> {
            }
            "ready" -> {
                beaconReadyHandler.eventSink?.success(getBleStatus())
            }
        }
    }

    private class Logger : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this.eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            this.eventSink = null
        }

        private fun log(stringArray: List<String>) {
            eventSink?.success(stringArray)
        }

        fun d(text: String) {
            log(listOf("Debug", "Android: $text"))
        }

        fun e(text: String) {
            log(listOf("Error", "Android: $text"))
        }

        fun i(text: String) {
            log(listOf("Info", "Android: $text"))
        }

        fun w(text: String) {
            log(listOf("Warning", "Android: $text"))
        }

    }

    private class IsAdvHandler : EventChannel.StreamHandler {
        var eventSink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this.eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            this.eventSink = null
        }
    }

    inner class BeaconReadyHandler : EventChannel.StreamHandler {
        var eventSink: EventChannel.EventSink? = null
        private val beaconReadyDisposable = SerialDisposable()
        private var lastBleStatus = listOf("", "")

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this.eventSink = events
            beaconReadyDisposable.set(eventSink?.let(::listenToBleStatus))
        }

        override fun onCancel(arguments: Any?) {
            beaconReadyDisposable.set(null)
            this.eventSink = null
        }

        private fun listenToBleStatus(eventSink: EventChannel.EventSink): Disposable =
            Observable.timer(100L, TimeUnit.MILLISECONDS)
                .repeat()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    if (lastBleStatus != getBleStatus()) {
                        lastBleStatus = getBleStatus()
                        eventSink.success(lastBleStatus)
                    }
                }
    }
}