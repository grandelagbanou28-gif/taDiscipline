package com.tadiscipline.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class ApexWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }

    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("apex_widget", Context.MODE_PRIVATE)
            val topPriority = prefs.getString("top_priority", "Aucune tâche") ?: "Aucune tâche"
            val score = prefs.getInt("discipline_score", 0)

            val views = RemoteViews(context.packageName, R.layout.widget_info)
            views.setTextViewText(R.id.widget_title, "Apex")
            views.setTextViewText(R.id.widget_priority, topPriority)
            views.setTextViewText(R.id.widget_score, "Score: $score")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
