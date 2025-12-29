package com.example.my_first_app  // <--- CRITICAL: CHECK THIS LINE BELOW

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get the data from SharedPreferences (using the key 'widget_task_text')
                val taskName = widgetData.getString("widget_task_text", "No tasks yet!")
                setTextViewText(R.id.widget_task_text, taskName)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}