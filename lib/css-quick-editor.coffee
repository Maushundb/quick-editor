CssQuickEditorView = require './css-quick-editor-view'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  panel: null
  subscriptions: null

  activate: (state) ->

    @cssQuickEditorView = new CssQuickEditorView(state.cssQuickEditorViewState)
    @cssQuickEditorView.setFile(@findFileFromCSSIdentifier("."))
    @panel = atom.workspace.addBottomPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:toggle': => @toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:quick-edit': =>
      @quickEdit()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()

  serialize: ->
    cssQuickEditorViewState: @cssQuickEditorView.serialize()

  toggle: ->
    console.log 'CssQuickEditor was toggled!'

  quickEdit: ->
    if @panel.isVisible()
      @cssQuickEditorView.save()
      @panel.hide()
    else
      @panel.show()

  findFileFromCSSIdentifier: (identifier)->
    rootDir = atom.project.getDirectories()[0]
    return rootDir.getSubdirectory("styles").getFile("css-quick-editor.less")
