package com.antigravity.hydro_reminder.hydro_reminder

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RectF

object WidgetThemeHelper {

    fun resolveBackground(theme: String?, mascotType: String?, percent: Int): Int {
        val key = when {
            !theme.isNullOrBlank() && theme != "ocean" -> theme.lowercase()
            !mascotType.isNullOrBlank() && mascotType != "vitality" -> mascotType.lowercase()
            else -> "ocean"
        }

        return when (key) {
            "cat" -> R.drawable.widget_card_bg_cat
            "dog" -> R.drawable.widget_card_bg_dog
            "penguin" -> R.drawable.widget_card_bg_penguin
            "panda" -> R.drawable.widget_card_bg_panda
            "squirrel" -> R.drawable.widget_card_bg_squirrel
            "glass" -> R.drawable.widget_card_bg_glass
            "neon" -> R.drawable.widget_card_bg_neon
            "emerald", "forest" -> R.drawable.widget_card_bg_forest
            else -> when {
                percent >= 100 -> R.drawable.widget_card_bg_emerald
                percent >= 75 -> R.drawable.widget_card_bg_teal
                percent >= 25 -> R.drawable.widget_card_bg_ocean
                else -> R.drawable.widget_card_bg
            }
        }
    }

    fun resolvePrimaryTextColor(theme: String?, mascotType: String?): Int {
        val key = when {
            !theme.isNullOrBlank() && theme != "ocean" -> theme.lowercase()
            !mascotType.isNullOrBlank() && mascotType != "vitality" -> mascotType.lowercase()
            else -> "ocean"
        }

        return when (key) {
            "cat" -> Color.parseColor("#7C3AED")
            "dog" -> Color.parseColor("#B45309")
            "penguin" -> Color.parseColor("#0284C7")
            "panda" -> Color.parseColor("#047857")
            "squirrel" -> Color.parseColor("#C2410C")
            "neon" -> Color.parseColor("#A91079")
            "glass" -> Color.parseColor("#38BDF8")
            else -> Color.parseColor("#0284C7")
        }
    }

    fun createRoundedCardBitmap(
        source: Bitmap,
        cornerRadiusRatio: Float = 0.12f,
        strokeWidthRatio: Float = 0.012f,
        strokeColor: Int = Color.argb(68, 255, 255, 255)
    ): Bitmap {
        if (source.width <= 0 || source.height <= 0 || source.isRecycled) {
            return source
        }

        // Clamp max dimension to 384px to prevent RemoteViews Binder TransactionTooLargeException
        val maxDim = 384
        val needsScale = source.width > maxDim || source.height > maxDim
        val scaledSource = if (needsScale) {
            val ratio = Math.min(maxDim.toFloat() / source.width, maxDim.toFloat() / source.height)
            val newW = (source.width * ratio).toInt().coerceAtLeast(1)
            val newH = (source.height * ratio).toInt().coerceAtLeast(1)
            Bitmap.createScaledBitmap(source, newW, newH, true)
        } else {
            source
        }

        val width = scaledSource.width
        val height = scaledSource.height
        val output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        val cornerRadius = width * cornerRadiusRatio

        // Draw rounded rectangle mask
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, paint)

        // Composite source image inside the rounded mask
        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(scaledSource, 0f, 0f, paint)

        // Draw subtle glass border
        if (strokeWidthRatio > 0f && strokeColor != 0) {
            paint.xfermode = null
            paint.style = Paint.Style.STROKE
            val strokeWidth = width * strokeWidthRatio
            paint.strokeWidth = strokeWidth
            paint.color = strokeColor

            val halfStroke = strokeWidth / 2f
            val strokeRect = RectF(
                halfStroke,
                halfStroke,
                width.toFloat() - halfStroke,
                height.toFloat() - halfStroke
            )
            canvas.drawRoundRect(strokeRect, cornerRadius, cornerRadius, paint)
        }

        if (needsScale && scaledSource != source && !scaledSource.isRecycled) {
            scaledSource.recycle()
        }

        return output
    }
}
