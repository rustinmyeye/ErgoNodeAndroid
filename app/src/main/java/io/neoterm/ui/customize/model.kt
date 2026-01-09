package io.neoterm.ui.customize

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.simplecityapps.recyclerview_fastscroll.views.FastScrollRecyclerView
import io.neoterm.App
import io.neoterm.R
import io.neoterm.backend.TerminalColors
import io.neoterm.component.colorscheme.NeoColorScheme

/**
 * @author kiva
 */
class ColorItem(var colorType: Int, var colorValue: String) {
  var colorName = App.get().resources
    .getStringArray(R.array.color_item_names)[colorType - NeoColorScheme.COLOR_TYPE_BEGIN]
}

/**
 * @author kiva
 */
class ColorItemAdapter(
  context: Context,
  initColorScheme: NeoColorScheme,
  private val listener: ColorItemAdapter.Listener
) : ListAdapter<ColorItem, ColorItemAdapter.ColorItemViewHolder>(DIFF_CALLBACK),
  FastScrollRecyclerView.SectionedAdapter {

  val colorList = mutableListOf<ColorItem>()

  companion object {
    private val DIFF_CALLBACK = object : DiffUtil.ItemCallback<ColorItem>() {
      override fun areItemsTheSame(oldItem: ColorItem, newItem: ColorItem): Boolean {
        return oldItem.colorType == newItem.colorType
      }

      override fun areContentsTheSame(oldItem: ColorItem, newItem: ColorItem): Boolean {
        return oldItem.colorType == newItem.colorType &&
               oldItem.colorValue == newItem.colorValue
      }
    }
  }

  init {
    (NeoColorScheme.COLOR_TYPE_BEGIN..NeoColorScheme.COLOR_TYPE_END)
      .forEach {
        colorList.add(ColorItem(it, initColorScheme.getColor(it) ?: ""))
      }
    submitList(colorList.toList())
  }

  interface Listener {
    fun onModelClicked(model: ColorItem)
  }

  override fun getSectionName(position: Int): String {
    return getItem(position).colorName[0].toString()
  }

  override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ColorItemViewHolder {
    val rootView = LayoutInflater.from(parent.context)
      .inflate(R.layout.item_color, parent, false)
    return ColorItemViewHolder(rootView, listener)
  }

  override fun onBindViewHolder(holder: ColorItemViewHolder, position: Int) {
    holder.bind(getItem(position))
  }

  class ColorItemViewHolder(
    private val rootView: View,
    private val listener: Listener
  ) : RecyclerView.ViewHolder(rootView) {
    private val colorItemName: TextView = rootView.findViewById(R.id.color_item_name)
    private val colorItemDesc: TextView = rootView.findViewById(R.id.color_item_description)
    private val colorView: View = rootView.findViewById(R.id.color_item_view)

    fun bind(item: ColorItem) {
      rootView.setOnClickListener { listener.onModelClicked(item) }
      colorItemName.text = item.colorName
      colorItemDesc.text = item.colorValue
      if (item.colorValue.isNotEmpty()) {
        val color = TerminalColors.parse(item.colorValue)
        colorView.setBackgroundColor(color)
        colorItemDesc.setTextColor(color)
      }
    }
  }
}
