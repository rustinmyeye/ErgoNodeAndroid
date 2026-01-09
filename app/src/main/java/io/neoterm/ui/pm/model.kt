package io.neoterm.ui.pm

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.simplecityapps.recyclerview_fastscroll.views.FastScrollRecyclerView
import io.neoterm.R
import io.neoterm.component.pm.NeoPackageInfo
import io.neoterm.utils.formatSizeInKB

class PackageAdapter(
  private val context: Context,
  private val listener: PackageAdapter.Listener
) : ListAdapter<PackageModel, PackageAdapter.PackageViewHolder>(DIFF_CALLBACK),
  FastScrollRecyclerView.SectionedAdapter {

  companion object {
    private val DIFF_CALLBACK = object : DiffUtil.ItemCallback<PackageModel>() {
      override fun areItemsTheSame(oldItem: PackageModel, newItem: PackageModel): Boolean {
        return oldItem.packageInfo.packageName == newItem.packageInfo.packageName
      }

      override fun areContentsTheSame(oldItem: PackageModel, newItem: PackageModel): Boolean {
        return oldItem.packageInfo.packageName == newItem.packageInfo.packageName &&
               oldItem.packageInfo.version == newItem.packageInfo.version
      }
    }
  }

  override fun getSectionName(position: Int): String {
    return getItem(position).packageInfo.packageName?.substring(0, 1) ?: "#"
  }

  interface Listener {
    fun onModelClicked(model: PackageModel)
  }

  override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PackageViewHolder {
    val rootView = LayoutInflater.from(parent.context)
      .inflate(R.layout.item_package, parent, false)
    return PackageViewHolder(rootView, listener)
  }

  override fun onBindViewHolder(holder: PackageViewHolder, position: Int) {
    holder.bind(getItem(position))
  }

  class PackageViewHolder(
    private val rootView: View,
    private val listener: Listener
  ) : RecyclerView.ViewHolder(rootView) {
    private val packageNameView: TextView = rootView.findViewById(R.id.package_item_name)
    private val packageDescView: TextView = rootView.findViewById(R.id.package_item_desc)

    fun bind(item: PackageModel) {
      rootView.setOnClickListener { listener.onModelClicked(item) }
      packageNameView.text = item.packageInfo.packageName
      packageDescView.text = item.packageInfo.description
    }
  }
}

/**
 * @author kiva
 */

class PackageModel(val packageInfo: NeoPackageInfo) {
  fun getPackageDetails(context: Context): String {
    return context.getString(
      R.string.package_details,
      packageInfo.packageName, packageInfo.version,
      packageInfo.dependenciesString,
      packageInfo.installedSizeInBytes.formatSizeInKB(),
      packageInfo.description, packageInfo.homePage
    )
  }
}
