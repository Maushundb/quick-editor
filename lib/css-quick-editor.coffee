CssQuickEditorView = require './css-quick-editor-view'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @cssQuickEditorView = new CssQuickEditorView(state.cssQuickEditorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()

  serialize: ->
    cssQuickEditorViewState: @cssQuickEditorView.serialize()

  toggle: ->
    console.log 'CssQuickEditor was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
