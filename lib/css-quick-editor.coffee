CssQuickEditorView = require './css-quick-editor-view'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  bottomPanel: null
  subscriptions: null

  activate: (state) ->
    @cssQuickEditorView = new CssQuickEditorView(state.cssQuickEditorViewState)
    @bottomPanel = atom.workspace.addBottomPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:toggle': => @toggle()

  deactivate: ->
    @bottomPanel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()

  serialize: ->
    cssQuickEditorViewState: @cssQuickEditorView.serialize()

  toggle: ->
    console.log 'CssQuickEditor was toggled!'

    if @bottomPanel.isVisible()
      @bottomPanel.hide()
    else
      @bottomPanel.show()
