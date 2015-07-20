CssQuickEditorView = require './css-quick-editor-view'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  panel: null
  subscriptions: null

  activate: (state) ->

    @cssQuickEditorView = new CssQuickEditorView()
    @panel = atom.workspace.addBottomPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles the editor
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:quick-edit': =>
      @quickEdit()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()

  serialize: ->
    cssQuickEditorViewState: @cssQuickEditorView.serialize()

  quickEdit: ->
    if @panel.isVisible()
      @cssQuickEditorView.save()
      @panel.hide()
    else
      @cssQuickEditorView.setFile(@findFileFromCSSIdentifier2("."))
      @findFileFromCSSIdentifier(@parseSelectedCSSIdentifier())
      @cssQuickEditorView.open()
      @panel.show()

  parseSelectedCSSIdentifier: ->
    activeTextEditor = atom.workspace.getActiveTextEditor()
    @moveCursorToIndentifierBoundary(activeTextEditor)
    return @getFirstIdentifier(activeTextEditor)

  moveCursorToIndentifierBoundary:(activeTextEditor) ->
    activeTextEditor.selectLeft()
    word = activeTextEditor.getSelectedText()
    while word isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      activeTextEditor.moveLeft()
      activeTextEditor.selectLeft()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word is "\n"
    activeTextEditor.selectRight()

  getFirstIdentifier:(activeTextEditor) ->
    activeTextEditor.selectRight()
    word = activeTextEditor.getSelectedText()
    while word.slice(-1) isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word.slice(-1) is "\n"
    activeTextEditor.selectLeft()
    return word.slice(0,-1)

  textNotCSSIdentifier: ->
    throw new Error("Selected text is not a CSS identifier")

  findFileFromCSSIdentifier:(identifier) ->
    id_reg = new RegExp(identifier)
    directories = atom.project.getDirectories()
    files = @searchDirectory(dir) for dir in directories

  searchDirectory: (dir) ->
    

  findFileFromCSSIdentifier2:(identifier) ->

    rootDir = atom.project.getDirectories()[0]
    return rootDir.getSubdirectory("styles").getFile("css-quick-editor.less")
