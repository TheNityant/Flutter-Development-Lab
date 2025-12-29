package com.example.habit_tracker // CHANGE THIS ACC TO YOUR PROJECT NAME

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HomeWidgetProvider : AppWidgetProvider() {

    // Define constants for our actions
    companion object {
        const val ACTION_NEXT = "ACTION_NEXT_VIEW"
        const val ACTION_PREV = "ACTION_PREV_VIEW"
        
        // List of views we can cycle through (matches the keys in Flutter)
        val VIEW_KEYS = listOf("snapshot_graph", "snapshot_calendar")
        val VIEW_TITLES = listOf("Daily Progress", "Monthly Calendar")
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, 0) // Default to index 0
        }
    }

    // This handles the button clicks!
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        val action = intent.action
        val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        
        // Get current index from storage (or default to 0)
        val widgetData = HomeWidgetPlugin.getData(context)
        var currentIndex = widgetData.getInt("current_view_index", 0)

        if (action == ACTION_NEXT) {
            currentIndex = (currentIndex + 1) % VIEW_KEYS.size
        } else if (action == ACTION_PREV) {
            currentIndex = if (currentIndex - 1 < 0) VIEW_KEYS.size - 1 else currentIndex - 1
        }

        // Save the new index so it remembers where we are
        widgetData.edit().putInt("current_view_index", currentIndex).apply()

        // Refresh the widget with the new index
        if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
            updateAppWidget(context, AppWidgetManager.getInstance(context), appWidgetId, currentIndex)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, index: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        val widgetData = HomeWidgetPlugin.getData(context)

        // 1. Get the correct image path based on the index
        val currentKey = VIEW_KEYS[index]
        val imagePath = widgetData.getString(currentKey, null)
        val currentTitle = VIEW_TITLES[index]

        // 2. Set the Title
        views.setTextViewText(R.id.view_title, currentTitle)

        // 3. Set the Image (if it exists)
        if (imagePath != null) {
             // HomeWidget helper to load the file into the ImageView
            val bitmap = android.graphics.BitmapFactory.decodeFile(imagePath)
            views.setImageViewBitmap(R.id.widget_image_snapshot, bitmap)
        }

        // 4. Attach Click Listeners to the Buttons
        views.setOnClickPendingIntent(R.id.btn_next, getPendingIntent(context, ACTION_NEXT, appWidgetId))
        views.setOnClickPendingIntent(R.id.btn_prev, getPendingIntent(context, ACTION_PREV, appWidgetId))

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    // Helper to create the button click action
    private fun getPendingIntent(context: Context, action: String, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, HomeWidgetProvider::class.java)
        intent.action = action
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        // Only for Android 12+ compatibility
        return PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }
}