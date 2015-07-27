quickEditorView = require './quick-editor-view'
DirectoryCSSSearcher = require './directory-css-searcher'
{CompositeDisposable} = require 'atom'

module.exports = QuickEditor =
  quickEditorView : null
  panel : null
  subscriptions : null
  searcher : null

  activate: (state) ->
    @quickEditorView = new quickEditorView()
    @panel = atom.workspace.addBottomPanel(item: @quickEditorView.getElement(), visible: false)

    @searcher = new DirectoryCSSSearcher

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-text-editor', 'quick-editor:quick-edit': =>
      @quickEdit()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @quickEditorView.destroy()

  quickEdit: ->
    if @panel.isVisible()
      @quickEditorView.save()
      @panel.hide()
    else
      identifier = @parseSelectedCSSIdentifier()
      @findFilesFromCSSIdentifier(identifier)
      .then ([text, start, end, file]) =>
        @searcher.clear()
        @quickEditorView.setup(text, start, end, file)
        @quickEditorView.open()
        @panel.show()

  findFilesFromCSSIdentifier:(identifier) ->
    @searcher.findFilesThatContain identifier
    .then () => @searcher.getSelectorText()

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
    while word.slice(-1) isnt "\"" and word.slice(-1) isnt "\'"
      activeTextEditor.selectRight()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word.slice(-1) is "\n"
    activeTextEditor.selectLeft()
    return word.slice(0,-1)

  textNotCSSIdentifier: ->
    throw new Error "Selected text is not a CSS identifier"
