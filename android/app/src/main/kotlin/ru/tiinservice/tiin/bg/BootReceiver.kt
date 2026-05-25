package ru.tiinservice.tiin.bg
import android.content.BroadcastReceiver
import android.content.Context

import android.content.Intent
import ru.tiinservice.tiin.MainActivity
import ru.tiinservice.tiin.Settings
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext


class BootReceiver : BroadcastReceiver() {
    @OptIn(DelicateCoroutinesApi::class)
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
            }

            else -> return
        }
        GlobalScope.launch(Dispatchers.IO) {
            if (Settings.startedByUser) {
                withContext(Dispatchers.Main) {
                    Settings.startCoreAfterStartingService=true //H
                    BoxService.start()
                }
            }
        }
    }
}