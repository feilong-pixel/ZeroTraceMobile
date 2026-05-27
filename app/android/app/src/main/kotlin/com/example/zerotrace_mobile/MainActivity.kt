package com.example.zerotrace_mobile

import android.Manifest
import android.content.ContentUris
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "zerotrace_mobile/photo_library"
    private val requestPhotoPermissionCode = 4101
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> requestPhotoPermission(result)
                "listAssets" -> result.success(listImageAssets())
                "openOriginalBytes" -> openOriginalBytes(call.argument<String>("assetId"), result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != requestPhotoPermissionCode) {
            return
        }

        val result = pendingPermissionResult ?: return
        pendingPermissionResult = null
        val granted = grantResults.any { it == PackageManager.PERMISSION_GRANTED }
        result.success(if (granted) "granted" else "denied")
    }

    private fun requestPhotoPermission(result: MethodChannel.Result) {
        val permission = photoReadPermission()
        if (hasPhotoReadPermission()) {
            result.success("granted")
            return
        }

        if (pendingPermissionResult != null) {
            result.error("permission_request_active", "Photo permission is already being requested.", null)
            return
        }

        pendingPermissionResult = result
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(arrayOf(permission), requestPhotoPermissionCode)
        } else {
            pendingPermissionResult = null
            result.success("granted")
        }
    }

    private fun listImageAssets(): List<Map<String, Any?>> {
        if (!hasPhotoReadPermission()) {
            return emptyList()
        }

        val collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.WIDTH,
            MediaStore.Images.Media.HEIGHT,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.DATE_ADDED
        )
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
        val assets = mutableListOf<Map<String, Any?>>()

        contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.WIDTH)
            val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.HEIGHT)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val uri = ContentUris.withAppendedId(collection, id).toString()
                assets.add(
                    mapOf(
                        "id" to uri,
                        "displayName" to cursor.getString(nameColumn),
                        "width" to cursor.getInt(widthColumn),
                        "height" to cursor.getInt(heightColumn),
                        "sizeBytes" to cursor.getLong(sizeColumn),
                        "createdAtMillis" to cursor.getLong(dateAddedColumn) * 1000L
                    )
                )
            }
        }

        return assets
    }

    private fun openOriginalBytes(assetId: String?, result: MethodChannel.Result) {
        if (assetId.isNullOrBlank()) {
            result.error("invalid_asset_id", "Asset id is required.", null)
            return
        }
        if (!hasPhotoReadPermission()) {
            result.error("photo_permission_denied", "Photo permission is not granted.", null)
            return
        }

        try {
            contentResolver.openInputStream(Uri.parse(assetId)).use { input ->
                if (input == null) {
                    result.error("asset_not_found", "Could not open original asset bytes.", null)
                    return
                }
                result.success(input.readBytes())
            }
        } catch (error: Exception) {
            result.error("asset_read_failed", error.message, null)
        }
    }

    private fun photoReadPermission(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_IMAGES
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
    }

    private fun hasPhotoReadPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(photoReadPermission()) == PackageManager.PERMISSION_GRANTED
    }
}
