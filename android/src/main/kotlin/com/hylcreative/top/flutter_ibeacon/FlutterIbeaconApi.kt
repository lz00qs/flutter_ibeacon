package com.hylcreative.top.flutter_ibeacon

import android.Manifest
import android.bluetooth.BluetoothManager
import android.bluetooth.le.*
import android.content.Context
import android.content.Context.BLUETOOTH_SERVICE
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
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
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.*
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
    private val beaconAdvertiseCallback = BeaconAdvertiseCallback(log, isAdvHandler)

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

    @RequiresApi(Build.VERSION_CODES.O)
    private fun startAdvertising(
        iUuidString: String,
        major: Int,
        minor: Int,
        txPower: Int = -59
    ): Int {


        val uuidString = iUuidString.replace("-", "")
        log.d("UUID $uuidString | UUID length: ${uuidString.length}")
        if (uuidString.length != 32) {
            log.e("UUID length is not 16")
            return -1
        }

        if (major < 0 || major > 65535) {
            log.e("Major is not in range 0-65535")
            return -1
        }

        if (minor < 0 || minor > 65535) {
            log.e("Minor is not in range 0-65535")
            return -1
        }

        var payload = byteArrayOf(
            0x02.toByte(),
            0x15.toByte(), // iBeacon 标识符
//            0x39.toByte(),
//            0xED.toByte(),
//            0x98.toByte(),
//            0xFF.toByte(),
//            0x29.toByte(),
//            0x00.toByte(),
//            0x44.toByte(),
//            0x1A.toByte(),
//            0x80.toByte(),
//            0x2F.toByte(),
//            0x9C.toByte(),
//            0x39.toByte(),
//            0x8F.toByte(),
//            0xC1.toByte(),
//            0x99.toByte(),
//            0xD2.toByte(),
//            0x00.toByte(),
//            0x01.toByte(), // Major
//            0x00.toByte(),
//            0x02.toByte(), // Minor
//            0xC5.toByte()
        ) // Minor

        payload += uuidString.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
        payload += ByteBuffer.allocate(2).order(ByteOrder.BIG_ENDIAN).putShort(major.toShort())
            .array()
        payload += ByteBuffer.allocate(2).order(ByteOrder.BIG_ENDIAN).putShort(minor.toShort())
            .array()
        payload += (-txPower).toByte()

        val settings: AdvertiseSettings = AdvertiseSettings.Builder()
            .setConnectable(false)
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setTimeout(0)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .setIncludeTxPowerLevel(false)
            .addManufacturerData(0x004c, payload)
            .build()


        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return -1
            }
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH_ADMIN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return -1
            }
        } else {
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH_ADVERTISE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return -1
            }
        }
        log.d("startAdvertising")
        bluetoothAdapter.bluetoothLeAdvertiser.startAdvertising(
            settings,
            data,
            beaconAdvertiseCallback
        )
        log.d("test: $data")

        return 0
    }

    private fun stopAdvertising() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH_ADMIN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
        } else {
            if (ActivityCompat.checkSelfPermission(
                    iContext,
                    Manifest.permission.BLUETOOTH_ADVERTISE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
        }
        if (bluetoothAdapter.bluetoothLeAdvertiser != null)
            bluetoothAdapter.bluetoothLeAdvertiser.stopAdvertising(beaconAdvertiseCallback)
    }


    private class BeaconAdvertiseCallback(iLog: Logger, iIsAdvHandler: IsAdvHandler) :
        AdvertiseCallback() {
        private val log = iLog
        private val isAdvHandler = iIsAdvHandler
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            super.onStartSuccess(settingsInEffect)
            log.d("onAdvertisingSetStarted: $settingsInEffect")
            isAdvHandler.eventSink?.success(true)
        }

        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
            log.d("onStartFailure: $errorCode")
            isAdvHandler.eventSink?.success(false)
        }
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
                Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED) &&
                    ContextCompat.checkSelfPermission(
                        iContext,
                        Manifest.permission.BLUETOOTH_ADMIN
                    ) == PackageManager.PERMISSION_GRANTED)
        } else {
            (ContextCompat.checkSelfPermission(
                iContext,
                Manifest.permission.BLUETOOTH_ADVERTISE
            ) ==
                    PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(
                iContext,
                Manifest.permission.BLUETOOTH_CONNECT
            ) ==
                    PackageManager.PERMISSION_GRANTED)
        }
    }

    private fun isBleSupported(): Boolean {
        return iContext.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
    }


    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val uuid = call.argument<String>("uuid")
                val major = call.argument<Int>("major")
                val minor = call.argument<Int>("minor")
                val txPower = call.argument<Int>("txPower")
                if (uuid != null && major != null && minor != null) {
                    log.d("startAdvertising: $uuid, $major, $minor, $txPower")
                    startAdvertising(uuid, major, minor, txPower ?: -59)
                    result.success(null)
                }
            }
            "stop" -> {
                stopAdvertising()
                isAdvHandler.eventSink?.success(false)
                result.success(null)
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