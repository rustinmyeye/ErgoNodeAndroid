package io.neoterm.utils

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.DialogInterface
import android.content.pm.PackageManager
import android.os.Build
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * @author kiva
 */
object NeoPermission {
  const val REQUEST_APP_PERMISSION = 10086

  fun initAppPermission(context: AppCompatActivity, requestCode: Int) {
    val permissions = ArrayList<String>()
    
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }
    }

    // On Android 13+ (API 33), READ_EXTERNAL_STORAGE is deprecated and always denied.
    // We only request it for older versions.
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
    }

    if (permissions.isNotEmpty()) {
      doRequestPermission(context, permissions.toTypedArray(), requestCode)
    }
  }

  private fun doRequestPermission(context: AppCompatActivity, permissions: Array<String>, requestCode: Int) {
    try {
      ActivityCompat.requestPermissions(context, permissions, requestCode)
    } catch (ignore: ActivityNotFoundException) {
      // for MIUI, we ignore it.
    }
  }
}
