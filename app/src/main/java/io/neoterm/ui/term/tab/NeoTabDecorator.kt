package io.neoterm.ui.term.tab

import android.content.Context
import android.graphics.Rect
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import de.mrapp.android.tabswitcher.Tab
import de.mrapp.android.tabswitcher.TabSwitcher
import de.mrapp.android.tabswitcher.TabSwitcherDecorator
import io.neoterm.Globals
import io.neoterm.NeoGLView
import io.neoterm.R
import io.neoterm.component.color.ColorSchemeComponent
import io.neoterm.frontend.component.ComponentManager
import io.neoterm.frontend.logging.NLog
import io.neoterm.frontend.terminal.TerminalView
import io.neoterm.frontend.terminal.eks.ExtraKeysView
import io.neoterm.ui.term.NeoTermActivity
import io.neoterm.utils.TerminalUtils

/**
 * @author kiva
 */
class NeoTabDecorator(val context: NeoTermActivity) : TabSwitcherDecorator() {
    companion object {
        private val VIEW_TYPE_TERM = 1
        private val VIEW_TYPE_X = 2
    }

    private fun setViewLayerType(view: View?) = view?.setLayerType(View.LAYER_TYPE_NONE, null)

    override fun onInflateView(inflater: LayoutInflater, parent: ViewGroup?, viewType: Int): View {
        return when (viewType) {
            VIEW_TYPE_TERM -> {
                inflater.inflate(R.layout.ui_term, parent, false)
            }

            VIEW_TYPE_X -> {
                inflater.inflate(R.layout.ui_xorg, parent, false)
            }

            else -> {
                throw RuntimeException("Unknown view type")
            }
        }
    }

    override fun onShowTab(context: Context, tabSwitcher: TabSwitcher,
                           view: View, tab: Tab, index: Int, viewType: Int, savedInstanceState: Bundle?) {
        val toolbar = this@NeoTabDecorator.context.toolbar
        toolbar.title = if (tabSwitcher.isSwitcherShown) null else tab.title

        when (viewType) {
            VIEW_TYPE_TERM -> {
                val termTab = tab as TermTab
                termTab.toolbar = toolbar
                val terminalView = findViewById<TerminalView>(R.id.terminal_view)
                val extraKeysView = findViewById<ExtraKeysView>(R.id.extra_keys)
                bindTerminalView(termTab, terminalView, extraKeysView)
                terminalView.requestFocus()
            }

            VIEW_TYPE_X -> {
                toolbar.visibility = View.GONE
                bindXSessionView(tab as XSessionTab)
            }
        }
    }

    private fun bindXSessionView(tab: XSessionTab) {
        val sessionData = tab.sessionData ?: return

        if (sessionData.videoLayout == null) {
            val videoLayout = findViewById<FrameLayout>(R.id.xorg_video_layout)
            sessionData.videoLayout = videoLayout
            setViewLayerType(videoLayout)
        }

        val videoLayout = sessionData.videoLayout!!

        if (sessionData.glView == null) {
            Thread {
                sessionData.client?.runOnUiThread {
                    sessionData.glView = NeoGLView(sessionData.client)
                    sessionData.glView?.isFocusableInTouchMode = true
                    sessionData.glView?.isFocusable = true
                    sessionData.glView?.requestFocus()

                    setViewLayerType(sessionData.glView)
                    videoLayout.addView(sessionData.glView,
                            FrameLayout.LayoutParams(
                                    FrameLayout.LayoutParams.MATCH_PARENT,
                                    FrameLayout.LayoutParams.MATCH_PARENT))

                    if (Globals.HideSystemMousePointer
                            && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        sessionData.glView?.pointerIcon =
                                android.view.PointerIcon.getSystemIcon(context,
                                        android.view.PointerIcon.TYPE_NULL)
                    }

                    val r = Rect()
                    videoLayout.getWindowVisibleDisplayFrame(r)
                    sessionData.glView?.callNativeScreenVisibleRect(r.left, r.top, r.right, r.bottom)
                    videoLayout.viewTreeObserver.addOnGlobalLayoutListener({
                        val r = Rect()
                        videoLayout.getWindowVisibleDisplayFrame(r)
                        val heightDiff = videoLayout.rootView.height - videoLayout.height // Take system bar into consideration
                        val widthDiff = videoLayout.rootView.width - videoLayout.width // Nexus 5 has system bar at the right side
                        Log.v("SDL", "Main window visible region changed: " + r.left + ":" + r.top + ":" + r.width() + ":" + r.height())
                        videoLayout.postDelayed({
                            sessionData.glView?.callNativeScreenVisibleRect(r.left + widthDiff, r.top + heightDiff, r.width(), r.height())
                        }, 300)
                        videoLayout.postDelayed({
                            sessionData.glView?.callNativeScreenVisibleRect(r.left + widthDiff, r.top + heightDiff, r.width(), r.height())
                        }, 600)
                    })
                }
            }.start()
        }
    }

    private fun bindTerminalView(tab: Tab, view: TerminalView?, extraKeysView: ExtraKeysView?) {
        if (view == null) {
            return
        }

        TerminalUtils.setupTerminalView(view)
        TerminalUtils.setupExtraKeysView(extraKeysView)

        val colorSchemeManager = ComponentManager.getComponent<ColorSchemeComponent>()
        colorSchemeManager.applyColorScheme(view, extraKeysView, colorSchemeManager.getCurrentColorScheme())

        if (tab is TermTab) {
            val termData = tab.termData

            TerminalUtils.setupTerminalSession(termData.termSession)

            // 复用前一次的 TermSessionCallback 和 TermViewClient
            termData.initializeViewWith(tab, view, extraKeysView)

            if (termData.termSession != null) {
                termData.viewClient?.updateExtraKeys(termData.termSession?.title, true)
            }

            view.setTerminalViewClient(termData.viewClient)
            view.attachSession(termData.termSession)

            // Still in progress with lots of bugs to deal with.
//            if (NeoPreference.loadBoolean(R.string.key_general_auto_completion, false)) {
//                if (termData.onAutoCompleteListener == null) {
//                    termData.onAutoCompleteListener = createAutoCompleteListener(view)
//                }
//                view.onAutoCompleteListener = termData.onAutoCompleteListener
//            }
        }
    }

//    private fun createAutoCompleteListener(view: TerminalView): OnAutoCompleteListener? {
//        return TermCompleteListener(view)
//    }

    override fun getViewTypeCount(): Int {
        return 2
    }

    override fun getViewType(tab: Tab, index: Int): Int {
        if (tab is TermTab) {
            return VIEW_TYPE_TERM
        } else if (tab is XSessionTab) {
            return VIEW_TYPE_X
        }
        return 0
    }
}